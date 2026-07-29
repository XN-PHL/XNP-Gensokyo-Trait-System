require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local P = Core.PurplePhoenixConstants

local defaults = {
    enabled = true,
    triggerHealth = P.TRIGGER_MAIN_DEFAULT,
    invulnerabilitySeconds = P.INVULNERABILITY_SECONDS_DEFAULT,
    cooldownMode = P.COOLDOWN_MODE,
    cooldownRealSeconds = P.COOLDOWN_REAL_SECONDS_DEFAULT,
    fullCure = false,
    clearZombification = true,
    recoveryHealth = 1.0,
    enduranceRestore = 1.0,
    protectRadius = P.PROTECT_RADIUS_DEFAULT,
    protectDuration = P.PROTECT_DURATION_DEFAULT,
    protectPulseInterval = P.PROTECT_PULSE_INTERVAL_DEFAULT,
    showStatusIcon = true,
    tooltipEnabled = true,
    iconShakeDuringInvulnerability = true,
    manualToggleEnabled = true,
    fallProtectionEnabled = true,
    rangedPredeathProtectionEnabled = true,
    maximumTriggerCount = 0,
    diagnosticDeathLogEnabled = false,
    rightClickRepairEnabled = true,
}

local Config = { values = nil, lastHash = nil }

local function numberValue(vars, key, fallback, minValue, maxValue, scale)
    local factor = scale or 1
    local rawFallback = fallback / factor
    local value = Core.SandboxTuning.GetNumber(key, rawFallback, minValue / factor, maxValue / factor)
    value = value * factor
    return Constants.Clamp(value, minValue, maxValue)
end

local function booleanValue(vars, key, fallback)
    return Core.SandboxTuning.GetBoolean(key, fallback)
end

-- Builds one typed snapshot. Gameplay reads only this table, preventing mixed
-- old/new Sandbox keys and preserving deterministic defaults during live refresh.
local function buildSnapshot()
    local vars = nil
    local invulnerability = Core.SandboxTuning.GetPurpleInvulnerabilitySnapshot()
    local value = {
        enabled = booleanValue(vars, "PurpleEnabled", booleanValue(vars, "EnablePhoenixTraitLogic", defaults.enabled)),
        triggerHealth = numberValue(vars, "PurpleTriggerHealthPercent", P.TRIGGER_MAIN_DEFAULT, 0.01, 0.50, 0.01),
        invulnerabilitySeconds = Constants.Clamp(
            tonumber(invulnerability.value) or defaults.invulnerabilitySeconds,
            0, 30),
        invulnerabilitySourceKey = invulnerability.source_key,
        invulnerabilitySourceValue = invulnerability.source_value,
        invulnerabilityRawEffectiveMatch =
            invulnerability.raw_effective_match == true,
        invulnerabilityMigrationVersion = invulnerability.migration_version,
        cooldownMode = numberValue(vars, "PurpleCooldownMode", 1, 1, 1) == 1 and "REAL_SECONDS" or "REAL_SECONDS",
        cooldownRealSeconds = numberValue(vars, "PurpleCooldownRealSeconds", defaults.cooldownRealSeconds, 1, 300),
        -- Kept in the snapshot only as an explicit compatibility tombstone.
        -- Broad healing must never bypass the dedicated infection switches.
        fullCure = false,
        clearZombification = booleanValue(vars, "PurpleClearZombificationEnabled", defaults.clearZombification),
        clearZombieInfection = booleanValue(vars, "PurpleClearZombieInfectionEnabled", true),
        clearFakeInfection = booleanValue(vars, "PurpleClearFakeInfectionEnabled", true),
        recoveryHealth = numberValue(vars, "PurpleRecoveryHealthPercent", defaults.recoveryHealth, 0.01, 1.0, 0.01),
        enduranceRestore = numberValue(vars, "PurpleRecoveryEndurancePercent", numberValue(vars, "PhoenixRestoreEndurancePercent", defaults.enduranceRestore, 0, 1.0, 0.01), 0, 1.0, 0.01),
        protectRadius = numberValue(vars, "PhoenixProtectRadius", defaults.protectRadius, 0, 5),
        protectDuration = 0,
        protectPulseInterval = 0,
        showStatusIcon = booleanValue(vars, "EnableRoundMarkers", booleanValue(vars, "PhoenixShowStatusIcon", defaults.showStatusIcon)),
        tooltipEnabled = booleanValue(vars, "EnableTooltips", booleanValue(vars, "PhoenixTooltipEnable", defaults.tooltipEnabled)),
        iconShakeDuringInvulnerability = booleanValue(vars, "PhoenixIconShakeDuringInvulnerability", defaults.iconShakeDuringInvulnerability),
        manualToggleEnabled = booleanValue(vars, "PurpleManualToggleEnabled", defaults.manualToggleEnabled),
        fallProtectionEnabled = booleanValue(vars, "PurpleFallProtectionEnabled", defaults.fallProtectionEnabled),
        rangedPredeathProtectionEnabled = booleanValue(vars, "PurpleRangedPredeathProtectionEnabled", defaults.rangedPredeathProtectionEnabled),
        maximumTriggerCount = math.floor(numberValue(vars, "PurpleMaximumTriggerCount", defaults.maximumTriggerCount, 0, 999) + 0.5),
        diagnosticDeathLogEnabled = booleanValue(vars, "PurpleDiagnosticDeathLogEnabled", defaults.diagnosticDeathLogEnabled),
        rightClickRepairEnabled = booleanValue(vars, "PurpleRightClickRepairEnabled", defaults.rightClickRepairEnabled),
        localZombiePushEnabled = booleanValue(vars, "PurpleLocalZombiePushEnabled", true),
        multiplayerAuthority = 1,
        cooldownReadyState = 1,
    }
    return value
end

function Config.Refresh()
    local value = buildSnapshot()
    local fields = {}
    for key, item in pairs(value) do fields[#fields + 1] = key .. "=" .. tostring(item) end
    table.sort(fields)
    local hash = table.concat(fields, "|")
    Config.values = value
    if hash ~= Config.lastHash then
        Config.lastHash = hash
        print(string.format("[XNP PHOENIX CONFIG] enabled=%s trigger=%.2f invulnerable_sec=%.1f cooldown_mode=%s cooldown_real_seconds=%.1f source_key=%s source_value=%s migration_version=%s", tostring(value.enabled), value.triggerHealth, value.invulnerabilitySeconds, value.cooldownMode, value.cooldownRealSeconds, tostring(value.invulnerabilitySourceKey), tostring(value.invulnerabilitySourceValue), tostring(value.invulnerabilityMigrationVersion)))
    end
    return value
end

function Config.Get()
    return Config.values or Config.Refresh()
end

function Config.GetInvulnerabilityTransactionSnapshot()
    local value = Config.Get()
    return {
        invulnerability_seconds_snapshot = value.invulnerabilitySeconds,
        source_key = value.invulnerabilitySourceKey,
        source_value = value.invulnerabilitySourceValue,
        raw_effective_match = value.invulnerabilityRawEffectiveMatch,
        migration_version = value.invulnerabilityMigrationVersion,
    }
end

function Config.GetDefaults()
    return defaults
end

Core.PurplePhoenixConfig = Config
return Config
