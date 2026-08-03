require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxSchema"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxClassification"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxCanonicalMigration"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Schema = Core.SandboxSchema
local Classification = Core.SandboxClassification
local Migration = Core.SandboxCanonicalMigration
local RedMigration = Core.RedPhysicalFeedbackMigration

local Health = {
    BACKUP_STORE_KEY = "XNP_CONFIG_HEALTH_BACKUPS_V1",
    MAX_BACKUPS = 5,
    EXPORT_DIRECTORY = "Lua/XNP_Diagnostics/",
    lastReport = nil,
    lastOperation = nil,
    memoryStore = { items = {} },
}

local DeveloperBypassKeys = {
    GreenRuntimeTestModeEnabled = true,
    GreenRuntimeTestNoCooldown = true,
    GreenRuntimeTestIgnoreResourceAdmission = true,
    GreenRuntimeTestAllowCastAtZeroEndurance = true,
}

local BalancedPreset = {
    GreenRuntimeTestModeEnabled = false,
    GreenRuntimeTestNoCooldown = false,
    GreenRuntimeTestIgnoreResourceAdmission = false,
    GreenRuntimeTestAllowCastAtZeroEndurance = false,
    PurpleCooldownRealSeconds = 5,
    PurpleInvulnerabilitySeconds = 10,
    PurpleLocalZombiePushEnabled = true,
    GeneralGameplayPreset = 1,
}

local OptionalFeatureKeys = {
    YellowAltCrowdBreakoutEnabled = true,
    YellowAltCrowdBreakoutStrongControlOverride = true,
    YellowAltCrowdBreakoutNotification = true,
    RedCraftSweatEnabled = true,
    RedCraftBodyHeatEnabled = true,
    RedCraftExertionFeedbackEnabled = true,
}

local FilterNames = {
    ALL = true,
    DANGEROUS = true,
    KNOWN_STALE = true,
    USER_CUSTOM = true,
    DEVELOPER_BYPASS = true,
    PURPLE = true,
    GREEN = true,
}

local function valueEquals(left, right)
    if type(left) == "number" and type(right) == "number" then
        return math.abs(left - right) < 0.0001
    end
    return left == right
end

local function copyPrimitives(source)
    local output = {}
    if type(source) ~= "table" then return output end
    for key, value in pairs(source) do
        local kind = type(value)
        if kind == "boolean" or kind == "number" or kind == "string" then
            output[tostring(key)] = value
        end
    end
    return output
end

local function sortedKeys(source)
    local keys = {}
    for key in pairs(source or {}) do keys[#keys + 1] = tostring(key) end
    table.sort(keys)
    return keys
end

local function currentRawVars()
    if type(SandboxVars) == "table"
        and type(SandboxVars.XNPDistanceRunner) == "table" then
        return SandboxVars.XNPDistanceRunner
    end
    return nil
end

local function currentEffective()
    local snapshot = Core.SandboxTuning
        and Core.SandboxTuning.GetSnapshot
        and Core.SandboxTuning.GetSnapshot() or nil
    return snapshot and snapshot.values or {}
end

local function buildRuleMap()
    local output = {}
    local rules = Migration.GetRules and Migration.GetRules() or {}
    for index = 1, #rules do output[rules[index].key] = rules[index] end
    return output
end

local MigrationRulesByKey = buildRuleMap()

local function classifyDifference(key, rawValue, effectiveValue, fallback,
        provenance, explicitCustom)
    local rule = MigrationRulesByKey[key]
    if explicitCustom == true then
        return "EXPLICIT_USER_CUSTOM", false,
            "EXPLICIT_CUSTOM_EVIDENCE"
    end
    if rule and valueEquals(rawValue, rule.old_value)
        and Migration.IsKnownSource(provenance) then
        return "KNOWN_STALE_DEFAULT", true,
            "KNOWN_SOURCE_AND_EXACT_OLD_DEFAULT"
    end
    if rule and valueEquals(rawValue, rule.old_value) then
        return "AMBIGUOUS", false, "OLD_VALUE_WITHOUT_PROVEN_SOURCE"
    end
    if DeveloperBypassKeys[key] then
        if not valueEquals(rawValue, effectiveValue) then
            return "TEST_ONLY", false,
                "DEVELOPER_BYPASS_EFFECTIVE_GATE"
        end
        return "TEST_ONLY", false, "DEVELOPER_BYPASS"
    end
    if rawValue == nil then
        return "NONE", false, "CANONICAL_DEFAULT"
    end
    if not valueEquals(rawValue, effectiveValue) then
        return "RAW_EFFECTIVE", false, "RUNTIME_NORMALIZATION_OR_PRESET"
    end
    if not valueEquals(rawValue, fallback) then
        return "UI_RAW", false, "VISIBLE_NONDEFAULT_VALUE"
    end
    return "NONE", false, "MATCH"
end

local function isDangerous(row)
    if DeveloperBypassKeys[row.key] and row.raw_value == true then
        return true
    end
    if row.key == "PurpleInvulnerabilitySeconds"
        and tonumber(row.raw_value) == 0 then return true end
    if row.key == "PurpleLocalZombiePushEnabled"
        and row.raw_value == false then return true end
    return false
end

function Health.IsTestChannel()
    return Constants.MOD_ID == Constants.TEST_MOD_ID
        and Constants.VERSION == "2.3.0-test.1"
        and Constants.BUILD_ID == "XNP_V2_230_TEST1_MULTI_RECORD_INHERITANCE_A"
        and Constants.RELEASE_CHANNEL == "B42_20_TEST_WORKSHOP"
end

function Health.HasWriteAuthority(player, overrides)
    if not Health.IsTestChannel() then return false, "NOT_TEST_CHANNEL" end
    if type(overrides) == "table" and overrides.authority ~= nil then
        return overrides.authority == true,
            overrides.authority == true and "HARNESS_AUTHORITY"
                or "HARNESS_NOT_AUTHORIZED"
    end
    local client = false
    if type(isClient) == "function" then
        local ok, value = pcall(isClient)
        client = ok and value == true
    end
    if not client then return true, "SINGLEPLAYER_OR_SERVER" end
    if type(isServer) == "function" then
        local ok, value = pcall(isServer)
        if ok and value == true then return true, "SERVER_AUTHORITY" end
    end
    if type(isCoopHost) == "function" then
        local ok, value = pcall(isCoopHost)
        if ok and value == true then return true, "COOP_HOST_AUTHORITY" end
    end
    return false, "CLIENT_READ_ONLY"
end

function Health.BuildReport(options)
    options = type(options) == "table" and options or {}
    local raw = options.raw or currentRawVars() or {}
    local effective = options.effective or currentEffective()
    local specs = options.specs or Schema.specs or {}
    local provenance = options.provenance
        or raw[Migration.PROVENANCE_KEY] or "UNPROVEN"
    local explicit = options.explicit_custom_keys or {}
    local rows = {}
    local compared = 0
    local different = 0
    local rawOnly = 0
    local safeRepair = 0
    local dangerous = 0

    local keys = sortedKeys(specs)
    for index = 1, #keys do
        local key = keys[index]
        if Classification.IsVisible("TEST", key) then
            local spec = specs[key]
            local rawValue = raw[key]
            local effectiveValue = effective[key]
            local uiValue = rawValue ~= nil and rawValue or spec.fallback
            local differenceType, eligible, reason = classifyDifference(
                key, rawValue, effectiveValue, spec.fallback,
                provenance, explicit[key] == true)
            local row = {
                key = key,
                classification = Classification.GetClass(key),
                ui_value = uiValue,
                raw_value = rawValue,
                effective_value = effectiveValue,
                canonical_default = spec.fallback,
                saved_source = provenance,
                difference_type = differenceType,
                safe_repair_eligible = eligible,
                reason = reason,
            }
            row.dangerous = isDangerous(row)
            compared = compared + 1
            if rawValue ~= nil
                and not valueEquals(rawValue, effectiveValue) then
                different = different + 1
            end
            if eligible then safeRepair = safeRepair + 1 end
            if row.dangerous then dangerous = dangerous + 1 end
            rows[#rows + 1] = row
        end
    end

    for key in pairs(raw) do
        if specs[key] == nil
            and Classification.GetClass(key)
                ~= Classification.INTERNAL_NOT_SANDBOX then
            rawOnly = rawOnly + 1
            rows[#rows + 1] = {
                key = tostring(key),
                classification = Classification.GetClass(key),
                ui_value = raw[key],
                raw_value = raw[key],
                effective_value = nil,
                canonical_default = nil,
                saved_source = provenance,
                difference_type = "RAW_ONLY",
                safe_repair_eligible = false,
                reason = "RAW_KEY_NOT_IN_CURRENT_SCHEMA",
                dangerous = false,
            }
        end
    end

    local bypass = Core.SandboxTuning.GetDeveloperBypassStatus
        and Core.SandboxTuning.GetDeveloperBypassStatus() or {}
    local migration = Migration.GetLastSummary and Migration.GetLastSummary() or {}
    local redMigration = RedMigration and RedMigration.GetLastSummary
        and RedMigration.GetLastSummary() or {}
    local redPhysicalEnabled = effective.RedCraftSweatEnabled == true
        and effective.RedCraftBodyHeatEnabled == true
        and effective.RedCraftExertionFeedbackEnabled == true
    local report = {
        rows = rows,
        compared = compared,
        different = different,
        raw_only = rawOnly,
        safe_repair_count = safeRepair,
        dangerous_count = dangerous,
        provenance = provenance,
        migration_marker = raw[Migration.MARKER_KEY],
        migration_marker_key = Migration.MARKER_KEY,
        migration_marker_write_attempted = migration.marker_write_attempted == true,
        migration_marker_write_status = migration.marker_write_status
            or (raw[Migration.MARKER_KEY] and "ALREADY_APPLIED" or "NOT_ATTEMPTED"),
        migration_marker_write_ok = migration.marker_write_ok,
        migration_marker_write_reason = migration.marker_write_reason or "NOT_EVALUATED",
        red_physical_feedback_enabled = redPhysicalEnabled,
        red_physical_feedback_status = redPhysicalEnabled
            and "ENABLED" or "RED_PHYSICAL_FEEDBACK_NOT_ENABLED",
        red_physical_migration_marker = RedMigration
            and raw[RedMigration.MARKER_KEY] or nil,
        red_physical_migration_reason = redMigration.reason
            or "NOT_EVALUATED",
        developer_bypass = bypass,
        generated_at = options.timestamp or tostring(os.time()),
    }
    Health.lastReport = report
    return report
end

function Health.FilterRows(report, filterName)
    filterName = string.upper(tostring(filterName or "ALL"))
    if not FilterNames[filterName] then filterName = "ALL" end
    local output = {}
    for index = 1, #(report and report.rows or {}) do
        local row = report.rows[index]
        local include = filterName == "ALL"
            or (filterName == "DANGEROUS" and row.dangerous)
            or (filterName == "KNOWN_STALE"
                and row.difference_type == "KNOWN_STALE_DEFAULT")
            or (filterName == "USER_CUSTOM"
                and row.difference_type == "EXPLICIT_USER_CUSTOM")
            or (filterName == "DEVELOPER_BYPASS"
                and DeveloperBypassKeys[row.key] == true)
            or (filterName == "PURPLE"
                and string.sub(row.key, 1, 6) == "Purple")
            or (filterName == "GREEN"
                and string.sub(row.key, 1, 5) == "Green")
        if include then output[#output + 1] = row end
    end
    return output
end

local function backupStore(options)
    if type(options) == "table" and type(options.store) == "table" then
        options.store.items = options.store.items or {}
        return options.store
    end
    if type(ModData) == "table"
        and type(ModData.getOrCreate) == "function" then
        local ok, store = pcall(ModData.getOrCreate, Health.BACKUP_STORE_KEY)
        if ok and type(store) == "table" then
            store.items = type(store.items) == "table" and store.items or {}
            return store
        end
    end
    return Health.memoryStore
end

local function captureSnapshot(vars)
    return copyPrimitives(vars)
end

function Health.CreateBackup(options, reason)
    options = type(options) == "table" and options or {}
    local vars = options.raw or currentRawVars()
    if type(vars) ~= "table" then return false, "SANDBOX_UNAVAILABLE" end
    local store = backupStore(options)
    local entry = {
        timestamp = options.timestamp or tostring(os.time()),
        reason = tostring(reason or "MANUAL"),
        values = captureSnapshot(vars),
        version = Constants.VERSION,
        marker = Constants.BUILD_ID,
    }
    table.insert(store.items, 1, entry)
    while #store.items > Health.MAX_BACKUPS do
        table.remove(store.items)
    end
    store.last_backup_timestamp = entry.timestamp
    if type(ModData) == "table" and type(ModData.transmit) == "function"
        and options.store == nil then
        pcall(ModData.transmit, Health.BACKUP_STORE_KEY)
    end
    return true, entry
end

local function rollback(vars, snapshot)
    for key, value in pairs(vars) do
        local kind = type(value)
        if (kind == "boolean" or kind == "number" or kind == "string")
            and snapshot[key] == nil then
            vars[key] = nil
        end
    end
    for key, value in pairs(snapshot) do vars[key] = value end
    if Core.SandboxTuning then Core.SandboxTuning.Refresh(true) end
end

local function writeChanges(options, changes, operation)
    options = type(options) == "table" and options or {}
    local authority, authorityReason =
        Health.HasWriteAuthority(options.player, options)
    if not authority then return false, authorityReason end
    if options.confirmed ~= true then return false, "CONFIRMATION_REQUIRED" end
    local vars = options.raw or currentRawVars()
    if type(vars) ~= "table" then return false, "SANDBOX_UNAVAILABLE" end
    local before = captureSnapshot(vars)
    local backupOk, backup = Health.CreateBackup(options,
        operation .. "_PREWRITE")
    if not backupOk then return false, backup end
    local writes = 0
    local ok, err = pcall(function()
        for key, value in pairs(changes) do
            vars[key] = value
            if not valueEquals(vars[key], value) then
                error("READBACK_MISMATCH:" .. tostring(key))
            end
            writes = writes + 1
        end
    end)
    if ok and options.fail_after_write == true then
        ok = false
        err = "HARNESS_FORCED_FAILURE"
    end
    if not ok then
        rollback(vars, before)
        Health.lastOperation = {
            operation = operation,
            success = false,
            rolled_back = true,
            error = tostring(err),
        }
        return false, "WRITE_FAILED_ROLLED_BACK"
    end
    if Core.SandboxTuning then Core.SandboxTuning.Refresh(true) end
    Health.lastOperation = {
        operation = operation,
        success = true,
        rolled_back = false,
        write_count = writes,
        authority = authorityReason,
        backup_timestamp = backup.timestamp,
    }
    return true, Health.lastOperation
end

function Health.RepairKnownDefaults(options)
    options = type(options) == "table" and options or {}
    local vars = options.raw or currentRawVars()
    if type(vars) ~= "table" then return false, "SANDBOX_UNAVAILABLE" end
    local plan = Migration.Apply(vars, {
        explicit_custom_keys = options.explicit_custom_keys,
    })
    local available = 0
    for index = 1, #(plan.records or {}) do
        if plan.records[index].reason
            == "KNOWN_LEGACY_DEFAULT_REPAIR_AVAILABLE" then
            available = available + 1
        end
    end
    if available == 0 then return false, "NO_SAFE_REPAIR_AVAILABLE" end
    local authority, authorityReason =
        Health.HasWriteAuthority(options.player, options)
    if not authority then return false, authorityReason end
    if options.confirmed ~= true then return false, "CONFIRMATION_REQUIRED" end
    local before = captureSnapshot(vars)
    local backupOk = Health.CreateBackup(options, "SAFE_REPAIR_PREWRITE")
    if not backupOk then return false, "BACKUP_FAILED" end
    local result = Migration.Apply(vars, {
        authorized = true,
        confirmed = true,
        server_authority = true,
        explicit_custom_keys = options.explicit_custom_keys,
    })
    if result.migrated_count ~= available
        or result.marker_write_ok ~= true
        or options.fail_after_write == true then
        rollback(vars, before)
        Health.lastOperation = {
            operation = "SAFE_REPAIR",
            success = false,
            rolled_back = true,
        }
        return false, "SAFE_REPAIR_FAILED_ROLLED_BACK"
    end
    if Core.SandboxTuning then Core.SandboxTuning.Refresh(true) end
    Health.lastOperation = {
        operation = "SAFE_REPAIR",
        success = true,
        rolled_back = false,
        write_count = result.write_count,
        marker = Migration.MARKER_KEY,
        authority = authorityReason,
    }
    return true, Health.lastOperation
end

function Health.ApplyBalancedPreset(options)
    options = type(options) == "table" and options or {}
    local changes = copyPrimitives(BalancedPreset)
    local choices = type(options.optional_features) == "table"
        and options.optional_features or {}
    for key in pairs(OptionalFeatureKeys) do
        if choices[key] ~= nil then changes[key] = choices[key] == true end
    end
    if RedMigration and RedMigration.EXPLICIT_CUSTOM_MARKER_KEY
        and (choices.RedCraftSweatEnabled ~= nil
            or choices.RedCraftBodyHeatEnabled ~= nil
            or choices.RedCraftExertionFeedbackEnabled ~= nil) then
        changes[RedMigration.EXPLICIT_CUSTOM_MARKER_KEY] = true
    end
    return writeChanges(options, changes, "BALANCED_PRESET")
end

function Health.RestoreLatest(options)
    options = type(options) == "table" and options or {}
    local authority, authorityReason =
        Health.HasWriteAuthority(options.player, options)
    if not authority then return false, authorityReason end
    if options.confirmed ~= true then return false, "CONFIRMATION_REQUIRED" end
    local vars = options.raw or currentRawVars()
    if type(vars) ~= "table" then return false, "SANDBOX_UNAVAILABLE" end
    local store = backupStore(options)
    local target = store.items and store.items[1] or nil
    if not target or type(target.values) ~= "table" then
        return false, "NO_BACKUP_AVAILABLE"
    end
    local current = captureSnapshot(vars)
    local backupOk = Health.CreateBackup(options, "RESTORE_PREWRITE")
    if not backupOk then return false, "BACKUP_FAILED" end
    local ok = pcall(function()
        rollback(vars, target.values)
    end)
    if ok and options.fail_after_write == true then ok = false end
    if not ok then
        rollback(vars, current)
        return false, "RESTORE_FAILED_ROLLED_BACK"
    end
    Health.lastOperation = {
        operation = "RESTORE",
        success = true,
        authority = authorityReason,
        restored_timestamp = target.timestamp,
    }
    return true, Health.lastOperation
end

local function sanitizeText(value)
    local text = tostring(value or "")
    text = string.gsub(text, "[A-Za-z]:[\\/][^%s]+", "<path>")
    text = string.gsub(text, "[%w%._%%+-]+@[%w%.%-]+", "<email>")
    text = string.gsub(text, "[Tt][Oo][Kk][Ee][Nn]=[^%s]+", "token=<redacted>")
    return text
end

function Health.SerializeSanitized(report)
    report = report or Health.BuildReport()
    local lines = {
        "XNP_CONFIG_HEALTH_DIAGNOSTIC",
        "version=" .. sanitizeText(Constants.VERSION),
        "build_marker=" .. sanitizeText(Constants.BUILD_ID),
        "channel=" .. sanitizeText(Constants.RELEASE_CHANNEL),
        "mod_id=" .. sanitizeText(Constants.MOD_ID),
        "compared=" .. tostring(report.compared),
        "different=" .. tostring(report.different),
        "raw_only=" .. tostring(report.raw_only),
        "safe_repair_count=" .. tostring(report.safe_repair_count),
        "dangerous_count=" .. tostring(report.dangerous_count),
    }
    for index = 1, #report.rows do
        local row = report.rows[index]
        if row.difference_type ~= "NONE" then
            lines[#lines + 1] = table.concat({
                "key=" .. sanitizeText(row.key),
                "type=" .. sanitizeText(row.difference_type),
                "raw=" .. sanitizeText(row.raw_value),
                "effective=" .. sanitizeText(row.effective_value),
                "reason=" .. sanitizeText(row.reason),
            }, " ")
        end
    end
    return table.concat(lines, "\n") .. "\n"
end

function Health.ExportSanitized(options)
    options = type(options) == "table" and options or {}
    local content = Health.SerializeSanitized(
        options.report or Health.BuildReport(options))
    if options.writer then
        local ok, reason = options.writer(content)
        return ok == true, reason or "HARNESS_WRITER"
    end
    if type(getFileWriter) ~= "function" then
        return false, "FILE_WRITER_UNAVAILABLE"
    end
    local stamp = tostring(os.time())
    local filename = "XNP_ConfigHealth_" .. Constants.VERSION
        .. "_" .. stamp .. ".txt"
    local relativePath = Health.EXPORT_DIRECTORY .. filename
    local ok, writer = pcall(getFileWriter, relativePath, true, false)
    if not ok or not writer then return false, "EXPORT_OPEN_FAILED" end
    local writeOk = pcall(function()
        writer:write(content)
        writer:close()
    end)
    return writeOk, writeOk and relativePath or "EXPORT_WRITE_FAILED"
end

function Health.GetAuditSnapshot(options)
    local report = Health.BuildReport(options)
    local store = backupStore(options)
    return {
        test_only = true,
        read_only_entry = true,
        write_requires_confirmation = true,
        server_authority_gate = true,
        compared = report.compared,
        different = report.different,
        raw_only = report.raw_only,
        backup_count = #(store.items or {}),
        max_backups = Health.MAX_BACKUPS,
        sanitized_export = true,
        private_path_export_count = 0,
        last_operation = Health.lastOperation,
    }
end

function Health.GetBackupSummary(options)
    local store = backupStore(options)
    return {
        count = #(store.items or {}),
        last_backup_timestamp = store.last_backup_timestamp or "NONE",
        max_backups = Health.MAX_BACKUPS,
    }
end

Core.ConfigHealthCore = Health
return Health
