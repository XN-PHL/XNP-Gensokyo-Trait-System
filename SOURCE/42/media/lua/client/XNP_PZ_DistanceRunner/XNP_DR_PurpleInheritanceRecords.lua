require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Codec"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Codec = Core.PurpleLifeStockCodec
local Registry = Core.PurpleLifeStockRegistry

local Records = {
    schema_version = 2,
    namespace = "XNP_PurpleInheritanceRecordLibraryV2",
    serial = 0,
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

local function gameDay()
    if Registry and type(Registry.GameDay) == "function" then
        local ok, value = pcall(Registry.GameDay)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return 0
end

local function transmit()
    if ModData and type(ModData.transmit) == "function" then
        pcall(ModData.transmit, Records.namespace)
    elseif GlobalModData and type(GlobalModData.transmit) == "function" then
        pcall(GlobalModData.transmit, Records.namespace)
    end
end

local function library()
    local result = nil
    if ModData and type(ModData.getOrCreate) == "function" then
        local ok, value = pcall(ModData.getOrCreate, Records.namespace)
        if ok then result = value end
    end
    if not result and GlobalModData and type(GlobalModData.getOrCreate) == "function" then
        local ok, value = pcall(GlobalModData.getOrCreate, Records.namespace)
        if ok then result = value end
    end
    if type(result) ~= "table" then return nil, "WORLD_MODDATA_UNAVAILABLE" end
    result.schema_version = Records.schema_version
    result.records_by_id = type(result.records_by_id) == "table" and result.records_by_id or {}
    result.ordered_record_ids = type(result.ordered_record_ids) == "table" and result.ordered_record_ids or {}
    result.legacy_migration = type(result.legacy_migration) == "table" and result.legacy_migration or {}
    result.last_selected_by_owner = type(result.last_selected_by_owner) == "table" and result.last_selected_by_owner or {}
    result.pending_delete_by_owner = type(result.pending_delete_by_owner) == "table" and result.pending_delete_by_owner or {}
    result.restore_transactions = type(result.restore_transactions) == "table" and result.restore_transactions or {}
    return result, "RECORD_LIBRARY_READY"
end

local function recordId(ownerKey)
    Records.serial = Records.serial + 1
    local prefix = tostring(ownerKey or "OWNER"):gsub("[^%w]", "_")
    return "record-v2-" .. tostring(nowMs()) .. "-" .. tostring(Records.serial) .. "-" .. prefix
end

local function listCopy(values)
    local result, seen = {}, {}
    for _, value in ipairs(values or {}) do
        local id = tostring(value or "")
        if id ~= "" and not seen[id] then seen[id] = true; result[#result + 1] = id end
    end
    table.sort(result)
    return result
end

local function perkMap(values)
    local result = {}
    for _, perk in ipairs(values or {}) do
        if type(perk) == "table" and tostring(perk.id or "") ~= "" then
            result[tostring(perk.id)] = tonumber(perk.xp) or 0
        end
    end
    return result
end

local function sourceName(snapshot)
    local identity = snapshot and snapshot.payload and snapshot.payload.identity or {}
    local first, last = tostring(identity.forename or ""), tostring(identity.surname or "")
    local name = (first .. " " .. last):gsub("^%s+", ""):gsub("%s+$", "")
    return name ~= "" and name or "Unknown"
end

local function contentDigest(payload)
    local checksum, reason = Codec.PayloadChecksum(payload)
    if not checksum then return nil, reason end
    return checksum, "CONTENT_DIGEST_READY"
end

local function validRecord(record)
    if type(record) ~= "table" or record.schema_version ~= Records.schema_version then
        return false, "RECORD_SCHEMA_INVALID"
    end
    if type(record.record_id) ~= "string" or record.record_id == "" then
        return false, "RECORD_ID_INVALID"
    end
    if type(record.snapshot_payload) ~= "table" then return false, "RECORD_PAYLOAD_INVALID" end
    local digest, reason = contentDigest(record.snapshot_payload)
    if not digest then return false, reason end
    if digest ~= record.content_sha256 then return false, "RECORD_CONTENT_DIGEST_MISMATCH" end
    return true, "RECORD_VALID"
end

local function ownedBy(record, ownerKey)
    return type(record) == "table" and tostring(record.owner_key or "")
        == tostring(ownerKey or "")
end

local function orderedRemove(values, id)
    for index = #values, 1, -1 do
        if values[index] == id then table.remove(values, index) end
    end
end

function Records.CreateFromSnapshot(player, snapshot, source)
    local lib, reason = library()
    if not lib then return nil, reason end
    if type(snapshot) ~= "table" or type(snapshot.payload) ~= "table" then
        return nil, "SNAPSHOT_INVALID"
    end
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return nil, ownerReason end
    local copied, copyReason = Codec.CopySerializable(snapshot.payload)
    if not copied then return nil, copyReason end
    local normalized, normalizeReason = Codec.NormalizePayload(copied)
    if not normalized then return nil, normalizeReason end
    local digest, digestReason = contentDigest(normalized)
    if not digest then return nil, digestReason end
    local id = recordId(ownerKey)
    while lib.records_by_id[id] do id = recordId(ownerKey) end
    local identity = normalized.identity or {}
    local sequence = #lib.ordered_record_ids + 1
    local displayName = sourceName(snapshot) .. " | "
        .. tostring(identity.profession_display or identity.profession_id or "Unknown")
        .. " | #" .. tostring(sequence) .. " | day " .. string.format("%.2f", gameDay())
    local record = {
        schema_version = Records.schema_version,
        record_id = id,
        display_name = displayName,
        source_character_name = sourceName(snapshot),
        source_character_identity = tostring(snapshot.lineage_id or ownerKey),
        owner_key = ownerKey,
        source_profession_id = tostring(identity.profession_id or ""),
        created_real_ms = nowMs(),
        created_world_age = gameDay(),
        traits_canonical = listCopy(normalized.trait_state and normalized.trait_state.actual_traits or normalized.traits),
        perks_total_xp = perkMap(normalized.perks),
        snapshot_payload = normalized,
        source_snapshot_id = tostring(snapshot.snapshot_id or ""),
        source = tostring(source or snapshot.source or "UNKNOWN"),
        content_sha256 = digest,
    }
    lib.records_by_id[id] = record
    lib.ordered_record_ids[#lib.ordered_record_ids + 1] = id
    lib.last_selected_by_owner[ownerKey] = id
    transmit()
    print("[XNP PURPLE RECORD] action=CREATE record_id=" .. id
        .. " display_name=" .. record.display_name
        .. " content_sha256=" .. record.content_sha256)
    return record, "RECORD_CREATED"
end

function Records.MigrateLegacy(player)
    local lib, reason = library()
    if not lib then return false, reason, 0 end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return false, ownerKey, 0 end
    if lib.legacy_migration[ownerKey] then return true, "LEGACY_ALREADY_MIGRATED", 0 end
    local entry = Registry.GetLatest(lineage)
    if not entry or not entry.snapshot then
        lib.legacy_migration[ownerKey] = "NO_LEGACY_SNAPSHOT"
        transmit()
        return true, "NO_LEGACY_SNAPSHOT", 0
    end
    for _, existingId in ipairs(lib.ordered_record_ids) do
        local existing = lib.records_by_id[existingId]
        if ownedBy(existing, ownerKey)
            and tostring(existing.source_snapshot_id or "")
                == tostring(entry.snapshot.snapshot_id or "")
            and validRecord(existing) then
            lib.legacy_migration[ownerKey] = existing.record_id
            transmit()
            return true, "LEGACY_ALREADY_REPRESENTED", 0
        end
    end
    local record, recordReason = Records.CreateFromSnapshot(player, entry.snapshot, "LEGACY_SINGLE_SLOT")
    if not record then return false, recordReason, 0 end
    lib.legacy_migration[ownerKey] = record.record_id
    transmit()
    return true, "LEGACY_MIGRATED", 1
end

function Records.Get(recordIdValue)
    local lib, reason = library()
    if not lib then return nil, reason end
    local record = lib.records_by_id[tostring(recordIdValue or "")]
    local valid, validReason = validRecord(record)
    return valid and record or nil, valid and "RECORD_FOUND" or validReason
end

function Records.ListValid(player)
    local lib, reason = library()
    if not lib then return nil, reason end
    local ownerKey = nil
    if player then
        local resolvedOwner, ownerReason = Registry.OwnerKey(player)
        if not resolvedOwner then return nil, ownerReason end
        ownerKey = resolvedOwner
    end
    local result = {}
    for _, id in ipairs(lib.ordered_record_ids) do
        local record = lib.records_by_id[id]
        if validRecord(record) and (not ownerKey or ownedBy(record, ownerKey)) then
            result[#result + 1] = record
        end
    end
    return result, "VALID_RECORDS_LISTED"
end

function Records.Select(player, recordIdValue, method)
    local record, reason = Records.Get(recordIdValue)
    if not record then return false, reason end
    local lib = library()
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return false, ownerReason end
    if not ownedBy(record, ownerKey) then return false, "RECORD_OWNER_MISMATCH" end
    lib.last_selected_by_owner[ownerKey] = record.record_id
    transmit()
    print("[XNP PURPLE RECORD] action=SELECT candidate_record_ids=" .. record.record_id
        .. " selected_record_id=" .. record.record_id
        .. " selected_display_name=" .. record.display_name
        .. " selection_method=" .. tostring(method or "DIRECT")
        .. " content_sha256=" .. record.content_sha256)
    return true, record.record_id
end

function Records.SelectRandom(player)
    local records, reason = Records.ListValid(player)
    if not records or #records == 0 then return false, reason or "NO_VALID_RECORDS" end
    local index = nil
    if type(ZombRand) == "function" then
        local ok, value = pcall(ZombRand, #records)
        if ok and tonumber(value) then index = tonumber(value) + 1 end
    end
    index = index or math.random(1, #records)
    return Records.Select(player, records[index].record_id, "RANDOM")
end

function Records.ResolveForRestore(player, snapshotId)
    local lib, reason = library()
    if not lib then return nil, reason end
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return nil, ownerReason end
    local selected = lib.last_selected_by_owner[ownerKey]
    local record = selected and lib.records_by_id[selected] or nil
    if record and ownedBy(record, ownerKey) and validRecord(record) then
        return record, "SELECTED_RECORD"
    end
    for _, id in ipairs(lib.ordered_record_ids) do
        local candidate = lib.records_by_id[id]
        if candidate and ownedBy(candidate, ownerKey)
            and candidate.source_snapshot_id == tostring(snapshotId or "")
            and validRecord(candidate) then
            lib.last_selected_by_owner[ownerKey] = candidate.record_id
            transmit()
            return candidate, "TOKEN_RECORD_FALLBACK"
        end
    end
    return nil, "NO_VALID_SELECTED_RECORD"
end

function Records.RequestDelete(player, recordIdValue)
    local record, reason = Records.Get(recordIdValue)
    if not record then return false, reason end
    local lib = library()
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return false, ownerReason end
    if not ownedBy(record, ownerKey) then return false, "RECORD_OWNER_MISMATCH" end
    lib.pending_delete_by_owner[ownerKey] = record.record_id
    transmit()
    return true, "DELETE_CONFIRM_REQUIRED"
end

function Records.ConfirmDelete(player, recordIdValue)
    local lib, reason = library()
    if not lib then return false, reason end
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return false, ownerReason end
    local id = tostring(recordIdValue or "")
    if lib.pending_delete_by_owner[ownerKey] ~= id then return false, "DELETE_CONFIRMATION_MISMATCH" end
    local record = lib.records_by_id[id]
    if not record then return false, "RECORD_NOT_FOUND" end
    if not ownedBy(record, ownerKey) then return false, "RECORD_OWNER_MISMATCH" end
    lib.records_by_id[id] = nil
    orderedRemove(lib.ordered_record_ids, id)
    if lib.last_selected_by_owner[ownerKey] == id then lib.last_selected_by_owner[ownerKey] = nil end
    lib.pending_delete_by_owner[ownerKey] = nil
    transmit()
    print("[XNP PURPLE RECORD] action=DELETE record_id=" .. id .. " confirmed=true")
    return true, "RECORD_DELETED"
end

function Records.IsDeletePending(player, recordIdValue)
    local lib, reason = library()
    if not lib then return false, reason end
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return false, ownerReason end
    return lib.pending_delete_by_owner[ownerKey] == tostring(recordIdValue or ""), "DELETE_PENDING_READ"
end

function Records.Rename(player, recordIdValue, displayName)
    local record, reason = Records.Get(recordIdValue)
    if not record then return false, reason end
    local ownerKey, ownerReason = Registry.OwnerKey(player)
    if not ownerKey then return false, ownerReason end
    if not ownedBy(record, ownerKey) then return false, "RECORD_OWNER_MISMATCH" end
    local normalized = tostring(displayName or ""):gsub("[\r\n]", " ")
    if normalized == "" or #normalized > 96 then return false, "DISPLAY_NAME_INVALID" end
    record.display_name = normalized
    transmit()
    print("[XNP PURPLE RECORD] action=RENAME record_id=" .. record.record_id
        .. " display_name=" .. record.display_name)
    return true, "RECORD_RENAMED"
end

function Records.BeginRestore(record, tokenId)
    local lib, reason = library()
    if not lib then return nil, reason end
    local transactionId = "restore-v2:" .. tostring(tokenId) .. ":" .. tostring(record.record_id)
    local existing = lib.restore_transactions[transactionId]
    if existing and existing.status == "COMMITTED" then return nil, "RESTORE_TRANSACTION_ALREADY_COMMITTED" end
    lib.restore_transactions[transactionId] = {
        transaction_id = transactionId, record_id = record.record_id,
        token_id = tostring(tokenId), status = "ACTIVE", created_real_ms = nowMs(),
    }
    transmit()
    return transactionId, "RESTORE_TRANSACTION_STARTED"
end

function Records.CompleteRestore(transactionId)
    local lib, reason = library()
    if not lib then return false, reason end
    local tx = lib.restore_transactions[transactionId]
    if not tx then return false, "RESTORE_TRANSACTION_MISSING" end
    tx.status = "COMMITTED"
    tx.completed_real_ms = nowMs()
    transmit()
    return true, "RESTORE_TRANSACTION_COMMITTED"
end

function Records.AbortRestore(transactionId)
    local lib = library()
    if lib and lib.restore_transactions[transactionId] then
        lib.restore_transactions[transactionId] = nil
        transmit()
    end
    return true, "RESTORE_TRANSACTION_ABORTED"
end

function Records.GetAuditSnapshot()
    local records = Records.ListValid() or {}
    return { schema_version = Records.schema_version, valid_record_count = #records }
end

Core.PurpleInheritanceRecords = Records
return Records
