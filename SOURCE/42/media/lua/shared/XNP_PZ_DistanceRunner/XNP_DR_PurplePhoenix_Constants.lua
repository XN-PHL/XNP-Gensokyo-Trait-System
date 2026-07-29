-- Phoenix owns a separate identity, point cost, and persistence namespace.
-- Character creation may select it together with Distance Runner without either
-- trait replacing the other trait, icon, cooldown, or saved UI position.
local Core = XNP_PZ_DistanceRunner

local PhoenixConstants = {
    TRAIT_ID = "XNPPurplePhoenix",
    TRAIT_FULL_ID = "XNPPhoenixTrait:XNPPurplePhoenix",
    TRAIT_DISPLAY_NAME_CN = "UI_trait_XNPPurplePhoenix",
    TRAIT_DISPLAY_NAME_EN = "Extra Life",
    TRAIT_POINT_COST = 1,
    TRAIT_ICON = "media/ui/Traits/trait_xnppurplephoenix.png",
    ENABLED_MODDATA_KEY = "XNP_DR_PHOENIX_ENABLED",
    PHOENIX_SURVIVAL_MODDATA_KEY = "phoenix_survival_enabled",
    PHOENIX_SURVIVAL_MIGRATION_MODDATA_KEY =
        "XNP_0560723_PhoenixSurvivalFieldMigration",
    PHOENIX_STATE_MODDATA_KEY = "XNP_Phoenix_State_0560724",
    COLOR_STATE_REPAIR_MIGRATION_MODDATA_KEY =
        "XNP_0560724_PhoenixColorStateRepair",
    COOLDOWN_DEFAULT_REPAIR_MIGRATION_MODDATA_KEY =
        "XNP_0560724_PhoenixCooldownDefault5Repair",
    COOLDOWN_CONFIG_SEEN_MODDATA_KEY =
        "XNP_Phoenix_CooldownConfiguredSeconds_0560724",
    COOLDOWN_EFFECTIVE_SECONDS_MODDATA_KEY =
        "XNP_Phoenix_CooldownEffectiveSeconds_0560724",
    DEFAULT_MODE_MIGRATION_MODDATA_KEY =
        "XNP_0560721_PurpleRespawnModeDefaultMigration",
    COOLDOWN_START_MODDATA_KEY = "XNP_Phoenix_CooldownStartWorldHours",
    LAST_TRIGGER_MODDATA_KEY = "XNP_PurplePhoenix_LastTriggerWorldHours",
    CALM_OBSERVED_MODDATA_KEY = "XNP_Phoenix_CalmResetObserved",
    LAST_CREDIT_HOUR_MODDATA_KEY = "XNP_Phoenix_LastCreditWorldHour",
    WELL_FED_HOURS_MODDATA_KEY = "XNP_Phoenix_WellFedGameHours",
    HEALTHY_HOURS_MODDATA_KEY = "XNP_Phoenix_HealthyGameHours",
    COOLDOWN_MODE = "REAL_SECONDS",
    COOLDOWN_REAL_SECONDS_DEFAULT = 5,
    COOLDOWN_END_REAL_MS_MODDATA_KEY = "XNP_Phoenix_CooldownEndRealMs_056072",
    REAL_SECONDS_MIGRATION_MODDATA_KEY = "XNP_056072_PhoenixCooldown3SecondsMigration",
    TEST_COOLDOWN_END_MS_MODDATA_KEY = "XNP_Phoenix_TestCooldownEndEpochMs_05601",
    TEST_MIGRATION_MODDATA_KEY = "XNP_Phoenix_TestStateMigrated_05601",
    LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY = "XNP_Phoenix_TestCooldownEndEpochMs_0560",
    LEGACY_TEST_MIGRATION_MODDATA_KEY = "XNP_Phoenix_TestStateMigrated_0560",
    ICON_X_MODDATA_KEY = "XNP_PurplePhoenix_IconX",
    ICON_Y_MODDATA_KEY = "XNP_PurplePhoenix_IconY",
    TRIGGER_MAIN_DEFAULT = 0.20,
    INVULNERABILITY_SECONDS_DEFAULT = 10.0,
    PROTECT_DURATION_DEFAULT = 0.0,
    PROTECT_RADIUS_DEFAULT = 3.0,
    PROTECT_PULSE_INTERVAL_DEFAULT = 0.0,
    PROTECT_TARGET_CAP = 24,
    PROTECT_PULSE_COUNT = 2,
    PROTECT_SECOND_PULSE_DELAY_MS = 2000,
    VERIFY_OBSERVATION_MS = 5000,
    VERIFY_MIN_FRAMES = 2,
    BURST_GUARD_MAX_MS = 250,
    BURST_GUARD_MAX_FRAMES = 2,
    HEALTH_STABILITY_TOLERANCE = 0.02,
}

Core.PurplePhoenixConstants = PhoenixConstants
return PhoenixConstants
