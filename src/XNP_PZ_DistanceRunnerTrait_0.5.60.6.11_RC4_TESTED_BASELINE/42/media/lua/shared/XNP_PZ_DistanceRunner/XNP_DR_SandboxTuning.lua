require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local SandboxTuning = {
    namespace = "XNPDistanceRunner",
    loaded = false,
    frame = 0,
    lastHash = nil,
    lastWarningKey = nil,
    lastCostLogKey = nil,
    snapshot = nil,
    normalizationWarned = false,
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
    EnableDebugSummary = true,
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

local AlwaysLiveNames = {
    "EnableYellowTraitSystem",
    "EnablePurplePhoenixSystem",
    "EnableGreenTraitSystem",
    "EnableRedTraitSystem",
    "RedStarterItemCount",
    "RedCraftEnabled",
    "RedCraftDurationSeconds",
    "RedCraftHealthCost",
    "RedCraftHungerCost",
    "RedSafetyFloorPercent",
    "RedStaminaImmediateRecovery",
    "RedStaminaPeriodicRecovery",
    "RedStaminaPeriodicIntervalSeconds",
    "RedStaminaPeriodicDurationSeconds",
    "RedFatigueReduction",
    "RedMoodReductionPercent",
    "RedHealingHealthAmount",
    "RedHealFractureEnabled",
    "RedClearZombieInfectionEnabled",
    "RedHealMinorWoundCount",
    "RedHealMajorWoundCount",
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
    if value == 2 then
        return "TESTING"
    elseif value == 3 then
        return "CUSTOM"
    end
    return "RELEASE"
end

local function readNumber(vars, name, fallback, minValue, maxValue)
    local value = vars and vars[name] or nil
    if not Constants.IsFiniteNumber(value) then
        return fallback, value == nil and "MISSING" or "INVALID"
    end
    return clamp(value, minValue, maxValue), value ~= clamp(value, minValue, maxValue) and "CLAMPED" or nil
end

local function readBoolean(vars, name, fallback)
    local value = vars and vars[name] or nil
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
        end
        out[name] = value
        if reason ~= nil then
            hadFallback = true
        end
    end
    return out, hadFallback
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

local function makeSnapshot()
    local vars = sourceVars()
    local missingNamespace = vars == nil
    local presetValue = Release.TuningPreset
    if vars and Constants.IsFiniteNumber(vars.TuningPreset) then
        presetValue = clamp(vars.TuningPreset, 1, 3)
    end
    local name = presetName(presetValue)
    local values
    local fallback = missingNamespace
    if name == "TESTING" then
        values = copyTable(Testing)
    elseif name == "CUSTOM" then
        values, fallback = readCustom(vars)
    else
        values = copyTable(Release)
    end
    for _, optionName in ipairs(AlwaysLiveNames) do
        local spec = Specs[optionName]
        if spec.kind == "boolean" then
            values[optionName] = readBoolean(vars, optionName, values[optionName])
        else
            values[optionName] = readNumber(vars, optionName, values[optionName], spec.min, spec.max)
        end
    end
    values.GreenExperimentalEntityRendering = false
    values.TuningPreset = presetValue
    local normalized = normalizeThresholds(values)
    local hash = buildHash(values)
    return {
        namespace = SandboxTuning.namespace,
        values = values,
        preset = name,
        hash = hash,
        source = "SERVER_SANDBOX_VARS",
        missingNamespace = missingNamespace,
        fallback = fallback,
        thresholdsNormalized = normalized,
        serverAuthoritative = true,
        clientLocalOverride = false,
    }
end

local function warnOnce(key, message)
    if SandboxTuning.lastWarningKey ~= key then
        SandboxTuning.lastWarningKey = key
        print(message)
    end
end

local function applyToConfig(snapshot)
    local v = snapshot.values
    Config.ENABLE_MOD = v.EnableMod == true
    Config.enable_mod = Config.ENABLE_MOD
    Config.DEBUG_SANDBOX_TUNING = v.EnableDebugSummary == true
    Config.RUNTIME_MODULE_STARTUP_LOGS = Config.RUNTIME_MODULE_STARTUP_LOGS
    Config.STATUS_ICON_UI_ENABLED = v.ShowStatusIcon == true
    Config.ICON_RECOVERY_ENABLED = v.ShowStatusIcon == true
    Config.ICON_SHAKE_ENABLED = v.EnableStatusShake == true
    Config.stamina_shake_enabled = v.EnableStatusShake == true

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
    Config.PERFORMANCE_IDLE_THREAT_INTERVAL = v.IdleThreatScanMs / 1000.0
    Config.PERFORMANCE_ACTIVE_THREAT_INTERVAL = v.ActiveThreatScanMs / 1000.0
    Config.PERFORMANCE_CRITICAL_INTERVAL = v.CriticalThreatScanMs / 1000.0
    Config.PERFORMANCE_MAX_NEARBY_CANDIDATES = math.min(math.floor(v.MaxNearbyCandidates), 16)
end

function SandboxTuning.Load()
    local snapshot = makeSnapshot()
    SandboxTuning.snapshot = snapshot
    SandboxTuning.lastHash = snapshot.hash
    SandboxTuning.loaded = true
    applyToConfig(snapshot)
    print("[XNP SANDBOX] namespace=" .. SandboxTuning.namespace)
    print("[XNP SANDBOX] preset=" .. tostring(snapshot.preset) .. " source=" .. tostring(snapshot.source))
    print("[XNP SANDBOX] multiplayer_authority=SERVER")
    Core.LogThrottle.Event("[XNP SANDBOX] authority=SERVER")
    if snapshot.missingNamespace then
        print("[XNP SANDBOX TUNING] legacy_save_fallback=RELEASE")
    end
    if snapshot.thresholdsNormalized then
        print("[XNP SANDBOX] thresholds_normalized=true reason=INVALID_ORDER")
    end
    print("[XNP SANDBOX TUNING] loaded=true")
    print("[XNP SANDBOX] full_option_layer=true entity_rendering_forced_false=true")
    print("[XNP SANDBOX TUNING] refresh_interval_frames=120")
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
        local oldHash = SandboxTuning.lastHash or "none"
        SandboxTuning.snapshot = snapshot
        SandboxTuning.lastHash = snapshot.hash
        applyToConfig(snapshot)
        print("[XNP SANDBOX TUNING] changed=true old_hash=" .. tostring(oldHash) .. " new_hash=" .. tostring(snapshot.hash))
        print("[XNP SANDBOX] preset=" .. tostring(snapshot.preset) .. " source=" .. tostring(snapshot.source))
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
    local vars = sourceVars()
    local value = vars and tonumber(vars.Preset) or 1
    local names = { "RELEASE", "BALANCED", "STRONG", "CUSTOM" }
    return names[math.max(1, math.min(4, math.floor(value + 0.5)))] or "RELEASE"
end

function SandboxTuning.GetNumber(name, fallback, minValue, maxValue)
    local values = SandboxTuning.snapshot and SandboxTuning.snapshot.values or Release
    local value = values[name]
    if not Constants.IsFiniteNumber(value) then
        local vars = sourceVars()
        value = vars and vars[name] or nil
    end
    if not Constants.IsFiniteNumber(value) then
        return fallback
    end
    if minValue ~= nil and maxValue ~= nil then
        return clamp(value, minValue, maxValue)
    end
    return value
end

function SandboxTuning.GetBoolean(name, fallback)
    if name == "GreenExperimentalEntityRendering" then return false end
    local values = SandboxTuning.snapshot and SandboxTuning.snapshot.values or Release
    local value = values[name]
    if type(value) ~= "boolean" then
        local vars = sourceVars()
        value = vars and vars[name] or nil
    end
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
