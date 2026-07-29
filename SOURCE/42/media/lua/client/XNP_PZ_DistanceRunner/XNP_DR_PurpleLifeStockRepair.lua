require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local MAXIMUM_DEPTH = 8
local Repair = {
    request_count = 0,
    repaired_count = 0,
    condition_write_count = 0,
    inventory_scan_count = 0,
    world_container_scan_count = 0,
    non_footwear_write_count = 0,
}

local function invoke(object, method, ...)
    local kind = type(object)
    if not object
        or (kind ~= "table" and kind ~= "userdata")
        or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function finite(value)
    value = tonumber(value)
    return value ~= nil and value == value
        and value > -1e308 and value < 1e308
end

local function trim(value)
    return string.match(value, "^%s*(.-)%s*$")
end

local function canonicalLocationId(value)
    if value == nil then return nil end
    if type(value) == "string" then
        local text = trim(value)
        if text == "Shoes" or text == "shoes"
            or text == "base:shoes" then
            return "Shoes"
        end
        return text
    end

    local idOk, id = invoke(value, "getId")
    if idOk and id ~= nil and id ~= value then
        return canonicalLocationId(id)
    end

    local pathOk, path = invoke(value, "getPath")
    if pathOk and type(path) == "string" then
        return canonicalLocationId(path)
    end

    -- B42 ItemBodyLocation has getTranslationName() and a verified
    -- ResourceLocation-backed toString(), but no public getId().
    if type(value.getTranslationName) == "function" then
        local textOk, text = pcall(tostring, value)
        if textOk and type(text) == "string" then
            return canonicalLocationId(text)
        end
    end
    return nil
end

local function baseResult(transactionId)
    return {
        transaction_id = tostring(transactionId or "UNSPECIFIED"),
        canonical_player_match = false,
        worn_entry_count = 0,
        worn_footwear_found = 0,
        root_inventory_item_count = 0,
        carried_container_count = 0,
        nested_container_count = 0,
        footwear_candidate_count = 0,
        unique_footwear_count = 0,
        repaired_count = 0,
        already_full_count = 0,
        unsupported_count = 0,
        duplicate_skipped_count = 0,
        non_footwear_write_count = 0,
        world_container_scan_count = 0,
        item_body_location_string_error_count = 0,
        condition_write_count = 0,
        broken_flag_clear_count = 0,
        maximum_depth = MAXIMUM_DEPTH,
        depth_limit_skip_count = 0,
        exception_count = 0,
        result = "NONE",
    }
end

local function validatePlayer(player)
    local identity = Core.CanonicalPlayerIdentity
    if not identity or type(identity.Validate) ~= "function" then
        return false, "CANONICAL_PLAYER_UNAVAILABLE"
    end
    local ok, valid, reason = pcall(identity.Validate, player, true)
    if not ok then return false, "CANONICAL_PLAYER_EXCEPTION" end
    return valid == true, valid == true and "CANONICAL" or reason
end

local function bodyLocationId(item)
    local itemOk, location = invoke(item, "getBodyLocation")
    local id = itemOk and canonicalLocationId(location) or nil
    if id ~= nil then return id end

    local scriptOk, scriptItem = invoke(item, "getScriptItem")
    if not scriptOk or not scriptItem then return nil end
    local scriptLocationOk, scriptLocation =
        invoke(scriptItem, "getBodyLocation")
    if not scriptLocationOk then return nil end
    return canonicalLocationId(scriptLocation)
end

local function stableItemKey(item)
    local ok, value = invoke(item, "getID")
    value = ok and tonumber(value) or nil
    if value and value >= 0 and value == math.floor(value) then
        return "item-id:" .. tostring(value)
    end
    return nil
end

local function readBroken(item)
    local ok, value = invoke(item, "isBroken")
    if ok then return true, value == true end
    ok, value = invoke(item, "getBroken")
    if ok then return true, value == true end
    return false, false
end

local function repairCandidate(item, result)
    local beforeOk, conditionBefore = invoke(item, "getCondition")
    local maxOk, conditionMax = invoke(item, "getConditionMax")
    if not beforeOk or not maxOk
        or not finite(conditionBefore) or not finite(conditionMax)
        or tonumber(conditionMax) <= 0
        or type(item.setCondition) ~= "function" then
        result.unsupported_count = result.unsupported_count + 1
        return
    end

    conditionBefore = tonumber(conditionBefore)
    conditionMax = tonumber(conditionMax)
    if conditionBefore >= conditionMax then
        result.already_full_count = result.already_full_count + 1
        return
    end

    local writeOk = pcall(item.setCondition, item, conditionMax)
    result.condition_write_count = result.condition_write_count + 1
    Repair.condition_write_count = Repair.condition_write_count + 1
    if not writeOk then
        result.unsupported_count = result.unsupported_count + 1
        return
    end

    local afterOk, conditionAfter = invoke(item, "getCondition")
    if not afterOk or not finite(conditionAfter)
        or tonumber(conditionAfter) ~= conditionMax then
        result.unsupported_count = result.unsupported_count + 1
        return
    end

    local brokenReadable, broken = readBroken(item)
    if brokenReadable and broken and conditionBefore <= 0
        and type(item.setBroken) == "function" then
        local clearOk = pcall(item.setBroken, item, false)
        local readOk, brokenAfter = readBroken(item)
        if not clearOk or not readOk or brokenAfter then
            result.unsupported_count = result.unsupported_count + 1
            return
        end
        result.broken_flag_clear_count =
            result.broken_flag_clear_count + 1
    end

    result.repaired_count = result.repaired_count + 1
    Repair.repaired_count = Repair.repaired_count + 1
end

local function addCandidate(item, result, candidates, seenObjects, seenIds)
    if not item then return end
    result.footwear_candidate_count =
        result.footwear_candidate_count + 1
    if seenObjects[item] then
        result.duplicate_skipped_count =
            result.duplicate_skipped_count + 1
        return
    end
    local stableKey = stableItemKey(item)
    if stableKey and seenIds[stableKey] then
        result.duplicate_skipped_count =
            result.duplicate_skipped_count + 1
        seenObjects[item] = true
        return
    end
    seenObjects[item] = true
    if stableKey then seenIds[stableKey] = true end
    candidates[#candidates + 1] = item
    result.unique_footwear_count =
        result.unique_footwear_count + 1
end

local function collectWorn(player, result, candidates, seenObjects, seenIds)
    local wornOk, wornItems = invoke(player, "getWornItems")
    if not wornOk or not wornItems then
        result.exception_count = result.exception_count + 1
        return
    end
    local sizeOk, size = invoke(wornItems, "size")
    size = sizeOk and tonumber(size) or nil
    if not size or size < 0 then
        result.exception_count = result.exception_count + 1
        return
    end
    size = math.floor(size)
    for index = 0, size - 1 do
        local entryOk, entry = invoke(wornItems, "get", index)
        if entryOk and entry then
            result.worn_entry_count = result.worn_entry_count + 1
            local locationOk, location =
                invoke(entry, "getLocation")
            local itemOk, item = invoke(entry, "getItem")
            if locationOk and itemOk
                and canonicalLocationId(location) == "Shoes" then
                result.worn_footwear_found =
                    result.worn_footwear_found + 1
                addCandidate(item, result, candidates,
                    seenObjects, seenIds)
            end
        else
            result.exception_count = result.exception_count + 1
        end
    end
end

local function scanContainer(container, depth, result, candidates,
        candidateObjects, candidateIds, visitedContainers, visitedItems)
    if not container or visitedContainers[container] then return end
    visitedContainers[container] = true
    if depth > MAXIMUM_DEPTH then
        result.depth_limit_skip_count =
            result.depth_limit_skip_count + 1
        return
    end

    local itemsOk, items = invoke(container, "getItems")
    local sizeOk, size = false, nil
    if itemsOk and items then
        sizeOk, size = invoke(items, "size")
    end
    size = sizeOk and tonumber(size) or nil
    if not size or size < 0 then
        result.exception_count = result.exception_count + 1
        return
    end
    size = math.floor(size)
    for index = 0, size - 1 do
        local itemOk, item = invoke(items, "get", index)
        if itemOk and item and not visitedItems[item] then
            visitedItems[item] = true
            if depth == 0 then
                result.root_inventory_item_count =
                    result.root_inventory_item_count + 1
            end
            if bodyLocationId(item) == "Shoes" then
                addCandidate(item, result, candidates,
                    candidateObjects, candidateIds)
            end

            local containerOk, isContainer =
                invoke(item, "IsInventoryContainer")
            if containerOk and isContainer == true then
                result.carried_container_count =
                    result.carried_container_count + 1
                if depth >= 1 then
                    result.nested_container_count =
                        result.nested_container_count + 1
                end
                if depth >= MAXIMUM_DEPTH then
                    result.depth_limit_skip_count =
                        result.depth_limit_skip_count + 1
                else
                    local inventoryOk, nested =
                        invoke(item, "getInventory")
                    if inventoryOk and nested then
                        scanContainer(nested, depth + 1, result,
                            candidates, candidateObjects, candidateIds,
                            visitedContainers, visitedItems)
                    else
                        result.exception_count =
                            result.exception_count + 1
                    end
                end
            end
        elseif not itemOk then
            result.exception_count = result.exception_count + 1
        end
    end
end

function Repair.RepairCurrentWornFootwear(player, transactionId)
    Repair.request_count = Repair.request_count + 1
    local result = baseResult(transactionId)
    local valid, reason = validatePlayer(player)
    result.canonical_player_match = valid == true
    if not valid then
        result.result = tostring(reason or "CANONICAL_PLAYER_REJECTED")
        return result
    end

    local candidates = {}
    local candidateObjects = {}
    local candidateIds = {}
    collectWorn(player, result, candidates,
        candidateObjects, candidateIds)

    local inventoryOk, rootInventory =
        invoke(player, "getInventory")
    if inventoryOk and rootInventory then
        Repair.inventory_scan_count =
            Repair.inventory_scan_count + 1
        scanContainer(rootInventory, 0, result, candidates,
            candidateObjects, candidateIds, {}, {})
    else
        result.exception_count = result.exception_count + 1
    end

    for index = 1, #candidates do
        repairCandidate(candidates[index], result)
    end

    if result.repaired_count > 0 and result.unsupported_count > 0 then
        result.result = "PARTIAL"
    elseif result.repaired_count > 0 then
        result.result = "REPAIRED"
    elseif result.already_full_count > 0
        and result.unsupported_count == 0 then
        result.result = "ALREADY_FULL"
    elseif result.unsupported_count > 0 then
        result.result = "PARTIAL"
    else
        result.result = "NONE"
    end
    return result
end

function Repair.GetAuditSnapshot()
    return {
        reachable = true,
        request_count = Repair.request_count,
        repaired_count = Repair.repaired_count,
        condition_write_count = Repair.condition_write_count,
        inventory_scan_count = Repair.inventory_scan_count,
        world_container_scan_count = Repair.world_container_scan_count,
        non_footwear_write_count = Repair.non_footwear_write_count,
        maximum_depth = MAXIMUM_DEPTH,
        max_writes_per_item_per_toggle = 1,
        nested_container_api = "InventoryContainer:getInventory",
        worn_entry_api = "WornItems:size/get",
    }
end

Repair.NormalizeBodyLocationId = canonicalLocationId
Core.PurpleLifeStockRepair = Repair
return Repair
