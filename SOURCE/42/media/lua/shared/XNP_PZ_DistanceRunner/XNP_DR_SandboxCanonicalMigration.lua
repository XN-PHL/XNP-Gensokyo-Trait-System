require "XNP_PZ_DistanceRunner/XNP_DR_SandboxClassification"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Classification = Core.SandboxClassification

local Migration = {
    MARKER_KEY = "XNP_B42_20_220_TEST4_CONFIG_HEALTH_MIGRATION_A",
    PROVENANCE_KEY = "XNP_B42_20_SANDBOX_SOURCE_PROVENANCE",
    KNOWN_SOURCES = {
        XNP_V2_210_TEST2_CHANNEL_MUTEX_A = true,
        XNP_V2_220_TEST2_B42_20_DUAL_CHANNEL_A = true,
        XNP_V2_220_TEST3_CONFIG_HEALTH_A = true,
    },
    lastSummary = nil,
    emitted = false,
}

local Rules = {
    {
        key = "GreenRuntimeTestModeEnabled",
        old_value = true,
        new_value = false,
    },
    {
        key = "GreenRuntimeTestNoCooldown",
        old_value = true,
        new_value = false,
    },
    {
        key = "GreenRuntimeTestIgnoreResourceAdmission",
        old_value = true,
        new_value = false,
    },
    {
        key = "GreenRuntimeTestAllowCastAtMaxFatigue",
        old_value = true,
        new_value = false,
    },
    {
        key = "GreenRuntimeTestAllowCastAtZeroEndurance",
        old_value = true,
        new_value = false,
    },
    {
        key = "PurpleCooldownRealSeconds",
        old_value = 3,
        new_value = 5,
    },
    {
        key = "PurpleInvulnerabilitySeconds",
        old_value = 0,
        new_value = 10,
    },
    {
        key = "PurpleLocalZombiePushEnabled",
        old_value = false,
        new_value = true,
    },
}

local function valueEquals(left, right)
    if type(left) == "number" and type(right) == "number" then
        return math.abs(left - right) < 0.0001
    end
    return left == right
end

local function markerSet(vars)
    if not vars then
        return false
    end
    local value = vars[Migration.MARKER_KEY]
    return value == true or value == 1 or value == "1"
        or string.lower(tostring(value or "")) == "true"
end

local function writeAndRead(vars, key, value)
    if not vars then
        return false, nil, "SANDBOX_NAMESPACE_MISSING"
    end
    local ok, err = pcall(function()
        vars[key] = value
    end)
    local readback = vars[key]
    if not ok then
        return false, readback, "WRITE_FAILED:" .. tostring(err)
    end
    if not valueEquals(readback, value) then
        return false, readback, "READBACK_MISMATCH"
    end
    return true, readback, "WRITE_READBACK_CONFIRMED"
end

local function makeRecord(rule, before, provenance)
    return {
        key = rule.key,
        before = before,
        source_provenance = provenance or "UNPROVEN",
        classification = Classification.GetClass(rule.key),
        migrated = false,
        reason = "NOT_EVALUATED",
        after = before,
        readback = before,
    }
end

local function emitOnce(summary)
    if Migration.emitted or not summary then
        return
    end
    Migration.emitted = true
    print("[XNP SANDBOX CANONICAL MIGRATION]"
        .. " marker=" .. Migration.MARKER_KEY
        .. " provenance=" .. tostring(summary.source_provenance)
        .. " migrated=" .. tostring(summary.migrated_count)
        .. " ambiguous=" .. tostring(summary.ambiguous_count)
        .. " writes=" .. tostring(summary.write_count)
        .. " marker_write_attempted=" .. tostring(summary.marker_write_attempted)
        .. " marker_write_status=" .. tostring(summary.marker_write_status)
        .. " marker_write_ok=" .. tostring(summary.marker_write_ok))
    for index = 1, #summary.records do
        local record = summary.records[index]
        if record.migrated or record.reason == "AMBIGUOUS_LEGACY_VALUE" then
            print("[XNP SANDBOX CANONICAL MIGRATION KEY]"
                .. " key=" .. tostring(record.key)
                .. " before=" .. tostring(record.before)
                .. " source_provenance=" .. tostring(record.source_provenance)
                .. " classification=" .. tostring(record.classification)
                .. " migrated=" .. tostring(record.migrated)
                .. " reason=" .. tostring(record.reason)
                .. " after=" .. tostring(record.after)
                .. " readback=" .. tostring(record.readback))
        end
    end
end

function Migration.Apply(vars, options)
    options = type(options) == "table" and options or {}
    local explicitCustom = type(options.explicit_custom_keys) == "table"
        and options.explicit_custom_keys or {}
    local provenance = vars and vars[Migration.PROVENANCE_KEY] or nil
    local knownSource = Migration.KNOWN_SOURCES[tostring(provenance)] == true
    local alreadyApplied = markerSet(vars)
    local authorized = options.authorized == true
        and options.confirmed == true
        and options.server_authority == true
    local summary = {
        marker_key = Migration.MARKER_KEY,
        source_provenance = provenance or "UNPROVEN",
        known_source = knownSource,
        already_applied = alreadyApplied,
        records = {},
        migrated_count = 0,
        ambiguous_count = 0,
        write_count = 0,
        ambiguous_user_value_auto_overwrite_count = 0,
        marker_write_attempted = false,
        marker_write_ok = alreadyApplied and true or nil,
        marker_write_status = alreadyApplied and "ALREADY_APPLIED"
            or "NOT_ATTEMPTED",
        marker_write_reason = alreadyApplied and "ALREADY_APPLIED"
            or "NOT_WRITTEN",
        authorized = authorized,
    }

    for index = 1, #Rules do
        local rule = Rules[index]
        local before = nil
        if vars then
            before = vars[rule.key]
        end
        local record = makeRecord(rule, before, provenance)

        if explicitCustom[rule.key] == true then
            record.reason = "EXPLICIT_USER_CUSTOM_PRESERVED"
        elseif alreadyApplied then
            record.reason = "MIGRATION_ALREADY_APPLIED"
        elseif before == nil then
            record.reason = "NO_RAW_VALUE_FORMAL_DEFAULT_APPLIES"
        elseif valueEquals(before, rule.old_value) and knownSource
            and authorized then
            local ok, readback, reason =
                writeAndRead(vars, rule.key, rule.new_value)
            record.migrated = ok
            record.reason = ok and "KNOWN_LEGACY_DEFAULT_MIGRATED"
                or reason
            record.after = ok and rule.new_value or before
            record.readback = readback
            if ok then
                summary.migrated_count = summary.migrated_count + 1
                summary.write_count = summary.write_count + 1
            end
        elseif valueEquals(before, rule.old_value) and knownSource then
            record.reason = "KNOWN_LEGACY_DEFAULT_REPAIR_AVAILABLE"
        elseif valueEquals(before, rule.old_value) then
            record.reason = "AMBIGUOUS_LEGACY_VALUE"
            summary.ambiguous_count = summary.ambiguous_count + 1
        else
            record.reason = "USER_OR_NONLEGACY_VALUE_PRESERVED"
        end

        if vars then
            record.readback = vars[rule.key]
            record.after = record.readback
        end
        summary.records[#summary.records + 1] = record
    end

    if vars and not alreadyApplied and authorized
        and summary.migrated_count > 0
        and summary.migrated_count == summary.write_count then
        local markerOk, markerReadback, markerReason =
            writeAndRead(vars, Migration.MARKER_KEY, true)
        summary.marker_write_attempted = true
        summary.marker_write_ok = markerOk
        summary.marker_write_status = markerOk and "WRITE_CONFIRMED" or "WRITE_FAILED"
        summary.marker_readback = markerReadback
        summary.marker_write_reason = markerReason
    elseif not vars then
        summary.marker_write_ok = nil
        summary.marker_write_status = "NOT_ATTEMPTED"
        summary.marker_write_reason = "SANDBOX_NAMESPACE_MISSING"
    elseif not authorized then
        summary.marker_write_ok = nil
        summary.marker_write_status = "NOT_ATTEMPTED"
        summary.marker_write_reason = "READ_ONLY_PLAN_REQUIRES_CONFIRMATION"
    elseif summary.migrated_count == 0 then
        summary.marker_write_ok = nil
        summary.marker_write_status = "NOT_ATTEMPTED"
        summary.marker_write_reason = "NO_ELIGIBLE_KNOWN_DEFAULTS"
    end

    Migration.lastSummary = summary
    emitOnce(summary)
    return summary
end

function Migration.IsKnownSource(value)
    return Migration.KNOWN_SOURCES[tostring(value)] == true
end

function Migration.GetRules()
    return Rules
end

function Migration.GetLastSummary()
    return Migration.lastSummary
end

Core.SandboxCanonicalMigration = Migration
return Migration
