require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local P = Core.PurplePhoenixConstants

local defaults = {
    enabled = true,
    triggerHealth = P.TRIGGER_MAIN_DEFAULT,
    invulnerabilitySeconds = P.INVULNERABILITY_SECONDS_DEFAULT,
    baseCooldownDays = P.COOLDOWN_DAYS_DEFAULT,
    requirePanicZero = true,
    panicZeroThreshold = 0,
    earlyRechargeEnabled = true,
    earlyRechargeMaxDays = P.EARLY_RECHARGE_MAX_DAYS_DEFAULT,
    minimumCooldownDays = P.MINIMUM_COOLDOWN_DAYS_DEFAULT,
    wellFedCreditMaxDays = P.WELL_FED_CREDIT_MAX_DAYS_DEFAULT,
    healthyCreditMaxDays = P.HEALTHY_CREDIT_MAX_DAYS_DEFAULT,
    wellFedRequiredGameHours = P.WELL_FED_REQUIRED_HOURS_DEFAULT,
    healthyRequiredGameHours = P.HEALTHY_REQUIRED_HOURS_DEFAULT,
    healthyMinHealth = P.HEALTHY_MIN_HEALTH_DEFAULT,
    fullCure = true,
    clearZombification = true,
    enduranceRestore = 1.0,
    protectRadius = P.PROTECT_RADIUS_DEFAULT,
    protectDuration = P.PROTECT_DURATION_DEFAULT,
    protectPulseInterval = P.PROTECT_PULSE_INTERVAL_DEFAULT,
    showStatusIcon = true,
    tooltipEnabled = true,
    iconShakeDuringInvulnerability = true,
}

local Config = { values = nil, lastHash = nil }

local function numberValue(vars, key, fallback, minValue, maxValue, scale)
    local value = vars and vars[key] or nil
    if not Constants.IsFiniteNumber(value) then return fallback end
    value = value * (scale or 1)
    return Constants.Clamp(value, minValue, maxValue)
end

local function booleanValue(vars, key, fallback)
    local value = vars and vars[key] or nil
    if type(value) == "boolean" then return value end
    return fallback
end

-- Builds one typed snapshot. Gameplay reads only this table, preventing mixed
-- old/new Sandbox keys and preserving deterministic defaults during live refresh.
local function buildSnapshot()
    local vars = SandboxVars and SandboxVars.XNPDistanceRunner or nil
    local value = {
        enabled = booleanValue(vars, "PurpleEnabled", booleanValue(vars, "EnablePhoenixTraitLogic", defaults.enabled)),
        triggerHealth = numberValue(vars, "PurpleTriggerHealthPercent", P.TRIGGER_MAIN_DEFAULT, 0.01, 0.50, 0.01),
        invulnerabilitySeconds = 0,
        baseCooldownDays = numberValue(vars, "PhoenixBaseCooldownDays", defaults.baseCooldownDays, 1, 30),
        requirePanicZero = booleanValue(vars, "PurplePanicGateEnabled", booleanValue(vars, "PhoenixRequirePanicZeroToRecharge", defaults.requirePanicZero)),
        panicZeroThreshold = numberValue(vars, "PhoenixPanicZeroThreshold", defaults.panicZeroThreshold, 0, 100),
        earlyRechargeEnabled = booleanValue(vars, "PhoenixEarlyRechargeEnabled", defaults.earlyRechargeEnabled),
        earlyRechargeMaxDays = numberValue(vars, "PhoenixEarlyRechargeMaxDays", defaults.earlyRechargeMaxDays, 0, 6),
        minimumCooldownDays = numberValue(vars, "PhoenixMinimumCooldownDays", defaults.minimumCooldownDays, 1, 30),
        wellFedCreditMaxDays = numberValue(vars, "PhoenixWellFedCreditMaxDays", defaults.wellFedCreditMaxDays, 0, 6),
        healthyCreditMaxDays = numberValue(vars, "PhoenixHealthyCreditMaxDays", defaults.healthyCreditMaxDays, 0, 6),
        wellFedRequiredGameHours = numberValue(vars, "PhoenixWellFedRequiredGameHours", defaults.wellFedRequiredGameHours, 1, 720),
        healthyRequiredGameHours = numberValue(vars, "PhoenixHealthyRequiredGameHours", defaults.healthyRequiredGameHours, 1, 720),
        healthyMinHealth = numberValue(vars, "PhoenixHealthyMinHealthPercent", defaults.healthyMinHealth, 0.50, 1.0, 0.01),
        fullCure = booleanValue(vars, "PhoenixFullCureToggle", defaults.fullCure),
        clearZombification = booleanValue(vars, "PhoenixClearZombification", defaults.clearZombification),
        enduranceRestore = numberValue(vars, "PurpleRecoveryEndurancePercent", numberValue(vars, "PhoenixRestoreEndurancePercent", defaults.enduranceRestore, 0, 1.0, 0.01), 0, 1.0, 0.01),
        protectRadius = numberValue(vars, "PhoenixProtectRadius", defaults.protectRadius, 0, 5),
        protectDuration = 0,
        protectPulseInterval = 0,
        showStatusIcon = booleanValue(vars, "EnableRoundMarkers", booleanValue(vars, "PhoenixShowStatusIcon", defaults.showStatusIcon)),
        tooltipEnabled = booleanValue(vars, "EnableTooltips", booleanValue(vars, "PhoenixTooltipEnable", defaults.tooltipEnabled)),
        iconShakeDuringInvulnerability = booleanValue(vars, "PhoenixIconShakeDuringInvulnerability", defaults.iconShakeDuringInvulnerability),
    }
    value.minimumCooldownDays = math.min(value.minimumCooldownDays, value.baseCooldownDays)
    value.earlyRechargeMaxDays = math.min(value.earlyRechargeMaxDays, value.baseCooldownDays - value.minimumCooldownDays)
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
        print(string.format("[XNP PHOENIX CONFIG] enabled=%s trigger=%.2f invulnerable_sec=%.1f base_days=%.1f min_days=%.1f early_max=%.1f panic_gate=%s", tostring(value.enabled), value.triggerHealth, value.invulnerabilitySeconds, value.baseCooldownDays, value.minimumCooldownDays, value.earlyRechargeMaxDays, tostring(value.requirePanicZero)))
    end
    return value
end

function Config.Get()
    return Config.values or Config.Refresh()
end

function Config.GetDefaults()
    return defaults
end

Core.PurplePhoenixConfig = Config
return Config
