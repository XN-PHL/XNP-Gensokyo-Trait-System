require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Codec"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Codec = Core.PurpleLifeStockCodec

local Registry = {
    serial = 0,
    cached = nil,
    canonicalMigrationCount = 0,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return os.time() * 1000
end

local function safeToken(value)
    local token = tostring(value or "UNKNOWN")
    token = string.gsub(token, "[|%c]", "_")
    return token ~= "" and token or "UNKNOWN"
end

local function gameDay()
    if type(getWorld) == "function" then
        local okWorld, world = pcall(getWorld)
        local okDays, days = invoke(okWorld and world or nil, "getWorldAgeDays")
        if okDays and tonumber(days) then return tonumber(days) end
    end
    if type(getGameTime) == "function" then
        local okTime, gameTime = pcall(getGameTime)
        local okHours, hours = invoke(okTime and gameTime or nil, "getWorldAgeHours")
        if okHours and tonumber(hours) then return tonumber(hours) / 24 end
    end
    return 0
end

local function worldIdentity()
    if type(getWorld) ~= "function" then return "WORLD_UNAVAILABLE" end
    local okWorld, world = pcall(getWorld)
    if not okWorld or not world then return "WORLD_UNAVAILABLE" end
    local okName, name = invoke(world, "getWorld")
    local okMap, map = invoke(world, "getMap")
    return safeToken(okName and name or "WORLD") .. "@"
        .. safeToken(okMap and map or "MAP")
end

local function multiplayerRuntime()
    local client, server = false, false
    if type(isClient) == "function" then
        local ok, value = pcall(isClient)
        client = ok and value == true
    end
    if type(isServer) == "function" then
        local ok, value = pcall(isServer)
        server = ok and value == true
    end
    return client or server
end

local function accountIdentity(player)
    local okSteam, steamId = invoke(player, "getSteamID")
    steamId = okSteam and tonumber(steamId) or 0
    if steamId and steamId > 0 then return "STEAM:" .. tostring(steamId) end
    if multiplayerRuntime() then
        local okUser, username = invoke(player, "getUsername")
        if okUser and username and tostring(username) ~= "" then
            return "ACCOUNT:" .. safeToken(username)
        end
        return "MULTIPLAYER_ACCOUNT_UNAVAILABLE"
    end
    return "LOCAL_ACCOUNT"
end

local function transmit()
    if ModData and type(ModData.transmit) == "function" then
        pcall(ModData.transmit, Constants.REGISTRY_NAMESPACE)
        return
    end
    if GlobalModData and type(GlobalModData.transmit) == "function" then
        pcall(GlobalModData.transmit, Constants.REGISTRY_NAMESPACE)
    end
end

local function generateId(prefix, ownerKey)
    Registry.serial = Registry.serial + 1
    if type(getRandomUUID) == "function" then
        local ok, value = pcall(getRandomUUID)
        if ok and value and tostring(value) ~= "" then
            return tostring(prefix) .. "-" .. tostring(value)
        end
    end
    return tostring(prefix) .. "-" .. tostring(nowMs()) .. "-"
        .. tostring(Registry.serial) .. "-" .. safeToken(ownerKey)
end

local function ensureLineageDefaults(state)
    state.death_serial = tonumber(state.death_serial) or 0
    state.next_auto_record_day = tonumber(state.next_auto_record_day)
    state.purple_trait_lineage = state.purple_trait_lineage == true
    if state.respawn_mode_enabled == nil then state.respawn_mode_enabled = true end
    state.starter_grant_done = state.starter_grant_done == true
    state.token_ids = type(state.token_ids) == "table" and state.token_ids or {}
    state.death_claims = type(state.death_claims) == "table"
        and state.death_claims or {}
    state.delivery_count = tonumber(state.delivery_count) or 0
    state.duplicate_delivery_count = tonumber(state.duplicate_delivery_count) or 0
    return state
end

local function rawRegistry()
    local result = nil
    if ModData and type(ModData.getOrCreate) == "function" then
        local ok, value = pcall(ModData.getOrCreate, Constants.REGISTRY_NAMESPACE)
        if ok then result = value end
    end
    if not result and GlobalModData and type(GlobalModData.getOrCreate) == "function" then
        local ok, value = pcall(GlobalModData.getOrCreate, Constants.REGISTRY_NAMESPACE)
        if ok then result = value end
    end
    if type(result) ~= "table" then return nil, "WORLD_MODDATA_UNAVAILABLE" end
    result.registry_version = tonumber(result.registry_version) or 1
    result.owner_lineages = type(result.owner_lineages) == "table"
        and result.owner_lineages or {}
    result.lineages = type(result.lineages) == "table" and result.lineages or {}
    result.entries = type(result.entries) == "table" and result.entries or {}
    result.tokens = type(result.tokens) == "table" and result.tokens or {}
    result.claimable_by_owner = type(result.claimable_by_owner) == "table"
        and result.claimable_by_owner or {}
    result.migration = type(result.migration) == "table" and result.migration or {}
    for _, state in pairs(result.lineages) do
        if type(state) == "table" then ensureLineageDefaults(state) end
    end
    Registry.cached = result
    return result, "REGISTRY_READY"
end

local function snapshotEntry(registry, snapshotId)
    local entry = registry.entries[snapshotId]
    return type(entry) == "table" and entry or nil
end

local function tokenCount(registry, lineage, includeConsumed)
    local count = 0
    for _, token in pairs(registry.tokens) do
        if type(token) == "table" and token.lineage_id == lineage
            and token.valid ~= false
            and (includeConsumed == true or token.consumed ~= true) then
            count = count + 1
        end
    end
    return count
end

function Registry.Get()
    return rawRegistry()
end

function Registry.GameDay()
    return gameDay()
end

function Registry.OwnerKey(player)
    if not player then return nil, "PLAYER_MISSING" end
    local okSlot, slot = invoke(player, "getPlayerNum")
    slot = okSlot and tonumber(slot) or 0
    return worldIdentity() .. "|SLOT:" .. tostring(slot)
        .. "|" .. accountIdentity(player), "OWNER_KEY_READY"
end

function Registry.GetLineage(player, create)
    local registry, registryReason = rawRegistry()
    if not registry then return nil, registryReason end
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return nil, ownerReason end
    local lineage = registry.owner_lineages[ownerKey]
    local okData, playerData = invoke(player, "getModData")
    local playerLineage = okData and type(playerData) == "table"
        and playerData[Constants.LINEAGE_MODDATA_KEY] or nil
    if type(lineage) ~= "string" or lineage == "" then
        if type(playerLineage) == "string" and playerLineage ~= "" then
            lineage = playerLineage
        elseif create == true then
            lineage = generateId("lineage", ownerKey)
        end
        if lineage then registry.owner_lineages[ownerKey] = lineage end
    end
    if not lineage then return nil, "LINEAGE_NOT_FOUND" end
    registry.lineages[lineage] = registry.lineages[lineage] or {
        lineage_id = lineage,
        owner_key = ownerKey,
    }
    local state = ensureLineageDefaults(registry.lineages[lineage])
    if state.owner_key ~= ownerKey then return nil, "LINEAGE_OWNER_MISMATCH" end
    if okData and type(playerData) == "table"
        and playerData[Constants.LINEAGE_MODDATA_KEY] ~= lineage then
        playerData[Constants.LINEAGE_MODDATA_KEY] = lineage
    end
    transmit()
    return lineage, ownerKey
end

function Registry.MarkPurpleLineage(lineage)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local state = registry.lineages[lineage]
    if not state then return false, "LINEAGE_NOT_FOUND" end
    ensureLineageDefaults(state)
    state.purple_trait_lineage = true
    transmit()
    return true, "PURPLE_TRAIT_LINEAGE_MARKED"
end

function Registry.IsPurpleLineage(lineage)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local state = registry.lineages[lineage]
    if not state then return false, "LINEAGE_NOT_FOUND" end
    ensureLineageDefaults(state)
    local valid = state.purple_trait_lineage == true
        or state.starter_grant_done == true
        or tokenCount(registry, lineage, true) > 0
    return valid, valid and "PURPLE_LINEAGE_VALID"
        or "PURPLE_LINEAGE_NOT_ESTABLISHED"
end

function Registry.NewSnapshotId(ownerKey)
    return generateId("snapshot", ownerKey)
end

function Registry.NewTokenId(ownerKey)
    return generateId("token", ownerKey)
end

function Registry.GetEntry(snapshotId)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local entry = snapshotEntry(registry, snapshotId)
    return entry, entry and "ENTRY_FOUND" or "ENTRY_NOT_FOUND"
end

function Registry.GetLatest(lineage)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local state = registry.lineages[lineage]
    if not state or not state.latest_snapshot_id then return nil, "LATEST_NOT_FOUND" end
    return snapshotEntry(registry, state.latest_snapshot_id), state.latest_snapshot_id
end

function Registry.ValidateLatestActive(lineage)
    local entry, reason = Registry.GetLatest(lineage)
    if not entry then return false, reason, nil end
    local valid, checksumOrReason = Codec.ValidateSnapshot(entry.snapshot)
    if not valid then return false, checksumOrReason, entry end
    if entry.checksum ~= checksumOrReason then
        return false, "LATEST_SNAPSHOT_CHECKSUM_MISMATCH", entry
    end
    return true, "LATEST_ACTIVE_SNAPSHOT_VALID", entry
end

function Registry.CaptureLineageState(lineage)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local snapshot = {
        lineage = registry.lineages[lineage],
        entries = {},
        tokens = {},
        claimable_by_owner = {},
    }
    for id, entry in pairs(registry.entries) do
        if type(entry) == "table" and entry.lineage_id == lineage then
            snapshot.entries[id] = entry
        end
    end
    for id, token in pairs(registry.tokens) do
        if type(token) == "table" and token.lineage_id == lineage then
            snapshot.tokens[id] = token
        end
    end
    for ownerKey, claim in pairs(registry.claimable_by_owner) do
        if type(claim) == "table" and claim.lineage_id == lineage then
            snapshot.claimable_by_owner[ownerKey] = claim
        end
    end
    return Codec.CopySerializable(snapshot)
end

function Registry.RestoreLineageState(lineage, saved)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    if type(saved) ~= "table" then return false, "SAVED_LINEAGE_STATE_MISSING" end
    for id, entry in pairs(registry.entries) do
        if type(entry) == "table" and entry.lineage_id == lineage then
            registry.entries[id] = nil
        end
    end
    for id, token in pairs(registry.tokens) do
        if type(token) == "table" and token.lineage_id == lineage then
            registry.tokens[id] = nil
        end
    end
    for ownerKey, claim in pairs(registry.claimable_by_owner) do
        if type(claim) == "table" and claim.lineage_id == lineage then
            registry.claimable_by_owner[ownerKey] = nil
        end
    end
    local copied, copyReason = Codec.CopySerializable(saved)
    if not copied then return false, copyReason end
    registry.lineages[lineage] = ensureLineageDefaults(copied.lineage or {})
    for id, entry in pairs(copied.entries or {}) do registry.entries[id] = entry end
    for id, token in pairs(copied.tokens or {}) do registry.tokens[id] = token end
    for ownerKey, claim in pairs(copied.claimable_by_owner or {}) do
        registry.claimable_by_owner[ownerKey] = claim
    end
    transmit()
    return true, "LINEAGE_STATE_RESTORED"
end

function Registry.CommitActiveSnapshot(ownerKey, snapshot)
    local valid, checksumOrReason = Codec.ValidateSnapshot(snapshot)
    if not valid then return false, checksumOrReason end
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local state = registry.lineages[snapshot.lineage_id]
    if not state or state.owner_key ~= ownerKey then
        return false, "SNAPSHOT_LINEAGE_OWNER_MISMATCH"
    end
    if registry.entries[snapshot.snapshot_id] then
        return false, "IMMUTABLE_SNAPSHOT_ID_ALREADY_EXISTS"
    end
    local stored, copyReason = Codec.CopySerializable(snapshot)
    if not stored then return false, copyReason end
    stored.checksum = checksumOrReason
    registry.entries[stored.snapshot_id] = {
        snapshot_id = stored.snapshot_id,
        lineage_id = stored.lineage_id,
        owner_key = ownerKey,
        status = Constants.STATUS_ACTIVE,
        snapshot = stored,
        checksum = checksumOrReason,
        immutable = true,
    }
    state.latest_snapshot_id = stored.snapshot_id
    state.last_record_game_day = gameDay()
    transmit()
    return true, checksumOrReason
end

function Registry.PruneSuperseded()
    return true, "IMMUTABLE_SNAPSHOTS_RETAINED_FOR_BOUND_TOKENS"
end

function Registry.SetNextAutoRecordDay(lineage, dueDay)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local state = registry.lineages[lineage]
    if not state then return false, "LINEAGE_NOT_FOUND" end
    state.next_auto_record_day = tonumber(dueDay)
    transmit()
    return true, "AUTO_DUE_SET"
end

function Registry.GetNextAutoRecordDay(lineage)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local state = registry.lineages[lineage]
    if not state then return nil, "LINEAGE_NOT_FOUND" end
    return tonumber(state.next_auto_record_day), "AUTO_DUE_READ"
end

function Registry.GetRespawnMode(lineage)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local state = registry.lineages[lineage]
    if not state then return nil, "LINEAGE_NOT_FOUND" end
    ensureLineageDefaults(state)
    return state.respawn_mode_enabled == true, "RESPAWN_MODE_READ"
end

function Registry.SetRespawnMode(lineage, enabled)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local state = registry.lineages[lineage]
    if not state then return false, "LINEAGE_NOT_FOUND" end
    state.respawn_mode_enabled = enabled == true
    transmit()
    return true, state.respawn_mode_enabled and "GREEN" or "BLUE"
end

function Registry.StarterGrantDone(lineage)
    local registry = rawRegistry()
    local state = registry and registry.lineages[lineage] or nil
    return state and state.starter_grant_done == true or false
end

function Registry.MarkStarterGrantDone(lineage)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local state = registry.lineages[lineage]
    if not state then return false, "LINEAGE_NOT_FOUND" end
    state.starter_grant_done = true
    state.starter_grant_count = 1
    transmit()
    return true, "STARTER_GRANT_MARKED"
end

function Registry.CreateToken(lineage, snapshotId, issuedSource, tokenId, metadata)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local state = registry.lineages[lineage]
    local entry = snapshotEntry(registry, snapshotId)
    if not state then return nil, "LINEAGE_NOT_FOUND" end
    if not entry or entry.lineage_id ~= lineage then
        return nil, "TOKEN_SNAPSHOT_NOT_FOUND"
    end
    local allowed = {
        [Constants.ISSUED_STARTER] = true,
        [Constants.ISSUED_MANUAL] = true,
        [Constants.ISSUED_LEGACY] = true,
        [Constants.ISSUED_REHOME] = true,
        [Constants.ISSUED_DEATH_AUTO] = true,
    }
    if not allowed[issuedSource] then return nil, "TOKEN_ISSUED_SOURCE_INVALID" end
    tokenId = tokenId or Registry.NewTokenId(state.owner_key)
    if registry.tokens[tokenId] then return nil, "TOKEN_ID_ALREADY_EXISTS" end
    local token = {
        token_id = tokenId,
        lineage_id = lineage,
        snapshot_id = snapshotId,
        schema_version = Constants.TOKEN_SCHEMA,
        issued_source = issuedSource,
        consumed = false,
        valid = true,
        checksum = entry.checksum,
        created_game_time = gameDay(),
    }
    if issuedSource == Constants.ISSUED_DEATH_AUTO then
        metadata = type(metadata) == "table" and metadata or {}
        token.death_serial = tonumber(metadata.death_serial)
        token.snapshot_source = tostring(
            metadata.snapshot_source or Constants.SOURCE_DEATH_FALLBACK)
        token.delivery_pending = true
        token.delivered = false
    end
    registry.tokens[tokenId] = token
    state.token_ids[tokenId] = true
    transmit()
    return token, "TOKEN_CREATED"
end

function Registry.GetToken(tokenId)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local token = registry.tokens[tokenId]
    return token, type(token) == "table" and "TOKEN_FOUND" or "TOKEN_NOT_FOUND"
end

function Registry.ValidateToken(tokenId, lineage)
    local token, reason = Registry.GetToken(tokenId)
    if not token then return false, reason end
    if lineage and token.lineage_id ~= lineage then
        return false, "TOKEN_LINEAGE_MISMATCH", token
    end
    if token.valid == false then return false, "TOKEN_INVALID", token end
    if token.consumed == true then return false, "TOKEN_ALREADY_CONSUMED", token end
    if token.schema_version ~= Constants.TOKEN_SCHEMA then
        return false, "TOKEN_SCHEMA_MISMATCH", token
    end
    local entry, entryReason = Registry.GetEntry(token.snapshot_id)
    if not entry then return false, entryReason, token end
    local valid, checksum = Codec.ValidateSnapshot(entry.snapshot)
    if not valid then return false, checksum, token end
    if token.checksum ~= checksum or entry.checksum ~= checksum then
        return false, "TOKEN_SNAPSHOT_CHECKSUM_MISMATCH", token
    end
    return true, "TOKEN_VALID", token, entry
end

function Registry.ListValidTokens(lineage)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local result = {}
    for _, token in pairs(registry.tokens) do
        if type(token) == "table" and token.lineage_id == lineage
            and token.valid ~= false and token.consumed ~= true then
            result[#result + 1] = token
        end
    end
    table.sort(result, function(left, right)
        return tostring(left.token_id) < tostring(right.token_id)
    end)
    return result, "VALID_TOKENS_LISTED"
end

function Registry.CountValidTokens(lineage)
    local registry, reason = rawRegistry()
    if not registry then return 0, reason end
    return tokenCount(registry, lineage, false), "VALID_TOKEN_COUNT"
end

function Registry.RebindValidTokens(lineage, snapshotId)
    local registry, reason = rawRegistry()
    if not registry then return false, reason, 0 end
    local entry = snapshotEntry(registry, snapshotId)
    if not entry or entry.lineage_id ~= lineage then
        return false, "REBIND_SNAPSHOT_NOT_FOUND", 0
    end
    local count = 0
    for _, token in pairs(registry.tokens) do
        if type(token) == "table" and token.lineage_id == lineage
            and token.valid ~= false and token.consumed ~= true
            and token.issued_source ~= Constants.ISSUED_DEATH_AUTO then
            token.snapshot_id = snapshotId
            token.checksum = entry.checksum
            token.last_weekly_rebind_game_day = gameDay()
            count = count + 1
        end
    end
    transmit()
    return true, "VALID_TOKENS_REBOUND", count
end

function Registry.CaptureTokenState(tokenId)
    local token, reason = Registry.GetToken(tokenId)
    if not token then return nil, reason end
    return Codec.CopySerializable(token)
end

function Registry.RestoreTokenState(saved)
    if type(saved) ~= "table" or type(saved.token_id) ~= "string" then
        return false, "SAVED_TOKEN_INVALID"
    end
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local copied, copyReason = Codec.CopySerializable(saved)
    if not copied then return false, copyReason end
    registry.tokens[copied.token_id] = copied
    local state = registry.lineages[copied.lineage_id]
    if state then state.token_ids[copied.token_id] = true end
    transmit()
    return true, "TOKEN_STATE_RESTORED"
end

function Registry.MarkTokenConsumed(tokenId)
    local token, reason = Registry.GetToken(tokenId)
    if not token then return false, reason end
    if token.consumed == true then return false, "TOKEN_ALREADY_CONSUMED" end
    token.consumed = true
    token.consumed_game_time = gameDay()
    transmit()
    return true, "TOKEN_CONSUMED"
end

function Registry.InvalidateToken(tokenId, reason)
    local token, tokenReason = Registry.GetToken(tokenId)
    if not token then return false, tokenReason end
    token.valid = false
    token.invalid_reason = tostring(reason or "INVALIDATED")
    transmit()
    return true, "TOKEN_INVALIDATED"
end

function Registry.MarkDeath(player, snapshotId, snapshotSource)
    local lineage, ownerKey = Registry.GetLineage(player, false)
    if not lineage then return false, ownerKey end
    local registry = rawRegistry()
    local state = registry.lineages[lineage]
    ensureLineageDefaults(state)
    local purpleLineage, purpleReason = Registry.IsPurpleLineage(lineage)
    if not purpleLineage then return false, purpleReason end
    local entry = snapshotEntry(registry, snapshotId)
    if not entry or entry.lineage_id ~= lineage then
        return false, "DEATH_AUTO_SNAPSHOT_NOT_FOUND"
    end
    local snapshotValid, snapshotReason =
        Codec.ValidateSnapshot(entry.snapshot)
    if not snapshotValid then return false, snapshotReason end
    state.death_serial = state.death_serial + 1
    local deathSerial = state.death_serial
    state.last_death_serial = deathSerial
    local tokenId = "death-auto-" .. safeToken(lineage)
        .. "-" .. tostring(deathSerial)
    local token, tokenReason = Registry.CreateToken(
        lineage, snapshotId, Constants.ISSUED_DEATH_AUTO, tokenId, {
            death_serial = deathSerial,
            snapshot_source = snapshotSource,
        })
    if not token then return false, tokenReason, deathSerial end
    local claim = {
        lineage_id = lineage,
        owner_key = ownerKey,
        death_serial = deathSerial,
        token_id = token.token_id,
        snapshot_id = snapshotId,
        snapshot_source = tostring(snapshotSource),
        issued_source = Constants.ISSUED_DEATH_AUTO,
        eligible = true,
        claimed = false,
        delivered = false,
        delivery_pending = true,
        death_game_day = gameDay(),
        gated_by_phoenix = false,
    }
    state.death_claims[tostring(deathSerial)] = claim
    registry.claimable_by_owner[ownerKey] = claim
    transmit()
    return true, claim, deathSerial
end

function Registry.GetClaimable(player)
    local registry, reason = rawRegistry()
    if not registry then return nil, reason end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return nil, ownerKey end
    local claim = registry.claimable_by_owner[ownerKey]
    if type(claim) ~= "table" then return nil, "CLAIMABLE_NOT_FOUND" end
    if claim.lineage_id ~= lineage then return nil, "CLAIMABLE_OWNER_MISMATCH" end
    if claim.eligible ~= true or claim.claimed == true then
        return nil, claim.reason or "CLAIMABLE_STATUS_INVALID"
    end
    local tokenValid, tokenReason = Registry.ValidateToken(
        claim.token_id, lineage)
    if not tokenValid then return nil, tokenReason end
    return claim, ownerKey
end

function Registry.MarkDelivered(claim, ownerKey)
    if type(claim) ~= "table" or claim.owner_key ~= ownerKey then
        return false, "DELIVERY_CLAIM_OWNER_MISMATCH"
    end
    if claim.delivered == true then
        return true, "DEATH_AUTO_ALREADY_DELIVERED"
    end
    claim.delivered = true
    claim.delivery_pending = false
    claim.delivered_game_day = gameDay()
    local token = Registry.GetToken(claim.token_id)
    if token then
        token.delivered = true
        token.delivery_pending = false
        token.delivered_game_day = claim.delivered_game_day
    end
    local registry = rawRegistry()
    registry.claimable_by_owner[ownerKey] = claim
    transmit()
    return true, "DEATH_AUTO_DELIVERY_MARKED"
end

function Registry.MarkClaimed(claim, ownerKey, tokenId)
    if type(claim) ~= "table" or claim.owner_key ~= ownerKey then
        return false, "CLAIM_OWNER_MISMATCH"
    end
    if claim.claimed == true then return false, "ALREADY_CLAIMED" end
    claim.claimed = true
    claim.claimed_token_id = tokenId
    claim.claimed_game_day = gameDay()
    local registry = rawRegistry()
    registry.claimable_by_owner[ownerKey] = claim
    local state = registry.lineages[claim.lineage_id]
    if state and type(state.death_claims) == "table" then
        state.death_claims[tostring(claim.death_serial)] = claim
    end
    transmit()
    return true, "CLAIM_COMMITTED"
end

local function migrateCanonicalSnapshots(registry)
    if registry.migration[Constants.MIGRATION_MARKER] == true then
        return 0, "CANONICAL_MIGRATION_ALREADY_APPLIED"
    end
    local count = 0
    for snapshotId, entry in pairs(registry.entries) do
        if type(entry) == "table" and type(entry.snapshot) == "table" then
            local migrated, checksum = Codec.MigrateSnapshot(entry.snapshot)
            if migrated then
                entry.snapshot = migrated
                entry.checksum = checksum
                entry.snapshot_id = snapshotId
                entry.lineage_id = migrated.lineage_id
                entry.immutable = true
                count = count + 1
            else
                entry.migration_error = tostring(checksum)
            end
        end
    end
    for _, token in pairs(registry.tokens) do
        local entry = snapshotEntry(registry, token.snapshot_id)
        if type(token) == "table" and entry then token.checksum = entry.checksum end
    end
    registry.migration[Constants.MIGRATION_MARKER] = true
    registry.registry_version = Constants.REGISTRY_VERSION
    registry.migration_version = "0.5.60.7.20"
    Registry.canonicalMigrationCount = count
    transmit()
    return count, "CANONICAL_MIGRATION_APPLIED"
end

function Registry.RepairLegacyBlockedDeathClaims()
    local registry, reason = rawRegistry()
    if not registry then return false, reason, 0 end
    local marker = Constants.DEATH_GATE_REPAIR_MIGRATION
    if registry.migration[marker] == true then
        return true, "DEATH_GATE_REPAIR_ALREADY_APPLIED",
            tonumber(registry.migration[marker .. "_count"]) or 0
    end

    local repaired = 0
    for ownerKey, claim in pairs(registry.claimable_by_owner) do
        local blockedReason = type(claim) == "table"
            and tostring(claim.reason or "") or ""
        local repairable = type(claim) == "table"
            and claim.claimed ~= true
            and claim.eligible ~= true
            and (blockedReason == "RESPAWN_MODE_DISABLED"
                or blockedReason == "NO_VALID_TOKEN")
        if repairable then
            local lineage = claim.lineage_id
            local state = lineage and registry.lineages[lineage] or nil
            if state then
                ensureLineageDefaults(state)
                local valid, _, entry =
                    Registry.ValidateLatestActive(lineage)
                if valid and entry and entry.snapshot_id then
                    local deathSerial = tonumber(claim.death_serial)
                        or tonumber(state.last_death_serial)
                        or tonumber(state.death_serial)
                        or 1
                    state.death_serial = math.max(
                        tonumber(state.death_serial) or 0, deathSerial)
                    state.purple_trait_lineage = true
                    local tokenId = "death-auto-" .. safeToken(lineage)
                        .. "-" .. tostring(deathSerial)
                    local token = registry.tokens[tokenId]
                    if not token then
                        token = Registry.CreateToken(
                            lineage, entry.snapshot_id,
                            Constants.ISSUED_DEATH_AUTO, tokenId, {
                                death_serial = deathSerial,
                                snapshot_source =
                                    Constants.SOURCE_DEATH_FALLBACK,
                            })
                    end
                    if token then
                        local repairedClaim = {
                            lineage_id = lineage,
                            owner_key = ownerKey,
                            death_serial = deathSerial,
                            token_id = token.token_id,
                            snapshot_id = entry.snapshot_id,
                            snapshot_source =
                                Constants.SOURCE_DEATH_FALLBACK,
                            issued_source =
                                Constants.ISSUED_DEATH_AUTO,
                            eligible = true,
                            claimed = false,
                            delivered = false,
                            delivery_pending = true,
                            migrated_from_reason = blockedReason,
                            migration_key = marker,
                            gated_by_phoenix = false,
                        }
                        state.death_claims[tostring(deathSerial)] =
                            repairedClaim
                        registry.claimable_by_owner[ownerKey] =
                            repairedClaim
                        repaired = repaired + 1
                    end
                end
            end
        end
    end
    registry.migration[marker] = true
    registry.migration[marker .. "_count"] = repaired
    registry.migration[marker .. "_version"] = "0.5.60.7.23"
    Registry.deathGateRepairCount = repaired
    transmit()
    print("[XNP LIFE STOCK INHERITANCE MIGRATION] key=" .. marker
        .. " repaired_count=" .. tostring(repaired)
        .. " idempotent=true"
        .. " old_respawn_mode_no_longer_gates_death=true")
    return true, "DEATH_GATE_REPAIR_APPLIED", repaired
end

function Registry.InitializeMigration(player)
    local registry, reason = rawRegistry()
    if not registry then return false, reason end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return false, ownerKey end
    for key, value in pairs(registry.claimable_by_owner) do
        if type(value) == "string" then
            local entry = snapshotEntry(registry, value)
            local legacyLineage = entry and entry.lineage_id or lineage
            local legacySerial = entry and entry.death_serial or 1
            local legacyToken = nil
            if entry then
                local tokenId = "legacy-claim-" .. safeToken(legacyLineage)
                    .. "-" .. tostring(legacySerial)
                legacyToken = registry.tokens[tokenId]
                    or Registry.CreateToken(
                        legacyLineage, value,
                        Constants.ISSUED_LEGACY, tokenId)
            end
            registry.claimable_by_owner[key] = {
                lineage_id = legacyLineage,
                owner_key = key,
                death_serial = legacySerial,
                token_id = legacyToken and legacyToken.token_id or nil,
                snapshot_id = entry and value or nil,
                eligible = entry ~= nil and legacyToken ~= nil,
                claimed = entry and entry.claimed == true or false,
                reason = entry and nil or "LEGACY_CLAIM_ENTRY_MISSING",
                gated_by_phoenix = false,
            }
        end
    end
    local count, migrationReason = migrateCanonicalSnapshots(registry)
    local repaired, repairReason, repairCount =
        Registry.RepairLegacyBlockedDeathClaims()
    if not repaired then return false, repairReason, lineage end
    return true, migrationReason .. ":" .. tostring(count)
        .. "|" .. repairReason .. ":" .. tostring(repairCount), lineage
end

function Registry.GetAuditSnapshot()
    local registry, reason = rawRegistry()
    if not registry then return { ready = false, reason = reason } end
    local entryCount, validTokenCount, consumedTokenCount = 0, 0, 0
    local deathAutoTokenCount, pendingDeliveryCount = 0, 0
    local claimableCount, duplicateTokenCount = 0, 0
    local seen = {}
    for _ in pairs(registry.entries) do entryCount = entryCount + 1 end
    for tokenId, token in pairs(registry.tokens) do
        if seen[tokenId] then duplicateTokenCount = duplicateTokenCount + 1 end
        seen[tokenId] = true
        if type(token) == "table" and token.valid ~= false then
            if token.issued_source == Constants.ISSUED_DEATH_AUTO then
                deathAutoTokenCount = deathAutoTokenCount + 1
                if token.delivery_pending == true then
                    pendingDeliveryCount = pendingDeliveryCount + 1
                end
            end
            if token.consumed == true then
                consumedTokenCount = consumedTokenCount + 1
            else
                validTokenCount = validTokenCount + 1
            end
        end
    end
    for _, claim in pairs(registry.claimable_by_owner) do
        if type(claim) == "table" and claim.eligible == true
            and claim.claimed ~= true then claimableCount = claimableCount + 1 end
    end
    return {
        ready = true,
        registry_version = registry.registry_version,
        entry_count = entryCount,
        valid_token_count = validTokenCount,
        consumed_token_count = consumedTokenCount,
        claimable_count = claimableCount,
        duplicate_valid_token_count = duplicateTokenCount,
        canonical_migration_count = Registry.canonicalMigrationCount,
        death_gate_repair_count = Registry.deathGateRepairCount or
            tonumber(registry.migration[
                Constants.DEATH_GATE_REPAIR_MIGRATION .. "_count"]) or 0,
        death_auto_token_count = deathAutoTokenCount,
        death_auto_pending_delivery_count = pendingDeliveryCount,
        auto_regrant_count = 0,
        auto_recreate_count = 0,
    }
end

Core.PurpleLifeStockRegistry = Registry
return Registry
