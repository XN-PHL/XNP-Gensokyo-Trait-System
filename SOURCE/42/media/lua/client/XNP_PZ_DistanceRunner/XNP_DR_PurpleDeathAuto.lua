require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Codec"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Snapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Items"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Codec = Core.PurpleLifeStockCodec
local Registry = Core.PurpleLifeStockRegistry
local Snapshot = Core.PurpleLifeStockSnapshot
local Items = Core.PurpleLifeStockItems

local DeathAuto = {
    candidates = setmetatable({}, { __mode = "k" }),
    processedDeaths = setmetatable({}, { __mode = "k" }),
    nextCaptureMs = setmetatable({}, { __mode = "k" }),
    captureIntervalMs = 1000,
    createdCount = 0,
    deliveredCount = 0,
    duplicateDeathCount = 0,
    duplicateDeliveryCount = 0,
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function copy(value)
    local copied = Codec.CopySerializable(value)
    return copied
end

local function buildSnapshotFromPayload(payload, lineage, ownerKey, source)
    local copied, copyReason = Codec.CopySerializable(payload)
    if not copied then return nil, copyReason end
    local snapshot = {
        schema_version = Constants.SNAPSHOT_SCHEMA,
        snapshot_id = Registry.NewSnapshotId(ownerKey),
        lineage_id = lineage,
        created_game_time = Registry.GameDay(),
        created_real_time_ms = nowMs(),
        source = source,
        build_marker = Core.Constants and Core.Constants.BUILD_ID
            or "XNP_0560723_PURPLE_DUAL_A",
        game_build_baseline = Core.Constants
            and Core.Constants.GAME_BUILD_TARGET or "42.20.0",
        payload = copied,
    }
    local valid, checksum = Codec.ValidateSnapshot(snapshot)
    if not valid then return nil, checksum end
    snapshot.checksum = checksum
    return snapshot, "DEATH_SNAPSHOT_BUILT"
end

local function eligibleLineage(player)
    local lineage, ownerKey = Registry.GetLineage(player, false)
    if not lineage then return nil, ownerKey end
    local valid, reason = Registry.IsPurpleLineage(lineage)
    if not valid then return nil, reason end
    return lineage, ownerKey
end

function DeathAuto.CaptureCandidate(player, source, force)
    if not player then return false, "PLAYER_MISSING" end
    local now = nowMs()
    if force ~= true and now < (DeathAuto.nextCaptureMs[player] or 0) then
        return true, "DEATH_CANDIDATE_CAPTURE_THROTTLED"
    end
    local lineage, ownerKey = eligibleLineage(player)
    if not lineage then return false, ownerKey end
    local payload, payloadReason = Snapshot.CapturePayload(player)
    if not payload then return false, payloadReason end
    local copied, copyReason = Codec.CopySerializable(payload)
    if not copied then return false, copyReason end
    DeathAuto.candidates[player] = {
        payload = copied,
        lineage = lineage,
        owner_key = ownerKey,
        captured_at_ms = now,
        source = tostring(source or "RUNTIME_LIVING_SNAPSHOT"),
    }
    DeathAuto.nextCaptureMs[player] = now + DeathAuto.captureIntervalMs
    return true, "DEATH_CANDIDATE_CAPTURED"
end

local function commitFinalOrCandidate(player, lineage, ownerKey)
    local payload, payloadReason = Snapshot.CapturePayload(player)
    local source = Constants.SOURCE_DEATH_FINAL
    if not payload then
        local candidate = DeathAuto.candidates[player]
        if candidate and candidate.lineage == lineage then
            payload = copy(candidate.payload)
            payloadReason = "LAST_LIVING_CANDIDATE:"
                .. tostring(candidate.source)
        end
    end
    if payload then
        local snapshot, snapshotReason = buildSnapshotFromPayload(
            payload, lineage, ownerKey, source)
        if snapshot then
            local committed, commitReason =
                Registry.CommitActiveSnapshot(ownerKey, snapshot)
            if committed then
                return snapshot.snapshot_id, source,
                    payloadReason or "FINAL_CAPTURE"
            end
            payloadReason = commitReason
        else
            payloadReason = snapshotReason
        end
    end

    local valid, fallbackReason, entry =
        Registry.ValidateLatestActive(lineage)
    if not valid or not entry then
        return nil, fallbackReason or payloadReason
    end
    return entry.snapshot_id, Constants.SOURCE_DEATH_FALLBACK,
        payloadReason or "LATEST_ACTIVE_FALLBACK"
end

function DeathAuto.OnDeath(player)
    if not player then return false, "PLAYER_MISSING" end
    if DeathAuto.processedDeaths[player] == true then
        DeathAuto.duplicateDeathCount = DeathAuto.duplicateDeathCount + 1
        return false, "DEATH_AUTO_DUPLICATE_PLAYER_EVENT"
    end
    local lineage, ownerKey = eligibleLineage(player)
    if not lineage then return false, ownerKey end
    DeathAuto.processedDeaths[player] = true

    local snapshotId, snapshotSource, captureReason =
        commitFinalOrCandidate(player, lineage, ownerKey)
    if not snapshotId then
        DeathAuto.processedDeaths[player] = nil
        return false, snapshotSource
    end
    local marked, claimOrReason, deathSerial = Registry.MarkDeath(
        player, snapshotId, snapshotSource)
    if not marked then
        DeathAuto.processedDeaths[player] = nil
        return false, claimOrReason
    end
    DeathAuto.createdCount = DeathAuto.createdCount + 1
    local claim = claimOrReason

    local phoenixEnabled, recharge, cooldownRemaining =
        false, "UNKNOWN", 0
    if Core.PurplePhoenixState then
        local okEnabled, enabled = pcall(
            Core.PurplePhoenixState.IsEnabled, player)
        if okEnabled then phoenixEnabled = enabled == true end
        local okRecharge, state, remaining = pcall(
            Core.PurplePhoenixState.GetRecharge, player)
        if okRecharge then
            recharge = state
            cooldownRemaining = remaining or 0
        end
    end
    print("[XNP LIFE STOCK DEATH AUTO]"
        .. " death_serial=" .. tostring(deathSerial)
        .. " source=" .. tostring(snapshotSource)
        .. " source_detail=" .. tostring(captureReason)
        .. " token_id=" .. tostring(claim.token_id)
        .. " snapshot_id=" .. tostring(snapshotId)
        .. " item_delivery_pending=true"
        .. " phoenix_survival_enabled=" .. tostring(phoenixEnabled)
        .. " phoenix_cooldown_state=" .. tostring(recharge)
        .. " phoenix_cooldown_remaining="
        .. tostring(cooldownRemaining)
        .. " gated_by_phoenix=false")
    DeathAuto.candidates[player] = nil
    DeathAuto.nextCaptureMs[player] = nil
    return true, claim
end

function DeathAuto.DeliverPending(player)
    if not player then return false, "PLAYER_MISSING" end
    local claim, ownerKey = Registry.GetClaimable(player)
    if not claim then return false, ownerKey end
    if claim.issued_source ~= Constants.ISSUED_DEATH_AUTO then
        return false, "CLAIM_NOT_DEATH_AUTO"
    end
    if claim.delivered == true then
        DeathAuto.duplicateDeliveryCount =
            DeathAuto.duplicateDeliveryCount + 1
        return true, "DEATH_AUTO_ALREADY_DELIVERED"
    end
    local token, tokenReason = Registry.GetToken(claim.token_id)
    if not token then return false, tokenReason end

    local item = Items.FindBackupByToken(player, token.token_id)
    local created = false
    if not item then
        local inventory = Items.InventoryOf(player)
        if not inventory then return false, "MAIN_INVENTORY_UNAVAILABLE" end
        local itemReason
        item, itemReason = Items.CreateBackupForToken(
            player, token, inventory)
        if not item then return false, itemReason end
        created = true
    end
    local delivered, deliveryReason =
        Registry.MarkDelivered(claim, ownerKey)
    if not delivered then
        if created then Items.RemoveExact(Items.InventoryOf(player), item) end
        return false, deliveryReason
    end
    DeathAuto.deliveredCount = DeathAuto.deliveredCount + 1
    print("[XNP LIFE STOCK INHERITANCE]"
        .. " delivery=SUCCESS"
        .. " death_serial=" .. tostring(claim.death_serial)
        .. " token_id=" .. tostring(claim.token_id)
        .. " snapshot_id=" .. tostring(claim.snapshot_id)
        .. " target=SUCCESSOR_MAIN_INVENTORY"
        .. " item_created=" .. tostring(created)
        .. " delivery_count_delta=1"
        .. " gated_by_phoenix=false")
    return true, "DEATH_AUTO_DELIVERED"
end

function DeathAuto.ResetPlayer(player)
    if not player then return true, "NO_PLAYER" end
    DeathAuto.candidates[player] = nil
    DeathAuto.nextCaptureMs[player] = nil
    return true
end

function DeathAuto.GetAuditSnapshot()
    return {
        death_auto_created_count = DeathAuto.createdCount,
        death_auto_delivered_count = DeathAuto.deliveredCount,
        duplicate_death_count = DeathAuto.duplicateDeathCount,
        duplicate_delivery_count = DeathAuto.duplicateDeliveryCount,
        gated_by_phoenix = false,
        requires_existing_token = false,
    }
end

Core.PurpleDeathAuto = DeathAuto
return DeathAuto
