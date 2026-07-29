require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Items"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Transactions"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleDeathAuto"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Registry = Core.PurpleLifeStockRegistry
local Items = Core.PurpleLifeStockItems
local Transactions = Core.PurpleLifeStockTransactions
local DeathAuto = Core.PurpleDeathAuto

local Controller = {
    initializedPlayer = nil,
    nextUpdateMs = 0,
    nextFailedAutoRetryMs = 0,
    deathClaimMarkCount = 0,
    deathAutoSuccessCount = 0,
    deathAutoFailureCount = 0,
    deathHandledPlayer = nil,
    deathHandlerCallCount = 0,
    deathHandlerDuplicateCount = 0,
    lastCleanupReason = nil,
    starterGrantCount = 0,
}

local UPDATE_INTERVAL_MS = 5000
local FAILED_AUTO_RETRY_MS = 60000

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return os.time() * 1000
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

local function purpleSystemEnabled()
    return sandboxBoolean("EnableMod", true)
        and sandboxBoolean("EnablePurplePhoenixSystem", true)
end

local function hasPurple(player)
    return Core.PurplePhoenixTrait
        and Core.PurplePhoenixTrait.PlayerHasTrait(player) == true
end

local function initializeAutoDue(lineage)
    local due = Registry.GetNextAutoRecordDay(lineage)
    if due ~= nil then return due, "AUTO_DUE_PRESENT" end
    local interval = sandboxNumber("PurpleBackupAutoRecordIntervalGameDays",
        Constants.AUTO_INTERVAL_GAME_DAYS_DEFAULT, 1, 365)
    local target = Registry.GameDay() + interval
    Registry.SetNextAutoRecordDay(lineage, target)
    return target, "AUTO_DUE_INITIALIZED"
end

function Controller.InitializePlayer(player, source)
    if not player then return false, "PLAYER_MISSING" end
    Items.InstallInteractions()
    local migrated, migrationReason, lineage = Registry.InitializeMigration(player)
    if not migrated then return false, migrationReason end
    local itemsMigrated, itemMigrationReason, itemMigrationCount =
        Items.MigrateVisibleLegacyItems(player)
    if not itemsMigrated then return false, itemMigrationReason end
    Controller.initializedPlayer = player
    Controller.nextUpdateMs = 0
    Controller.nextFailedAutoRetryMs = 0
    Controller.deathHandledPlayer = nil
    Controller.deathHandlerCallCount = 0
    Controller.lastCleanupReason = nil
    if purpleSystemEnabled() and hasPurple(player) then
        Registry.MarkPurpleLineage(lineage)
        Core.PurplePhoenixState.EnsureDefaultMigration(
            player, source or "LIFE_STOCK_INITIALIZE")
        local starterWasDone = Registry.StarterGrantDone(lineage)
        local starterOk, starterReason = Transactions.GrantStarter(player)
        if not starterOk then
            print("[XNP PURPLE STARTER] starter_grant_done=false reason="
                .. tostring(starterReason))
        elseif not starterWasDone then
            Controller.starterGrantCount = Controller.starterGrantCount + 1
        end
        initializeAutoDue(lineage)
        DeathAuto.CaptureCandidate(
            player, "INITIAL_LIVING_SNAPSHOT", true)
    end
    local delivered, deliveryReason = DeathAuto.DeliverPending(player)
    if not delivered and deliveryReason ~= "CLAIMABLE_NOT_FOUND"
        and deliveryReason ~= "CLAIM_NOT_DEATH_AUTO" then
        print("[XNP LIFE STOCK INHERITANCE] delivery=DEFERRED reason="
            .. tostring(deliveryReason)
            .. " gated_by_phoenix=false")
    end
    local tokenCount = Registry.CountValidTokens(lineage)
    print("[XNP PURPLE BACKUP INIT] source=" .. tostring(source or "INITIALIZE")
        .. " migration=" .. tostring(migrationReason)
        .. " legacy_item_migration=" .. tostring(itemMigrationReason)
        .. " legacy_item_migration_count=" .. tostring(itemMigrationCount or 0)
        .. " valid_token_count=" .. tostring(tokenCount)
        .. " auto_regrant_count=0 auto_recreate_count=0"
        .. " recorder_grant_enabled=false")
    return true, "PURPLE_BACKUP_PLAYER_INITIALIZED"
end

function Controller.CaptureDeathCandidate(player, source)
    return DeathAuto.CaptureCandidate(player, source, true)
end

function Controller.OnPlayerDeath(player)
    if Controller.deathHandledPlayer == player then
        Controller.deathHandlerDuplicateCount =
            Controller.deathHandlerDuplicateCount + 1
        return false, "DEATH_HANDLER_DUPLICATE_FILTERED"
    end
    Controller.deathHandledPlayer = player
    Controller.deathHandlerCallCount = Controller.deathHandlerCallCount + 1
    local marked, claimOrReason = DeathAuto.OnDeath(player)
    if marked then
        Controller.deathClaimMarkCount = Controller.deathClaimMarkCount + 1
        Controller.deathAutoSuccessCount =
            Controller.deathAutoSuccessCount + 1
        return true, claimOrReason
    end
    Controller.deathAutoFailureCount =
        Controller.deathAutoFailureCount + 1
    print("[XNP LIFE STOCK DEATH AUTO] result=FAILED"
        .. " death_allowed_to_complete=true"
        .. " gated_by_phoenix=false"
        .. " reason=" .. tostring(claimOrReason))
    return false, claimOrReason
end

function Controller.Update(player)
    if not player or not Core.CanonicalPlayerIdentity
        or Core.CanonicalPlayerIdentity.Validate(player, true) ~= true then
        return false, "CONTROLLED_PLAYER_IDENTITY_REJECTED"
    end
    DeathAuto.CaptureCandidate(player, "RUNTIME_LIVING_SNAPSHOT", false)
    local now = nowMs()
    if now < Controller.nextUpdateMs then return true, "UPDATE_THROTTLED" end
    Controller.nextUpdateMs = now + UPDATE_INTERVAL_MS
    if Controller.initializedPlayer ~= player then
        local initialized, reason = Controller.InitializePlayer(
            player, "RUNTIME_REBIND")
        if not initialized then return false, reason end
    end
    DeathAuto.DeliverPending(player)
    if not purpleSystemEnabled() or not hasPurple(player) then
        return true, "PURPLE_BACKUP_INACTIVE_FOR_PLAYER"
    end
    local lineage, ownerReason = Registry.GetLineage(player, true)
    if not lineage then return false, ownerReason end
    if not Registry.StarterGrantDone(lineage) then
        local starterOk, starterReason = Transactions.GrantStarter(player)
        if not starterOk then return false, starterReason end
    end
    if not sandboxBoolean("PurpleBackupAutoRecordEnabled", true) then
        return true, "AUTO_RECORD_DISABLED"
    end
    local due = Registry.GetNextAutoRecordDay(lineage)
    if due == nil then due = initializeAutoDue(lineage) end
    if Registry.GameDay() < due then return true, "AUTO_RECORD_NOT_DUE" end
    if now < Controller.nextFailedAutoRetryMs then
        return true, "AUTO_RECORD_RETRY_THROTTLED"
    end
    local refreshed, refreshReason = Transactions.RefreshWeekly(player)
    if not refreshed then
        Controller.nextFailedAutoRetryMs = now + FAILED_AUTO_RETRY_MS
        print("[XNP PURPLE BACKUP AUTO] result=DEFERRED reason="
            .. tostring(refreshReason)
            .. " item_created=false token_count_delta=0 sound_call=false")
        return false, refreshReason
    end
    Controller.nextFailedAutoRetryMs = 0
    return true, "AUTO_RECORD_COMMITTED"
end

function Controller.GetStatus(player)
    local status = {
        right_top_icon_authority = true,
        has_trait = player and hasPurple(player) or false,
        has_snapshot = false,
        claimable = false,
        next_auto_record_day = nil,
        days_until_auto_record = nil,
        phoenix_survival_enabled = false,
        valid_token_count = 0,
    }
    if not player then return status end
    local lineage = Registry.GetLineage(player, false)
    if not lineage then return status end
    status.has_snapshot = Registry.GetLatest(lineage) ~= nil
    status.claimable = Registry.GetClaimable(player) ~= nil
    status.phoenix_survival_enabled =
        Core.PurplePhoenixState.IsEnabled(player) == true
    status.valid_token_count = Registry.CountValidTokens(lineage)
    status.next_auto_record_day = Registry.GetNextAutoRecordDay(lineage)
    if status.next_auto_record_day then
        status.days_until_auto_record = math.max(
            0, status.next_auto_record_day - Registry.GameDay())
    end
    return status
end

function Controller.Cleanup(reason)
    local cleanupReason = tostring(reason or "UNKNOWN")
    if cleanupReason == Controller.lastCleanupReason then
        return true, "CLEANUP_ALREADY_APPLIED"
    end
    Controller.lastCleanupReason = cleanupReason
    local previousPlayer = Controller.initializedPlayer
    Controller.initializedPlayer = nil
    Controller.nextUpdateMs = 0
    Controller.nextFailedAutoRetryMs = 0
    if Core.PurpleDeathAuto then
        Core.PurpleDeathAuto.ResetPlayer(previousPlayer)
    end
    if cleanupReason ~= "player_death" and cleanupReason ~= "dead_character"
        and cleanupReason ~= "death_done" then
        Controller.deathHandledPlayer = nil
        Controller.deathHandlerCallCount = 0
    end
    print("[XNP PURPLE BACKUP] cleanup=true reason=" .. cleanupReason)
    return true, "CLEANUP_APPLIED"
end

function Controller.GetAuditSnapshot()
    local registry = Registry.GetAuditSnapshot()
    local transactions = Transactions.GetAuditSnapshot()
    local items = Items.GetAuditSnapshot()
    return {
        death_claim_mark_count = Controller.deathClaimMarkCount,
        death_handler_call_count_per_death = Controller.deathHandlerCallCount,
        death_handler_duplicate_count = Controller.deathHandlerDuplicateCount,
        death_auto_success_count = Controller.deathAutoSuccessCount,
        death_auto_failure_count = Controller.deathAutoFailureCount,
        starter_grant_count = Controller.starterGrantCount,
        duplicate_valid_token_count = registry.duplicate_valid_token_count or 0,
        valid_token_count = registry.valid_token_count or 0,
        auto_regrant_count = items.auto_regrant_count or 0,
        auto_recreate_count = items.auto_recreate_count or 0,
        manual_record_transaction_pass = transactions.manual_record_transaction_pass,
        auto_weekly_record_transaction_pass =
            transactions.auto_weekly_record_transaction_pass,
        initial_snapshot_transaction_pass =
            transactions.initial_snapshot_transaction_pass,
        restore_transaction_pass = transactions.restore_transaction_pass,
        restore_rollback_pass = transactions.restore_rollback_pass,
        restore_failure_item_preserved =
            transactions.restore_failure_item_preserved,
        inventory_duplication_count = transactions.inventory_duplication_count,
    }
end

Core.PurpleLifeStockController = Controller
return Controller
