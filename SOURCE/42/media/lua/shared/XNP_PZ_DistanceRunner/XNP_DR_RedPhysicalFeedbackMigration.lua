require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Migration = {
    MARKER_KEY = "XNP_B42_20_220_TEST5_RED_PHYSICAL_FEEDBACK_MIGRATION_A",
    EXPLICIT_CUSTOM_MARKER_KEY =
        "XNP_RED_PHYSICAL_FEEDBACK_EXPLICIT_CUSTOM_A",
    SOURCE_VERSION = "2.2.0-test.4",
    SOURCE_BUILD_MARKER =
        "XNP_V2_220_TEST4_RED_MOOD_GREEN_CONTINUITY_A",
    TARGET_VERSION = "2.2.0-test.7",
    TARGET_BUILD_MARKER = "XNP_V2_220_TEST7_GREEN_CAST_REPAIR_NO_RETICLE_A",
    lastSummary = nil,
    lastLogKey = nil,
}

local Keys = {
    "RedCraftSweatEnabled",
    "RedCraftBodyHeatEnabled",
    "RedCraftExertionFeedbackEnabled",
}

local function markerSet(value)
    return value == true or value == 1 or value == "1"
        or string.lower(tostring(value or "")) == "true"
end

local function valueEquals(left, right)
    if type(left) == "number" and type(right) == "number" then
        return math.abs(left - right) < 0.0001
    end
    return left == right
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

local function isTargetTestChannel()
    return Constants
        and Constants.MOD_ID == Constants.TEST_MOD_ID
        and Constants.RELEASE_CHANNEL == "B42_20_TEST_WORKSHOP"
        and Constants.VERSION == Migration.TARGET_VERSION
        and Constants.BUILD_ID == Migration.TARGET_BUILD_MARKER
end

local function exactFalseTriplet(vars)
    return vars
        and vars.RedCraftSweatEnabled == false
        and vars.RedCraftBodyHeatEnabled == false
        and vars.RedCraftExertionFeedbackEnabled == false
end

local function test4Fingerprint(vars)
    if not vars then return false end
    return valueEquals(vars.RedCraftUnhappinessReductionPoints, 10)
        and valueEquals(vars.RedPCraftBoredomReduction, 30)
        and valueEquals(vars.RedCraftSweatIntensity, 2)
        and valueEquals(vars.RedCraftFatigueCostPercent, 10)
end

local function writeAndRead(vars, key, value)
    local ok, err = pcall(function() vars[key] = value end)
    if not ok then return false, vars[key], tostring(err) end
    return valueEquals(vars[key], value), vars[key],
        valueEquals(vars[key], value) and "WRITE_READBACK_CONFIRMED"
            or "READBACK_MISMATCH"
end

local function emit(summary)
    local key = tostring(summary.reason) .. ":"
        .. tostring(summary.migrated) .. ":"
        .. tostring(summary.marker_present)
    if Migration.lastLogKey == key then return end
    Migration.lastLogKey = key
    print("[XNP RED PHYSICAL MIGRATION]"
        .. " marker=" .. Migration.MARKER_KEY
        .. " source_version=" .. Migration.SOURCE_VERSION
        .. " source_build_marker=" .. Migration.SOURCE_BUILD_MARKER
        .. " source_identity_basis="
        .. tostring(summary.source_identity_basis)
        .. " exact_false_triplet="
        .. tostring(summary.exact_false_triplet)
        .. " explicit_custom=" .. tostring(summary.explicit_custom)
        .. " authority=" .. tostring(summary.authority_reason)
        .. " migrated=" .. tostring(summary.migrated)
        .. " write_count=" .. tostring(summary.write_count)
        .. " reason=" .. tostring(summary.reason))
end

function Migration.Apply(vars, options)
    options = type(options) == "table" and options or {}
    local authority, authorityReason = hasAuthority(options)
    local markerPresent = vars and markerSet(vars[Migration.MARKER_KEY])
        or false
    local explicitCustom = vars
        and markerSet(vars[Migration.EXPLICIT_CUSTOM_MARKER_KEY]) or false
    if options.explicit_custom == true then explicitCustom = true end
    local fingerprint = test4Fingerprint(vars)
    local summary = {
        marker_key = Migration.MARKER_KEY,
        marker_present = markerPresent,
        source_version = Migration.SOURCE_VERSION,
        source_build_marker = Migration.SOURCE_BUILD_MARKER,
        source_identity_basis = fingerprint
            and "TEST4_UNIQUE_RED_MOOD_SANDBOX_FINGERPRINT"
            or "UNPROVEN",
        exact_false_triplet = exactFalseTriplet(vars),
        explicit_custom = explicitCustom,
        authority = authority,
        authority_reason = authorityReason,
        test_channel = isTargetTestChannel(),
        migrated = false,
        write_count = 0,
        explicit_user_false_overwrite_count = 0,
        reason = "NOT_EVALUATED",
    }

    if type(vars) ~= "table" then
        summary.reason = "SANDBOX_NAMESPACE_MISSING"
    elseif markerPresent then
        summary.reason = "MIGRATION_ALREADY_APPLIED"
    elseif not summary.test_channel then
        summary.reason = "NOT_TARGET_TEST_CHANNEL"
    elseif not authority then
        summary.reason = authorityReason
    elseif explicitCustom then
        summary.reason = "EXPLICIT_USER_CUSTOM_PRESERVED"
    elseif not fingerprint then
        summary.reason = "SOURCE_TEST4_NOT_PROVEN"
    elseif not summary.exact_false_triplet then
        summary.reason = "NOT_EXACT_FALSE_TRIPLET_PRESERVED"
    else
        local before = {}
        for index = 1, #Keys do
            before[Keys[index]] = vars[Keys[index]]
        end
        local writesOk = true
        for index = 1, #Keys do
            local ok = writeAndRead(vars, Keys[index], true)
            if ok then
                summary.write_count = summary.write_count + 1
            else
                writesOk = false
                break
            end
        end
        local markerOk = false
        if writesOk and summary.write_count == #Keys then
            markerOk = writeAndRead(vars, Migration.MARKER_KEY, true)
        end
        if writesOk and markerOk then
            summary.migrated = true
            summary.marker_present = true
            summary.reason = "TEST4_EXACT_FALSE_TRIPLET_MIGRATED"
        else
            for index = 1, #Keys do
                vars[Keys[index]] = before[Keys[index]]
            end
            vars[Migration.MARKER_KEY] = nil
            summary.write_count = 0
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

function Migration.GetKeys()
    return Keys
end

Core.RedPhysicalFeedbackMigration = Migration
return Migration
