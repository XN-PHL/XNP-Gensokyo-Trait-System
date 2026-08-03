local XNPChannelGuard = require "XNP_PZ_DistanceRunner/XNP_DR_ChannelGuard"
if type(XNPChannelGuard) == "table"
    and type(XNPChannelGuard.allowRuntime) == "function"
    and not XNPChannelGuard.allowRuntime() then
    return
end

require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianConsumeAction"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianCraftAction"
require "TimedActions/ISTimedActionQueue"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local RedGuardian = {
    TRAIT_FULL_ID = "XNPFeastGuardianTrait:XNPFeastGuardian",
    ITEM_FULL_TYPE = "XNP_PZ_DistanceRunner.RedGuardianMark",
    MODE_KEY = "XNP_RED_MAGIC_MODE",
    MODE_STAMINA = "GREEN_STAMINA",
    MODE_TREATMENT = "WHITE_TREATMENT",
    STARTER_KEY = "XNP_RED_GUARDIAN_STARTER_GRANTED_0555",
    STARTER_VERSION_KEY = "XNP_RedGuardian_StarterGrantVersion",
    STARTER_VERSION = "0.5.60.7",
    STARTER_MIGRATION_KEY = "XNP_RedGuardian_StarterGrantReason",
    REGEN_TASK_ID = "xnp_red_guardian_green_regen_05604",
    REGEN_TICKS = 10,
    REGEN_INTERVAL = 2.0,
    regenAmount = 0.05,
    contextRegistered = false,
    activeConsumeAction = nil,
    activeUseTransaction = nil,
    activeCraftAction = nil,
    regenGeneration = 0,
    regenTicksRemaining = 0,
    regenPlayer = nil,
    starterRetryFrame = 0,
    starterResolvedPlayer = nil,
    lastStarterLog = nil,
    traitCachePlayer = nil,
    traitCacheResult = nil,
    traitCacheLogged = nil,
    traitCacheCanonical = nil,
    traitNextCheckMs = 0,
    lastUseByPlayer = setmetatable({}, { __mode = "k" }),
    lastCraftByPlayer = setmetatable({}, { __mode = "k" }),
    craftSubsystemBlocked = false,
    craftSubsystemError = nil,
    craftTransactionSerial = 0,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function sandboxNumber(name, fallback, minimum, maximum)
    local tuning = Core.SandboxTuning
    if tuning and type(tuning.GetNumber) == "function" then
        return tuning.GetNumber(name, fallback, minimum, maximum)
    end
    return fallback
end

local function sandboxBoolean(name, fallback)
    local tuning = Core.SandboxTuning
    if tuning and type(tuning.GetBoolean) == "function" then
        return tuning.GetBoolean(name, fallback)
    end
    return fallback
end

local function playerData(player)
    local ok, data = invoke(player, "getModData")
    return ok and type(data) == "table" and data or nil
end

local function isDead(player)
    local ok, value = invoke(player, "isDead")
    return not player or (ok and value == true)
end

local function traitNowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function resolveRedCanonical()
    if RedGuardian.traitCacheCanonical then return RedGuardian.traitCacheCanonical end
    if not ResourceLocation or type(ResourceLocation.of) ~= "function" then return nil end
    if not CharacterTrait or type(CharacterTrait.get) ~= "function" then return nil end
    local ok, value = pcall(function()
        return CharacterTrait.get(ResourceLocation.of(RedGuardian.TRAIT_FULL_ID))
    end)
    if ok and value then RedGuardian.traitCacheCanonical = value end
    return RedGuardian.traitCacheCanonical
end

local function redKnownTraits(player)
    if player and type(player.getCharacterTraits) == "function" then
        local ok, value = pcall(function()
            local characterTraits = player:getCharacterTraits()
            return characterTraits and characterTraits:getKnownTraits() or nil
        end)
        if ok and value then return value end
    end
    if player and type(player.getTraits) == "function" then
        local ok, value = pcall(function() return player:getTraits() end)
        if ok and value then return value end
    end
    return nil
end

local function redTraitName(value, method)
    local ok, result = invoke(value, method)
    return ok and result ~= nil and tostring(result) or nil
end

local function isRedTraitAlias(name)
    return name == RedGuardian.TRAIT_FULL_ID
        or name == "XNPFeastGuardian"
        or name == "XNPFeastGuardianTrait"
end

local function redCollectionContains(collection)
    local canonical = resolveRedCanonical()
    if collection and canonical then
        local ok, found = pcall(function() return collection:contains(canonical) end)
        if ok and found == true then return true end
    end
    local sizeOk, size = pcall(function() return collection and collection:size() or 0 end)
    size = sizeOk and tonumber(size) or 0
    for index = 0, size - 1 do
        local itemOk, item = pcall(function() return collection:get(index) end)
        if itemOk and item then
            if canonical and item == canonical then return true end
            local names = { tostring(item) }
            for _, method in ipairs({ "getType", "getId", "getID", "getFullType", "getFullName" }) do
                names[#names + 1] = redTraitName(item, method)
            end
            for _, name in ipairs(names) do
                if isRedTraitAlias(name) then return true end
            end
        end
    end
    return false
end

function RedGuardian.PlayerHasTrait(player)
    if not player then return false end
    local now = traitNowMs()
    if RedGuardian.traitCachePlayer == player and RedGuardian.traitCacheResult == true then return true end
    if RedGuardian.traitCachePlayer == player and RedGuardian.traitCacheResult == false
        and now < RedGuardian.traitNextCheckMs then return false end
    local found = redCollectionContains(redKnownTraits(player)) == true
    local changed = RedGuardian.traitCachePlayer ~= player or RedGuardian.traitCacheLogged ~= found
    RedGuardian.traitCachePlayer = player
    RedGuardian.traitCacheResult = found
    RedGuardian.traitCacheLogged = found
    RedGuardian.traitNextCheckMs = found and math.huge or (now + 750)
    if changed then
        print("[XNP RED TRAIT] full_id=" .. RedGuardian.TRAIT_FULL_ID
            .. " detected=" .. tostring(found)
            .. " method=" .. (found and "OBJECT_COLLECTION" or "NOT_FOUND"))
    end
    return found
end

local function livingTraitOwner(player)
    return sandboxBoolean("RedEnabled", true)
        and player ~= nil and not isDead(player) and RedGuardian.PlayerHasTrait(player)
end

local function currentControlledPlayer(candidate)
    local identity = Core.CanonicalPlayerIdentity
    if not identity or type(identity.ResolveCurrentControlledPlayer) ~= "function" then
        return nil, "CONTROLLED_PLAYER_IDENTITY_UNAVAILABLE"
    end
    local playerIndex = 0
    local indexOk, indexValue = invoke(candidate, "getPlayerNum")
    if indexOk and tonumber(indexValue) then playerIndex = tonumber(indexValue) end
    local callOk, player, reason = pcall(identity.ResolveCurrentControlledPlayer,
        playerIndex, candidate, true)
    if not callOk then return nil, "CONTROLLED_PLAYER_IDENTITY_EXCEPTION" end
    if player ~= candidate then return nil, reason or "NOT_CURRENT_CONTROLLED_PLAYER" end
    return player, reason or "IDENTITY_MATCH"
end

local function getStats(player)
    local ok, stats = invoke(player, "getStats")
    return ok and stats or nil
end

local function statRead(stats, stat)
    if not stats or not stat then return nil end
    local ok, value = pcall(function() return stats:get(stat) end)
    value = ok and tonumber(value) or nil
    return value
end

local function statWrite(stats, stat, value)
    if not stats or not stat then return false end
    local apiResult = nil
    local callOk = pcall(function() apiResult = stats:set(stat, value) end)
    -- B42 Stats:set() may return false when the value did not change. The
    -- authoritative success test is the get() readback performed by the
    -- transaction, not this change-notification return value.
    return callOk, apiResult
end

local function statRange(stat)
    local okMin, minimum = invoke(stat, "getMinimumValue")
    local okMax, maximum = invoke(stat, "getMaximumValue")
    minimum = okMin and tonumber(minimum) or 0
    maximum = okMax and tonumber(maximum) or 1
    if maximum <= minimum then return 0, 1 end
    return minimum, maximum
end

local function statPointsDelta(stat, points)
    local minimum, maximum = statRange(stat)
    return (maximum - minimum) * ((tonumber(points) or 0) / 100)
end

local function statClamp(stat, value)
    local minimum, maximum = statRange(stat)
    return math.max(minimum, math.min(tonumber(value) or minimum, maximum))
end

local function statId(stat, fallback)
    local ok, value = invoke(stat, "getId")
    if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    return tostring(fallback or "UNKNOWN")
end

local function bodyParts(player)
    local okBody, body = invoke(player, "getBodyDamage")
    if not okBody or not body then return nil, nil end
    local okParts, parts = invoke(body, "getBodyParts")
    return body, okParts and parts or nil
end

local function forEachPart(parts, callback)
    local okSize, size = invoke(parts, "size")
    size = okSize and tonumber(size) or 0
    for index = 0, size - 1 do
        local okPart, part = invoke(parts, "get", index)
        if okPart and part then callback(part, index) end
    end
end

local function boolRead(object, method)
    local ok, value = invoke(object, method)
    return ok and value == true
end

local function numberRead(object, method, fallback)
    local ok, value = invoke(object, method)
    value = ok and tonumber(value) or nil
    return value or fallback
end

function RedGuardian.GetMode(player)
    local data = playerData(player)
    local defaultMode = sandboxNumber("RedDefaultMode", 1, 1, 2) == 2
        and RedGuardian.MODE_TREATMENT or RedGuardian.MODE_STAMINA
    if not data then return defaultMode end
    local mode = data[RedGuardian.MODE_KEY]
    if mode == "STAMINA" then mode = RedGuardian.MODE_STAMINA end
    if mode == "TREATMENT" then mode = RedGuardian.MODE_TREATMENT end
    if mode ~= RedGuardian.MODE_STAMINA and mode ~= RedGuardian.MODE_TREATMENT then
        mode = defaultMode
        data[RedGuardian.MODE_KEY] = mode
    end
    return mode
end

function RedGuardian.SetMode(player, mode)
    if not livingTraitOwner(player) then return false, "RED_TRAIT_REQUIRED" end
    if not sandboxBoolean("RedRightClickModeToggleEnabled", true) then return false, "RED_MODE_TOGGLE_DISABLED" end
    if mode ~= RedGuardian.MODE_STAMINA and mode ~= RedGuardian.MODE_TREATMENT then
        return false, "INVALID_MODE"
    end
    local data = playerData(player)
    if not data then return false, "NO_MODDATA" end
    local oldMode = RedGuardian.GetMode(player)
    if oldMode == mode then return false, "MODE_UNCHANGED" end
    data[RedGuardian.MODE_KEY] = mode
    print("[XNP RED ROUND] mode_switch=true old=" .. tostring(oldMode) .. " new=" .. tostring(mode))
    return true, mode
end

local function cancelRegen(reason)
    RedGuardian.regenGeneration = RedGuardian.regenGeneration + 1
    RedGuardian.regenTicksRemaining = 0
    RedGuardian.regenPlayer = nil
    local scheduler = Core.PerformanceScheduler
    if scheduler and type(scheduler.CancelActiveSecondTask) == "function" then
        scheduler.CancelActiveSecondTask(RedGuardian.REGEN_TASK_ID)
    end
    if reason then print("[XNP RED GREEN] regen_cancelled=true reason=" .. tostring(reason)) end
end

local function scheduleRegen(player, generation)
    local scheduler = Core.PerformanceScheduler
    if not scheduler or type(scheduler.RegisterActiveSecondTask) ~= "function" then
        return false, "ACTIVE_SECOND_SCHEDULER_UNAVAILABLE"
    end
    local ok, status = scheduler.RegisterActiveSecondTask(RedGuardian.REGEN_TASK_ID, RedGuardian.REGEN_INTERVAL,
        function(currentPlayer)
            if generation ~= RedGuardian.regenGeneration then return end
            local owner = RedGuardian.regenPlayer
            if currentPlayer ~= owner or not livingTraitOwner(owner) then cancelRegen("OWNER_INVALID") return end
            local stats = getStats(owner)
            local before = statRead(stats, CharacterStat and CharacterStat.ENDURANCE)
            if before == nil then cancelRegen("ENDURANCE_UNAVAILABLE") return end
            statWrite(stats, CharacterStat.ENDURANCE, math.min(1.0, before + RedGuardian.regenAmount))
            RedGuardian.regenTicksRemaining = RedGuardian.regenTicksRemaining - 1
            print("[XNP RED GREEN] regen_tick=true remaining=" .. tostring(RedGuardian.regenTicksRemaining))
            if RedGuardian.regenTicksRemaining > 0 then scheduleRegen(owner, generation) else cancelRegen("COMPLETE_60_ACTIVE_SECONDS") end
        end)
    return ok == true, status
end

local function startRegen(player)
    cancelRegen(nil)
    RedGuardian.regenAmount = sandboxNumber("RedStaminaPeriodicRecovery", 0.05, 0.0, 1.0)
    RedGuardian.REGEN_INTERVAL = sandboxNumber("RedStaminaPeriodicIntervalSeconds", 2.0, 0.5, 60.0)
    local duration = sandboxNumber("RedStaminaPeriodicDurationSeconds", 20.0, 0.0, 300.0)
    RedGuardian.REGEN_TICKS = math.max(0, math.ceil(duration / RedGuardian.REGEN_INTERVAL))
    if RedGuardian.regenAmount <= 0 or RedGuardian.REGEN_TICKS <= 0 then
        print("[XNP RED GREEN] regen_started=false reason=SANDBOX_DISABLED")
        return true
    end
    RedGuardian.regenPlayer = player
    RedGuardian.regenTicksRemaining = RedGuardian.REGEN_TICKS
    local generation = RedGuardian.regenGeneration
    local ok, reason = scheduleRegen(player, generation)
    print("[XNP RED GREEN] regen_started=" .. tostring(ok)
        .. " ticks=" .. tostring(RedGuardian.REGEN_TICKS)
        .. " amount=" .. tostring(RedGuardian.regenAmount)
        .. " interval_active_seconds=" .. tostring(RedGuardian.REGEN_INTERVAL)
        .. " reason=" .. tostring(reason))
    return ok
end

local function applyGreenPositive(player)
    local stats = getStats(player)
    if not stats or not CharacterStat then return false, "STATS_UNAVAILABLE" end
    local values = {
        endurance = statRead(stats, CharacterStat.ENDURANCE),
        fatigue = statRead(stats, CharacterStat.FATIGUE),
        panic = statRead(stats, CharacterStat.PANIC),
        boredom = statRead(stats, CharacterStat.BOREDOM),
        unhappiness = statRead(stats, CharacterStat.UNHAPPINESS),
    }
    for _, value in pairs(values) do if value == nil then return false, "REQUIRED_STAT_UNAVAILABLE" end end
    local immediate = sandboxNumber("RedStaminaImmediateRecovery", 0.50, 0.0, 1.0)
    local fatigueReduction = sandboxNumber("RedFatigueReduction", 0.25, 0.0, 1.0)
    local panicRemaining = 1.0 - (sandboxNumber("RedPanicReduction", 50, 0, 100) / 100.0)
    local boredomRemaining = 1.0 - (sandboxNumber("RedBoredomReduction", 50, 0, 100) / 100.0)
    local unhappinessRemaining = 1.0 - (sandboxNumber("RedUnhappinessReduction", 50, 0, 100) / 100.0)
    local writes = {
        { CharacterStat.ENDURANCE, math.min(1.0, values.endurance + immediate) },
        { CharacterStat.FATIGUE, math.max(0.0, values.fatigue - fatigueReduction) },
        { CharacterStat.PANIC, math.max(0.0, values.panic * panicRemaining) },
        { CharacterStat.BOREDOM, math.max(0.0, values.boredom * boredomRemaining) },
        { CharacterStat.UNHAPPINESS, math.max(0.0, values.unhappiness * unhappinessRemaining) },
    }
    for _, entry in ipairs(writes) do
        if not statWrite(stats, entry[1], entry[2]) then return false, "STAT_WRITE_FAILED" end
    end
    startRegen(player)
    print("[XNP RED MAGIC] mode=GREEN_STAMINA positive_only=true endurance_plus=" .. tostring(immediate)
        .. " fatigue_minus=" .. tostring(fatigueReduction)
        .. " panic_remaining=" .. tostring(panicRemaining)
        .. " boredom_remaining=" .. tostring(boredomRemaining)
        .. " unhappiness_remaining=" .. tostring(unhappinessRemaining))
    return true, "GREEN_POSITIVE_APPLIED"
end

local function randomCandidate(candidates, used)
    local eligible = {}
    for _, entry in ipairs(candidates) do
        if not used or not used[entry.index] then eligible[#eligible + 1] = entry end
    end
    if #eligible == 0 then return nil end
    if type(ZombRand) ~= "function" then return nil end
    local ok, index = pcall(function() return ZombRand(#eligible) + 1 end)
    local selected = ok and eligible[index] or nil
    if selected and used then used[selected.index] = true end
    return selected
end

local function clearSelectedWound(entry)
    if not entry then return false end
    local part, kind = entry.part, entry.kind
    local ok = true
    if kind == "FRACTURE" then ok = invoke(part, "setFractureTime", 0) end
    if kind == "BITE" then invoke(part, "SetBitten", false); ok = invoke(part, "setBiteTime", 0) end
    if kind == "DEEP_WOUND" then invoke(part, "setDeepWounded", false); ok = invoke(part, "setDeepWoundTime", 0) end
    if kind == "BURN" then ok = invoke(part, "setBurnTime", 0); invoke(part, "setNeedBurnWash", false) end
    if kind == "CUT" then invoke(part, "setCut", false); ok = invoke(part, "setCutTime", 0) end
    if kind == "SCRATCH" then invoke(part, "setScratched", false, true); ok = invoke(part, "setScratchTime", 0) end
    invoke(part, "setBleeding", false)
    invoke(part, "setBleedingTime", 0)
    return ok == true
end

local function collectTreatment(parts)
    local fracture, major, minor = {}, {}, {}
    forEachPart(parts, function(part, index)
        if numberRead(part, "getFractureTime", 0) > 0 then
            fracture[#fracture + 1] = { part = part, index = index, kind = "FRACTURE" }
        end
        local majorKind = nil
        if boolRead(part, "bitten") or numberRead(part, "getBiteTime", 0) > 0 then majorKind = "BITE"
        elseif boolRead(part, "isDeepWounded") or numberRead(part, "getDeepWoundTime", 0) > 0 then majorKind = "DEEP_WOUND"
        elseif boolRead(part, "isBurnt") or numberRead(part, "getBurnTime", 0) > 0 then majorKind = "BURN" end
        if majorKind then
            major[#major + 1] = { part = part, index = index, kind = majorKind }
        else
            local minorKind = nil
            if boolRead(part, "isCut") or numberRead(part, "getCutTime", 0) > 0 then minorKind = "CUT"
            elseif boolRead(part, "scratched") or numberRead(part, "getScratchTime", 0) > 0 then minorKind = "SCRATCH" end
            if minorKind then minor[#minor + 1] = { part = part, index = index, kind = minorKind } end
        end
    end)
    return fracture, major, minor
end

local function clearZombieInfection(player, body, parts, clearZombie, clearZombification, clearFake, clearNormalWound)
    if clearZombie then
        invoke(body, "setInfected", false)
        invoke(body, "setInfectionTime", -1.0)
    end
    if clearFake then
        invoke(body, "setIsFakeInfected", false)
        invoke(body, "setReduceFakeInfection", false)
    end
    local stats = getStats(player)
    if clearZombification and stats and CharacterStat and CharacterStat.ZOMBIE_INFECTION then
        statWrite(stats, CharacterStat.ZOMBIE_INFECTION, 0.0)
    end
    forEachPart(parts, function(part)
        if clearNormalWound then invoke(part, "SetInfected", false) end
        if clearFake then invoke(part, "SetFakeInfected", false) end
    end)
end

local function applyWhiteTreatment(player)
    local body, parts = bodyParts(player)
    if not body or not parts then return false, "BODY_DAMAGE_UNAVAILABLE" end
    local before = numberRead(body, "getOverallBodyHealth", nil)
    if before == nil then return false, "OVERALL_HEALTH_UNAVAILABLE" end
    local fractures, majors, minors = collectTreatment(parts)
    local healingAmount = sandboxNumber("RedHealingHealthAmount", 25, 0, 100)
    local target = math.min(100.0, before + healingAmount)
    local infectionPresent = boolRead(body, "isInfected")
        or boolRead(body, "isFakeInfected")
    local conditionCount = #fractures + #majors + #minors
    if target <= before + 0.001 and conditionCount == 0
        and infectionPresent ~= true then
        print("[XNP RED HEAL TRANSACTION] mode=WHITE_TREATMENT"
            .. " health_before=" .. string.format("%.2f", before)
            .. " health_requested=" .. string.format("%.2f", healingAmount)
            .. " health_target=" .. string.format("%.2f", target)
            .. " health_after=" .. string.format("%.2f", before)
            .. " general_health_delta=0 wound_write_count=0 infection_write_count=0"
            .. " fracture_write_count=0 effect_count=0 consume_count=0 success=false"
            .. " failure_reason=NO_HEALABLE_CONDITION")
        return false, "NO_HEALABLE_CONDITION"
    end
    local used = {}
    local fractureEnabled = sandboxBoolean("RedHealFractureEnabled", true)
    local infectionEnabled = sandboxBoolean("RedClearZombieInfectionEnabled", true)
    local zombificationEnabled = sandboxBoolean("RedClearZombificationEnabled", true)
    local fakeInfectionEnabled = sandboxBoolean("RedClearFakeInfectionEnabled", true)
    local clearNormalWound = sandboxBoolean("RedClearNormalWoundInfectionEnabled", true)
    local majorLimit = math.floor(sandboxNumber("RedHealMajorWoundCount", 1, 0, 20))
    local minorLimit = math.floor(sandboxNumber("RedHealMinorWoundCount", 3, 0, 20))
    local selectedFracture = fractureEnabled and randomCandidate(fractures, used) or nil
    local majorCleared, minorCleared = 0, 0
    if infectionEnabled or zombificationEnabled or fakeInfectionEnabled or clearNormalWound then
        clearZombieInfection(player, body, parts, infectionEnabled, zombificationEnabled,
            fakeInfectionEnabled, clearNormalWound)
    end
    local fractureCleared = clearSelectedWound(selectedFracture)
    for _ = 1, majorLimit do
        local selected = randomCandidate(majors, used)
        if not selected then break end
        if clearSelectedWound(selected) then majorCleared = majorCleared + 1 end
    end
    for _ = 1, minorLimit do
        local selected = randomCandidate(minors, used)
        if not selected then break end
        if clearSelectedWound(selected) then minorCleared = minorCleared + 1 end
    end
    local wrote = invoke(body, "setOverallBodyHealth", target)
    local after = numberRead(body, "getOverallBodyHealth", nil)
    local healthDelta = after and (after - before) or 0
    local woundWriteCount = majorCleared + minorCleared
    local fractureWriteCount = fractureCleared and 1 or 0
    local infectionWriteCount = (infectionEnabled or zombificationEnabled
        or fakeInfectionEnabled or clearNormalWound) and 1 or 0
    local effectCount = (healthDelta > 0.001 and 1 or 0)
        + woundWriteCount + fractureWriteCount
        + ((infectionPresent == true and infectionWriteCount > 0) and 1 or 0)
    if wrote ~= true or after == nil or effectCount <= 0 then
        print("[XNP RED HEAL TRANSACTION] mode=WHITE_TREATMENT"
            .. " health_before=" .. string.format("%.2f", before)
            .. " health_requested=" .. string.format("%.2f", healingAmount)
            .. " health_target=" .. string.format("%.2f", target)
            .. " health_after=" .. tostring(after)
            .. " general_health_delta=" .. string.format("%.2f", healthDelta)
            .. " wound_write_count=" .. tostring(woundWriteCount)
            .. " infection_write_count=" .. tostring(infectionWriteCount)
            .. " fracture_write_count=" .. tostring(fractureWriteCount)
            .. " effect_count=" .. tostring(effectCount)
            .. " consume_count=0 success=false failure_reason=OVERALL_HEALTH_WRITE_FAILED")
        return false, "OVERALL_HEALTH_WRITE_FAILED"
    end
    print("[XNP RED MAGIC] mode=WHITE_TREATMENT health_before=" .. string.format("%.2f", before)
        .. " health_target=" .. string.format("%.2f", target)
        .. " fracture=" .. tostring(selectedFracture and selectedFracture.kind or "NONE")
        .. " major_cleared=" .. tostring(majorCleared)
        .. " minor_cleared=" .. tostring(minorCleared)
        .. " zombie_infection_cleared=" .. tostring(infectionEnabled)
        .. " zombification_stat_cleared=" .. tostring(zombificationEnabled)
        .. " ordinary_wound_infection_preserved=" .. tostring(not clearNormalWound))
    print("[XNP RED HEAL TRANSACTION] mode=WHITE_TREATMENT"
        .. " health_before=" .. string.format("%.2f", before)
        .. " health_requested=" .. string.format("%.2f", healingAmount)
        .. " health_target=" .. string.format("%.2f", target)
        .. " health_after=" .. string.format("%.2f", after)
        .. " general_health_delta=" .. string.format("%.2f", healthDelta)
        .. " wound_write_count=" .. tostring(woundWriteCount)
        .. " infection_write_count=" .. tostring(infectionWriteCount)
        .. " fracture_write_count=" .. tostring(fractureWriteCount)
        .. " effect_count=" .. tostring(effectCount)
        .. " consume_count=1 success=true failure_reason=NONE")
    return true, "WHITE_TREATMENT_APPLIED"
end

function RedGuardian.HasTreatableState(player, mode)
    if not livingTraitOwner(player) then return false, "RED_TRAIT_REQUIRED" end
    mode = mode or RedGuardian.GetMode(player)
    if mode == RedGuardian.MODE_STAMINA or mode == RedGuardian.MODE_TREATMENT then return true, "READY" end
    return false, "INVALID_MODE"
end

function RedGuardian.ApplyConsumption(player, mode)
    if not livingTraitOwner(player) then return false, "RED_TRAIT_REQUIRED" end
    mode = mode or RedGuardian.GetMode(player)
    if mode == RedGuardian.MODE_STAMINA then return applyGreenPositive(player) end
    if mode == RedGuardian.MODE_TREATMENT then return applyWhiteTreatment(player) end
    return false, "INVALID_MODE"
end

function RedGuardian.GetCraftCost(player)
    if RedGuardian.craftSubsystemBlocked then
        return nil, "RED_CRAFT_SUBSYSTEM_GUARDED:" ..
            tostring(RedGuardian.craftSubsystemError or "ROLLBACK_INCOMPLETE")
    end
    if not livingTraitOwner(player) then return nil, "RED_TRAIT_REQUIRED" end
    if not sandboxBoolean("RedCraftEnabled", true) then return nil, "RED_CRAFT_DISABLED" end
    local controlled, controlledReason = currentControlledPlayer(player)
    if controlled ~= player then return nil, controlledReason end
    local lastCraft = RedGuardian.lastCraftByPlayer[player]
    local craftCooldownMs = sandboxNumber("RedCraftCooldownSeconds", 0, 0, 3600) * 1000
    if lastCraft and traitNowMs() - lastCraft < craftCooldownMs then return nil, "RED_CRAFT_COOLDOWN" end
    if not Core.Authority or type(Core.Authority.CanWriteNonFoodStats) ~= "function" then
        return nil, "RED_CRAFT_AUTHORITY_API_UNAVAILABLE"
    end
    local authoritative, authorityReason = Core.Authority.CanWriteNonFoodStats(player, "RED_CRAFT_COST")
    if authoritative ~= true then return nil, authorityReason end
    local body = bodyParts(player)
    local stats = getStats(player)
    local health = body and numberRead(body, "getOverallBodyHealth", nil) or nil
    local hunger = stats and statRead(stats, CharacterStat and CharacterStat.HUNGER) or nil
    local fatigueStat = CharacterStat and CharacterStat.FATIGUE or nil
    local unhappinessStat = CharacterStat and CharacterStat.UNHAPPINESS or nil
    local boredomStat = CharacterStat and CharacterStat.BOREDOM or nil
    local fatigue = stats and statRead(stats, fatigueStat) or nil
    local unhappiness = stats and statRead(stats, unhappinessStat) or nil
    local boredom = stats and statRead(stats, boredomStat) or nil
    local satiety = hunger and (1.0 - hunger) or nil
    if health == nil or satiety == nil or fatigue == nil
        or unhappiness == nil or boredom == nil then
        return nil, "CRAFT_RESOURCE_API_UNAVAILABLE"
    end
    local safetyFloorPoints = sandboxNumber("RedSafetyFloorPercent", 20, 1, 95)
    local satietyFloor = safetyFloorPoints / 100.0
    local healthCostPoints = sandboxNumber("RedCraftHealthCostPoints", 10, 0, 99)
    local unhappinessReduction = sandboxNumber(
        "RedCraftUnhappinessReductionPoints", 10, 0, 100)
    local boredomReduction = sandboxNumber("RedPCraftBoredomReduction", 30, 0, 100)
    local fatigueCostPercent = sandboxNumber(
        "RedCraftFatigueCostPercent", 10, 0, 100)
    local hungerCost = sandboxNumber("RedCraftHungerCost", 0.10, 0.0, 1.0)
    if health - healthCostPoints < safetyFloorPoints then return nil, "HEALTH_RESERVE_TOO_LOW" end
    if satiety - hungerCost < satietyFloor then return nil, "SATIETY_RESERVE_TOO_LOW" end
    return {
        body = body,
        stats = stats,
        healthBefore = health,
        hungerBefore = hunger,
        fatigueBefore = fatigue,
        unhappinessBefore = unhappiness,
        boredomBefore = boredom,
        healthCostPoints = healthCostPoints,
        unhappinessReduction = unhappinessReduction,
        boredomReduction = boredomReduction,
        fatigueCostPercent = fatigueCostPercent,
        fatigueStat = fatigueStat,
        unhappinessStat = unhappinessStat,
        boredomStat = boredomStat,
        fatigueRawDelta = statPointsDelta(fatigueStat, fatigueCostPercent),
        unhappinessRawDelta = statPointsDelta(unhappinessStat, unhappinessReduction),
        boredomRawDelta = statPointsDelta(boredomStat, boredomReduction),
        hungerCost = hungerCost,
        safetyFloorPoints = safetyFloorPoints,
        satietyFloor = satietyFloor,
        authorityReason = authorityReason,
    }, "READY"
end

function RedGuardian.GetCraftDurationSeconds()
    return sandboxNumber("RedCraftDurationSeconds", 4.0, 0.5, 60.0)
end

local function closeEnough(actual, expected, tolerance)
    return actual ~= nil and math.abs(actual - expected) <= tolerance
end

local function visibleDirection(beforeValue, afterValue)
    beforeValue = tonumber(beforeValue)
    afterValue = tonumber(afterValue)
    if beforeValue == nil or afterValue == nil then return "UNAVAILABLE" end
    if afterValue > beforeValue then return "INCREASE" end
    if afterValue < beforeValue then return "DECREASE" end
    return "UNCHANGED_AT_BOUNDARY"
end

local function logMoodProbe(stat, fallbackName, beforeValue, configuredDelta,
        afterValue, cnLabel, claimedDirection)
    local rawBefore = tonumber(beforeValue)
    local rawAfter = tonumber(afterValue)
    local rawDelta = rawBefore and rawAfter and (rawAfter - rawBefore) or nil
    print("[XNP RED CRAFT MOOD PROBE] raw_stat_id="
        .. statId(stat, fallbackName)
        .. " raw_before=" .. tostring(rawBefore)
        .. " raw_delta=" .. tostring(rawDelta)
        .. " configured_delta=" .. tostring(configuredDelta)
        .. " raw_after=" .. tostring(rawAfter)
        .. " cn_ui_label=" .. tostring(cnLabel)
        .. " ui_before=" .. tostring(rawBefore)
        .. " ui_after=" .. tostring(rawAfter)
        .. " ui_visible_direction="
        .. visibleDirection(rawBefore, rawAfter)
        .. " tooltip_claimed_direction=" .. tostring(claimedDirection)
        .. " sandbox_claimed_direction=" .. tostring(claimedDirection)
        .. " ui_mapping_basis=BUILD42_CHARACTER_STAT_DIRECT"
        .. " user_visible_confirmation=NOT_YET_TESTED")
end

local function exactItemAbsent(inventory, item)
    local containsOk, contained = invoke(inventory, "contains", item)
    return containsOk and contained ~= true
end

local function removeCreatedItem(inventory, item)
    invoke(item, "Remove")
    if exactItemAbsent(inventory, item) then return true end
    invoke(inventory, "Remove", item)
    return exactItemAbsent(inventory, item)
end

local function restoreCraftSnapshot(cost, inventory, item)
    local result = nil
    for attempt = 1, 2 do
        removeCreatedItem(inventory, item)
        invoke(cost.body, "setOverallBodyHealth", cost.healthBefore)
        statWrite(cost.stats, CharacterStat.HUNGER, cost.hungerBefore)
        statWrite(cost.stats, cost.fatigueStat, cost.fatigueBefore)
        statWrite(cost.stats, CharacterStat.UNHAPPINESS, cost.unhappinessBefore)
        statWrite(cost.stats, CharacterStat.BOREDOM, cost.boredomBefore)

        local restoredHealth = numberRead(cost.body, "getOverallBodyHealth", nil)
        local restoredHunger = statRead(cost.stats, CharacterStat.HUNGER)
        local restoredFatigue = statRead(cost.stats, cost.fatigueStat)
        local restoredUnhappiness = statRead(cost.stats, CharacterStat.UNHAPPINESS)
        local restoredBoredom = statRead(cost.stats, CharacterStat.BOREDOM)
        result = {
            attempt = attempt,
            item = exactItemAbsent(inventory, item),
            health = closeEnough(restoredHealth, cost.healthBefore, 0.01),
            hunger = closeEnough(restoredHunger, cost.hungerBefore, 0.001),
            fatigue = closeEnough(restoredFatigue, cost.fatigueBefore, 0.001),
            unhappiness = closeEnough(restoredUnhappiness, cost.unhappinessBefore, 0.01),
            boredom = closeEnough(restoredBoredom, cost.boredomBefore, 0.01),
        }
        result.complete = result.item and result.health and result.hunger and result.fatigue
            and result.unhappiness and result.boredom
        if result.complete then return result end
    end
    return result
end

function RedGuardian.CommitCraft(player)
    local cost, reason = RedGuardian.GetCraftCost(player)
    if not cost then return false, reason end
    local okInventory, inventory = invoke(player, "getInventory")
    if not okInventory or not inventory then return false, "INVENTORY_UNAVAILABLE" end
    RedGuardian.craftTransactionSerial = RedGuardian.craftTransactionSerial + 1
    local transactionId = "red-p-craft-" .. tostring(traitNowMs())
        .. "-" .. tostring(RedGuardian.craftTransactionSerial)
    local okItem, item = invoke(inventory, "AddItem", RedGuardian.ITEM_FULL_TYPE)
    if not okItem or not item then return false, "ITEM_CREATE_FAILED" end
    local createdItemReference = item
    local containsOk, itemContained = invoke(inventory, "contains", item)
    if not containsOk or itemContained ~= true then
        removeCreatedItem(inventory, createdItemReference)
        return false, containsOk and "ITEM_INSERT_READBACK_FAILED" or "ITEM_INSERT_READBACK_UNAVAILABLE"
    end
    local healthTarget = cost.healthBefore - cost.healthCostPoints
    local hungerTarget = math.min(1.0, cost.hungerBefore + cost.hungerCost)
    local fatigueTarget = statClamp(cost.fatigueStat,
        cost.fatigueBefore + cost.fatigueRawDelta)
    local unhappinessTarget = statClamp(cost.unhappinessStat,
        cost.unhappinessBefore - cost.unhappinessRawDelta)
    local boredomTarget = statClamp(cost.boredomStat,
        cost.boredomBefore - cost.boredomRawDelta)
    local healthCallOk = invoke(cost.body, "setOverallBodyHealth", healthTarget)
    local hungerOk = statWrite(cost.stats, CharacterStat.HUNGER, hungerTarget)
    local fatigueOk = statWrite(cost.stats, cost.fatigueStat, fatigueTarget)
    local unhappinessOk = statWrite(cost.stats, cost.unhappinessStat, unhappinessTarget)
    local boredomOk = statWrite(cost.stats, cost.boredomStat, boredomTarget)
    local healthReadback = numberRead(cost.body, "getOverallBodyHealth", nil)
    local hungerReadback = statRead(cost.stats, CharacterStat.HUNGER)
    local fatigueReadback = statRead(cost.stats, cost.fatigueStat)
    local unhappinessReadback = statRead(cost.stats, cost.unhappinessStat)
    local boredomReadback = statRead(cost.stats, cost.boredomStat)
    local unhappinessReadbackPass = closeEnough(
        unhappinessReadback, unhappinessTarget, 0.0001)
    local boredomReadbackPass = closeEnough(
        boredomReadback, boredomTarget, 0.0001)
    print("[XNP RED CRAFT STAT] stat_id="
        .. statId(cost.unhappinessStat, "Unhappiness")
        .. " before=" .. tostring(cost.unhappinessBefore)
        .. " configured_delta=-" .. tostring(cost.unhappinessReduction)
        .. " target=" .. tostring(unhappinessTarget)
        .. " after=" .. tostring(unhappinessReadback)
        .. " direction=DECREASE readback_pass=" .. tostring(unhappinessReadbackPass))
    print("[XNP RED CRAFT MOOD] before=" .. tostring(cost.unhappinessBefore)
        .. " requested_reduction=" .. tostring(cost.unhappinessReduction)
        .. " after=" .. tostring(unhappinessReadback)
        .. " direction=DECREASE readback_pass=" .. tostring(unhappinessReadbackPass)
        .. " halo_created=false")
    print("[XNP RED CRAFT STAT] stat_id="
        .. statId(cost.boredomStat, "Boredom")
        .. " before=" .. tostring(cost.boredomBefore)
        .. " configured_delta=-" .. tostring(cost.boredomReduction)
        .. " target=" .. tostring(boredomTarget)
        .. " after=" .. tostring(boredomReadback)
        .. " direction=DECREASE readback_pass=" .. tostring(boredomReadbackPass))
    logMoodProbe(cost.unhappinessStat, "Unhappiness",
        cost.unhappinessBefore, "-" .. tostring(cost.unhappinessReduction),
        unhappinessReadback, "CN_UI_UNHAPPINESS_YOUYU", "DECREASE")
    logMoodProbe(cost.boredomStat, "Boredom",
        cost.boredomBefore, "-" .. tostring(cost.boredomReduction),
        boredomReadback, "CN_UI_BOREDOM_WULIAO", "DECREASE")
    local fatigueReadbackPass = closeEnough(fatigueReadback, fatigueTarget, 0.001)
    local committed = healthCallOk and hungerOk and fatigueOk
        and unhappinessOk and boredomOk
        and closeEnough(healthReadback, healthTarget, 0.01)
        and closeEnough(hungerReadback, hungerTarget, 0.001)
        and fatigueReadbackPass
        and unhappinessReadbackPass and boredomReadbackPass
    if not committed then
        local rollback = restoreCraftSnapshot(cost, inventory, createdItemReference)
        if rollback and rollback.complete then
            print("[XNP RED CRAFT] complete=false reason=CRAFT_COMMIT_ROLLED_BACK"
                .. " item_removed=true health_restored=true hunger_restored=true"
                .. " fatigue_restored=true"
                .. " unhappiness_restored=true boredom_restored=true HEALTH_COST_CHARGED=false"
                .. " UNHAPPINESS_COST_CHARGED=false rollback_readback_verified=true"
                .. " preexisting_items_preserved=true created_item_reference_tracked=true"
                .. " rollback_attempt=" .. tostring(rollback.attempt)
                .. " transaction_id=" .. transactionId)
            return false, "CRAFT_COMMIT_ROLLED_BACK"
        end
        RedGuardian.craftSubsystemBlocked = true
        RedGuardian.craftSubsystemError = "ROLLBACK_INCOMPLETE:" .. transactionId
        print("[XNP RED CRAFT] complete=false reason=ROLLBACK_INCOMPLETE"
            .. " item_removed=" .. tostring(rollback and rollback.item == true)
            .. " health_restored=" .. tostring(rollback and rollback.health == true)
            .. " hunger_restored=" .. tostring(rollback and rollback.hunger == true)
            .. " fatigue_restored=" .. tostring(rollback and rollback.fatigue == true)
            .. " unhappiness_restored=" .. tostring(rollback and rollback.unhappiness == true)
            .. " boredom_restored=" .. tostring(rollback and rollback.boredom == true)
            .. " zero_cost_claimed=false SUBSYSTEM_GUARD=RED_CRAFT_ONLY"
            .. " other_subsystems_continue=true transaction_id=" .. transactionId)
        return false, "ROLLBACK_INCOMPLETE"
    end
    if Core.RedMagicUI then Core.RedMagicUI.MarkDirty() end
    RedGuardian.lastCraftByPlayer[player] = traitNowMs()
    print("[XNP RED CRAFT] complete=true item_count=1 health_cost_points="
        .. string.format("%.2f", cost.healthCostPoints)
        .. " unhappiness_reduction=" .. string.format("%.2f", cost.unhappinessReduction)
        .. " unhappiness_direction=DECREASE halo_created=false"
        .. " hunger_cost=" .. string.format("%.4f", cost.hungerCost)
        .. " fatigue_cost_percent=" .. string.format("%.2f", cost.fatigueCostPercent)
        .. " fatigue_before=" .. string.format("%.4f", cost.fatigueBefore)
        .. " fatigue_after=" .. string.format("%.4f", fatigueTarget)
        .. " fatigue_readback_pass=" .. tostring(fatigueReadbackPass)
        .. " health_before_points=" .. string.format("%.2f", cost.healthBefore)
        .. " health_after_points=" .. string.format("%.2f", healthTarget)
        .. " unhappiness_before=" .. string.format("%.2f", cost.unhappinessBefore)
        .. " unhappiness_after=" .. string.format("%.2f", unhappinessTarget)
        .. " boredom_before=" .. string.format("%.2f", cost.boredomBefore)
        .. " boredom_after=" .. string.format("%.2f", boredomTarget)
        .. " mood_commit_after_item_success=true"
        .. " reserve_floor_points=" .. string.format("%.2f", cost.safetyFloorPoints)
        .. " authority=" .. tostring(cost.authorityReason)
        .. " cost_charged_once=true created_item_reference_tracked=true"
        .. " transaction_id=" .. transactionId)
    return true, "CRAFT_COMMITTED", {
        transactionId = transactionId,
        costsReadbackPass = true,
        itemCreated = true,
        healthBefore = cost.healthBefore,
        healthAfter = healthReadback,
        hungerBefore = cost.hungerBefore,
        hungerAfter = hungerReadback,
        fatigueBefore = cost.fatigueBefore,
        fatigueAfter = fatigueReadback,
        unhappinessBefore = cost.unhappinessBefore,
        unhappinessAfter = unhappinessReadback,
        boredomBefore = cost.boredomBefore,
        boredomAfter = boredomReadback,
        authority = cost.authorityReason,
    }
end

local function starterLog(key, message)
    if RedGuardian.lastStarterLog == key then return end
    RedGuardian.lastStarterLog = key
    print(message)
end

local function playerHours(player)
    local ok, value = invoke(player, "getHoursSurvived")
    return ok and tonumber(value) or 0
end

function RedGuardian.GrantStarter(player)
    if not player or isDead(player) then return false, "PLAYER_UNAVAILABLE" end
    local data = playerData(player)
    if not data then return false, "MODDATA_UNAVAILABLE" end
    if data[RedGuardian.STARTER_VERSION_KEY] == RedGuardian.STARTER_VERSION then
        RedGuardian.starterResolvedPlayer = player
        starterLog("ALREADY_COMPLETED", "[XNP RED GUARDIAN] starter_grant=false reason=ALREADY_COMPLETED")
        return false, "ALREADY_COMPLETED"
    end
    if data[RedGuardian.STARTER_KEY] == true then
        data[RedGuardian.STARTER_VERSION_KEY] = RedGuardian.STARTER_VERSION
        data[RedGuardian.STARTER_MIGRATION_KEY] = "LEGACY_ALREADY_COMPLETED"
        RedGuardian.starterResolvedPlayer = player
        starterLog("ALREADY_COMPLETED", "[XNP RED GUARDIAN] starter_grant=false reason=ALREADY_COMPLETED")
        return false, "ALREADY_COMPLETED"
    end
    if not RedGuardian.PlayerHasTrait(player) then
        starterLog("NO_TRAIT", "[XNP RED GUARDIAN] starter_grant=false reason=NO_TRAIT")
        return false, "NO_TRAIT"
    end
    if playerHours(player) > 0.05 and not sandboxBoolean("RedGrantOnOldSave", true) then
        return false, "OLD_SAVE_GRANT_DISABLED"
    end
    local okInventory, inventory = invoke(player, "getInventory")
    if not okInventory or not inventory then return false, "INVENTORY_UNAVAILABLE" end
    local count = math.floor(sandboxNumber("RedStarterItemCount", 3, 0, 20))
    local reason = playerHours(player) > 0.05 and "05608_MISSED_GRANT_MIGRATION" or "NEW_CHARACTER"
    if count <= 0 then
        data[RedGuardian.STARTER_KEY] = true
        data[RedGuardian.STARTER_VERSION_KEY] = RedGuardian.STARTER_VERSION
        data[RedGuardian.STARTER_MIGRATION_KEY] = "SANDBOX_ZERO"
        RedGuardian.starterResolvedPlayer = player
        starterLog("SANDBOX_ZERO", "[XNP RED GUARDIAN] starter_grant=false reason=SANDBOX_ZERO")
        return true, "SANDBOX_ZERO"
    end
    local added = {}
    for _ = 1, count do
        local ok, item = invoke(inventory, "AddItem", RedGuardian.ITEM_FULL_TYPE)
        if not ok or not item then
            for _, rollbackItem in ipairs(added) do invoke(rollbackItem, "Remove") end
            return false, "STARTER_ROLLED_BACK"
        end
        added[#added + 1] = item
    end
    data[RedGuardian.STARTER_KEY] = true
    data[RedGuardian.STARTER_VERSION_KEY] = RedGuardian.STARTER_VERSION
    data[RedGuardian.STARTER_MIGRATION_KEY] = reason
    RedGuardian.starterResolvedPlayer = player
    if Core.RedMagicUI then Core.RedMagicUI.MarkDirty() end
    starterLog("GRANTED:" .. reason, "[XNP RED GUARDIAN] starter_grant=true count=" .. tostring(count)
        .. " once_key=" .. RedGuardian.STARTER_KEY .. " reason=" .. reason)
    return true, "GRANTED"
end

function RedGuardian.UpdateStarterGrant(player)
    if not player or RedGuardian.starterResolvedPlayer == player then return false end
    RedGuardian.starterRetryFrame = RedGuardian.starterRetryFrame + 1
    if RedGuardian.starterRetryFrame < 30 then return false end
    RedGuardian.starterRetryFrame = 0
    return RedGuardian.GrantStarter(player)
end

local function itemFullType(item)
    local ok, value = invoke(item, "getFullType")
    return ok and value or nil
end

local function scanContainer(container, result, visited)
    if not container or visited[container] then return end
    visited[container] = true
    local okItems, items = invoke(container, "getItems")
    local okSize, size = invoke(items, "size")
    size = okItems and okSize and tonumber(size) or 0
    for index = 0, size - 1 do
        local okItem, item = invoke(items, "get", index)
        if okItem and item then
            if itemFullType(item) == RedGuardian.ITEM_FULL_TYPE then result.count = result.count + 1; if not result.first then result.first = item end end
            local okNested, nested = invoke(item, "getInventory")
            if okNested and nested then scanContainer(nested, result, visited) end
        end
    end
end

function RedGuardian.GetInventorySnapshot(player)
    local result = { count = 0, first = nil }
    local okInventory, inventory = invoke(player, "getInventory")
    if okInventory and inventory then scanContainer(inventory, result, {}) end
    return result
end

function RedGuardian.ClearConsumeAction(action)
    if action == nil or RedGuardian.activeConsumeAction == action then RedGuardian.activeConsumeAction = nil; return true end
    return false
end

function RedGuardian.ClearCraftAction(action)
    if action == nil or RedGuardian.activeCraftAction == action then RedGuardian.activeCraftAction = nil; return true end
    return false
end

local function blockedUse(reason, detail)
    print("[XNP RED USE] result=BLOCKED reason=" .. tostring(reason)
        .. " effect_transaction_count=0 consumed=0 detail=" .. tostring(detail or "NONE"))
    return false, reason
end

local function countInContainer(container)
    local result = { count = 0, first = nil }
    if container then scanContainer(container, result, {}) end
    return result.count
end

local function removeAdditionalMarks(container, wanted)
    local removed = 0
    while removed < wanted do
        local result = { count = 0, first = nil }
        scanContainer(container, result, {})
        if not result.first or type(result.first.Remove) ~= "function" then break end
        local ok = pcall(function() result.first:Remove() end)
        if not ok then break end
        removed = removed + 1
    end
    return removed
end

local refreshAfterUse

local function consumeFailedUse(item, container)
    local requested = math.floor(sandboxNumber("RedFailedUseConsumesCount", 0, 0, 20) + 0.5)
    if requested <= 0 or not item or type(item.Remove) ~= "function" then return 0 end
    local removed = pcall(function() item:Remove() end)
    if not removed then return 0 end
    return 1 + removeAdditionalMarks(container, requested - 1)
end

local function failedEffect(item, container, detail)
    local consumed = consumeFailedUse(item, container)
    refreshAfterUse(container)
    print("[XNP RED USE] result=BLOCKED reason=EFFECT_FAILED effect_transaction_count=0 consumed="
        .. tostring(consumed) .. " detail=" .. tostring(detail or "NONE"))
    return false, "EFFECT_FAILED"
end

refreshAfterUse = function(container)
    if Core.RedMagicUI and type(Core.RedMagicUI.MarkDirty) == "function" then
        pcall(Core.RedMagicUI.MarkDirty)
    end
    if type(triggerEvent) == "function" then
        pcall(triggerEvent, "OnContainerUpdate", container)
    end
end

local function playRedUseSound(player)
    if sandboxBoolean("RedUseSoundEnabled", true) and Core.Audio and type(Core.Audio.PlayOnce) == "function" then
        pcall(Core.Audio.PlayOnce, player, "RED_USE_OR_PHOENIX_READY", "red-use:" .. tostring(traitNowMs()))
    end
end

function RedGuardian.TryUse(player, item)
    if not player then return blockedUse("NO_PLAYER") end
    if itemFullType(item) ~= RedGuardian.ITEM_FULL_TYPE then return blockedUse("INVALID_ITEM") end
    if not livingTraitOwner(player) then return blockedUse("NO_TRAIT") end
    local lastUse = RedGuardian.lastUseByPlayer[player]
    local useCooldownMs = sandboxNumber("RedUseCooldownSeconds", 0, 0, 3600) * 1000
    if lastUse and traitNowMs() - lastUse < useCooldownMs then return blockedUse("USE_COOLDOWN") end

    local mode = RedGuardian.GetMode(player)
    if RedGuardian.activeUseTransaction then return blockedUse("DUPLICATE_TRANSACTION") end

    local okContainer, originalContainer = invoke(item, "getContainer")
    if not okContainer or not originalContainer or type(item.Remove) ~= "function" then
        return blockedUse("INVALID_ITEM", "ORIGINAL_CONTAINER_OR_REMOVE_UNAVAILABLE")
    end

    local transaction = {}
    RedGuardian.activeUseTransaction = transaction

    local readyCall, ready, readyReason = pcall(RedGuardian.HasTreatableState, player, mode)
    if not readyCall or ready ~= true then
        RedGuardian.activeUseTransaction = nil
        return failedEffect(item, originalContainer, readyCall and readyReason or ready)
    end

    local effectCall, applied, applyReason = pcall(RedGuardian.ApplyConsumption, player, mode)
    if not effectCall or applied ~= true then
        RedGuardian.activeUseTransaction = nil
        return failedEffect(item, originalContainer, effectCall and applyReason or applied)
    end

    local removeCall, removeError = pcall(function() item:Remove() end)
    if not removeCall then
        RedGuardian.activeUseTransaction = nil
        print("[XNP RED USE] result=BLOCKED reason=EFFECT_FAILED effect_transaction_count=1 consumed=0"
            .. " detail=ITEM_REMOVE_FAILED_AFTER_EFFECT error=" .. tostring(removeError))
        return false, "EFFECT_FAILED"
    end

    local _, afterContainer = invoke(item, "getContainer")
    if afterContainer == originalContainer then
        RedGuardian.activeUseTransaction = nil
        print("[XNP RED USE] result=BLOCKED reason=EFFECT_FAILED effect_transaction_count=1 consumed=0"
            .. " detail=ITEM_STILL_IN_ORIGINAL_CONTAINER_AFTER_REMOVE")
        return false, "EFFECT_FAILED"
    end

    local requestedConsume = math.floor(sandboxNumber("RedSuccessfulUseConsumesCount", 1, 1, 20) + 0.5)
    local consumed = 1 + removeAdditionalMarks(originalContainer, requestedConsume - 1)
    local remaining = countInContainer(originalContainer)
    refreshAfterUse(originalContainer)
    playRedUseSound(player)
    RedGuardian.lastUseByPlayer[player] = traitNowMs()
    RedGuardian.activeUseTransaction = nil
    print("[XNP RED USE] result=SUCCESS mode=" .. tostring(mode)
        .. " consumed=" .. tostring(consumed) .. " remaining=" .. tostring(remaining) .. " effect_transaction_count=1")
    return true, mode
end

function RedGuardian.QueueConsumeItem(player, item, source)
    local mode = player and RedGuardian.GetMode(player) or RedGuardian.MODE_STAMINA
    print("[XNP RED USE] request=true item=" .. tostring(itemFullType(item)) .. " mode=" .. tostring(mode))
    if not player then return blockedUse("NO_PLAYER") end
    if itemFullType(item) ~= RedGuardian.ITEM_FULL_TYPE then return blockedUse("INVALID_ITEM") end
    if not livingTraitOwner(player) then return blockedUse("NO_TRAIT") end
    if RedGuardian.activeConsumeAction or RedGuardian.activeCraftAction or RedGuardian.activeUseTransaction then
        return blockedUse("DUPLICATE_TRANSACTION")
    end
    local actionCall, action = pcall(function()
        return XNPRedGuardianConsumeAction:new(player, item, mode)
    end)
    if not actionCall or not action then return blockedUse("EFFECT_FAILED", "ACTION_CREATE_FAILED") end
    RedGuardian.activeConsumeAction = action
    local queueCall, queueError = pcall(function() ISTimedActionQueue.add(action) end)
    if not queueCall then
        RedGuardian.activeConsumeAction = nil
        return blockedUse("EFFECT_FAILED", queueError)
    end
    print("[XNP RED MAGIC] consume_queued=true source=" .. tostring(source or "UNKNOWN"))
    return true, "QUEUED"
end

function RedGuardian.QueueConsumeOne(player, source)
    local snapshot = RedGuardian.GetInventorySnapshot(player)
    if not snapshot.first then
        print("[XNP RED USE] request=true item=nil mode=" .. tostring(player and RedGuardian.GetMode(player) or RedGuardian.MODE_STAMINA))
        return blockedUse("INVALID_ITEM", "NO_ITEM")
    end
    return RedGuardian.QueueConsumeItem(player, snapshot.first, source)
end

function RedGuardian.QueueCraftOne(player, source)
    if not livingTraitOwner(player) then return false, "RED_TRAIT_REQUIRED" end
    if not sandboxBoolean("RedDoubleClickCraftEnabled", true) then return false, "RED_DOUBLE_CLICK_CRAFT_DISABLED" end
    if RedGuardian.activeConsumeAction or RedGuardian.activeCraftAction then return false, "ACTION_ALREADY_QUEUED" end
    local cost, reason = RedGuardian.GetCraftCost(player)
    if not cost then print("[XNP RED CRAFT] queued=false reason=" .. tostring(reason)); return false, reason end
    local action = XNPRedGuardianCraftAction:new(player)
    RedGuardian.activeCraftAction = action
    ISTimedActionQueue.add(action)
    print("[XNP RED CRAFT] queued=true source=" .. tostring(source or "UNKNOWN") .. " costs_deferred_until_complete=true")
    return true, "QUEUED"
end

local function forEachContextEntry(collection, callback)
    if not collection then return end
    if type(collection) == "table" then
        for _, entry in ipairs(collection) do callback(entry) end
        return
    end
    local okSize, size = invoke(collection, "size")
    size = okSize and tonumber(size) or 0
    for index = 0, size - 1 do
        local okEntry, entry = invoke(collection, "get", index)
        if okEntry then callback(entry) end
    end
end

local function collectMatchingItems(items)
    local result, seen = {}, {}
    local function collect(entry)
        if not entry or seen[entry] then return end
        seen[entry] = true
        if itemFullType(entry) == RedGuardian.ITEM_FULL_TYPE then
            result[#result + 1] = entry
            return
        end
        if type(entry) == "table" and entry.items then
            forEachContextEntry(entry.items, collect)
        end
    end
    forEachContextEntry(items, collect)
    return result
end

local function queueConsumeFromContext(item, player)
    RedGuardian.QueueConsumeItem(player, item, "INVENTORY_CONTEXT")
end

local function markTraitRequired(option)
    if not option then return end
    option.notAvailable = true
    if ISInventoryPaneContextMenu and type(ISInventoryPaneContextMenu.addToolTip) == "function" then
        local tooltip = ISInventoryPaneContextMenu.addToolTip()
        if tooltip then
            tooltip.description = getText("Tooltip_XNPRedGuardianTraitRequired")
            option.toolTip = tooltip
        end
    end
end

function RedGuardian.OnFillInventoryObjectContextMenu(playerIndex, context, items)
    local player = type(getSpecificPlayer) == "function" and getSpecificPlayer(playerIndex) or nil
    local matches = collectMatchingItems(items)
    if not context or #matches == 0 then return end
    local option = context:addOption(getText("ContextMenu_UseRedMagicMark"), matches[1], queueConsumeFromContext, player)
    if not livingTraitOwner(player) then markTraitRequired(option) end
end

local function onFillInventoryObjectContextMenuAdapter(playerIndex, context, items)
    return RedGuardian.OnFillInventoryObjectContextMenu(playerIndex, context, items)
end

function RedGuardian.RegisterSchedulerTask()
    return true, "LEGACY_FRACTURE_TASK_DISABLED_05604"
end

function RedGuardian.RegisterEvents()
    if not RedGuardian.contextRegistered and Events and Events.OnFillInventoryObjectContextMenu then
        Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenuAdapter)
        RedGuardian.contextRegistered = true
    print("[XNP RED GUARDIAN] context_registered=true version=0.5.60.7.11")
    end
    return RedGuardian.contextRegistered
end

function RedGuardian.Cleanup(reason)
    RedGuardian.activeConsumeAction = nil
    RedGuardian.activeUseTransaction = nil
    RedGuardian.activeCraftAction = nil
    cancelRegen(reason or "CLEANUP")
    RedGuardian.starterRetryFrame = 0
    RedGuardian.starterResolvedPlayer = nil
    RedGuardian.lastStarterLog = nil
    RedGuardian.traitCachePlayer = nil
    RedGuardian.traitCacheResult = nil
    RedGuardian.traitCacheLogged = nil
    RedGuardian.traitCacheCanonical = nil
    RedGuardian.traitNextCheckMs = 0
end

Core.RedGuardianMark = RedGuardian
return RedGuardian
