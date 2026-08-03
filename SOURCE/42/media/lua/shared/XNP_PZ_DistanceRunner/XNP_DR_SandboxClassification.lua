XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner

local Classification = {
    PUBLIC_SHARED = "PUBLIC_SHARED",
    TEST_ONLY_VISIBLE = "TEST_ONLY_VISIBLE",
    HIDDEN_COMPAT = "HIDDEN_COMPAT",
    DEPRECATED_HIDDEN = "DEPRECATED_HIDDEN",
    INTERNAL_NOT_SANDBOX = "INTERNAL_NOT_SANDBOX",
}

local function makeSet(values)
    local result = {}
    for index = 1, #values do
        result[values[index]] = true
    end
    return result
end

Classification.testOnlyVisible = makeSet({
    "EnableRuntimeDebug",
    "EnableDebugSummary",
    "EvidenceLogEnabled",
    "PerformanceStatisticsEnabled",
    "GreenPerformanceStatisticsEnabled",
    "GreenRuntimeTestModeEnabled",
    "GreenRuntimeTestNoCooldown",
    "GreenRuntimeTestIgnoreResourceAdmission",
    "GreenRuntimeTestStillApplyCosts",
    "GreenRuntimeTestAllowCastAtMaxFatigue",
    "GreenRuntimeTestAllowCastAtZeroEndurance",
    "DiagnosticLogLevel",
    "TransactionLogEnabled",
    "PurpleDiagnosticDeathLogEnabled",
    "GreenInflightDiagnosticBorderEnabled",
    "YellowAltCrowdBreakoutEnabled",
    "YellowAltCrowdBreakoutRadiusTiles",
    "YellowAltCrowdBreakoutMinimumNearbyZombies",
    "YellowAltCrowdBreakoutCooldownSeconds",
    "YellowAltCrowdBreakoutEnduranceCost",
    "YellowAltCrowdBreakoutStrongControlOverride",
    "YellowAltCrowdBreakoutLowEnduranceMultiplier",
    "YellowAltCrowdBreakoutNotification",
    "YellowAltCrowdBreakoutTestPresetEnabled",
    "RedCraftSweatEnabled",
    "RedCraftSweatIntensity",
    "RedCraftFatigueCostPercent",
    "RedCraftBodyHeatEnabled",
    "RedCraftExertionFeedbackEnabled",
    "RedCraftPhysicalLoadDurationSeconds",
    "RedCraftPhysicalLoadStackLimit",
    "RedCraftHeatFeedbackIntensity",
    "RedCraftExertionFeedbackIntensity",
    "RedCraftMinimumVisibleFeedbackMode",
    "GreenContinuousRollingCastEnabled",
    "GreenRollingCastRetainedCount",
    "GreenRollingCastEvictOldestEnabled",
    "RedCraftImmediateFullSweatEnabled",
    "RedCraftImmediateSweatPercent",
    "RedCraftImmediateTemperatureIncreaseC",
    "RedCraftMaximumBodyTemperatureC",
    "RedCraftImmediateEnduranceTargetPercent",
    "DeveloperTestToolsEnabled",
    "GeneralGameplayPreset",
})

Classification.hiddenCompat = makeSet({
    "GreenGuidanceMaxTurnRateDegreesPerSecond",
    "GreenProjectileLifetimeEnabled",
    "GreenProjectileLifetimeSeconds",
    "PhoenixBaseCooldownDays",
    "PhoenixClearZombification",
    "PhoenixEarlyRechargeMaxDays",
    "PhoenixInvulnerabilitySeconds",
    "PhoenixMinimumCooldownDays",
    "PhoenixProtectDurationSeconds",
    "PhoenixRestoreEndurancePercent",
    "PhoenixTriggerHealthPercent",
    "TuningPreset",
    "YellowDistanceDecayDelay",
    "YellowDistanceDecayRate",
    "YellowEnableDistanceGrowth",
    "YellowLowEnduranceInjuryRisk",
    "YellowMaxSpeedMultiplier",
    "YellowSpeedGrowthRate",
    "CompatibilityMode",
    "LegacySaveMigration",
})

Classification.deprecatedHidden = makeSet({
    "GreenExperimentalEntityRendering",
    "RedCraftUnhappinessCost",
})

Classification.internalNotSandbox = makeSet({
    "XNP_B42_20_220_SANDBOX_CANONICAL_MIGRATION_A",
    "XNP_B42_20_220_TEST3_CONFIG_HEALTH_MIGRATION_A",
    "XNP_B42_20_220_TEST4_CONFIG_HEALTH_MIGRATION_A",
    "XNP_B42_20_220_TEST5_RED_PHYSICAL_FEEDBACK_MIGRATION_A",
    "XNP_RED_PHYSICAL_FEEDBACK_EXPLICIT_CUSTOM_A",
    "XNP_B42_20_SANDBOX_SOURCE_PROVENANCE",
    "XNP_B42_20_220_TEST6_GREEN_BLOOM_FOUR_SKILL_POLISH_A",
    "XNP_TEST6_GREEN_VISUAL_EXPLICIT_CUSTOM_A",
})

function Classification.GetClass(name)
    if Classification.testOnlyVisible[name] then
        return Classification.TEST_ONLY_VISIBLE
    end
    if Classification.hiddenCompat[name] then
        return Classification.HIDDEN_COMPAT
    end
    if Classification.deprecatedHidden[name] then
        return Classification.DEPRECATED_HIDDEN
    end
    if Classification.internalNotSandbox[name] then
        return Classification.INTERNAL_NOT_SANDBOX
    end
    return Classification.PUBLIC_SHARED
end

function Classification.IsVisible(channel, name)
    local className = Classification.GetClass(name)
    if className == Classification.PUBLIC_SHARED then
        return true
    end
    return channel == "TEST"
        and className == Classification.TEST_ONLY_VISIBLE
end

function Classification.GetExpectedCounts()
    return {
        source_public_catalog = 426,
        public_shared = 389,
        test_only_visible = 36,
        stable_visible = 389,
        test_visible = 425,
        hidden_compat = 20,
        deprecated_hidden = 2,
        internal_not_sandbox = 8,
        classification_union = 455,
    }
end

Core.SandboxClassification = Classification
return Classification
