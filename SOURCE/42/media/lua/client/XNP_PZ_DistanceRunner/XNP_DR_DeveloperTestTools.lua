require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"

local Core = XNP_PZ_DistanceRunner
local Tools = {
    OWNER_KEY = "XNP_V2_TEST_TOOL_OWNED",
    TYPE_KEY = "XNP_V2_TEST_TOOL_TYPE",
    spawnCount = 0,
    clearCount = 0,
    nonOwnedDeleteCount = 0,
    registered = false,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function enabled()
    return Core.SandboxTuning
        and Core.SandboxTuning.GetBoolean
        and Core.SandboxTuning.GetBoolean(
            "DeveloperTestToolsEnabled", false) == true
end

local function playerForIndex(index)
    if type(getSpecificPlayer) ~= "function" then return nil end
    local ok, player = pcall(getSpecificPlayer, index)
    return ok and player or nil
end

local function markAndDamage(item, ratio, kind)
    if not item then return false end
    local dataOk, data = invoke(item, "getModData")
    if not dataOk or type(data) ~= "table" then return false end
    data[Tools.OWNER_KEY] = true
    data[Tools.TYPE_KEY] = tostring(kind)
    local maxOk, maximum = invoke(item, "getConditionMax")
    if maxOk and tonumber(maximum) then
        local target = math.max(0,
            math.floor(tonumber(maximum) * ratio + 0.5))
        invoke(item, "setCondition", target)
    end
    Tools.spawnCount = Tools.spawnCount + 1
    print("[XNP TEST ITEM] spawn=true kind=" .. tostring(kind)
        .. " condition_ratio=" .. tostring(ratio)
        .. " owned=true")
    return true
end

function Tools.Spawn(player, fullType, ratio, kind)
    if not enabled() then return false, "TOOLS_DISABLED" end
    local inventoryOk, inventory = invoke(player, "getInventory")
    if not inventoryOk or not inventory then
        return false, "INVENTORY_UNAVAILABLE"
    end
    local addOk, item = invoke(inventory, "AddItem", fullType)
    if not addOk or not item then return false, "ITEM_CREATE_FAILED" end
    if not markAndDamage(item, ratio, kind) then
        invoke(item, "Remove")
        return false, "ITEM_MARK_FAILED"
    end
    return true, item
end

local function itemsFrom(container)
    local ok, items = invoke(container, "getItems")
    if not ok or not items or type(items.size) ~= "function"
        or type(items.get) ~= "function" then return {} end
    local result = {}
    local sizeOk, size = invoke(items, "size")
    if not sizeOk then return result end
    for index = 0, (tonumber(size) or 0) - 1 do
        local itemOk, item = invoke(items, "get", index)
        if itemOk and item then result[#result + 1] = item end
    end
    return result
end

local function collectOwned(container, output, visited, depth)
    if not container or visited[container] or depth > 8 then return end
    visited[container] = true
    local items = itemsFrom(container)
    for index = 1, #items do
        local item = items[index]
        local dataOk, data = invoke(item, "getModData")
        if dataOk and type(data) == "table"
            and data[Tools.OWNER_KEY] == true then
            output[#output + 1] = item
        end
        local childOk, child = invoke(item, "getInventory")
        if childOk and child then
            collectOwned(child, output, visited, depth + 1)
        end
    end
end

function Tools.ClearOwned(player)
    if not enabled() then return false, "TOOLS_DISABLED" end
    local inventoryOk, inventory = invoke(player, "getInventory")
    if not inventoryOk or not inventory then
        return false, "INVENTORY_UNAVAILABLE"
    end
    local owned = {}
    collectOwned(inventory, owned, {}, 0)
    local removed = 0
    for index = 1, #owned do
        local item = owned[index]
        local dataOk, data = invoke(item, "getModData")
        if dataOk and type(data) == "table"
            and data[Tools.OWNER_KEY] == true then
            local removeOk = invoke(item, "Remove") == true
            if removeOk then removed = removed + 1 end
        else
            Tools.nonOwnedDeleteCount = Tools.nonOwnedDeleteCount + 1
        end
    end
    Tools.clearCount = Tools.clearCount + removed
    print("[XNP TEST ITEM] clear=true owned_removed="
        .. tostring(removed) .. " non_owned_deleted=0")
    return true, removed
end

local function addOption(context, label, callback, player)
    if context and type(context.addOption) == "function" then
        context:addOption(label, player, callback)
    end
end

local function text(key, fallback)
    if type(getText) == "function" then
        local ok, value = pcall(getText, key)
        if ok and value and value ~= key then return tostring(value) end
    end
    return fallback
end

function Tools.OnFillInventoryObjectContextMenu(playerIndex, context)
    if not enabled() then return end
    local player = playerForIndex(playerIndex)
    if not player then return end
    addOption(context, text("ContextMenu_XNPTestSpawnShoe10",
        "[XNP TEST] Spawn shoe at 10%"), function(p)
        Tools.Spawn(p, "Base.Shoes_TrainerTINT", 0.10, "SHOE_10")
    end, player)
    addOption(context, text("ContextMenu_XNPTestSpawnShoe50",
        "[XNP TEST] Spawn shoe at 50%"), function(p)
        Tools.Spawn(p, "Base.Shoes_TrainerTINT", 0.50, "SHOE_50")
    end, player)
    addOption(context, text("ContextMenu_XNPTestSpawnNonShoe10",
        "[XNP TEST] Spawn non-shoe clothing at 10%"), function(p)
        Tools.Spawn(p, "Base.Jacket_WhiteTINT", 0.10, "NON_SHOE_10")
    end, player)
    addOption(context, text("ContextMenu_XNPTestSpawnWeapon10",
        "[XNP TEST] Spawn weapon at 10%"), function(p)
        Tools.Spawn(p, "Base.Hammer", 0.10, "WEAPON_10")
    end, player)
    addOption(context, text("ContextMenu_XNPTestClearOwned",
        "[XNP TEST] Clear XNP test items"), function(p)
        Tools.ClearOwned(p)
    end, player)
end

function Tools.GetAuditSnapshot()
    return {
        reachable = true,
        default_enabled = false,
        spawn_count = Tools.spawnCount,
        clear_count = Tools.clearCount,
        non_owned_item_delete_count = Tools.nonOwnedDeleteCount,
        owner_marker = Tools.OWNER_KEY,
    }
end

if Events and Events.OnFillInventoryObjectContextMenu
    and type(Events.OnFillInventoryObjectContextMenu.Add) == "function" then
    Events.OnFillInventoryObjectContextMenu.Add(
        Tools.OnFillInventoryObjectContextMenu)
    Tools.registered = true
end

Core.DeveloperTestTools = Tools
return Tools
