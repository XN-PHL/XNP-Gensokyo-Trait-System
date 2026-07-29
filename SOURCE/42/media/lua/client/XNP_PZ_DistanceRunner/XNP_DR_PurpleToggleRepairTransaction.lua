require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStockRepair"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local ToggleRepair = {
    request_count = 0,
    rejected_source_count = 0,
    disabled_count = 0,
}

local function value(result, key, fallback)
    if type(result) == "table" and result[key] ~= nil then
        return result[key]
    end
    return fallback
end

local function disabledResult(transactionId)
    return {
        transaction_id = tostring(transactionId or "UNSPECIFIED"),
        sandbox_enabled = false,
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
        result = "DISABLED",
    }
end

local function logResult(result, source)
    print("[XNP PURPLE FOOTWEAR REPAIR]"
        .. " transaction_id=" .. tostring(
            value(result, "transaction_id", "UNSPECIFIED"))
        .. " source=" .. tostring(source)
        .. " sandbox_enabled=" .. tostring(
            value(result, "sandbox_enabled", false))
        .. " worn_entry_count=" .. tostring(
            value(result, "worn_entry_count", 0))
        .. " worn_footwear_found=" .. tostring(
            value(result, "worn_footwear_found", 0))
        .. " root_inventory_item_count=" .. tostring(
            value(result, "root_inventory_item_count", 0))
        .. " carried_container_count=" .. tostring(
            value(result, "carried_container_count", 0))
        .. " nested_container_count=" .. tostring(
            value(result, "nested_container_count", 0))
        .. " footwear_candidate_count=" .. tostring(
            value(result, "footwear_candidate_count", 0))
        .. " unique_footwear_count=" .. tostring(
            value(result, "unique_footwear_count", 0))
        .. " repaired_count=" .. tostring(
            value(result, "repaired_count", 0))
        .. " already_full_count=" .. tostring(
            value(result, "already_full_count", 0))
        .. " unsupported_count=" .. tostring(
            value(result, "unsupported_count", 0))
        .. " duplicate_skipped_count=" .. tostring(
            value(result, "duplicate_skipped_count", 0))
        .. " non_footwear_write_count=" .. tostring(
            value(result, "non_footwear_write_count", 0))
        .. " world_container_scan_count=" .. tostring(
            value(result, "world_container_scan_count", 0))
        .. " item_body_location_string_error_count=" .. tostring(
            value(result, "item_body_location_string_error_count", 0))
        .. " condition_write_count=" .. tostring(
            value(result, "condition_write_count", 0))
        .. " result=" .. tostring(value(result, "result", "PARTIAL")))
end

function ToggleRepair.Request(player, transactionId, source)
    if source ~= "RIGHT_CLICK_TOGGLE_COMMITTED" then
        ToggleRepair.rejected_source_count =
            ToggleRepair.rejected_source_count + 1
        return {
            transaction_id = tostring(transactionId or "UNSPECIFIED"),
            result = "SOURCE_REJECTED",
            condition_write_count = 0,
            condition_set_call_count = 0,
        }
    end
    ToggleRepair.request_count = ToggleRepair.request_count + 1

    local config = Core.PurplePhoenixConfig
        and Core.PurplePhoenixConfig.Get
        and Core.PurplePhoenixConfig.Get() or nil
    local enabled = config
        and config.rightClickRepairEnabled == true
    local result
    if not enabled then
        ToggleRepair.disabled_count = ToggleRepair.disabled_count + 1
        result = disabledResult(transactionId)
    else
        local repair = Core.PurpleLifeStockRepair
        result = repair.RepairCurrentWornFootwear(
            player, transactionId)
        result.sandbox_enabled = true
    end

    -- Compatibility field consumed by the existing Purple toggle summary.
    result.condition_set_call_count =
        tonumber(result.condition_write_count) or 0
    logResult(result, source)
    return result
end

function ToggleRepair.GetAuditSnapshot()
    return {
        reachable = true,
        request_count = ToggleRepair.request_count,
        rejected_source_count = ToggleRepair.rejected_source_count,
        disabled_count = ToggleRepair.disabled_count,
        owns_ui = false,
        owns_purple_state = false,
        rolls_back_toggle = false,
        world_container_scan_count = 0,
    }
end

Core.PurpleToggleRepairTransaction = ToggleRepair
return ToggleRepair
