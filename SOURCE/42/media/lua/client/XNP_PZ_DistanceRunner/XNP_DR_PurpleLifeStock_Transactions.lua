require "TimedActions/ISTimedActionQueue"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Codec"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Snapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Items"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Sound"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStockCraftAction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStockRestoreAction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStockRepair"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleToggleRepairTransaction"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Codec = Core.PurpleLifeStockCodec
local Registry = Core.PurpleLifeStockRegistry
local Snapshot = Core.PurpleLifeStockSnapshot
local Items = Core.PurpleLifeStockItems
local Sound = Core.PurpleLifeStockSound

local Transactions = {
    activeRecord = false,
    activeRestore = false,
    queuedCraftAction = nil,
    queuedRestoreAction = nil,
    recordSubsystemBlocked = false,
    recordSubsystemError = nil,
    manualRecordPass = false,
    autoRecordPass = false,
    initialRecordPass = false,
    restorePass = false,
    restoreRollbackPass = false,
    restoreFailureItemPreserved = false,
    recordRollbackPass = false,
    inventoryDuplicationCount = 0,
    craftActionQueueCount = 0,
    restoreActionQueueCount = 0,
    exactItemRemovedCount = 0,
    consumedTokenCount = 0,
    toggleSerial = 0,
    toggleTransactionCount = 0,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function sandboxNumber(name, fallback, minimum, maximum)
    local value = Core.SandboxTuning and Core.SandboxTuning.GetNumber
        and Core.SandboxTuning.GetNumber(name, fallback) or fallback
    value = tonumber(value) or fallback
    if minimum and value < minimum then value = minimum end
    if maximum and value > maximum then value = maximum end
    return value
end

local function sandboxBoolean(name, fallback)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean then
        return Core.SandboxTuning.GetBoolean(name, fallback) == true
    end
    return fallback == true
end

local function controlledLivingPlayer(player)
    if not player then return false, "PLAYER_MISSING" end
    if not Core.CanonicalPlayerIdentity
        or Core.CanonicalPlayerIdentity.Validate(player, true) ~= true then
        return false, "CONTROLLED_PLAYER_IDENTITY_REJECTED"
    end
    local okDead, dead = invoke(player, "isDead")
    if okDead and dead == true then return false, "PLAYER_DEAD" end
    return true, "CONTROLLED_LIVING_PLAYER"
end

local function hasPurpleTrait(player)
    return Core.PurplePhoenixTrait
        and Core.PurplePhoenixTrait.PlayerHasTrait(player) == true
end

local function safeText(key, fallback)
    if type(getText) == "function" then
        local ok, value = pcall(getText, key)
        if ok and value and value ~= key then return tostring(value) end
    end
    return fallback
end

local function notifyPlayer(player, key, fallback)
    local text = safeText(key, fallback)
    if player and type(player.setHaloNote) == "function" then
        pcall(function() player:setHaloNote(text, 190, 120, 255, 240) end)
    end
    return text
end

local function notifyPlayerRepairSummary(player, repaired, alreadyFull)
    local fallback = "Footwear repair: repaired %d, already full %d."
    local template = safeText(
        "UI_XNPPurpleFootwearRepairSummary", fallback)
    local ok, text = pcall(
        string.format, template, repaired, alreadyFull)
    if not ok then
        text = string.format(fallback, repaired, alreadyFull)
    end
    if player and type(player.setHaloNote) == "function" then
        pcall(function()
            player:setHaloNote(text, 240, 240, 240, 240)
        end)
    end
end

local function statRange(stat)
    local okMin, minimum = invoke(stat, "getMinimumValue")
    local okMax, maximum = invoke(stat, "getMaximumValue")
    minimum = okMin and tonumber(minimum) or 0
    maximum = okMax and tonumber(maximum) or 1
    if maximum <= minimum then return 0, 1 end
    return minimum, maximum
end

local function statRead(stats, stat)
    local ok, value = invoke(stats, "get", stat)
    return ok and tonumber(value) or nil
end

local function statWrite(stats, stat, value)
    local minimum, maximum = statRange(stat)
    value = math.max(minimum, math.min(tonumber(value) or minimum, maximum))
    local ok = invoke(stats, "set", stat, value)
    if not ok then return false, nil end
    return true, statRead(stats, stat)
end

local function statId(stat, fallback)
    local ok, value = invoke(stat, "getId")
    if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    return tostring(fallback or "UNKNOWN")
end

local function pointsDelta(stat, points)
    local minimum, maximum = statRange(stat)
    return (maximum - minimum) * ((tonumber(points) or 0) / 100)
end

local function closeEnough(stat, actual, expected)
    if actual == nil or expected == nil then return false end
    local minimum, maximum = statRange(stat)
    return math.abs(actual - expected)
        <= math.max(0.0001, (maximum - minimum) * 0.00001)
end

local function captureCosts(player)
    if not CharacterStat then return nil, "CHARACTER_STAT_API_UNAVAILABLE" end
    local okStats, stats = invoke(player, "getStats")
    if not okStats or not stats then return nil, "PLAYER_STATS_UNAVAILABLE" end
    local fields = {
        boredom = CharacterStat.BOREDOM,
        unhappiness = CharacterStat.UNHAPPINESS,
        endurance = CharacterStat.ENDURANCE,
        hunger = CharacterStat.HUNGER,
    }
    local before = {}
    for name, stat in pairs(fields) do
        before[name] = statRead(stats, stat)
        if before[name] == nil then return nil, "COST_READ_FAILED:" .. name end
    end
    local boredomPoints = sandboxNumber("PurpleBackupBoredomIncreasePoints",
        Constants.RECORD_BOREDOM_POINTS_DEFAULT, 0, 100)
    local unhappinessPoints = sandboxNumber("PurpleBackupUnhappinessDecreasePoints",
        Constants.RECORD_UNHAPPINESS_POINTS_DEFAULT, 0, 100)
    local endurancePoints = sandboxNumber("PurpleBackupEnduranceCostPoints",
        Constants.RECORD_ENDURANCE_POINTS_DEFAULT, 0, 100)
    local hungerPoints = sandboxNumber("PurpleBackupHungerIncreasePoints",
        Constants.RECORD_HUNGER_POINTS_DEFAULT, 0, 100)
    local targets = {
        boredom = before.boredom + pointsDelta(fields.boredom, boredomPoints),
        unhappiness = before.unhappiness
            - pointsDelta(fields.unhappiness, unhappinessPoints),
        endurance = before.endurance
            - pointsDelta(fields.endurance, endurancePoints),
        hunger = before.hunger + pointsDelta(fields.hunger, hungerPoints),
    }
    for name, stat in pairs(fields) do
        local minimum, maximum = statRange(stat)
        targets[name] = math.max(minimum, math.min(targets[name], maximum))
    end
    return {
        stats = stats,
        fields = fields,
        before = before,
        targets = targets,
        points = {
            boredom_increase = boredomPoints,
            unhappiness_decrease = unhappinessPoints,
            endurance_cost = endurancePoints,
            hunger_increase = hungerPoints,
        },
    }, "COST_SNAPSHOT_READY"
end

local function applyCosts(cost)
    cost.after = {}
    for _, name in ipairs({ "boredom", "unhappiness", "endurance", "hunger" }) do
        local written, readback = statWrite(
            cost.stats, cost.fields[name], cost.targets[name])
        cost.after[name] = readback
        if not written or not closeEnough(
            cost.fields[name], readback, cost.targets[name]) then
            return false, "COST_WRITE_READBACK_FAILED:" .. name
        end
    end
    return true, "COSTS_APPLIED"
end

local function restoreCosts(cost)
    if not cost then return true, "NO_COSTS_TO_RESTORE" end
    local complete, failures = true, {}
    for _, name in ipairs({ "boredom", "unhappiness", "endurance", "hunger" }) do
        local written, readback = statWrite(
            cost.stats, cost.fields[name], cost.before[name])
        if not written or not closeEnough(
            cost.fields[name], readback, cost.before[name]) then
            complete = false
            failures[#failures + 1] = name
        end
    end
    return complete, complete and "COSTS_RESTORED"
        or "COST_ROLLBACK_FAILED:" .. table.concat(failures, ",")
end

local function logCosts(source, cost)
    print("[XNP PURPLE BACKUP COST] source=" .. source
        .. " boredom_increase_points=" .. tostring(cost.points.boredom_increase)
        .. " unhappiness_decrease_points=" .. tostring(cost.points.unhappiness_decrease)
        .. " endurance_cost_points=" .. tostring(cost.points.endurance_cost)
        .. " hunger_increase_points=" .. tostring(cost.points.hunger_increase))
    local directions = {
        boredom = "INCREASE",
        unhappiness = "DECREASE",
        endurance = "DECREASE",
        hunger = "INCREASE",
    }
    for _, name in ipairs({ "boredom", "unhappiness", "endurance", "hunger" }) do
        print("[XNP PURPLE BACKUP COST STAT] source=" .. source
            .. " stat_id=" .. statId(cost.fields[name], name)
            .. " before=" .. tostring(cost.before[name])
            .. " target=" .. tostring(cost.targets[name])
            .. " after=" .. tostring(cost.after[name])
            .. " direction=" .. directions[name]
            .. " readback_pass="
            .. tostring(closeEnough(
                cost.fields[name], cost.after[name], cost.targets[name])))
    end
end

local function removeCreatedItem(item)
    if not item then return true end
    local okContainer, container = invoke(item, "getContainer")
    if not okContainer or not container then return true end
    return Items.RemoveExact(container, item) == true
end

local function rollbackRecord(lineage, savedRegistry, cost, newItem)
    local itemRemoved = removeCreatedItem(newItem)
    local registryRestored = Registry.RestoreLineageState(
        lineage, savedRegistry) == true
    local costsRestored = restoreCosts(cost) == true
    local complete = itemRemoved and registryRestored and costsRestored
    Transactions.recordRollbackPass = complete
    if not complete then
        Transactions.recordSubsystemBlocked = true
        Transactions.recordSubsystemError = "RECORD_ROLLBACK_INCOMPLETE"
    end
    return complete, complete and "RECORD_ROLLBACK_COMPLETE"
        or "RECORD_ROLLBACK_INCOMPLETE"
end

local function actionQueueAdd(action)
    if not ISTimedActionQueue or type(ISTimedActionQueue.add) ~= "function" then
        return false, "TIMED_ACTION_QUEUE_UNAVAILABLE"
    end
    local ok, result = pcall(ISTimedActionQueue.add, action)
    if not ok then return false, "TIMED_ACTION_QUEUE_EXCEPTION:" .. tostring(result) end
    return true, "TIMED_ACTION_QUEUED"
end


function Transactions.TogglePhoenixSurvival(player, source)
    local controlled, reason = controlledLivingPlayer(player)
    if not controlled then return false, reason end
    if not hasPurpleTrait(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    if not Core.PurplePhoenixState then return false, "PURPLE_STATE_UNAVAILABLE" end

    local beforeColor, beforeRemaining =
        Core.PurplePhoenixState.GetVisualState(player)
    local beforeEnabled = Core.PurplePhoenixState.IsEnabled(player) == true
    local changed, stateReason, remaining = Core.PurplePhoenixState.Toggle(
        player, source or "PURPLE_ICON_RIGHT_CLICK")
    if not changed then
        if stateReason == "PHOENIX_SURVIVAL_COOLDOWN" then
            local seconds = tonumber(remaining)
                or tonumber(beforeRemaining) or 0
            local template = safeText(
                "UI_XNPPurpleRespawnCooldown",
                "Phoenix Survival cooldown: %.1f seconds remaining")
            local text = string.format(template, seconds)
            if player and type(player.setHaloNote) == "function" then
                pcall(function()
                    player:setHaloNote(text, 240, 240, 240, 240)
                end)
            end
        end
        return false, stateReason
    end

    local targetEnabled = not beforeEnabled
    local readback =
        Core.PurplePhoenixState.IsEnabled(player) == targetEnabled
    local rolledBack = false
    if not readback then
        local rollbackChanged, rollbackReason = Core.PurplePhoenixState.SetEnabled(
            player, beforeEnabled)
        rolledBack = rollbackChanged == true
            or rollbackReason == "TOGGLE_STATE_UNCHANGED"
        return false, "FULL_COMMIT_READBACK_MISMATCH"
    end

    Transactions.toggleSerial = Transactions.toggleSerial + 1
    Transactions.toggleTransactionCount = Transactions.toggleTransactionCount + 1
    local transactionId = "purple-toggle-" .. tostring(Transactions.toggleSerial)
    local repairRequested = true
    local repairResult = "WRITE_FAILED"
    local repairWriteCount = 0
    local repairSummary = nil
    if Core.PurpleToggleRepairTransaction
        and type(Core.PurpleToggleRepairTransaction.Request) == "function" then
        local repairOk, repair =
            pcall(Core.PurpleToggleRepairTransaction.Request,
                player, transactionId, "RIGHT_CLICK_TOGGLE_COMMITTED")
        if repairOk and type(repair) == "table" then
            repairSummary = repair
            repairResult = tostring(repair.result or "WRITE_FAILED")
            repairWriteCount =
                tonumber(repair.condition_set_call_count) or 0
        elseif not repairOk then
            repairResult = "WRITE_FAILED"
        end
    else
        repairRequested = false
        repairResult = "MODULE_UNAVAILABLE"
    end
    local afterColor = Core.PurplePhoenixState.GetVisualState(player)
    local soundPlayed, soundReason = false, "FULL_COMMIT_REQUIRED"
    if readback and Core.Audio and type(Core.Audio.PlayOnce) == "function" then
        soundPlayed, soundReason = Core.Audio.PlayOnce(
            player, "MARKER_TOGGLE", transactionId)
    end
    print("[XNP PHOENIX SURVIVAL TOGGLE] transaction_id="
        .. transactionId
        .. " from_state=" .. tostring(beforeColor)
        .. " to_state=" .. tostring(afterColor)
        .. " identity_match=true from_enabled=" .. tostring(beforeEnabled)
        .. " to_enabled=" .. tostring(targetEnabled)
        .. " state_commit=" .. tostring(changed == true)
        .. " ui_commit_deferred=true"
        .. " readback_match=" .. tostring(readback)
        .. " rolled_back=" .. tostring(rolledBack)
        .. " sound_after_full_commit=" .. tostring(soundPlayed == true)
        .. " sound_reason=" .. tostring(soundReason or "NONE")
        .. " footwear_repair_requested=" .. tostring(repairRequested)
        .. " footwear_repair_result=" .. tostring(repairResult)
        .. " footwear_repair_write_count=" .. tostring(repairWriteCount)
        .. " right_click_controls=PHOENIX_SURVIVAL_ONLY"
        .. " life_stock_registry_changed=false"
        .. " result="
        .. tostring(readback and "COMMITTED" or "READBACK_MISMATCH"))
    local repaired = repairSummary
        and tonumber(repairSummary.repaired_count) or 0
    local alreadyFull = repairSummary
        and tonumber(repairSummary.already_full_count) or 0
    if repaired > 0 or alreadyFull > 0 then
        notifyPlayerRepairSummary(player, repaired, alreadyFull)
    elseif repairSummary then
        notifyPlayer(player, "UI_XNPPurpleFootwearNothingToRepair",
            "No footwear needs repair.")
    else
        notifyPlayer(player,
            targetEnabled and "UI_XNPPurpleModeEnabled"
                or "UI_XNPPurpleModeDisabled",
            targetEnabled
                and "Phoenix Survival enabled: critical health will recover."
                or "Phoenix Survival disabled. Life Stock inheritance is unchanged.")
    end
    Core.PurplePhoenixState.AuditConsistency(
        player, "TOGGLE_COMMITTED", "NA")
    return true, targetEnabled and "BLUE" or "GREEN"
end

-- Compatibility entry retained for old UI callers. It controls Phoenix
-- Survival only and never reads or writes the Life Stock registry.
Transactions.ToggleRespawnMode = Transactions.TogglePhoenixSurvival

function Transactions.GetCraftDurationSeconds()
    return sandboxNumber("PurpleBackupCraftDurationSeconds",
        Constants.CRAFT_DURATION_SECONDS_DEFAULT, 1, 60)
end

function Transactions.GetRestoreDurationSeconds()
    return sandboxNumber("PurpleBackupRestoreDurationSeconds",
        Constants.RESTORE_DURATION_SECONDS_DEFAULT, 1, 60)
end

function Transactions.PreflightCraft(player, action)
    local controlled, reason = controlledLivingPlayer(player)
    if not controlled then return false, reason end
    if not hasPurpleTrait(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    if not sandboxBoolean("PurpleBackupManualRecordEnabled", true) then
        return false, "MANUAL_RECORD_DISABLED"
    end
    if Transactions.recordSubsystemBlocked then
        return false, "RECORD_SUBSYSTEM_GUARDED:"
            .. tostring(Transactions.recordSubsystemError)
    end
    if Transactions.activeRecord or Transactions.activeRestore then
        return false, "PURPLE_TRANSACTION_ALREADY_ACTIVE"
    end
    if Transactions.queuedCraftAction
        and Transactions.queuedCraftAction ~= action then
        return false, "CRAFT_ACTION_ALREADY_QUEUED"
    end
    return true, "CRAFT_PREFLIGHT_PASS"
end

function Transactions.QueueCraft(player, source)
    local valid, reason = Transactions.PreflightCraft(player, nil)
    if not valid then
        Sound.NotifyFailure(player, "UI_XNPPurpleCraftFailed",
            "Extra Life backup crafting is not available.", reason)
        return false, reason
    end
    local action = XNPPurpleLifeStockCraftAction:new(
        player, Transactions.GetCraftDurationSeconds())
    local queued, queueReason = actionQueueAdd(action)
    if not queued then return false, queueReason end
    Transactions.queuedCraftAction = action
    Transactions.craftActionQueueCount = Transactions.craftActionQueueCount + 1
    print("[XNP PURPLE CRAFT ACTION] queued=true source="
        .. tostring(source or "PURPLE_ICON_LEFT_DOUBLE_CLICK")
        .. " duration_seconds=" .. tostring(Transactions.GetCraftDurationSeconds())
        .. " progress_bar_route=ISBaseTimedAction")
    return true, "CRAFT_TIMED_ACTION_QUEUED"
end

function Transactions.ClearCraftAction(action)
    if Transactions.queuedCraftAction == action then
        Transactions.queuedCraftAction = nil
    end
    return true
end

function Transactions.CommitCraft(player)
    local valid, reason = Transactions.PreflightCraft(
        player, Transactions.queuedCraftAction)
    if not valid then return false, reason end
    Transactions.activeRecord = true
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then Transactions.activeRecord = false; return false, ownerKey end
    local snapshot, snapshotReason = Snapshot.Build(
        player, lineage, ownerKey, Constants.SOURCE_MANUAL)
    if not snapshot then
        Transactions.activeRecord = false
        return false, snapshotReason
    end
    local savedRegistry, savedReason = Registry.CaptureLineageState(lineage)
    if not savedRegistry then
        Transactions.activeRecord = false
        return false, savedReason
    end
    local cost, costReason = captureCosts(player)
    if not cost then Transactions.activeRecord = false; return false, costReason end
    local costsApplied, costApplyReason = applyCosts(cost)
    if not costsApplied then
        restoreCosts(cost)
        Transactions.activeRecord = false
        return false, costApplyReason
    end
    logCosts(Constants.SOURCE_MANUAL, cost)
    local committed, commitReason = Registry.CommitActiveSnapshot(ownerKey, snapshot)
    if not committed then
        rollbackRecord(lineage, savedRegistry, cost, nil)
        Transactions.activeRecord = false
        return false, commitReason
    end
    local token, tokenReason = Registry.CreateToken(
        lineage, snapshot.snapshot_id, Constants.ISSUED_MANUAL)
    if not token then
        rollbackRecord(lineage, savedRegistry, cost, nil)
        Transactions.activeRecord = false
        return false, tokenReason
    end
    local item, itemReason = Items.CreateBackupForToken(player, token)
    if not item then
        rollbackRecord(lineage, savedRegistry, cost, nil)
        Transactions.activeRecord = false
        return false, itemReason
    end
    local itemValid, itemValidReason, metadata = Items.ValidateItemToken(player, item)
    if not itemValid or metadata.token_id ~= token.token_id then
        rollbackRecord(lineage, savedRegistry, cost, item)
        Transactions.activeRecord = false
        return false, itemValidReason or "CRAFT_ITEM_READBACK_FAILED"
    end
    local interval = sandboxNumber("PurpleBackupAutoRecordIntervalGameDays",
        Constants.AUTO_INTERVAL_GAME_DAYS_DEFAULT, 1, 365)
    Registry.SetNextAutoRecordDay(lineage, Registry.GameDay() + interval)
    Transactions.manualRecordPass = true
    Transactions.activeRecord = false
    Sound.PlaySuccess(player, "CRAFT_SUCCESS",
        "purple-craft:" .. tostring(token.token_id))
    print("[XNP PURPLE BACKUP RECORD] result=SUCCESS source=MANUAL"
        .. " snapshot_id=" .. tostring(snapshot.snapshot_id)
        .. " token_id=" .. tostring(token.token_id)
        .. " snapshot_commit=true item_created=true token_count_delta=1"
        .. " progress_complete=true animation=Craft")
    return true, token.token_id
end

function Transactions.GrantStarter(player)
    local controlled, reason = controlledLivingPlayer(player)
    if not controlled then return false, reason end
    if not hasPurpleTrait(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return false, ownerKey end
    if Registry.StarterGrantDone(lineage) then
        return true, "STARTER_ALREADY_GRANTED"
    end
    local existingCount = Registry.CountValidTokens(lineage)
    if existingCount > 0 then
        Registry.MarkStarterGrantDone(lineage)
        return true, "MIGRATED_VALID_TOKEN_COUNTS_AS_STARTER"
    end
    local entry = Registry.GetLatest(lineage)
    local snapshot = entry and entry.snapshot or nil
    if not snapshot then
        local snapshotReason
        snapshot, snapshotReason = Snapshot.Build(
            player, lineage, ownerKey, Constants.SOURCE_INITIAL)
        if not snapshot then return false, snapshotReason end
        local committed, commitReason = Registry.CommitActiveSnapshot(ownerKey, snapshot)
        if not committed then return false, commitReason end
    end
    local saved, savedReason = Registry.CaptureLineageState(lineage)
    if not saved then return false, savedReason end
    local token, tokenReason = Registry.CreateToken(
        lineage, snapshot.snapshot_id, Constants.ISSUED_STARTER)
    if not token then return false, tokenReason end
    local item, itemReason = Items.CreateBackupForToken(player, token)
    if not item then
        Registry.RestoreLineageState(lineage, saved)
        return false, itemReason
    end
    Registry.MarkStarterGrantDone(lineage)
    Transactions.initialRecordPass = true
    print("[XNP PURPLE STARTER] starter_grant_done=true"
        .. " starter_grant_count=1 token_id=" .. tostring(token.token_id)
        .. " snapshot_id=" .. tostring(snapshot.snapshot_id)
        .. " issued_source=STARTER")
    return true, token.token_id
end

function Transactions.RefreshWeekly(player)
    local controlled, reason = controlledLivingPlayer(player)
    if not controlled then return false, reason end
    if not hasPurpleTrait(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    if not sandboxBoolean("PurpleBackupAutoRecordEnabled", true) then
        return false, "AUTO_RECORD_DISABLED"
    end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return false, ownerKey end
    local tokenCount = Registry.CountValidTokens(lineage)
    if tokenCount < 1 then return false, "AUTO_RECORD_REQUIRES_VALID_TOKEN" end
    local snapshot, snapshotReason = Snapshot.Build(
        player, lineage, ownerKey, Constants.SOURCE_AUTO)
    if not snapshot then return false, snapshotReason end
    local committed, commitReason = Registry.CommitActiveSnapshot(ownerKey, snapshot)
    if not committed then return false, commitReason end
    local rebound, reboundReason, reboundCount = Registry.RebindValidTokens(
        lineage, snapshot.snapshot_id)
    if not rebound then return false, reboundReason end
    local interval = sandboxNumber("PurpleBackupAutoRecordIntervalGameDays",
        Constants.AUTO_INTERVAL_GAME_DAYS_DEFAULT, 1, 365)
    Registry.SetNextAutoRecordDay(lineage, Registry.GameDay() + interval)
    Transactions.autoRecordPass = true
    print("[XNP PURPLE BACKUP AUTO] result=SUCCESS snapshot_id="
        .. tostring(snapshot.snapshot_id)
        .. " valid_tokens_rebound=" .. tostring(reboundCount)
        .. " token_count_delta=0 item_created=false cost_applied=false"
        .. " sound_call=false immutable_snapshot=true")
    return true, snapshot.snapshot_id
end

function Transactions.Record(player, source)
    if source == Constants.SOURCE_MANUAL then return Transactions.QueueCraft(player) end
    if source == Constants.SOURCE_AUTO then return Transactions.RefreshWeekly(player) end
    if source == Constants.SOURCE_INITIAL then return Transactions.GrantStarter(player) end
    return false, "RECORD_SOURCE_INVALID"
end

function Transactions.PreflightRestore(player, item, action)
    local controlled, controlledReason = controlledLivingPlayer(player)
    if not controlled then return false, controlledReason end
    if Transactions.activeRestore or Transactions.activeRecord then
        return false, "PURPLE_TRANSACTION_ALREADY_ACTIVE"
    end
    if Transactions.queuedRestoreAction
        and Transactions.queuedRestoreAction ~= action then
        return false, "RESTORE_ACTION_ALREADY_QUEUED"
    end
    local itemValid, itemReason, metadata, token, entry =
        Items.ValidateItemToken(player, item)
    if not itemValid then return false, itemReason end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return false, ownerKey end
    if metadata.lineage_id ~= lineage or token.lineage_id ~= lineage then
        return false, "BACKUP_LINEAGE_OWNER_MISMATCH"
    end
    local claim, claimReason = Registry.GetClaimable(player)
    if not claim then return false, claimReason end
    if claim.claimed == true then return false, "DEATH_CLAIM_ALREADY_USED" end
    if not entry or not entry.snapshot then return false, "TOKEN_SNAPSHOT_MISSING" end
    local valid, checksum = Codec.ValidateSnapshot(entry.snapshot)
    if not valid then return false, checksum end
    if checksum ~= token.checksum or checksum ~= metadata.checksum then
        return false, "BACKUP_CHECKSUM_MISMATCH"
    end
    return true, "RESTORE_PREFLIGHT_PASS", {
        metadata = metadata,
        token = token,
        entry = entry,
        lineage = lineage,
        owner_key = ownerKey,
        claim = claim,
    }
end

function Transactions.QueueRestore(player, item)
    local valid, reason = Transactions.PreflightRestore(player, item, nil)
    if not valid then
        Sound.NotifyFailure(player,
            "UI_XNPPurpleRestoreFailed",
            "Extra Life backup cannot be used yet; the item was preserved.",
            reason)
        return false, reason
    end
    local action = XNPPurpleLifeStockRestoreAction:new(
        player, item, Transactions.GetRestoreDurationSeconds())
    local queued, queueReason = actionQueueAdd(action)
    if not queued then return false, queueReason end
    Transactions.queuedRestoreAction = action
    Transactions.restoreActionQueueCount = Transactions.restoreActionQueueCount + 1
    print("[XNP PURPLE RESTORE ACTION] queued=true"
        .. " duration_seconds=" .. tostring(Transactions.GetRestoreDurationSeconds())
        .. " exact_item_bound=true progress_bar_route=ISBaseTimedAction")
    return true, "RESTORE_TIMED_ACTION_QUEUED"
end

function Transactions.ClearRestoreAction(action)
    if Transactions.queuedRestoreAction == action then
        Transactions.queuedRestoreAction = nil
    end
    return true
end

local function refreshTraitRuntime(player, reason)
    local refreshed = false
    if Core.Runtime and type(Core.Runtime.InvalidateTraitState) == "function" then
        Core.Runtime.InvalidateTraitState(reason or "PURPLE_TRAIT_MUTATION")
    end
    if Core.Runtime and type(Core.Runtime.RefreshTraitState) == "function" then
        local ok = pcall(Core.Runtime.RefreshTraitState,
            player, nil, true)
        refreshed = ok == true
    end
    if reason == "PURPLE_RESTORE_SUCCESS" and Core.PurpleLifeStockUI
        and type(Core.PurpleLifeStockUI.RebindAfterRestore) == "function" then
        local ok, bound, bindReason = pcall(
            Core.PurpleLifeStockUI.RebindAfterRestore, player)
        print("[XNP PURPLE POST RESTORE CONTROL] runtime_refreshed="
            .. tostring(refreshed)
            .. " rebind_call_ok=" .. tostring(ok == true)
            .. " callbacks_bound=" .. tostring(ok and bound == true)
            .. " reason=" .. tostring(ok and bindReason or bound))
    end
    return refreshed
end

local function deprecatedAutoRearmAfterRestore()
    print("[XNP LIFE STOCK INHERITANCE] post_restore_auto_rearm=false"
        .. " PurpleAutoRearmAfterSuccessfulRestore=DEPRECATED"
        .. " phoenix_survival_state_changed=false"
        .. " restore_payload_changed=false")
    return true, "DEPRECATED_OPTION_NO_EFFECT"
end

local function rollbackRestore(player, beforePayload, lineage, savedRegistry, item)
    local playerRestored, playerReason = Snapshot.ApplyPayload(player, beforePayload)
    local registryRestored = Registry.RestoreLineageState(
        lineage, savedRegistry) == true
    local itemPreserved = item ~= nil and select(1,
        Items.IsExactAccessible(player, item)) == true
    refreshTraitRuntime(player, "PURPLE_RESTORE_ROLLBACK")
    local complete = playerRestored == true and registryRestored and itemPreserved
    Transactions.restoreRollbackPass = complete
    Transactions.restoreFailureItemPreserved = itemPreserved
    return complete, complete and "RESTORE_ROLLBACK_COMPLETE"
        or "RESTORE_ROLLBACK_INCOMPLETE:" .. tostring(playerReason)
end

function Transactions.CommitRestore(player, item)
    local valid, reason, context = Transactions.PreflightRestore(
        player, item, Transactions.queuedRestoreAction)
    if not valid then return false, reason end
    Transactions.activeRestore = true
    local beforePayload, beforeReason = Snapshot.CapturePayload(player)
    if not beforePayload then
        Transactions.activeRestore = false
        return false, beforeReason
    end
    local savedRegistry, savedReason = Registry.CaptureLineageState(context.lineage)
    if not savedRegistry then
        Transactions.activeRestore = false
        return false, savedReason
    end
    local applied, applyReason = Snapshot.ApplyPayload(
        player, context.entry.snapshot.payload)
    if not applied then
        local _, rollbackReason = rollbackRestore(
            player, beforePayload, context.lineage, savedRegistry, item)
        Transactions.activeRestore = false
        print("[XNP PURPLE BACKUP RESTORE] result=FAILED stage=APPLY reason="
            .. tostring(applyReason) .. " " .. tostring(rollbackReason)
            .. " item_preserved=true success_sound_call=false")
        return false, applyReason
    end
    local consumed, consumeReason = Registry.MarkTokenConsumed(
        context.token.token_id)
    if not consumed then
        rollbackRestore(player, beforePayload, context.lineage, savedRegistry, item)
        Transactions.activeRestore = false
        return false, consumeReason
    end
    local claimed, claimReason = Registry.MarkClaimed(
        context.claim, context.owner_key, context.token.token_id)
    if not claimed then
        rollbackRestore(player, beforePayload, context.lineage, savedRegistry, item)
        Transactions.activeRestore = false
        return false, claimReason
    end
    local okContainer, container = invoke(item, "getContainer")
    local removed, removeReason = Items.RemoveExact(
        okContainer and container or nil, item)
    local stillAccessible = select(1, Items.IsExactAccessible(player, item))
    if not removed or stillAccessible == true then
        rollbackRestore(player, beforePayload, context.lineage, savedRegistry, item)
        Transactions.activeRestore = false
        return false, removeReason or "EXACT_ITEM_REMOVE_READBACK_FAILED"
    end
    local rearmed, rearmReason =
        deprecatedAutoRearmAfterRestore()
    refreshTraitRuntime(player, "PURPLE_RESTORE_SUCCESS")
    Sound.PlaySuccess(player, "RESTORE_SUCCESS",
        "purple-restore:" .. tostring(context.token.token_id))
    Transactions.restorePass = true
    Transactions.exactItemRemovedCount = Transactions.exactItemRemovedCount + 1
    Transactions.consumedTokenCount = Transactions.consumedTokenCount + 1
    Transactions.activeRestore = false
    print("[XNP PURPLE BACKUP RESTORE] result=SUCCESS"
        .. " token_id=" .. tostring(context.token.token_id)
        .. " snapshot_id=" .. tostring(context.token.snapshot_id)
        .. " PURPLE_RESTORE_SUCCESS=true"
        .. " PURPLE_EXACT_ITEM_REMOVED=true"
        .. " PURPLE_CONSUMED_TOKEN_COUNT_DELTA=1"
        .. " PURPLE_OTHER_BACKUP_REMOVED_COUNT=0"
        .. " POST_RESTORE_AUTO_REARM=" .. tostring(rearmed == true)
        .. " POST_RESTORE_AUTO_REARM_REASON=" .. tostring(rearmReason)
        .. " profession_traits_perks_visual_restored=true")
    return true, context.token.token_id
end

function Transactions.Restore(player, item)
    return Transactions.QueueRestore(player, item)
end

function Transactions.GetAuditSnapshot()
    return {
        manual_record_transaction_pass = Transactions.manualRecordPass,
        auto_weekly_record_transaction_pass = Transactions.autoRecordPass,
        initial_snapshot_transaction_pass = Transactions.initialRecordPass,
        restore_transaction_pass = Transactions.restorePass,
        restore_rollback_pass = Transactions.restoreRollbackPass,
        restore_failure_item_preserved = Transactions.restoreFailureItemPreserved,
        record_rollback_pass = Transactions.recordRollbackPass,
        inventory_duplication_count = Transactions.inventoryDuplicationCount,
        record_subsystem_blocked = Transactions.recordSubsystemBlocked,
        record_subsystem_error = Transactions.recordSubsystemError,
        craft_action_queue_count = Transactions.craftActionQueueCount,
        restore_action_queue_count = Transactions.restoreActionQueueCount,
        exact_item_removed_count = Transactions.exactItemRemovedCount,
        consumed_token_count = Transactions.consumedTokenCount,
        toggle_transaction_count = Transactions.toggleTransactionCount,
    }
end

Core.PurpleLifeStockTransactions = Transactions
return Transactions
