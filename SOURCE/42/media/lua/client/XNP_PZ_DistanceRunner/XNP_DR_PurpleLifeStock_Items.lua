local XNPChannelGuard = require "XNP_PZ_DistanceRunner/XNP_DR_ChannelGuard"
if type(XNPChannelGuard) == "table"
    and type(XNPChannelGuard.allowRuntime) == "function"
    and not XNPChannelGuard.allowRuntime() then
    return
end

require "ISUI/ISInventoryPane"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleInheritanceRecords"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Registry = Core.PurpleLifeStockRegistry
local Records = Core.PurpleInheritanceRecords

local Items = {
    doubleClickInstalled = false,
    contextMenuInstalled = false,
    originalContextualDoubleClick = nil,
    originalMouseDoubleClick = nil,
    contextualDoubleClickWrapper = nil,
    mouseDoubleClickWrapper = nil,
    legacyMigrationCount = 0,
    autoRegrantCount = 0,
    autoRecreateCount = 0,
}

local function safeToken(value)
    local token = tostring(value or "UNKNOWN")
    token = string.gsub(token, "[^%w_%-]", "_")
    return token
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function inventoryOf(player)
    local ok, inventory = invoke(player, "getInventory")
    if not ok or not inventory then return nil, "INVENTORY_UNAVAILABLE" end
    return inventory, "INVENTORY_READY"
end

local function itemType(item)
    local ok, value = invoke(item, "getFullType")
    return ok and tostring(value or "") or ""
end

local function itemData(item)
    local ok, data = invoke(item, "getModData")
    if not ok or type(data) ~= "table" then
        return nil, "ITEM_MODDATA_UNAVAILABLE"
    end
    return data, "ITEM_MODDATA_READY"
end

local function playerByIndex(playerIndex)
    if type(playerIndex) == "table" or type(playerIndex) == "userdata" then
        return playerIndex
    end
    if type(getSpecificPlayer) == "function" then
        local ok, player = pcall(getSpecificPlayer, tonumber(playerIndex) or 0)
        if ok then return player end
    end
    return nil
end

local function inventoryItems(inventory)
    local okItems, collection = invoke(inventory, "getItems")
    if not okItems or not collection then
        return nil, "INVENTORY_ITEMS_UNAVAILABLE"
    end
    local okSize, size = invoke(collection, "size")
    size = okSize and tonumber(size) or nil
    if not size then return nil, "INVENTORY_SIZE_UNAVAILABLE" end
    local result = {}
    for index = 0, size - 1 do
        local okItem, item = invoke(collection, "get", index)
        if okItem and item then result[#result + 1] = item end
    end
    return result, "INVENTORY_ITEMS_READY"
end

local function containerOf(item)
    local ok, container = invoke(item, "getContainer")
    return ok and container or nil
end

local function containsExact(container, item)
    if not container or not item then return false end
    local okContains, contained = invoke(container, "contains", item)
    if okContains and contained == true then return true end
    return containerOf(item) == container
end

local function addToContainer(container, fullType)
    if not container then return nil, "TARGET_CONTAINER_MISSING" end
    local okAdd, item = invoke(container, "AddItem", fullType)
    if not okAdd or not item then return nil, "ITEM_CREATE_FAILED" end
    if not containsExact(container, item) then
        invoke(item, "Remove")
        return nil, "ITEM_INSERT_READBACK_FAILED"
    end
    return item, "ITEM_CREATED"
end

local function markInvalid(item, reason)
    local data = itemData(item)
    if data then
        data[Constants.ITEM_VALID_KEY] = false
        data[Constants.ITEM_INVALID_REASON_KEY] = tostring(reason or "INVALID")
        data[Constants.ITEM_MIGRATION_KEY] = true
    end
    if item and type(item.setName) == "function" then
        local name = "Invalid Legacy Extra Life"
        if type(getText) == "function" then
            local ok, value = pcall(getText, "ItemName_XNPPurpleLegacyInvalid")
            if ok and value and value ~= "ItemName_XNPPurpleLegacyInvalid" then
                name = value
            end
        end
        pcall(function() item:setName(name) end)
    end
    return false, "LEGACY_ITEM_INVALID:" .. tostring(reason)
end

function Items.ItemType(item)
    return itemType(item)
end

function Items.InventoryOf(player)
    return inventoryOf(player)
end

function Items.IsExactInMainInventory(player, item)
    local inventory = inventoryOf(player)
    return inventory ~= nil and containsExact(inventory, item)
end

function Items.IsExactAccessible(player, item)
    if not player or not item then return false, "ACCESS_INPUT_INVALID" end
    local container = containerOf(item)
    if not container or not containsExact(container, item) then
        return false, "EXACT_ITEM_CONTAINER_MISSING"
    end
    local main = inventoryOf(player)
    if main and containsExact(main, item) then return true, "MAIN_INVENTORY" end
    if main and type(main.containsRecursive) == "function" then
        local ok, contained = invoke(main, "containsRecursive", item)
        if ok and contained == true then return true, "NESTED_PLAYER_INVENTORY" end
    end
    -- The exact object can also be selected from an open world/vehicle/corpse
    -- inventory pane. A non-nil owning container is the fail-closed boundary.
    return true, "OPEN_ACCESSIBLE_CONTAINER"
end

function Items.RemoveExact(container, item)
    container = container or containerOf(item)
    if not container or not item then return false, "REMOVE_INPUT_INVALID" end
    if not containsExact(container, item) then
        return false, "EXACT_ITEM_NOT_IN_CONTAINER"
    end
    local okRemove = invoke(item, "Remove")
    if not okRemove or containsExact(container, item) then
        local okFallback = invoke(container, "Remove", item)
        if not okFallback or containsExact(container, item) then
            return false, "EXACT_ITEM_REMOVE_READBACK_FAILED"
        end
    end
    return true, "EXACT_ITEM_REMOVED"
end

function Items.FindByType(player, fullType)
    local inventory, reason = inventoryOf(player)
    if not inventory then return nil, reason end
    local contents, contentsReason = inventoryItems(inventory)
    if not contents then return nil, contentsReason end
    local result = {}
    for _, item in ipairs(contents) do
        if itemType(item) == fullType then result[#result + 1] = item end
    end
    return result, inventory
end

function Items.ReadBackupMetadata(item)
    if itemType(item) ~= Constants.BACKUP_ITEM then return nil, "NOT_BACKUP_ITEM" end
    local data, reason = itemData(item)
    if not data then return nil, reason end
    if data[Constants.ITEM_VALID_KEY] == false then
        return nil, "BACKUP_MARKED_INVALID:"
            .. tostring(data[Constants.ITEM_INVALID_REASON_KEY] or "UNKNOWN")
    end
    local metadata = {
        token_id = data[Constants.ITEM_TOKEN_ID_KEY],
        snapshot_id = data[Constants.ITEM_SNAPSHOT_ID_KEY],
        schema_version = data[Constants.ITEM_SCHEMA_KEY],
        lineage_id = data[Constants.ITEM_LINEAGE_KEY],
        created_game_time = data[Constants.ITEM_CREATED_GAME_TIME_KEY],
        issued_source = data[Constants.ITEM_ISSUED_SOURCE_KEY],
        checksum = data[Constants.ITEM_CHECKSUM_KEY],
        consumed = data[Constants.ITEM_CONSUMED_KEY] == true,
        valid = data[Constants.ITEM_VALID_KEY] ~= false,
    }
    if type(metadata.token_id) ~= "string" or metadata.token_id == "" then
        return nil, "BACKUP_TOKEN_ID_MISSING"
    end
    if metadata.schema_version ~= Constants.TOKEN_SCHEMA then
        return nil, "BACKUP_TOKEN_SCHEMA_MISMATCH"
    end
    if type(metadata.lineage_id) ~= "string" or metadata.lineage_id == "" then
        return nil, "BACKUP_LINEAGE_MISSING"
    end
    if type(metadata.snapshot_id) ~= "string" or metadata.snapshot_id == "" then
        return nil, "BACKUP_SNAPSHOT_ID_MISSING"
    end
    if type(metadata.checksum) ~= "string" or metadata.checksum == "" then
        return nil, "BACKUP_CHECKSUM_MISSING"
    end
    if metadata.consumed then return nil, "BACKUP_ITEM_ALREADY_CONSUMED" end
    return metadata, "BACKUP_METADATA_VALID"
end

function Items.WriteTokenMetadata(item, token)
    if not item or type(token) ~= "table" then
        return false, "WRITE_TOKEN_INPUT_INVALID"
    end
    local entry, entryReason = Registry.GetEntry(token.snapshot_id)
    if not entry or not entry.snapshot then return false, entryReason end
    local data, reason = itemData(item)
    if not data then return false, reason end
    data[Constants.ITEM_TOKEN_ID_KEY] = token.token_id
    data[Constants.ITEM_SNAPSHOT_ID_KEY] = token.snapshot_id
    data[Constants.ITEM_SCHEMA_KEY] = Constants.TOKEN_SCHEMA
    data[Constants.ITEM_LINEAGE_KEY] = token.lineage_id
    data[Constants.ITEM_CREATED_GAME_TIME_KEY] = token.created_game_time
    data[Constants.ITEM_SOURCE_KEY] = entry.snapshot.source
    data[Constants.ITEM_ISSUED_SOURCE_KEY] = token.issued_source
    data[Constants.ITEM_CHECKSUM_KEY] = token.checksum
    data[Constants.ITEM_CONSUMED_KEY] = token.consumed == true
    data[Constants.ITEM_VALID_KEY] = token.valid ~= false
    data[Constants.ITEM_MIGRATION_KEY] = true
    data[Constants.ITEM_INVALID_REASON_KEY] = nil
    local readback, readbackReason = Items.ReadBackupMetadata(item)
    if not readback then return false, readbackReason end
    if readback.token_id ~= token.token_id
        or readback.snapshot_id ~= token.snapshot_id
        or readback.checksum ~= token.checksum then
        return false, "BACKUP_METADATA_READBACK_MISMATCH"
    end
    return true, "BACKUP_METADATA_WRITTEN"
end

function Items.WriteBackupMetadata(item, snapshot)
    if type(snapshot) ~= "table" then return false, "SNAPSHOT_MISSING" end
    local tokenId = "legacy-" .. tostring(snapshot.lineage_id) .. "-"
        .. tostring(snapshot.snapshot_id)
    local token = Registry.GetToken(tokenId)
    if not token then
        token = Registry.CreateToken(snapshot.lineage_id, snapshot.snapshot_id,
            Constants.ISSUED_LEGACY, tokenId)
    end
    if not token then return false, "LEGACY_TOKEN_CREATE_FAILED" end
    return Items.WriteTokenMetadata(item, token)
end

function Items.CreateBackupForToken(player, token, targetContainer)
    local valid, reason, validatedToken = Registry.ValidateToken(
        token and token.token_id or nil, token and token.lineage_id or nil)
    if not valid then return nil, reason end
    local container = targetContainer or inventoryOf(player)
    if not container then return nil, "TARGET_CONTAINER_UNAVAILABLE" end
    local item, createReason = addToContainer(container, Constants.BACKUP_ITEM)
    if not item then return nil, createReason end
    local written, writeReason = Items.WriteTokenMetadata(item, validatedToken)
    if not written then
        Items.RemoveExact(container, item)
        return nil, writeReason
    end
    return item, "BACKUP_ITEM_CREATED_FOR_TOKEN"
end

function Items.CreateBackup(player, snapshot)
    local issued = snapshot and snapshot.source == Constants.SOURCE_INITIAL
        and Constants.ISSUED_STARTER or Constants.ISSUED_MANUAL
    local token, reason = Registry.CreateToken(snapshot.lineage_id,
        snapshot.snapshot_id, issued)
    if not token then return nil, reason end
    local item, itemReason = Items.CreateBackupForToken(player, token)
    if not item then
        Registry.InvalidateToken(token.token_id, itemReason)
        return nil, itemReason
    end
    return item, "BACKUP_ITEM_AND_TOKEN_CREATED"
end

function Items.FindBackupsForLineage(player, lineage)
    local backups, inventory = Items.FindByType(player, Constants.BACKUP_ITEM)
    if not backups then return nil, inventory end
    local result = {}
    for _, item in ipairs(backups) do
        local metadata = Items.ReadBackupMetadata(item)
        if metadata and metadata.lineage_id == lineage then
            result[#result + 1] = { item = item, metadata = metadata }
        end
    end
    return result, inventory
end

function Items.FindBackupBySnapshot(player, snapshotId)
    local backups, inventory = Items.FindByType(player, Constants.BACKUP_ITEM)
    if not backups then return nil, inventory end
    for _, item in ipairs(backups) do
        local metadata = Items.ReadBackupMetadata(item)
        if metadata and metadata.snapshot_id == snapshotId then
            return item, metadata, inventory
        end
    end
    return nil, "BACKUP_NOT_FOUND", inventory
end

function Items.FindBackupByToken(player, tokenId)
    local backups, inventory = Items.FindByType(player, Constants.BACKUP_ITEM)
    if not backups then return nil, inventory end
    for _, item in ipairs(backups) do
        local metadata = Items.ReadBackupMetadata(item)
        if metadata and metadata.token_id == tokenId then
            return item, metadata, inventory
        end
    end
    return nil, "BACKUP_TOKEN_NOT_IN_MAIN_INVENTORY", inventory
end

function Items.EnsureRecorder()
    return false, "PUBLIC_RECORDER_DISABLED_NO_AUTO_GRANT"
end

function Items.DeliverClaimable()
    return false, "NO_AUTO_DELIVERY_EXISTING_TOKEN_REMAINS_IN_WORLD", 0
end

function Items.RestoreBackupCopy(player, metadata)
    local token = metadata and Registry.GetToken(metadata.token_id) or nil
    if not token then return nil, "RESTORE_TOKEN_MISSING" end
    return Items.CreateBackupForToken(player, token)
end

function Items.RehomeExistingToken(player, item)
    local valid, reason, metadata, token = Items.ValidateItemToken(player, item)
    if not valid then return false, reason end
    local target, targetReason = inventoryOf(player)
    if not target then return false, targetReason end
    local source = containerOf(item)
    if not source then return false, "REHOME_SOURCE_CONTAINER_MISSING" end
    if containsExact(target, item) then
        return true, "REHOME_NOT_NEEDED_ALREADY_IN_MAIN", item
    end

    local beforeCount = Registry.CountValidTokens(metadata.lineage_id)
    local okMove = invoke(target, "AddItem", item)
    if okMove and containsExact(target, item) and not containsExact(source, item) then
        local afterCount = Registry.CountValidTokens(metadata.lineage_id)
        if afterCount ~= beforeCount then
            return false, "REHOME_TOKEN_COUNT_CHANGED"
        end
        print("[XNP PURPLE TOKEN REHOME] result=SUCCESS method=EXACT_OBJECT_MOVE"
            .. " token_id=" .. tostring(metadata.token_id)
            .. " valid_token_count_before=" .. tostring(beforeCount)
            .. " valid_token_count_after=" .. tostring(afterCount)
            .. " duplicate_valid_token_count=0")
        return true, "EXACT_TOKEN_OBJECT_REHOMED", item
    end

    -- Build 42 containers do not all accept an existing InventoryItem object.
    -- In that case the old representation is invalidated before one replacement
    -- is bound to the same registry token. No token is created or copied.
    local invalidated, invalidReason = markInvalid(
        item, "REHOMED_TO_SUCCESSOR_SAME_TOKEN")
    local replacement, createReason = Items.CreateBackupForToken(
        player, token, target)
    if not replacement then
        Items.WriteTokenMetadata(item, token)
        return false, createReason or invalidReason
    end
    if containsExact(source, item) then
        Items.RemoveExact(source, item)
    end
    local afterCount = Registry.CountValidTokens(metadata.lineage_id)
    if afterCount ~= beforeCount then
        Items.RemoveExact(target, replacement)
        Items.WriteTokenMetadata(item, token)
        return false, "REHOME_TOKEN_COUNT_CHANGED"
    end
    print("[XNP PURPLE TOKEN REHOME] result=SUCCESS"
        .. " method=SAME_TOKEN_REPRESENTATION_REBUILD"
        .. " token_id=" .. tostring(metadata.token_id)
        .. " old_representation_invalidated=" .. tostring(invalidated == false)
        .. " valid_token_count_before=" .. tostring(beforeCount)
        .. " valid_token_count_after=" .. tostring(afterCount)
        .. " duplicate_valid_token_count=0")
    return true, "SAME_TOKEN_REPRESENTATION_REHOMED", replacement
end

function Items.ValidateItemToken(player, item)
    local accessible, accessReason = Items.IsExactAccessible(player, item)
    if not accessible then return false, accessReason end
    local metadata, metadataReason = Items.ReadBackupMetadata(item)
    if not metadata then return false, metadataReason end
    local valid, validReason, token, entry = Registry.ValidateToken(
        metadata.token_id, metadata.lineage_id)
    if not valid then return false, validReason end
    if metadata.snapshot_id ~= token.snapshot_id
        or metadata.checksum ~= token.checksum then
        local synced, syncReason = Items.WriteTokenMetadata(item, token)
        if not synced then return false, syncReason end
        metadata = Items.ReadBackupMetadata(item)
    end
    return true, "ITEM_TOKEN_VALID", metadata, token, entry
end

local function deterministicLegacyToken(lineage, snapshotId)
    return "legacy-" .. safeToken(lineage) .. "-" .. safeToken(snapshotId)
end

function Items.MigrateLegacyItem(player, item)
    local fullType = itemType(item)
    if fullType ~= Constants.RECORDER_ITEM and fullType ~= Constants.BACKUP_ITEM then
        return false, "NOT_LEGACY_PURPLE_ITEM"
    end
    local data, dataReason = itemData(item)
    if not data then return false, dataReason end
    if fullType == Constants.BACKUP_ITEM
        and type(data[Constants.ITEM_TOKEN_ID_KEY]) == "string" then
        local token = Registry.GetToken(data[Constants.ITEM_TOKEN_ID_KEY])
        if not token then return markInvalid(item, "TOKEN_NOT_FOUND") end
        local written, reason = Items.WriteTokenMetadata(item, token)
        return written, written and "ITEM_ALREADY_MIGRATED_SYNCED" or reason
    end
    if data[Constants.ITEM_MIGRATION_KEY] == true
        and data[Constants.ITEM_VALID_KEY] == false then
        return false, "LEGACY_ITEM_ALREADY_MARKED_INVALID"
    end
    local lineage, ownerKey = Registry.GetLineage(player, true)
    if not lineage then return markInvalid(item, ownerKey) end
    local snapshotId = data[Constants.ITEM_SNAPSHOT_ID_KEY]
    local entry = snapshotId and Registry.GetEntry(snapshotId) or nil
    if not entry then
        entry, snapshotId = Registry.GetLatest(lineage)
    end
    if not entry or entry.lineage_id ~= lineage then
        return markInvalid(item, "SAFE_SNAPSHOT_BINDING_UNAVAILABLE")
    end
    local tokenId = deterministicLegacyToken(lineage, snapshotId)
    local token = Registry.GetToken(tokenId)
    if not token then
        token = Registry.CreateToken(lineage, snapshotId,
            Constants.ISSUED_LEGACY, tokenId)
    end
    if not token then return markInvalid(item, "LEGACY_TOKEN_CREATE_FAILED") end
    if fullType == Constants.BACKUP_ITEM then
        local written, reason = Items.WriteTokenMetadata(item, token)
        if written then Items.legacyMigrationCount = Items.legacyMigrationCount + 1 end
        return written, reason
    end
    local container = containerOf(item)
    if not container then return markInvalid(item, "LEGACY_RECORDER_CONTAINER_MISSING") end
    local replacement, createReason = Items.CreateBackupForToken(
        player, token, container)
    if not replacement then return markInvalid(item, createReason) end
    local removed, removeReason = Items.RemoveExact(container, item)
    if not removed then
        Items.RemoveExact(container, replacement)
        Registry.InvalidateToken(token.token_id, "LEGACY_REPLACEMENT_ROLLBACK")
        return markInvalid(item, removeReason)
    end
    Items.legacyMigrationCount = Items.legacyMigrationCount + 1
    print("[XNP PURPLE LEGACY MIGRATION] result=SUCCESS one_to_one=true"
        .. " token_id=" .. tostring(token.token_id)
        .. " source=LEGACY_MIGRATION")
    return true, "LEGACY_RECORDER_REPLACED_ONE_TO_ONE"
end

function Items.MigrateVisibleLegacyItems(player)
    local migrated = 0
    for _, fullType in ipairs({ Constants.RECORDER_ITEM, Constants.BACKUP_ITEM }) do
        local list = Items.FindByType(player, fullType)
        for _, item in ipairs(list or {}) do
            local ok, reason = Items.MigrateLegacyItem(player, item)
            if ok and reason ~= "ITEM_ALREADY_MIGRATED_SYNCED" then
                migrated = migrated + 1
            end
        end
    end
    return true, "VISIBLE_LEGACY_MIGRATION_COMPLETE", migrated
end

local function isSupportedType(fullType)
    return fullType == Constants.RECORDER_ITEM or fullType == Constants.BACKUP_ITEM
end

local function inputLog(route, fullType, playerResolved, accessible,
        accepted, rejectReason)
    print("[XNP PURPLE ITEM INPUT] route=" .. tostring(route)
        .. " full_type=" .. tostring(fullType)
        .. " player_resolved=" .. tostring(playerResolved == true)
        .. " exact_item_accessible=" .. tostring(accessible == true)
        .. " accepted=" .. tostring(accepted == true)
        .. " reject_reason=" .. tostring(rejectReason or "NONE"))
end

function Items.HandleInput(route, playerIndex, item)
    local fullType = itemType(item)
    if not isSupportedType(fullType) then return false, "NOT_XNP_PURPLE_ITEM" end
    local player = playerByIndex(playerIndex)
    if not player then
        inputLog(route, fullType, false, false, false, "PLAYER_RESOLUTION_FAILED")
        return true, "PLAYER_RESOLUTION_FAILED"
    end
    if fullType == Constants.RECORDER_ITEM then
        local migrated, migrationReason = Items.MigrateLegacyItem(player, item)
        inputLog(route, fullType, true, true, migrated, migrationReason)
        return true, migrationReason
    end
    local accessible, accessReason = Items.IsExactAccessible(player, item)
    if not accessible then
        inputLog(route, fullType, true, false, false, accessReason)
        return true, accessReason
    end
    local transaction = Core.PurpleLifeStockTransactions
    if not transaction or type(transaction.QueueRestore) ~= "function" then
        inputLog(route, fullType, true, true, false, "TRANSACTION_MODULE_UNAVAILABLE")
        return true, "TRANSACTION_MODULE_UNAVAILABLE"
    end
    local okCall, queued, reason = pcall(transaction.QueueRestore, player, item)
    inputLog(route, fullType, true, true, okCall and queued == true,
        okCall and reason or queued)
    return true, okCall and reason or "TRANSACTION_EXCEPTION"
end

function Items.HandleDoubleClick(playerIndex, item)
    return Items.HandleInput("DOUBLE_CLICK", playerIndex, item)
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
        if okEntry and entry then callback(entry) end
    end
end

local function collectContextItems(items)
    local result, seen = {}, {}
    local function collect(entry)
        if not entry or seen[entry] then return end
        seen[entry] = true
        if isSupportedType(itemType(entry)) then
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

function Items.OnContextAction(item, playerIndex)
    return Items.HandleInput("CONTEXT_MENU", playerIndex, item)
end

function Items.OnSelectInheritanceRecord(record, playerIndex)
    local player = playerByIndex(playerIndex)
    local transaction = Core.PurpleLifeStockTransactions
    if not player or not transaction then return false, "RECORD_SELECTION_UNAVAILABLE" end
    return transaction.SelectInheritanceRecord(player, record.record_id)
end

function Items.OnRandomInheritanceRecord(_, playerIndex)
    local player = playerByIndex(playerIndex)
    local transaction = Core.PurpleLifeStockTransactions
    if not player or not transaction then return false, "RECORD_SELECTION_UNAVAILABLE" end
    return transaction.SelectRandomInheritanceRecord(player)
end

function Items.OnRequestDeleteInheritanceRecord(record, playerIndex)
    local player = playerByIndex(playerIndex)
    local transaction = Core.PurpleLifeStockTransactions
    if not player or not transaction then return false, "RECORD_DELETE_UNAVAILABLE" end
    return transaction.RequestDeleteInheritanceRecord(player, record.record_id)
end

function Items.OnConfirmDeleteInheritanceRecord(record, playerIndex)
    local player = playerByIndex(playerIndex)
    local transaction = Core.PurpleLifeStockTransactions
    if not player or not transaction then return false, "RECORD_DELETE_UNAVAILABLE" end
    return transaction.ConfirmDeleteInheritanceRecord(player, record.record_id)
end

function Items.OnFillInventoryObjectContextMenu(playerIndex, context, items)
    local player = playerByIndex(playerIndex)
    if not player or not context then return end
    local recorder, backup = nil, nil
    for _, item in ipairs(collectContextItems(items)) do
        if itemType(item) == Constants.RECORDER_ITEM and not recorder then
            recorder = item
        elseif itemType(item) == Constants.BACKUP_ITEM and not backup then
            backup = item
        end
    end
    if recorder then
        context:addOption(getText("ContextMenu_XNPPurpleMigrateLegacy"),
            recorder, Items.OnContextAction, playerIndex)
    end
    if backup then
        context:addOption(getText("ContextMenu_XNPPurpleUseBackup"),
            backup, Items.OnContextAction, playerIndex)
        local records = Records and Records.ListValid
            and Records.ListValid(player) or {}
        if #records > 0 then
            context:addOption(getText("ContextMenu_XNPPurpleSelectRandomRecord"),
                backup, Items.OnRandomInheritanceRecord, playerIndex)
        end
        for _, record in ipairs(records) do
            local label = getText("ContextMenu_XNPPurpleSelectRecord")
                .. ": " .. tostring(record.display_name)
                .. " [" .. tostring(record.record_id) .. "]"
            context:addOption(label, record, Items.OnSelectInheritanceRecord, playerIndex)
            local pending = Records.IsDeletePending and Records.IsDeletePending(
                player, record.record_id) == true
            if pending then
                context:addOption(getText("ContextMenu_XNPPurpleConfirmDeleteRecord")
                    .. ": " .. tostring(record.display_name), record,
                    Items.OnConfirmDeleteInheritanceRecord, playerIndex)
            else
                context:addOption(getText("ContextMenu_XNPPurpleDeleteRecord")
                    .. ": " .. tostring(record.display_name), record,
                    Items.OnRequestDeleteInheritanceRecord, playerIndex)
            end
        end
    end
end

local function hoveredPurpleItem(pane)
    if not pane or not pane.items or not pane.mouseOverOption then return nil end
    local selected = pane.items[pane.mouseOverOption]
    local found = nil
    local function collect(entry)
        if found or not entry then return end
        if isSupportedType(itemType(entry)) then found = entry; return end
        if type(entry) == "table" and entry.items then
            forEachContextEntry(entry.items, collect)
        end
    end
    collect(selected)
    return found
end

function Items.InstallContextMenu()
    if Items.contextMenuInstalled then return true, "CONTEXT_MENU_ALREADY_INSTALLED" end
    if not Events or not Events.OnFillInventoryObjectContextMenu then
        return false, "INVENTORY_CONTEXT_MENU_EVENT_UNAVAILABLE"
    end
    Events.OnFillInventoryObjectContextMenu.Add(
        Items.OnFillInventoryObjectContextMenu)
    Items.contextMenuInstalled = true
    print("[XNP PURPLE BACKUP ITEM] context_menu_installed=true"
        .. " public_backup_action=USE_TIMED_ACTION legacy_action=MIGRATE_ONLY")
    return true, "CONTEXT_MENU_INSTALLED"
end

function Items.InstallDoubleClick()
    if Items.doubleClickInstalled then return true, "DOUBLE_CLICK_ALREADY_INSTALLED" end
    if not ISInventoryPane
        or type(ISInventoryPane.doContextualDblClick) ~= "function"
        or type(ISInventoryPane.onMouseDoubleClick) ~= "function" then
        return false, "INVENTORY_DOUBLE_CLICK_API_UNAVAILABLE"
    end
    Items.originalContextualDoubleClick = ISInventoryPane.doContextualDblClick
    Items.contextualDoubleClickWrapper = function(pane, item)
        local handled = Items.HandleDoubleClick(pane and pane.player or 0, item)
        if handled then return true end
        return Items.originalContextualDoubleClick(pane, item)
    end
    ISInventoryPane.doContextualDblClick = Items.contextualDoubleClickWrapper
    Items.originalMouseDoubleClick = ISInventoryPane.onMouseDoubleClick
    Items.mouseDoubleClickWrapper = function(pane, x, y)
        local item = hoveredPurpleItem(pane)
        if item then
            local handled = Items.HandleDoubleClick(pane and pane.player or 0, item)
            if handled then pane.previousMouseUp = nil; return true end
        end
        return Items.originalMouseDoubleClick(pane, x, y)
    end
    ISInventoryPane.onMouseDoubleClick = Items.mouseDoubleClickWrapper
    Items.doubleClickInstalled = true
    print("[XNP PURPLE BACKUP ITEM] double_click_installed=true"
        .. " restore_route=PURPLE_RESTORE_TIMED_ACTION")
    return true, "DOUBLE_CLICK_INSTALLED"
end

function Items.InstallInteractions()
    local contextOk, contextReason = Items.InstallContextMenu()
    local doubleOk, doubleReason = Items.InstallDoubleClick()
    return contextOk and doubleOk,
        tostring(contextReason) .. "|" .. tostring(doubleReason)
end

function Items.GetAuditSnapshot()
    return {
        legacy_migration_count = Items.legacyMigrationCount,
        auto_regrant_count = Items.autoRegrantCount,
        auto_recreate_count = Items.autoRecreateCount,
        public_recorder_grant_enabled = false,
    }
end

Core.PurpleLifeStockItems = Items
return Items
