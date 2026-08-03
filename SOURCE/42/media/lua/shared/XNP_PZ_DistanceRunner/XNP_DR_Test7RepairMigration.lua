require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Migration = {
    MARKER_KEY = "XNP_B42_20_220_TEST7_GREEN_CAST_REPAIR_A",
    EXPLICIT_CUSTOM_MARKER_KEY = "XNP_TEST7_SANDBOX_EXPLICIT_CUSTOM_A",
    TARGET_VERSION = "2.2.0-test.7",
    TARGET_BUILD_MARKER = "XNP_V2_220_TEST7_GREEN_CAST_REPAIR_NO_RETICLE_A",
    lastSummary = nil,
}

local CHANGES = {
    { key = "PurpleCooldownRealSeconds", from = 3, to = 5 },
    { key = "PurpleInvulnerabilitySeconds", from = 0, to = 10 },
    { key = "PurpleLocalZombiePushEnabled", from = false, to = true },
    { key = "GreenOrbVisualStyle", from = 4, to = 5 },
    { key = "GreenTargetOutlineEnabled", from = true, to = false },
    { key = "GreenTargetFlashEnabled", from = true, to = false },
    { key = "GreenTargetFeedbackMode", from = 2, to = 0 },
}

local function markerSet(value)
    return value == true or value == 1 or value == "1"
        or string.lower(tostring(value or "")) == "true"
end

local function sameValue(left, right)
    if type(right) == "number" then return tonumber(left) == right end
    return left == right
end

local function isTargetChannel()
    return Constants
        and Constants.MOD_ID == Constants.TEST_MOD_ID
        and Constants.RELEASE_CHANNEL == "B42_20_TEST_WORKSHOP"
        and Constants.VERSION == Migration.TARGET_VERSION
        and Constants.BUILD_ID == Migration.TARGET_BUILD_MARKER
end

local function sideFlag(name)
    local callback = _G[name]
    if type(callback) ~= "function" then return false end
    local ok, value = pcall(callback)
    return ok and value == true
end

function Migration.Apply(vars, options)
    options = type(options) == "table" and options or {}
    local authority = options.authority
    if authority == nil then
        local client = sideFlag("isClient")
        local server = sideFlag("isServer")
        local host = sideFlag("isCoopHost")
        authority = not (client and not server and not host)
    end
    local summary = {
        marker_key = Migration.MARKER_KEY,
        target_channel = isTargetChannel(),
        authority = authority == true,
        migrated = false,
        write_count = 0,
        field_write_count = 0,
        explicit_user_value_overwrite_count = 0,
        ambiguous_value_auto_write_count = 0,
        fields = {},
        reason = "NOT_EVALUATED",
    }
    if type(vars) ~= "table" then
        summary.reason = "SANDBOX_NAMESPACE_MISSING"
    elseif markerSet(vars[Migration.MARKER_KEY]) then
        summary.reason = "MIGRATION_ALREADY_APPLIED"
    elseif not summary.target_channel then
        summary.reason = "NOT_TEST7_CHANNEL"
    elseif not summary.authority then
        summary.reason = "REGULAR_MULTIPLAYER_CLIENT_READ_ONLY"
    elseif markerSet(vars[Migration.EXPLICIT_CUSTOM_MARKER_KEY])
        or options.explicit_custom == true then
        summary.reason = "EXPLICIT_USER_CUSTOM_PRESERVED"
    else
        local rollback = {}
        local ok = true
        for _, change in ipairs(CHANGES) do
            local current = vars[change.key]
            local field = {
                key = change.key,
                before = current,
                expected_old_default = change.from,
                new_default = change.to,
                changed = false,
                reason = "CUSTOM_OR_UNKNOWN_VALUE_PRESERVED",
            }
            if sameValue(current, change.from) then
                rollback[change.key] = current
                local writeOk = pcall(function() vars[change.key] = change.to end)
                    and sameValue(vars[change.key], change.to)
                if writeOk then
                    field.changed = true
                    field.reason = "EXACT_TEST6_DEFAULT_MIGRATED"
                    summary.field_write_count = summary.field_write_count + 1
                else
                    ok = false
                    field.reason = "WRITE_FAILED"
                    break
                end
            end
            summary.fields[#summary.fields + 1] = field
        end
        local markerOk = ok and pcall(function()
            vars[Migration.MARKER_KEY] = true
        end) and markerSet(vars[Migration.MARKER_KEY])
        if ok and markerOk then
            summary.migrated = summary.field_write_count > 0
            summary.write_count = summary.field_write_count + 1
            summary.reason = summary.migrated
                and "EXACT_TEST6_DEFAULTS_MIGRATED"
                or "NO_EXACT_OLD_DEFAULTS_CUSTOM_VALUES_PRESERVED"
        else
            for key, value in pairs(rollback) do pcall(function() vars[key] = value end) end
            pcall(function() vars[Migration.MARKER_KEY] = nil end)
            summary.reason = "MIGRATION_WRITE_FAILED_ROLLED_BACK"
            summary.field_write_count = 0
            summary.write_count = 0
        end
    end
    Migration.lastSummary = summary
    print("[XNP TEST7 REPAIR MIGRATION] marker=" .. Migration.MARKER_KEY
        .. " migrated=" .. tostring(summary.migrated)
        .. " field_writes=" .. tostring(summary.field_write_count)
        .. " explicit_overwrites=0 ambiguous_writes=0"
        .. " reason=" .. tostring(summary.reason))
    return summary
end

function Migration.GetLastSummary()
    return Migration.lastSummary
end

Core.Test7RepairMigration = Migration
return Migration
