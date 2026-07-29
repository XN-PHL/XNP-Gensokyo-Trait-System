require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxSchema"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleInvulnerabilityResolver"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config
local Schema = Core.SandboxSchema

local SandboxTuning = {
    namespace = "XNPDistanceRunner",
    loaded = false,
    frame = 0,
    lastHash = nil,
    lastWarningKey = nil,
    lastCostLogKey = nil,
    snapshot = nil,
    normalizationWarned = false,
    legacyPresetMigrationChecked = false,
    legacyPresetImported = false,
    legacyPresetValue = nil,
    legacyPresetSource = "NOT_CHECKED",
    greenLifetimeMigrationChecked = false,
}

local LEGACY_PRESET_MIGRATION_MARKER = "XNP_056071_LegacyPresetMigration"
local LegacyPresetMap = {
    [1] = 1, -- Release -> VanillaPlus
    [2] = 3, -- Testing -> Action
    [3] = 5, -- Custom -> Custom
}

local Release = {
    EnableMod = true,
    TuningPreset = 1,
    EnableDebugSummary = false,
    LiveRefreshTuning = true,
    GlobalSkillCostMultiplier = 1.00,
    ZombieImpactCostMultiplier = 0.24,
    JogBumpCostMultiplier = 1.00,
    SprintPrecollisionCostMultiplier = 1.00,
    SprintVehicleZombieCostMultiplier = 1.00,
    ControlledEscapeCostMultiplier = 1.00,
    NativeTripCostMultiplier = 1.00,
    StaminaAssistIntensity = 1.00,
    BlueRefundPercent = 30,
    YellowRefundPercent = 38,
    RedRefundPercent = 55,
    EnableLowEnduranceFoodConversion = true,
    EnableTieredFoodRecovery = true,
    FoodRecoveryPulseSeconds = 2.0,
    BlueFoodCostPercent = 0.5,
    BlueEnduranceGainPercent = 1.5,
    YellowRedFoodCostPercent = 1.0,
    YellowRedEnduranceGainPercent = 2.0,
    FoodConversionTriggerPercent = 30,
    FoodConversionTargetPercent = 40,
    MinimumFoodReservePercent = 40,
    FoodToEnduranceRatioPercent = 100,
    FoodConversionRatePercentPerSecond = 1,
    EnableHighEnduranceMeleePower = true,
    MeleePowerStartEndurancePercent = 80,
    MeleePowerFullEndurancePercent = 95,
    MeleePowerMaxMultiplier = 2.00,
    ExtraHungerCostMultiplier = 1.00,
    ResourceGateEnabled = true,
    GreenExitPercent = 70,
    GreenEnterPercent = 76,
    BlueLowerPercent = 36,
    YellowLowerPercent = 14,
    ShowStatusIcon = true,
    EnableStatusShake = true,
    PerformanceMode = 2,
    IdleThreatScanMs = 500,
    ActiveThreatScanMs = 100,
    CriticalThreatScanMs = 50,
    MaxNearbyCandidates = 16,
    EnableRuntimeDebug = false,
    EnableYellowTraitSystem = true,
    EnablePurplePhoenixSystem = true,
    EnableGreenTraitSystem = true,
    EnableRedTraitSystem = true,
    GreenExperimentalEntityRendering = false,
    RedStarterItemCount = 3,
    RedCraftEnabled = true,
    RedCraftDurationSeconds = 4.0,
    RedCraftHealthCost = 0.05,
    RedCraftHungerCost = 0.10,
    RedCraftSweatEnabled = true,
    RedCraftSweatIntensity = 2,
    RedCraftFatigueCostPercent = 10,
    RedCraftBodyHeatEnabled = true,
    RedCraftExertionFeedbackEnabled = true,
    YellowAltCrowdBreakoutEnabled = true,
    YellowAltCrowdBreakoutRadiusTiles = 1.75,
    YellowAltCrowdBreakoutMinimumNearbyZombies = 3,
    YellowAltCrowdBreakoutCooldownSeconds = 8,
    YellowAltCrowdBreakoutEnduranceCost = 0.12,
    YellowAltCrowdBreakoutStrongControlOverride = true,
    YellowAltCrowdBreakoutLowEnduranceMultiplier = 0.60,
    YellowAltCrowdBreakoutNotification = true,
    DeveloperTestToolsEnabled = false,
    RedSafetyFloorPercent = 20,
    RedStaminaImmediateRecovery = 0.50,
    RedStaminaPeriodicRecovery = 0.05,
    RedStaminaPeriodicIntervalSeconds = 2.0,
    RedStaminaPeriodicDurationSeconds = 20.0,
    RedFatigueReduction = 0.25,
    RedMoodReductionPercent = 50,
    RedHealingHealthAmount = 25,
    RedHealFractureEnabled = true,
    RedClearZombieInfectionEnabled = true,
    RedHealMinorWoundCount = 3,
    RedHealMajorWoundCount = 1,
}

local Testing = {
    EnableMod = true,
    TuningPreset = 2,
    EnableDebugSummary = false,
    LiveRefreshTuning = true,
    GlobalSkillCostMultiplier = 1.00,
    ZombieImpactCostMultiplier = 0.24,
    JogBumpCostMultiplier = 1.00,
    SprintPrecollisionCostMultiplier = 1.00,
    SprintVehicleZombieCostMultiplier = 1.00,
    ControlledEscapeCostMultiplier = 1.00,
    NativeTripCostMultiplier = 1.00,
    StaminaAssistIntensity = 1.00,
    BlueRefundPercent = 30,
    YellowRefundPercent = 38,
    RedRefundPercent = 55,
    EnableLowEnduranceFoodConversion = true,
    EnableTieredFoodRecovery = true,
    FoodRecoveryPulseSeconds = 2.0,
    BlueFoodCostPercent = 0.5,
    BlueEnduranceGainPercent = 1.5,
    YellowRedFoodCostPercent = 1.0,
    YellowRedEnduranceGainPercent = 2.0,
    FoodConversionTriggerPercent = 30,
    FoodConversionTargetPercent = 40,
    MinimumFoodReservePercent = 40,
    FoodToEnduranceRatioPercent = 100,
    FoodConversionRatePercentPerSecond = 1,
    EnableHighEnduranceMeleePower = true,
    MeleePowerStartEndurancePercent = 80,
    MeleePowerFullEndurancePercent = 95,
    MeleePowerMaxMultiplier = 2.00,
    ExtraHungerCostMultiplier = 1.00,
    ResourceGateEnabled = true,
    GreenExitPercent = 80,
    GreenEnterPercent = 86,
    BlueLowerPercent = 55,
    YellowLowerPercent = 30,
    ShowStatusIcon = true,
    EnableStatusShake = true,
    PerformanceMode = 2,
    IdleThreatScanMs = 500,
    ActiveThreatScanMs = 100,
    CriticalThreatScanMs = 50,
    MaxNearbyCandidates = 16,
    EnableRuntimeDebug = false,
    EnableYellowTraitSystem = true,
    EnablePurplePhoenixSystem = true,
    EnableGreenTraitSystem = true,
    EnableRedTraitSystem = true,
    GreenExperimentalEntityRendering = false,
    RedStarterItemCount = 3,
    RedCraftEnabled = true,
    RedCraftDurationSeconds = 4.0,
    RedCraftHealthCost = 0.05,
    RedCraftHungerCost = 0.10,
    RedCraftSweatEnabled = true,
    RedCraftSweatIntensity = 2,
    RedCraftFatigueCostPercent = 10,
    RedCraftBodyHeatEnabled = true,
    RedCraftExertionFeedbackEnabled = true,
    YellowAltCrowdBreakoutEnabled = true,
    YellowAltCrowdBreakoutRadiusTiles = 1.75,
    YellowAltCrowdBreakoutMinimumNearbyZombies = 3,
    YellowAltCrowdBreakoutCooldownSeconds = 8,
    YellowAltCrowdBreakoutEnduranceCost = 0.12,
    YellowAltCrowdBreakoutStrongControlOverride = true,
    YellowAltCrowdBreakoutLowEnduranceMultiplier = 0.60,
    YellowAltCrowdBreakoutNotification = true,
    DeveloperTestToolsEnabled = false,
    RedSafetyFloorPercent = 20,
    RedStaminaImmediateRecovery = 0.50,
    RedStaminaPeriodicRecovery = 0.05,
    RedStaminaPeriodicIntervalSeconds = 2.0,
    RedStaminaPeriodicDurationSeconds = 20.0,
    RedFatigueReduction = 0.25,
    RedMoodReductionPercent = 50,
    RedHealingHealthAmount = 25,
    RedHealFractureEnabled = true,
    RedClearZombieInfectionEnabled = true,
    RedHealMinorWoundCount = 3,
    RedHealMajorWoundCount = 1,
}

local Specs = {
    EnableMod = { kind = "boolean", fallback = Release.EnableMod },
    TuningPreset = { kind = "number", fallback = Release.TuningPreset, min = 1, max = 3 },
    EnableDebugSummary = { kind = "boolean", fallback = Release.EnableDebugSummary },
    LiveRefreshTuning = { kind = "boolean", fallback = Release.LiveRefreshTuning },
    GlobalSkillCostMultiplier = { kind = "number", fallback = Release.GlobalSkillCostMultiplier, min = 0.00, max = 2.00 },
    ZombieImpactCostMultiplier = { kind = "number", fallback = Release.ZombieImpactCostMultiplier, min = 0.00, max = 2.00 },
    JogBumpCostMultiplier = { kind = "number", fallback = Release.JogBumpCostMultiplier, min = 0.00, max = 2.00 },
    SprintPrecollisionCostMultiplier = { kind = "number", fallback = Release.SprintPrecollisionCostMultiplier, min = 0.00, max = 2.00 },
    SprintVehicleZombieCostMultiplier = { kind = "number", fallback = Release.SprintVehicleZombieCostMultiplier, min = 0.00, max = 2.00 },
    ControlledEscapeCostMultiplier = { kind = "number", fallback = Release.ControlledEscapeCostMultiplier, min = 0.00, max = 2.00 },
    NativeTripCostMultiplier = { kind = "number", fallback = Release.NativeTripCostMultiplier, min = 0.00, max = 2.00 },
    StaminaAssistIntensity = { kind = "number", fallback = Release.StaminaAssistIntensity, min = 0.00, max = 2.00 },
    BlueRefundPercent = { kind = "number", fallback = Release.BlueRefundPercent, min = 0, max = 90 },
    YellowRefundPercent = { kind = "number", fallback = Release.YellowRefundPercent, min = 0, max = 90 },
    RedRefundPercent = { kind = "number", fallback = Release.RedRefundPercent, min = 0, max = 90 },
    EnableLowEnduranceFoodConversion = { kind = "boolean", fallback = Release.EnableLowEnduranceFoodConversion },
    EnableTieredFoodRecovery = { kind = "boolean", fallback = Release.EnableTieredFoodRecovery },
    FoodRecoveryPulseSeconds = { kind = "number", fallback = Release.FoodRecoveryPulseSeconds, min = 0.50, max = 10.00 },
    BlueFoodCostPercent = { kind = "number", fallback = Release.BlueFoodCostPercent, min = 0.00, max = 10.00 },
    BlueEnduranceGainPercent = { kind = "number", fallback = Release.BlueEnduranceGainPercent, min = 0.01, max = 20.00 },
    YellowRedFoodCostPercent = { kind = "number", fallback = Release.YellowRedFoodCostPercent, min = 0.00, max = 10.00 },
    YellowRedEnduranceGainPercent = { kind = "number", fallback = Release.YellowRedEnduranceGainPercent, min = 0.01, max = 20.00 },
    FoodConversionTriggerPercent = { kind = "number", fallback = Release.FoodConversionTriggerPercent, min = 5, max = 95 },
    FoodConversionTargetPercent = { kind = "number", fallback = Release.FoodConversionTargetPercent, min = 5, max = 95 },
    MinimumFoodReservePercent = { kind = "number", fallback = Release.MinimumFoodReservePercent, min = 40, max = 95 },
    FoodToEnduranceRatioPercent = { kind = "number", fallback = Release.FoodToEnduranceRatioPercent, min = 25, max = 400 },
    FoodConversionRatePercentPerSecond = { kind = "number", fallback = Release.FoodConversionRatePercentPerSecond, min = 1, max = 10 },
    EnableHighEnduranceMeleePower = { kind = "boolean", fallback = Release.EnableHighEnduranceMeleePower },
    MeleePowerStartEndurancePercent = { kind = "number", fallback = Release.MeleePowerStartEndurancePercent, min = 1, max = 100 },
    MeleePowerFullEndurancePercent = { kind = "number", fallback = Release.MeleePowerFullEndurancePercent, min = 1, max = 100 },
    MeleePowerMaxMultiplier = { kind = "number", fallback = Release.MeleePowerMaxMultiplier, min = 1.00, max = 2.00 },
    ExtraHungerCostMultiplier = { kind = "number", fallback = Release.ExtraHungerCostMultiplier, min = 0.00, max = 3.00 },
    ResourceGateEnabled = { kind = "boolean", fallback = Release.ResourceGateEnabled },
    GreenExitPercent = { kind = "number", fallback = Release.GreenExitPercent, min = 40, max = 95 },
    GreenEnterPercent = { kind = "number", fallback = Release.GreenEnterPercent, min = 45, max = 100 },
    BlueLowerPercent = { kind = "number", fallback = Release.BlueLowerPercent, min = 10, max = 80 },
    YellowLowerPercent = { kind = "number", fallback = Release.YellowLowerPercent, min = 1, max = 60 },
    ShowStatusIcon = { kind = "boolean", fallback = Release.ShowStatusIcon },
    EnableStatusShake = { kind = "boolean", fallback = Release.EnableStatusShake },
    PerformanceMode = { kind = "number", fallback = Release.PerformanceMode, min = 1, max = 3 },
    IdleThreatScanMs = { kind = "number", fallback = Release.IdleThreatScanMs, min = 100, max = 2000 },
    ActiveThreatScanMs = { kind = "number", fallback = Release.ActiveThreatScanMs, min = 50, max = 1000 },
    CriticalThreatScanMs = { kind = "number", fallback = Release.CriticalThreatScanMs, min = 25, max = 500 },
    MaxNearbyCandidates = { kind = "number", fallback = Release.MaxNearbyCandidates, min = 4, max = 16 },
    EnableRuntimeDebug = { kind = "boolean", fallback = Release.EnableRuntimeDebug },
    EnableYellowTraitSystem = { kind = "boolean", fallback = Release.EnableYellowTraitSystem },
    EnablePurplePhoenixSystem = { kind = "boolean", fallback = Release.EnablePurplePhoenixSystem },
    EnableGreenTraitSystem = { kind = "boolean", fallback = Release.EnableGreenTraitSystem },
    EnableRedTraitSystem = { kind = "boolean", fallback = Release.EnableRedTraitSystem },
    GreenExperimentalEntityRendering = { kind = "boolean", fallback = false },
    RedStarterItemCount = { kind = "number", fallback = Release.RedStarterItemCount, min = 0, max = 20 },
    RedCraftEnabled = { kind = "boolean", fallback = Release.RedCraftEnabled },
    RedCraftDurationSeconds = { kind = "number", fallback = Release.RedCraftDurationSeconds, min = 0.5, max = 60.0 },
    RedCraftHealthCost = { kind = "number", fallback = Release.RedCraftHealthCost, min = 0.0, max = 0.5 },
    RedCraftHungerCost = { kind = "number", fallback = Release.RedCraftHungerCost, min = 0.0, max = 1.0 },
    RedSafetyFloorPercent = { kind = "number", fallback = Release.RedSafetyFloorPercent, min = 1, max = 95 },
    RedStaminaImmediateRecovery = { kind = "number", fallback = Release.RedStaminaImmediateRecovery, min = 0.0, max = 1.0 },
    RedStaminaPeriodicRecovery = { kind = "number", fallback = Release.RedStaminaPeriodicRecovery, min = 0.0, max = 1.0 },
    RedStaminaPeriodicIntervalSeconds = { kind = "number", fallback = Release.RedStaminaPeriodicIntervalSeconds, min = 0.5, max = 60.0 },
    RedStaminaPeriodicDurationSeconds = { kind = "number", fallback = Release.RedStaminaPeriodicDurationSeconds, min = 0.0, max = 300.0 },
    RedFatigueReduction = { kind = "number", fallback = Release.RedFatigueReduction, min = 0.0, max = 1.0 },
    RedMoodReductionPercent = { kind = "number", fallback = Release.RedMoodReductionPercent, min = 0, max = 100 },
    RedHealingHealthAmount = { kind = "number", fallback = Release.RedHealingHealthAmount, min = 0, max = 100 },
    RedHealFractureEnabled = { kind = "boolean", fallback = Release.RedHealFractureEnabled },
    RedClearZombieInfectionEnabled = { kind = "boolean", fallback = Release.RedClearZombieInfectionEnabled },
    RedHealMinorWoundCount = { kind = "number", fallback = Release.RedHealMinorWoundCount, min = 0, max = 20 },
    RedHealMajorWoundCount = { kind = "number", fallback = Release.RedHealMajorWoundCount, min = 0, max = 20 },
}

-- The generated schema is the complete 0.5.60.7 option contract. Existing
-- release entries above remain authoritative where they already existed.
for name, spec in pairs(Schema.specs) do
    Specs[name] = spec
    if Release[name] == nil then Release[name] = spec.fallback end
    if Testing[name] == nil then Testing[name] = spec.fallback end
end

local AlwaysLiveNames = {
    "EnableMod",
    "Preset",
    "EnableDebugSummary",
    "EnableRuntimeDebug",
    "CompatibilityMode",
    "LegacySaveMigration",
    "EnableYellowTraitSystem",
    "EnablePurplePhoenixSystem",
    "EnableGreenTraitSystem",
    "EnableRedTraitSystem",
    "EnableRoundMarkers",
    "EnableTooltips",
    "EnableSounds",
    "HideMarkersWithMap",
    "MultiplayerAuthorityMode",
    "PerformancePreset",
    "DiagnosticLogLevel",
    "EvidenceLogEnabled",
    "PerformanceStatisticsEnabled",
    "GreenPerformanceStatisticsEnabled",
    "GreenRuntimeTestModeEnabled",
    "GreenRuntimeTestNoCooldown",
    "GreenRuntimeTestIgnoreResourceAdmission",
    "GreenRuntimeTestStillApplyCosts",
    "GreenRuntimeTestAllowCastAtMaxFatigue",
    "GreenRuntimeTestAllowCastAtZeroEndurance",
    "GreenCooldownEnabled",
    "GreenCooldownRealSeconds",
    "GreenCooldownSeconds",
    "GreenVisualMaximumFPS",
    "GreenSimulationUpdatesPerSecond",
    "GreenMaximumVirtualSpeedTilesPerSecond",
    "PurpleInvulnerabilitySeconds",
    "PurpleCooldownRealSeconds",
    "PurpleLocalZombiePushEnabled",
    "PurpleRightClickRepairEnabled",
    "PurpleAutoRearmAfterSuccessfulRestore",
    "YellowAltCrowdBreakoutEnabled",
    "YellowAltCrowdBreakoutRadiusTiles",
    "YellowAltCrowdBreakoutMinimumNearbyZombies",
    "YellowAltCrowdBreakoutCooldownSeconds",
    "YellowAltCrowdBreakoutEnduranceCost",
    "YellowAltCrowdBreakoutStrongControlOverride",
    "YellowAltCrowdBreakoutLowEnduranceMultiplier",
    "YellowAltCrowdBreakoutNotification",
    "RedCraftSweatEnabled",
    "RedCraftSweatIntensity",
    "RedCraftFatigueCostPercent",
    "RedCraftBodyHeatEnabled",
    "RedCraftExertionFeedbackEnabled",
    "DeveloperTestToolsEnabled",
}

local routeKeys = {
    JOG_BUMP = "JogBumpCostMultiplier",
    SPRINT_PRECOLLISION = "SprintPrecollisionCostMultiplier",
    SPRINT_VEHICLE_ZOMBIE = "SprintVehicleZombieCostMultiplier",
    CONTROLLED_ESCAPE = "ControlledEscapeCostMultiplier",
    NATIVE_TRIP = "NativeTripCostMultiplier",
}

local zombieImpactRoutes = {
    JOG_BUMP = true,
    SPRINT_PRECOLLISION = true,
    SPRINT_VEHICLE_ZOMBIE = true,
}

local function clamp(value, minValue, maxValue)
    return Constants.Clamp(value, minValue, maxValue)
end

local function copyTable(src)
    local out = {}
    for k, v in pairs(src) do
        out[k] = v
    end
    return out
end

local function sourceVars()
    if SandboxVars and SandboxVars.XNPDistanceRunner then
        return SandboxVars.XNPDistanceRunner
    end
    return nil
end

local function presetName(value)
    return Schema.presetNames[value] or "VANILLA_PLUS"
end

local function resolvePreset(vars)
    local fallback = Release.Preset or 1
    if not vars then return fallback end

    if Constants.IsFiniteNumber(vars.Preset) then
        local explicit = math.floor(clamp(vars.Preset, 1, 5) + 0.5)
        SandboxTuning.legacyPresetMigrationChecked = true
        if Constants.IsFiniteNumber(vars[LEGACY_PRESET_MIGRATION_MARKER])
            and math.floor(vars[LEGACY_PRESET_MIGRATION_MARKER] + 0.5) == explicit then
            SandboxTuning.legacyPresetImported = true
            SandboxTuning.legacyPresetValue = explicit
            SandboxTuning.legacyPresetSource = "LEGACY_TUNING_PRESET"
        else
            SandboxTuning.legacyPresetSource = "EXPLICIT_PRESET"
        end
        return explicit
    end

    if Constants.IsFiniteNumber(vars[LEGACY_PRESET_MIGRATION_MARKER]) then
        local migrated = math.floor(clamp(vars[LEGACY_PRESET_MIGRATION_MARKER], 1, 5) + 0.5)
        SandboxTuning.legacyPresetMigrationChecked = true
        SandboxTuning.legacyPresetImported = true
        SandboxTuning.legacyPresetValue = migrated
        SandboxTuning.legacyPresetSource = "LEGACY_MIGRATION_MARKER"
        return migrated
    end

    if not SandboxTuning.legacyPresetMigrationChecked then
        SandboxTuning.legacyPresetMigrationChecked = true
        if Constants.IsFiniteNumber(vars.TuningPreset) then
            local legacy = math.floor(clamp(vars.TuningPreset, 1, 3) + 0.5)
            local migrated = LegacyPresetMap[legacy] or fallback
            SandboxTuning.legacyPresetImported = true
            SandboxTuning.legacyPresetValue = migrated
            SandboxTuning.legacyPresetSource = "LEGACY_TUNING_PRESET"
            pcall(function()
                vars.Preset = migrated
                vars[LEGACY_PRESET_MIGRATION_MARKER] = migrated
            end)
            return migrated
        end
        SandboxTuning.legacyPresetSource = "NO_LEGACY_VALUE"
    end

    if SandboxTuning.legacyPresetImported and SandboxTuning.legacyPresetValue then
        return SandboxTuning.legacyPresetValue
    end
    return fallback
end

local function readNumber(vars, name, fallback, minValue, maxValue)
    local value = vars and vars[name] or nil
    if not Constants.IsFiniteNumber(value) then
        return fallback, value == nil and "MISSING" or "INVALID"
    end
    return clamp(value, minValue, maxValue), value ~= clamp(value, minValue, maxValue) and "CLAMPED" or nil
end

local function readBoolean(vars, name, fallback)
    local value = nil
    if vars then
        value = vars[name]
    end
    if type(value) == "boolean" then
        return value, nil
    end
    if value == nil then
        return fallback, "MISSING"
    end
    return fallback, "INVALID"
end

local function readCustom(vars)
    local out = {}
    local hadFallback = false
    for name, spec in pairs(Specs) do
        local value, reason
        if spec.kind == "boolean" then
            value, reason = readBoolean(vars, name, spec.fallback)
        else
            value, reason = readNumber(vars, name, spec.fallback, spec.min, spec.max)
            if spec.integer == true then value = math.floor(value + 0.5) end
        end
        out[name] = value
        if reason ~= nil then
            hadFallback = true
        end
    end
    return out, hadFallback
end

local function applyAliases(values)
    for alias, canonical in pairs(Schema.aliases) do
        values[alias] = values[canonical]
    end
end

local function applySafetyLocks(values)
    for name in pairs(Schema.safetyFalse) do values[name] = false end
    for name in pairs(Schema.safetyZero) do values[name] = 0 end
    for name in pairs(Schema.safetyOne or {}) do values[name] = 1 end
end

local function normalizeThresholds(values)
    local ge = values.GreenEnterPercent
    local gx = values.GreenExitPercent
    local bl = values.BlueLowerPercent
    local yl = values.YellowLowerPercent
    if ge > gx and gx > bl and bl > yl and yl > 0 then
        return false
    end
    values.GreenEnterPercent = Release.GreenEnterPercent
    values.GreenExitPercent = Release.GreenExitPercent
    values.BlueLowerPercent = Release.BlueLowerPercent
    values.YellowLowerPercent = Release.YellowLowerPercent
    return true
end

local function buildHash(values)
    local keys = {}
    for k in pairs(Specs) do
        keys[#keys + 1] = k
    end
    table.sort(keys)
    local parts = {}
    for i = 1, #keys do
        parts[#parts + 1] = keys[i] .. "=" .. tostring(values[keys[i]])
    end
    return table.concat(parts, ";")
end

local ImportantChangeNames = {
    "EnableRuntimeDebug",
    "EnableDebugSummary",
    "EvidenceLogEnabled",
    "PerformanceStatisticsEnabled",
    "GreenPerformanceStatisticsEnabled",
    "GreenRuntimeTestModeEnabled",
    "GreenRuntimeTestNoCooldown",
    "GreenRuntimeTestIgnoreResourceAdmission",
    "GreenRuntimeTestAllowCastAtMaxFatigue",
    "GreenRuntimeTestAllowCastAtZeroEndurance",
    "GreenCooldownEnabled",
    "GreenCooldownSeconds",
    "PurpleCooldownRealSeconds",
    "PurpleInvulnerabilitySeconds",
    "PurpleLocalZombiePushEnabled",
    "PurpleRightClickRepairEnabled",
}

local function shortDigest(text)
    text = tostring(text or "")
    local sum1 = 1
    local sum2 = 0
    for index = 1, #text do
        sum1 = (sum1 + string.byte(text, index)) % 65521
        sum2 = (sum2 + sum1) % 65521
    end
    return "v2-" .. tostring(#text) .. "-"
        .. tostring(sum1) .. "-" .. tostring(sum2)
end

local function summarizeChanges(oldValues, newValues)
    if type(newValues) ~= "table" then return 0, "NONE" end
    local count = 0
    for name in pairs(Specs) do
        local oldValue = type(oldValues) == "table" and oldValues[name] or nil
        if oldValue ~= newValues[name] then count = count + 1 end
    end
    local important = {}
    for index = 1, #ImportantChangeNames do
        local name = ImportantChangeNames[index]
        local oldValue = type(oldValues) == "table" and oldValues[name] or nil
        if oldValue ~= newValues[name] then
            important[#important + 1] = name .. "=" .. tostring(newValues[name])
        end
    end
    return count, #important > 0 and table.concat(important, ",") or "NONE"
end

local function makeSnapshot()
    local vars = sourceVars()
    local missingNamespace = vars == nil
    local presetValue = resolvePreset(vars)
    local name = presetName(presetValue)
    local values
    local fallback = missingNamespace
    if name == "CUSTOM" then
        values, fallback = readCustom(vars)
    else
        values = copyTable(Release)
        local overrides = Schema.presetOverrides[name] or {}
        for optionName, optionValue in pairs(overrides) do values[optionName] = optionValue end
    end
    for _, optionName in ipairs(AlwaysLiveNames) do
        local spec = Specs[optionName]
        if spec and spec.kind == "boolean" then
            values[optionName] = readBoolean(vars, optionName, values[optionName])
        elseif spec then
            values[optionName] = readNumber(vars, optionName, values[optionName], spec.min, spec.max)
            if spec.integer == true then values[optionName] = math.floor(values[optionName] + 0.5) end
        end
    end
    local redHealthCostMigrated = false
    if vars and vars.RedCraftHealthCostPoints == nil
        and Constants.IsFiniteNumber(vars.RedCraftHealthCost) then
        values.RedCraftHealthCostPoints = clamp(vars.RedCraftHealthCost * 100.0, 0, 99)
        redHealthCostMigrated = true
    end
    local greenRadiusMigrated = false
    if vars and Constants.IsFiniteNumber(vars.GreenExplosionRadiusTiles) then
        local legacyRadius = clamp(vars.GreenExplosionRadiusTiles, 0.5, 15)
        if vars.GreenKnockdownRadiusTiles == nil then
            values.GreenKnockdownRadiusTiles = legacyRadius
            greenRadiusMigrated = true
        end
        if vars.GreenLethalRadiusTiles == nil then
            values.GreenLethalRadiusTiles = clamp(legacyRadius * 0.5, 0.1, 15)
            greenRadiusMigrated = true
        end
    end
    local greenCooldownMigrated = false
    if vars and vars.GreenCooldownSeconds == nil
        and Constants.IsFiniteNumber(vars.GreenCooldownRealSeconds) then
        values.GreenCooldownSeconds = clamp(vars.GreenCooldownRealSeconds, 0.5, 120)
        greenCooldownMigrated = true
    end
    local greenTurnLevelMigrated = false
    if vars and vars.GreenGuidanceTurnLevel == nil
        and Constants.IsFiniteNumber(vars.GreenGuidanceMaxTurnRateDegreesPerSecond) then
        local legacyTurn = tonumber(vars.GreenGuidanceMaxTurnRateDegreesPerSecond)
        if legacyTurn <= 67.5 then
            values.GreenGuidanceTurnLevel = 1
        elseif legacyTurn <= 112.5 then
            values.GreenGuidanceTurnLevel = 2
        elseif legacyTurn <= 157.5 then
            values.GreenGuidanceTurnLevel = 3
        else
            values.GreenGuidanceTurnLevel = 4
        end
        greenTurnLevelMigrated = true
    end
    local purpleInvulnerability =
        Core.PurpleInvulnerabilityResolver.Resolve(vars)
    values.PurpleInvulnerabilitySeconds = purpleInvulnerability.value
    local releaseMigration = {
        version = "0.5.60.7.20",
        greenFps = false,
        greenHz = false,
        greenVirtualCap = false,
        purpleInvulnerabilityAlias = purpleInvulnerability.migrated == true,
        purplePushDefault = false,
    }
    if vars then
        local rawFps = tonumber(vars.GreenVisualMaximumFPS)
        local rawHz = tonumber(vars.GreenSimulationUpdatesPerSecond)
        local fpsMap = { [1] = 15, [2] = 30, [3] = 60 }
        local hzMap = { [1] = 20, [2] = 30, [3] = 60 }
        if rawFps and fpsMap[math.floor(rawFps + 0.5)] then
            values.GreenVisualMaximumFPS = fpsMap[math.floor(rawFps + 0.5)]
            releaseMigration.greenFps = true
        end
        if rawHz and hzMap[math.floor(rawHz + 0.5)] then
            values.GreenSimulationUpdatesPerSecond = hzMap[math.floor(rawHz + 0.5)]
            releaseMigration.greenHz = true
        end
        if name ~= "CUSTOM" and tonumber(vars.GreenMaximumVirtualSpeedTilesPerSecond) == 8 then
            values.GreenMaximumVirtualSpeedTilesPerSecond = 12
            releaseMigration.greenVirtualCap = true
        end
        -- V2 treats an explicit false as authoritative. The old profile
        -- migration must not silently re-enable the push behind the Sandbox UI.
        releaseMigration.purplePushDefault = false
    end
    local greenLifetimeAliasMigrated = false
    local greenLifetimeAliasSource = "NONE"
    if vars and not SandboxTuning.greenLifetimeMigrationChecked then
        SandboxTuning.greenLifetimeMigrationChecked = true
        local canonical = tonumber(vars.GreenMaximumFlightSeconds)
        local alias = tonumber(vars.GreenProjectileLifetimeSeconds)
        local aliasEnabled = vars.GreenProjectileLifetimeEnabled ~= false
        local canonicalIsOldDefault = canonical ~= nil and math.abs(canonical - 8.0) < 0.0001
        if aliasEnabled and alias ~= nil and alias == alias
            and (canonical == nil or canonicalIsOldDefault) then
            local migrated = clamp(alias, 0.5, 30.0)
            values.GreenMaximumFlightSeconds = migrated
            greenLifetimeAliasMigrated = true
            greenLifetimeAliasSource = "GreenProjectileLifetimeSeconds"
            pcall(function() vars.GreenMaximumFlightSeconds = migrated end)
        end
    end
    -- The removed duplicate-target option is intentionally ignored. Every old
    -- true value therefore migrates to the fixed false runtime policy.
    values.GreenAllowDuplicateTargetWhenNoAlternative = false
    values.Preset = presetValue
    applySafetyLocks(values)
    applyAliases(values)
    local normalized = normalizeThresholds(values)
    local hash = buildHash(values)
    return {
        namespace = SandboxTuning.namespace,
        values = values,
        preset = name,
        hash = hash,
        digest = shortDigest(hash),
        source = "SERVER_SANDBOX_VARS",
        missingNamespace = missingNamespace,
        fallback = fallback,
        thresholdsNormalized = normalized,
        serverAuthoritative = true,
        legacyPresetImported = SandboxTuning.legacyPresetImported,
        legacyPresetSource = SandboxTuning.legacyPresetSource,
        clientLocalOverride = false,
        redHealthCostMigrated = redHealthCostMigrated,
        greenRadiusMigrated = greenRadiusMigrated,
        greenCooldownMigrated = greenCooldownMigrated,
        greenTurnLevelMigrated = greenTurnLevelMigrated,
        greenLifetimeAliasMigrated = greenLifetimeAliasMigrated,
        greenLifetimeAliasSource = greenLifetimeAliasSource,
        greenDuplicateTargetMigratedFalse = true,
        purpleInvulnerability = purpleInvulnerability,
        releaseMigration = releaseMigration,
    }
end

local function warnOnce(key, message)
    if SandboxTuning.lastWarningKey ~= key then
        SandboxTuning.lastWarningKey = key
        print(message)
    end
end

local function printGreenSummary(snapshot, source)
    local values = snapshot and snapshot.values or {}
    print("[XNP GREEN CONFIG SUMMARY] source=" .. tostring(source)
        .. " preset=" .. tostring(snapshot and snapshot.preset or "UNKNOWN")
        .. " runtime_test=" .. tostring(values.GreenRuntimeTestModeEnabled == true)
        .. " no_cooldown=" .. tostring(values.GreenRuntimeTestNoCooldown == true)
        .. " resource_bypass="
        .. tostring(values.GreenRuntimeTestIgnoreResourceAdmission == true)
        .. " cooldown_enabled=" .. tostring(values.GreenCooldownEnabled == true)
        .. " cooldown_seconds=" .. tostring(values.GreenCooldownSeconds)
        .. " debug_summary=" .. tostring(values.EnableDebugSummary == true))
end

local function applyToConfig(snapshot)
    local v = snapshot.values
    Config.ENABLE_MOD = v.EnableMod == true
    Config.enable_mod = Config.ENABLE_MOD
    Config.DEBUG_SANDBOX_TUNING = v.EnableDebugSummary == true
    Config.SOUNDS_ENABLED = v.EnableSounds == true
    Config.DIAGNOSTIC_LOG_LEVEL = v.DiagnosticLogLevel
    Config.TRANSACTION_LOG_ENABLED = v.TransactionLogEnabled == true
    Config.EVIDENCE_LOG_ENABLED = v.EvidenceLogEnabled == true
    Config.MULTIPLAYER_AUTHORITY_MODE = 1
    Config.COMPATIBILITY_MODE = v.CompatibilityMode
    Config.LEGACY_SAVE_MIGRATION_ENABLED = v.LegacySaveMigration == true
    Config.RUNTIME_MODULE_STARTUP_LOGS = Config.RUNTIME_MODULE_STARTUP_LOGS
    local markersEnabled = v.EnableRoundMarkers == true and v.MarkersEnabled == true
    Config.STATUS_ICON_UI_ENABLED = markersEnabled and v.ShowStatusIcon == true and v.YellowMarkerEnabled == true
    Config.ICON_RECOVERY_ENABLED = Config.STATUS_ICON_UI_ENABLED
    Config.ICON_SHAKE_ENABLED = v.EnableStatusShake == true and v.YellowMarkerShakeEnabled == true
    Config.stamina_shake_enabled = Config.ICON_SHAKE_ENABLED
    Config.YELLOW_MARKER_SHAKE_INTENSITY = v.YellowMarkerShakeIntensity
    Config.YELLOW_MARKER_COLOR_PROFILE = v.YellowMarkerColorThresholds
    Config.XNP_MARKER_SCALE = v.MarkerScale
    Config.XNP_MARKER_OPACITY = v.MarkerOpacity
    Config.XNP_MARKER_SPACING = v.MarkerSpacing
    Config.XNP_MARKER_UPDATE_INTERVAL_FRAMES = v.MarkerUpdateIntervalFrames
    Config.XNP_TOOLTIP_ENABLED = v.EnableTooltips == true and v.TooltipEnabled == true
    Config.XNP_TOOLTIP_DETAIL_LEVEL = v.TooltipDetailLevel

    local yellowEnabled = v.EnableYellowTraitSystem == true and v.YellowEnabled == true
    Config.ENABLE_BREAKOUT_PUSH = yellowEnabled
    Config.JOG_BUMP_LAUNCH_ENABLED = yellowEnabled and v.YellowJogBumpEnabled == true
    Config.jog_bump_launch_enabled = Config.JOG_BUMP_LAUNCH_ENABLED
    Config.JOG_BUMP_MIN_SPEED = v.YellowJogMinimumSpeed
    Config.JOG_BUMP_STAGGER_CHANCE = v.YellowJogStaggerChance
    Config.JOG_BUMP_KNOCKDOWN_CHANCE = v.YellowJogKnockdownChance
    Config.JOG_BUMP_IMPACT_FORCE = v.YellowJogImpactForce
    Config.ENABLE_PRECOLLISION_PREDICTOR = yellowEnabled and v.YellowSprintImpactEnabled == true
    Config.PRECOLLISION_SPRINT_MIN_SPEED = v.YellowSprintMinimumSpeed
    Config.SPRINT_IMPACT_FORCE = v.YellowSprintImpactForce
    Config.SPRINT_STAGGER_CHANCE = v.YellowSprintStaggerChance
    Config.SPRINT_KNOCKDOWN_CHANCE = v.YellowSprintKnockdownChance
    Config.SPRINT_IMMUNITY_ENABLED = yellowEnabled and v.YellowSprintTripImmunityEnabled == true
    Config.SPRINT_TRIP_CANCEL_ENABLED = Config.SPRINT_IMMUNITY_ENABLED
    Config.ENABLE_GRAB_BREAKOUT_TRIGGER = yellowEnabled and v.YellowGrabBreakoutEnabled == true
    Config.GRAB_BREAKOUT_COOLDOWN = v.YellowGrabBreakoutCooldownSeconds
    Config.GRAB_BREAKOUT_ENDURANCE_COST = v.YellowGrabEnduranceCost
    Config.CONTACT_PUSH_ENDURANCE_COST = v.YellowContactEnduranceCost
    Config.EMERGENCY_BREAKOUT_ENABLED = yellowEnabled and v.YellowEmergencyGetupEnabled == true
    Config.EMERGENCY_BREAKOUT_COOLDOWN = v.YellowEmergencyGetupCooldownSeconds
    Config.YELLOW_DISTANCE_GROWTH_ENABLED = yellowEnabled and v.YellowDistanceGrowthEnabled == true
    Config.YELLOW_DISTANCE_GROWTH_RATE = v.YellowDistanceGrowthRate
    Config.YELLOW_DISTANCE_CURVE_MODE = v.YellowDistanceCurveMode
    Config.YELLOW_INITIAL_SPEED_MULTIPLIER = v.YellowInitialSpeedMultiplier
    Config.YELLOW_MAXIMUM_SPEED_MULTIPLIER = v.YellowMaximumSpeedMultiplier
    Config.YELLOW_DISTANCE_DECAY_DELAY_SECONDS = v.YellowDecayDelaySeconds
    Config.YELLOW_DISTANCE_DECAY_RATE = v.YellowDecayRate
    Config.YELLOW_LOW_ENDURANCE_INJURY_RISK_ENABLED = v.YellowLowEnduranceInjuryRiskEnabled == true
    Config.YELLOW_LOW_ENDURANCE_INJURY_CHANCE = v.YellowLowEnduranceInjuryChance
    Config.YELLOW_ALT_CROWD_BREAKOUT_ENABLED =
        yellowEnabled and v.YellowAltCrowdBreakoutEnabled == true
    Config.YELLOW_ALT_CROWD_BREAKOUT_RADIUS =
        v.YellowAltCrowdBreakoutRadiusTiles
    Config.YELLOW_ALT_CROWD_BREAKOUT_MINIMUM =
        v.YellowAltCrowdBreakoutMinimumNearbyZombies
    Config.YELLOW_ALT_CROWD_BREAKOUT_COOLDOWN =
        v.YellowAltCrowdBreakoutCooldownSeconds
    Config.YELLOW_ALT_CROWD_BREAKOUT_ENDURANCE_COST =
        v.YellowAltCrowdBreakoutEnduranceCost
    Config.YELLOW_ALT_CROWD_BREAKOUT_STRONG_OVERRIDE =
        v.YellowAltCrowdBreakoutStrongControlOverride == true
    Config.YELLOW_ALT_CROWD_BREAKOUT_LOW_ENDURANCE_MULTIPLIER =
        v.YellowAltCrowdBreakoutLowEnduranceMultiplier
    Config.YELLOW_ALT_CROWD_BREAKOUT_NOTIFICATION =
        v.YellowAltCrowdBreakoutNotification == true
    Config.YELLOW_ALT_CROWD_BREAKOUT_DAMAGE = 0
    Config.YELLOW_ALT_CROWD_BREAKOUT_KNOCKDOWN_CHANCE = 0

    Config.RED_CRAFT_SWEAT_ENABLED = v.RedCraftSweatEnabled == true
    Config.RED_CRAFT_SWEAT_INTENSITY = v.RedCraftSweatIntensity
    Config.RED_CRAFT_FATIGUE_COST_PERCENT =
        v.RedCraftFatigueCostPercent
    Config.RED_CRAFT_BODY_HEAT_ENABLED =
        v.RedCraftBodyHeatEnabled == true
    Config.RED_CRAFT_EXERTION_FEEDBACK_ENABLED =
        v.RedCraftExertionFeedbackEnabled == true
    Config.DEVELOPER_TEST_TOOLS_ENABLED =
        v.DeveloperTestToolsEnabled == true

    Config.resource_gate_enabled = v.ResourceGateEnabled == true

    local assist = v.StaminaAssistIntensity
    Config.green_refund_fraction = 0.00
    Config.release_green_refund_fraction = 0.00
    Config.blue_refund_fraction = clamp((v.BlueRefundPercent / 100.0) * assist, 0.0, 0.90)
    Config.yellow_refund_fraction = clamp((v.YellowRefundPercent / 100.0) * assist, 0.0, 0.90)
    Config.red_refund_fraction = clamp((v.RedRefundPercent / 100.0) * assist, 0.0, 0.90)
    Config.release_blue_refund_fraction = Config.blue_refund_fraction
    Config.release_yellow_refund_fraction = Config.yellow_refund_fraction
    Config.release_red_refund_fraction = Config.red_refund_fraction

    Config.OLD_HUNGER_CONVERSION_COST_ACTIVE = false
    Config.hunger_conversion_green = 0.00
    Config.hunger_conversion_blue = 0.00
    Config.hunger_conversion_yellow = 0.00
    Config.hunger_conversion_red = 0.00

    Config.release_green_enter = v.GreenEnterPercent / 100.0
    Config.release_green_exit = v.GreenExitPercent / 100.0
    Config.release_blue_lower = v.BlueLowerPercent / 100.0
    Config.release_yellow_lower = v.YellowLowerPercent / 100.0
    Config.endurance_green_enter = Config.release_green_enter
    Config.endurance_green_exit = Config.release_green_exit
    Config.endurance_blue_upper = Config.release_green_exit
    Config.endurance_blue_lower = Config.release_blue_lower
    Config.endurance_yellow_upper = Config.release_blue_lower
    Config.endurance_yellow_lower = Config.release_yellow_lower
    Config.endurance_red_upper = Config.release_yellow_lower

    Config.ENABLE_LOW_ENDURANCE_FOOD_CONVERSION = v.EnableLowEnduranceFoodConversion == true
    Config.enable_low_endurance_food_conversion = Config.ENABLE_LOW_ENDURANCE_FOOD_CONVERSION
    Config.ENABLE_TIERED_FOOD_RECOVERY = v.EnableTieredFoodRecovery == true
    Config.enable_tiered_food_recovery = Config.ENABLE_TIERED_FOOD_RECOVERY
    Config.FOOD_RECOVERY_PULSE_SECONDS = clamp(v.FoodRecoveryPulseSeconds, 0.50, 10.00)
    Config.BLUE_FOOD_COST_PER_PULSE = clamp(v.BlueFoodCostPercent / 100.0, 0.0, 0.10)
    Config.BLUE_ENDURANCE_GAIN_PER_PULSE = clamp(v.BlueEnduranceGainPercent / 100.0, 0.0001, 0.20)
    Config.YELLOW_RED_FOOD_COST_PER_PULSE = clamp(v.YellowRedFoodCostPercent / 100.0, 0.0, 0.10)
    Config.YELLOW_RED_ENDURANCE_GAIN_PER_PULSE = clamp(v.YellowRedEnduranceGainPercent / 100.0, 0.0001, 0.20)
    Config.RED_FOOD_COST_PER_PULSE = Config.YELLOW_RED_FOOD_COST_PER_PULSE
    Config.RED_ENDURANCE_GAIN_PER_PULSE = Config.YELLOW_RED_ENDURANCE_GAIN_PER_PULSE
    local rawTrigger = v.FoodConversionTriggerPercent / 100.0
    local rawTarget = v.FoodConversionTargetPercent / 100.0
    local rawFloor = v.MinimumFoodReservePercent / 100.0
    Config.LOW_ENDURANCE_FOOD_CONVERSION_TRIGGER = clamp(rawTrigger, 0.01, 0.98)
    Config.LOW_ENDURANCE_FOOD_CONVERSION_TARGET = clamp(rawTarget, Config.LOW_ENDURANCE_FOOD_CONVERSION_TRIGGER + 0.01, 1.0)
    Config.LOW_ENDURANCE_FOOD_CONVERSION_MIN_RESERVE = clamp(rawFloor, 0.40, 0.95)
    Config.MINIMUM_TIERED_FOOD_RESERVE = Config.LOW_ENDURANCE_FOOD_CONVERSION_MIN_RESERVE
    Config.LOW_ENDURANCE_FOOD_CONVERSION_RATIO = math.max(v.FoodToEnduranceRatioPercent / 100.0, 0.01)
    Config.LOW_ENDURANCE_FOOD_CONVERSION_RATE = math.max(v.FoodConversionRatePercentPerSecond / 100.0, 0.0001)
    if not SandboxTuning.normalizationWarned and (rawTrigger ~= Config.LOW_ENDURANCE_FOOD_CONVERSION_TRIGGER or rawTarget ~= Config.LOW_ENDURANCE_FOOD_CONVERSION_TARGET or rawFloor ~= Config.LOW_ENDURANCE_FOOD_CONVERSION_MIN_RESERVE) then
        SandboxTuning.normalizationWarned = true
        print("[XNP FOOD NORMALIZE WARNING] invalid sandbox relationship normalized once")
    end

    Config.ENABLE_HIGH_ENDURANCE_MELEE_POWER = v.EnableHighEnduranceMeleePower == true
    Config.enable_high_endurance_melee_power = Config.ENABLE_HIGH_ENDURANCE_MELEE_POWER
    Config.HIGH_ENDURANCE_MELEE_START = v.MeleePowerStartEndurancePercent / 100.0
    Config.HIGH_ENDURANCE_MELEE_FULL = v.MeleePowerFullEndurancePercent / 100.0
    Config.HIGH_ENDURANCE_MELEE_MAX_MULTIPLIER = clamp(v.MeleePowerMaxMultiplier, 1.0, 2.0)
    Config.HIGH_ENDURANCE_MELEE_AFFECTS_UNARMED = false
    Config.HIGH_ENDURANCE_MELEE_AFFECTS_STOMP = false
    Config.HIGH_ENDURANCE_MELEE_FORCE_EXECUTE = false

    Config.PERFORMANCE_MODE = v.PerformanceMode
    Config.PERFORMANCE_PRESET = v.PerformancePreset
    local performanceScale = ({ [1] = 1.5, [2] = 1.0, [3] = 2.0 })[v.PerformancePreset] or 1.0
    local generalFrameInterval = math.max(1, math.floor(v.PerformanceUpdateIntervalFrames)) / 60.0
    local schedulerFrameInterval = math.max(1, math.floor(v.SchedulerUpdateIntervalFrames)) / 60.0
    local queryFrameInterval = math.max(1, math.floor(v.WorldQueryIntervalFrames)) / 60.0
    Config.PERFORMANCE_IDLE_THREAT_INTERVAL = math.max(v.IdleThreatScanMs / 1000.0, generalFrameInterval) * performanceScale
    Config.PERFORMANCE_ACTIVE_THREAT_INTERVAL = math.max(v.ActiveThreatScanMs / 1000.0, queryFrameInterval) * performanceScale
    Config.PERFORMANCE_CRITICAL_INTERVAL = math.max(v.CriticalThreatScanMs / 1000.0, schedulerFrameInterval) * performanceScale
    Config.PERFORMANCE_MAX_NEARBY_CANDIDATES = math.min(math.floor(v.MaxNearbyCandidates), 16)
    Config.LOW_PERFORMANCE_UI_MODE = v.LowPerformanceUIMode == true
    Config.PERFORMANCE_STATISTICS_ENABLED = v.PerformanceStatisticsEnabled == true
    Config.PERFORMANCE_UI_INTERVAL = math.max(v.UIRefreshIntervalFrames / 60.0,
        Config.LOW_PERFORMANCE_UI_MODE and 0.5 or (1 / 60.0))
    Config.PERFORMANCE_SANDBOX_INTERVAL = math.max(120 / 60.0, 1.0)
    Config.NEARBY_ZOMBIE_CACHE_TTL_FRAMES = math.max(1, math.floor(v.NearbyZombieCacheRefreshFrames))
    Config.nearby_zombie_cache_ttl_frames = Config.NEARBY_ZOMBIE_CACHE_TTL_FRAMES

    -- Safety boundaries are duplicated here so a downstream module cannot
    -- accidentally treat a visible advanced option as permission.
    Config.GREEN_RUNTIME_ENTITY_RENDERING_ENABLED = false
    Config.GREEN_PLAYER_DAMAGE_ENABLED = false
    Config.GREEN_NPC_DAMAGE_ENABLED = false
    Config.GREEN_ANIMAL_DAMAGE_ENABLED = false
    Config.GREEN_ACTIVE_STRUCTURE_DAMAGE_ENABLED = false
    Config.GREEN_VEHICLE_DAMAGE_ENABLED = false
    Config.GREEN_FIRE_ENABLED = false
end

function SandboxTuning.Load()
    local snapshot = makeSnapshot()
    SandboxTuning.snapshot = snapshot
    SandboxTuning.lastHash = snapshot.hash
    SandboxTuning.loaded = true
    applyToConfig(snapshot)
    print("[XNP SANDBOX] namespace=" .. SandboxTuning.namespace)
    print("[XNP SANDBOX] preset=" .. tostring(snapshot.preset) .. " source=" .. tostring(snapshot.source))
    if snapshot.legacyPresetImported then
        print("[XNP SANDBOX MIGRATION] old=TuningPreset new=Preset mapped="
            .. tostring(snapshot.preset) .. " source=" .. tostring(snapshot.legacyPresetSource)
            .. " marker=" .. LEGACY_PRESET_MIGRATION_MARKER)
    end
    if snapshot.redHealthCostMigrated then
        print("[XNP SANDBOX MIGRATION] old=RedCraftHealthCost new=RedCraftHealthCostPoints"
            .. " semantics=LEGACY_FRACTION_TO_HEALTH_POINTS")
    end
    if snapshot.greenLifetimeAliasMigrated then
        print("[XNP SANDBOX MIGRATION] old=" .. tostring(snapshot.greenLifetimeAliasSource)
            .. " new=GreenMaximumFlightSeconds canonical_runtime_source=true")
    end
    if snapshot.purpleInvulnerability then
        local invulnerability = snapshot.purpleInvulnerability
        print("[XNP PHOENIX INVULNERABILITY MIGRATION]"
            .. " key=" .. tostring(invulnerability.migration_key)
            .. " migrated=" .. tostring(invulnerability.migrated == true)
            .. " write_ok="
            .. tostring(invulnerability.migration_write_ok == true)
            .. " source_value=" .. tostring(invulnerability.source_value)
            .. " effective_value=" .. tostring(invulnerability.value)
            .. " runtime_reachable="
            .. tostring(invulnerability.runtime_reachable == true)
            .. " reason=" .. tostring(invulnerability.reason)
            .. " old_alias_runtime_arbitration=false")
    end
    print("[XNP SANDBOX] multiplayer_authority=SERVER")
    Core.LogThrottle.Event("[XNP SANDBOX] authority=SERVER")
    if snapshot.missingNamespace then
        print("[XNP SANDBOX TUNING] legacy_save_fallback=RELEASE")
    end
    if snapshot.thresholdsNormalized then
        print("[XNP SANDBOX] thresholds_normalized=true reason=INVALID_ORDER")
    end
    print("[XNP SANDBOX TUNING] loaded=true digest="
        .. tostring(snapshot.digest))
    print("[XNP SANDBOX] full_option_layer=true entity_rendering_forced_false=true")
    print("[XNP SANDBOX TUNING] refresh_interval_frames=120")
    printGreenSummary(snapshot, "LOAD")
    print("[XNP RELEASE BALANCE] zombie_impact_previous=0.40 scale=0.60 new_default=0.24")
    print("[XNP RELEASE BALANCE] blue_refund_previous=18 new_default=30")
    return snapshot
end

function SandboxTuning.Refresh(force)
    if not SandboxTuning.loaded then
        return SandboxTuning.Load()
    end
    local snapshot = makeSnapshot()
    if force == true or snapshot.hash ~= SandboxTuning.lastHash then
        local previous = SandboxTuning.snapshot
        local oldDigest = previous and previous.digest or "none"
        local changedKeyCount, importantChangedKeys =
            summarizeChanges(previous and previous.values, snapshot.values)
        SandboxTuning.snapshot = snapshot
        SandboxTuning.lastHash = snapshot.hash
        applyToConfig(snapshot)
        print("[XNP SANDBOX TUNING] changed=true"
            .. " old_digest=" .. tostring(oldDigest)
            .. " new_digest=" .. tostring(snapshot.digest)
            .. " changed_key_count=" .. tostring(changedKeyCount)
            .. " important_changed_keys=" .. tostring(importantChangedKeys))
        print("[XNP SANDBOX] preset=" .. tostring(snapshot.preset) .. " source=" .. tostring(snapshot.source))
        printGreenSummary(snapshot, "REFRESH_CHANGED")
        if snapshot.thresholdsNormalized then
            print("[XNP SANDBOX] thresholds_normalized=true reason=INVALID_ORDER")
        end
    elseif (SandboxTuning.snapshot and SandboxTuning.snapshot.values.EnableDebugSummary == true) then
        Core.LogThrottle.Blocked("SANDBOX_TUNING", "UNCHANGED")
    end
    return SandboxTuning.snapshot
end

function SandboxTuning.Tick()
    if not SandboxTuning.loaded then
        SandboxTuning.Load()
    end
    SandboxTuning.frame = SandboxTuning.frame + 1
    local live = SandboxTuning.GetBoolean("LiveRefreshTuning", true)
    if live and SandboxTuning.frame >= 120 then
        SandboxTuning.frame = 0
        SandboxTuning.Refresh(false)
    end
end

function SandboxTuning.GetPreset()
    local snapshot = SandboxTuning.snapshot or SandboxTuning.Load()
    return snapshot.preset or "VANILLA_PLUS"
end

function SandboxTuning.GetNumber(name, fallback, minValue, maxValue)
    local values = SandboxTuning.snapshot and SandboxTuning.snapshot.values or Release
    local value = values[name]
    if Schema.safetyZero[name] then return 0 end
    if not Constants.IsFiniteNumber(value) then
        return fallback
    end
    if minValue ~= nil and maxValue ~= nil then
        return clamp(value, minValue, maxValue)
    end
    return value
end

function SandboxTuning.GetPurpleInvulnerabilitySnapshot()
    local snapshot = SandboxTuning.snapshot
    local value = snapshot and snapshot.purpleInvulnerability or nil
    if not value then
        value = Core.PurpleInvulnerabilityResolver.Resolve(sourceVars())
    end
    local copy = {}
    for key, item in pairs(value) do copy[key] = item end
    return copy
end

function SandboxTuning.GetBoolean(name, fallback)
    if Schema.safetyFalse[name] then return false end
    local values = SandboxTuning.snapshot and SandboxTuning.snapshot.values or Release
    local value = values[name]
    if type(value) == "boolean" then
        return value
    end
    return fallback
end

function SandboxTuning.GetEnum(name, fallback, minimum, maximum)
    local value = SandboxTuning.GetNumber(name, fallback, minimum, maximum)
    return math.floor((tonumber(value) or fallback or 1) + 0.5)
end

function SandboxTuning.IsSystemEnabled(systemName)
    local names = {
        YELLOW = "EnableYellowTraitSystem",
        PURPLE = "EnablePurplePhoenixSystem",
        GREEN = "EnableGreenTraitSystem",
        RED = "EnableRedTraitSystem",
    }
    local option = names[string.upper(tostring(systemName or ""))]
    return option ~= nil and SandboxTuning.GetBoolean(option, true) == true
end

function SandboxTuning.GetCostMultiplier(route)
    if tostring(route) == "WALL_IMPACT" then
        return 1.00
    end
    local snap = SandboxTuning.snapshot or SandboxTuning.Load()
    local v = snap.values
    local routeKey = routeKeys[route] or routeKeys[tostring(route)] or nil
    local routeMultiplier = routeKey and v[routeKey] or 1.00
    local zombieMultiplier = zombieImpactRoutes[route] == true and v.ZombieImpactCostMultiplier or 1.00
    return v.GlobalSkillCostMultiplier * zombieMultiplier * routeMultiplier
end

function SandboxTuning.GetCostDetails(route, baseCost)
    if tostring(route) == "WALL_IMPACT" then
        return {
            route = route,
            base = baseCost or 0,
            global = 1.00,
            zombie = 1.00,
            routeMultiplier = 1.00,
            final = clamp(baseCost or 0, 0.0, 1.0),
            zombieApplied = false,
        }
    end
    local snap = SandboxTuning.snapshot or SandboxTuning.Load()
    local v = snap.values
    local routeKey = routeKeys[route] or routeKeys[tostring(route)] or nil
    local routeMultiplier = routeKey and v[routeKey] or 1.00
    local zombieMultiplier = zombieImpactRoutes[route] == true and v.ZombieImpactCostMultiplier or 1.00
    local global = v.GlobalSkillCostMultiplier
    local final = clamp((baseCost or 0) * global * zombieMultiplier * routeMultiplier, 0.0, 1.0)
    return {
        route = route,
        base = baseCost or 0,
        global = global,
        zombie = zombieMultiplier,
        routeMultiplier = routeMultiplier,
        final = final,
        zombieApplied = zombieImpactRoutes[route] == true,
    }
end

function SandboxTuning.ComputeCost(route, baseCost)
    local details = SandboxTuning.GetCostDetails(route, baseCost)
    local key = tostring(route) .. "|" .. tostring(details.base) .. "|" .. tostring(details.final)
    if key ~= SandboxTuning.lastCostLogKey then
        SandboxTuning.lastCostLogKey = key
        print("[XNP COST TUNING] source=SANDBOX_VARS")
        print(string.format("[XNP COST TUNING] route=%s base=%.4f global=%.2f zombie=%.2f route_multiplier=%.2f final=%.4f", tostring(route), details.base, details.global, details.zombie, details.routeMultiplier, details.final))
        if details.zombieApplied ~= true then
            print("[XNP COST TUNING] route=" .. tostring(route) .. " zombie_multiplier_not_applied=true")
        end
        print("[XNP COST TUNING] no_double_multiplier=true")
    end
    return details.final
end

function SandboxTuning.GetRefundFraction(state)
    if state == "BLUE_STAMINA_SUPPORT" then
        return Config.blue_refund_fraction or 0.30
    elseif state == "YELLOW_LOW_STAMINA_SUPPORT" then
        return Config.yellow_refund_fraction or 0.38
    elseif state == "RED_EXHAUSTED_SUPPORT" then
        return Config.red_refund_fraction or 0.55
    end
    return 0.0
end

function SandboxTuning.GetThresholds()
    return {
        greenEnter = Config.release_green_enter or 0.76,
        greenExit = Config.release_green_exit or 0.70,
        blueLower = Config.release_blue_lower or 0.36,
        yellowLower = Config.release_yellow_lower or 0.14,
    }
end

function SandboxTuning.GetSnapshot()
    return SandboxTuning.snapshot or SandboxTuning.Load()
end

function SandboxTuning.Validate()
    local s = SandboxTuning.GetSnapshot()
    return s ~= nil and s.thresholdsNormalized ~= true
end

function SandboxTuning.IsServerAuthoritative()
    return true
end

Core.SandboxTuning = SandboxTuning
return SandboxTuning
