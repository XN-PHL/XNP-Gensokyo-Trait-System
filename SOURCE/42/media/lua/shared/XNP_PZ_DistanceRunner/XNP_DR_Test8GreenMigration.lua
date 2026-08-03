require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Migration = {
    MARKER_KEY = "XNP_B42_20_220_TEST8_GREEN_CORE_BURST_TUNING_A",
    TEST7_PROVENANCE_MARKER_KEY = "XNP_B42_20_220_TEST7_GREEN_CAST_REPAIR_A",
    EXPLICIT_CUSTOM_MARKER_KEY = "XNP_TEST7_SANDBOX_EXPLICIT_CUSTOM_A",
    TARGET_VERSION = "2.2.0-test.8",
    TARGET_BUILD_MARKER = "XNP_V2_220_TEST8_GREEN_CORE_BURST_TUNING_A",
    lastSummary = nil,
}

local function markerSet(value)
    return value == true or value == 1 or value == "1"
        or string.lower(tostring(value or "")) == "true"
end

local function sameNumber(left, right)
    return tonumber(left) == tonumber(right)
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

local function writeField(vars, rollback, summary, key, expected, replacement)
    local current = vars[key]
    local field = {
        key = key,
        before = current,
        expected_test7_default = expected,
        test8_default = replacement,
        changed = false,
        reason = "CUSTOM_OR_UNKNOWN_VALUE_PRESERVED",
    }
    if sameNumber(current, replacement) then
        field.reason = "ALREADY_TEST8_DEFAULT"
    elseif sameNumber(current, expected) then
        rollback[key] = current
        local ok = pcall(function() vars[key] = replacement end)
            and sameNumber(vars[key], replacement)
        if not ok then
            field.reason = "WRITE_FAILED"
            summary.fields[#summary.fields + 1] = field
            return false
        end
        field.changed = true
        field.reason = "EXACT_TEST7_DEFAULT_MIGRATED"
        summary.field_write_count = summary.field_write_count + 1
    end
    summary.fields[#summary.fields + 1] = field
    return true
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
        test7_provenance = type(vars) == "table"
            and markerSet(vars[Migration.TEST7_PROVENANCE_MARKER_KEY]),
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
        summary.reason = "NOT_TEST8_CHANNEL"
    elseif not summary.authority then
        summary.reason = "REGULAR_MULTIPLAYER_CLIENT_READ_ONLY"
    elseif not summary.test7_provenance then
        summary.reason = "TEST7_PROVENANCE_NOT_PROVEN_NO_AUTO_WRITE"
    elseif markerSet(vars[Migration.EXPLICIT_CUSTOM_MARKER_KEY])
        or options.explicit_custom == true then
        summary.reason = "EXPLICIT_USER_CUSTOM_PRESERVED"
    else
        local rollback = {}
        local ok = writeField(vars, rollback, summary,
            "GreenOrbVisualStyle", 5, 6)
        if ok then
            ok = writeField(vars, rollback, summary,
                "GreenAccelerationTimeToMaxSeconds", 6, 4.5)
        end
        if ok then
            local degrees = vars.GreenGuidanceTurnDegreesPerSecond
            if degrees == nil and sameNumber(vars.GreenGuidanceTurnLevel, 4) then
                rollback.GreenGuidanceTurnDegreesPerSecond = false
                local writeOk = pcall(function()
                    vars.GreenGuidanceTurnDegreesPerSecond = 150
                end) and sameNumber(vars.GreenGuidanceTurnDegreesPerSecond, 150)
                local field = {
                    key = "GreenGuidanceTurnDegreesPerSecond",
                    before = degrees,
                    expected_test7_default = "ABSENT_WITH_LEVEL_4",
                    test8_default = 150,
                    changed = writeOk,
                    reason = writeOk and "EXACT_TEST7_LEVEL_DEFAULT_MIGRATED"
                        or "WRITE_FAILED",
                }
                summary.fields[#summary.fields + 1] = field
                if writeOk then
                    summary.field_write_count = summary.field_write_count + 1
                else
                    ok = false
                end
            else
                ok = writeField(vars, rollback, summary,
                    "GreenGuidanceTurnDegreesPerSecond", 180, 150)
            end
        end
        local markerOk = ok and pcall(function()
            vars[Migration.MARKER_KEY] = true
        end) and markerSet(vars[Migration.MARKER_KEY])
        if ok and markerOk then
            summary.migrated = summary.field_write_count > 0
            summary.write_count = summary.field_write_count + 1
            summary.reason = summary.migrated
                and "EXACT_TEST7_DEFAULTS_MIGRATED"
                or "NO_EXACT_TEST7_DEFAULTS_CUSTOM_VALUES_PRESERVED"
        else
            for key, value in pairs(rollback) do
                pcall(function()
                    vars[key] = value == false and nil or value
                end)
            end
            pcall(function() vars[Migration.MARKER_KEY] = nil end)
            summary.reason = "MIGRATION_WRITE_FAILED_ROLLED_BACK"
            summary.field_write_count = 0
            summary.write_count = 0
        end
    end
    Migration.lastSummary = summary
    print("[XNP TEST8 GREEN MIGRATION] marker=" .. Migration.MARKER_KEY
        .. " test7_provenance=" .. tostring(summary.test7_provenance)
        .. " migrated=" .. tostring(summary.migrated)
        .. " field_writes=" .. tostring(summary.field_write_count)
        .. " explicit_overwrites=0 ambiguous_writes=0"
        .. " reason=" .. tostring(summary.reason))
    return summary
end

function Migration.GetLastSummary()
    return Migration.lastSummary
end

Core.Test8GreenMigration = Migration
return Migration
