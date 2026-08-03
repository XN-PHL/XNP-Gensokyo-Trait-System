require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Migration = {
    MARKER_KEY = "XNP_B42_20_220_TEST6_GREEN_BLOOM_FOUR_SKILL_POLISH_A",
    EXPLICIT_CUSTOM_MARKER_KEY = "XNP_TEST6_GREEN_VISUAL_EXPLICIT_CUSTOM_A",
    PROVENANCE_KEY = "XNP_B42_20_SANDBOX_SOURCE_PROVENANCE",
    SOURCE_VERSION = "2.2.0-test.5",
    SOURCE_BUILD_MARKER = "XNP_V2_220_TEST5_RED_PHYSICAL_LOAD_A",
    TARGET_VERSION = "2.2.0-test.6",
    TARGET_BUILD_MARKER = "XNP_V2_220_TEST6_GREEN_BLOOM_FOUR_SKILL_POLISH_A",
    lastSummary = nil,
    lastLogKey = nil,
}

local function markerSet(value)
    return value == true or value == 1 or value == "1"
        or string.lower(tostring(value or "")) == "true"
end

local function sideFlag(name)
    local callback = _G[name]
    if type(callback) ~= "function" then return false end
    local ok, value = pcall(callback)
    return ok and value == true
end

local function hasAuthority(options)
    if options.authority ~= nil then
        return options.authority == true,
            options.authority == true and "HARNESS_AUTHORITY"
                or "HARNESS_CLIENT_READ_ONLY"
    end
    local client = sideFlag("isClient")
    local server = sideFlag("isServer")
    local coopHost = sideFlag("isCoopHost")
    if client and not server and not coopHost then
        return false, "REGULAR_MULTIPLAYER_CLIENT_READ_ONLY"
    end
    return true, server and "SERVER_AUTHORITY"
        or (coopHost and "COOP_HOST_AUTHORITY" or "SINGLEPLAYER_AUTHORITY")
end

local function isTargetChannel()
    return Constants
        and Constants.MOD_ID == Constants.TEST_MOD_ID
        and Constants.RELEASE_CHANNEL == "B42_20_TEST_WORKSHOP"
        and Constants.VERSION == Migration.TARGET_VERSION
        and Constants.BUILD_ID == Migration.TARGET_BUILD_MARKER
end

local function emit(summary)
    local key = tostring(summary.reason) .. ":"
        .. tostring(summary.migrated) .. ":"
        .. tostring(summary.marker_present)
    if Migration.lastLogKey == key then return end
    Migration.lastLogKey = key
    print("[XNP TEST6 VISUAL MIGRATION]"
        .. " marker=" .. Migration.MARKER_KEY
        .. " source_version=" .. Migration.SOURCE_VERSION
        .. " source_build_marker=" .. Migration.SOURCE_BUILD_MARKER
        .. " provenance=" .. tostring(summary.provenance)
        .. " old_style=" .. tostring(summary.old_style)
        .. " explicit_custom=" .. tostring(summary.explicit_custom)
        .. " authority=" .. tostring(summary.authority_reason)
        .. " migrated=" .. tostring(summary.migrated)
        .. " write_count=" .. tostring(summary.write_count)
        .. " reason=" .. tostring(summary.reason))
end

function Migration.Apply(vars, options)
    options = type(options) == "table" and options or {}
    local authority, authorityReason = hasAuthority(options)
    local provenance = type(vars) == "table"
        and vars[Migration.PROVENANCE_KEY] or nil
    local markerPresent = type(vars) == "table"
        and markerSet(vars[Migration.MARKER_KEY]) or false
    local explicitCustom = type(vars) == "table"
        and markerSet(vars[Migration.EXPLICIT_CUSTOM_MARKER_KEY]) or false
    if options.explicit_custom == true then explicitCustom = true end
    local oldStyle = type(vars) == "table"
        and tonumber(vars.GreenOrbVisualStyle) or nil
    local summary = {
        marker_key = Migration.MARKER_KEY,
        marker_present = markerPresent,
        source_version = Migration.SOURCE_VERSION,
        source_build_marker = Migration.SOURCE_BUILD_MARKER,
        provenance = provenance or "UNPROVEN",
        old_style = oldStyle,
        explicit_custom = explicitCustom,
        authority = authority,
        authority_reason = authorityReason,
        test_channel = isTargetChannel(),
        migrated = false,
        write_count = 0,
        explicit_user_value_overwrite_count = 0,
        ambiguous_value_auto_write_count = 0,
        reason = "NOT_EVALUATED",
    }

    if type(vars) ~= "table" then
        summary.reason = "SANDBOX_NAMESPACE_MISSING"
    elseif markerPresent then
        summary.reason = "MIGRATION_ALREADY_APPLIED"
    elseif not summary.test_channel then
        summary.reason = "NOT_TEST6_CHANNEL"
    elseif not authority then
        summary.reason = authorityReason
    elseif explicitCustom then
        summary.reason = "EXPLICIT_USER_CUSTOM_PRESERVED"
    elseif tostring(provenance) ~= Migration.SOURCE_BUILD_MARKER then
        summary.reason = "SOURCE_TEST5_BUILD_MARKER_NOT_PROVEN"
    elseif oldStyle ~= 1 then
        summary.reason = "OLD_STYLE_NOT_EXACT_TEST5_DEFAULT_PRESERVED"
    else
        local styleBefore = vars.GreenOrbVisualStyle
        local styleOk = pcall(function() vars.GreenOrbVisualStyle = 4 end)
            and tonumber(vars.GreenOrbVisualStyle) == 4
        local markerOk = false
        if styleOk then
            markerOk = pcall(function() vars[Migration.MARKER_KEY] = true end)
                and markerSet(vars[Migration.MARKER_KEY])
        end
        if styleOk and markerOk then
            summary.migrated = true
            summary.marker_present = true
            summary.write_count = 2
            summary.reason = "PROVEN_TEST5_DEFAULT_STYLE_MIGRATED_TO_BLOOM"
        else
            pcall(function() vars.GreenOrbVisualStyle = styleBefore end)
            pcall(function() vars[Migration.MARKER_KEY] = nil end)
            summary.reason = "MIGRATION_WRITE_FAILED_ROLLED_BACK"
        end
    end

    Migration.lastSummary = summary
    emit(summary)
    return summary
end

function Migration.GetLastSummary()
    return Migration.lastSummary
end

Core.Test6VisualMigration = Migration
return Migration
