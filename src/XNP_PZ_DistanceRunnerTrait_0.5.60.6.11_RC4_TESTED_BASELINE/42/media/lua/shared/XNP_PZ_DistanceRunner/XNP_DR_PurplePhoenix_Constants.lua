-- Phoenix owns a separate identity, point cost, and persistence namespace.
-- Character creation may select it together with Distance Runner without either
-- trait replacing the other trait, icon, cooldown, or saved UI position.
local Core = XNP_PZ_DistanceRunner

local PhoenixConstants = {
    TRAIT_ID = "XNPPurplePhoenix",
    TRAIT_FULL_ID = "XNPPhoenixTrait:XNPPurplePhoenix",
    TRAIT_DISPLAY_NAME_CN = "UI_trait_XNPPurplePhoenix",
    TRAIT_DISPLAY_NAME_EN = "Phoenix",
    TRAIT_POINT_COST = 1,
    TRAIT_ICON = "media/ui/Traits/trait_xnppurplephoenix.png",
    ENABLED_MODDATA_KEY = "XNP_DR_PHOENIX_ENABLED",
    COOLDOWN_START_MODDATA_KEY = "XNP_Phoenix_CooldownStartWorldHours",
    LAST_TRIGGER_MODDATA_KEY = "XNP_PurplePhoenix_LastTriggerWorldHours",
    CALM_OBSERVED_MODDATA_KEY = "XNP_Phoenix_CalmResetObserved",
    LAST_CREDIT_HOUR_MODDATA_KEY = "XNP_Phoenix_LastCreditWorldHour",
    WELL_FED_HOURS_MODDATA_KEY = "XNP_Phoenix_WellFedGameHours",
    HEALTHY_HOURS_MODDATA_KEY = "XNP_Phoenix_HealthyGameHours",
    TEST_COOLDOWN_MODE = true,
    TEST_COOLDOWN_MS = 5000,
    TEST_COOLDOWN_END_MS_MODDATA_KEY = "XNP_Phoenix_TestCooldownEndEpochMs_05601",
    TEST_MIGRATION_MODDATA_KEY = "XNP_Phoenix_TestStateMigrated_05601",
    LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY = "XNP_Phoenix_TestCooldownEndEpochMs_0560",
    LEGACY_TEST_MIGRATION_MODDATA_KEY = "XNP_Phoenix_TestStateMigrated_0560",
    ICON_X_MODDATA_KEY = "XNP_PurplePhoenix_IconX",
    ICON_Y_MODDATA_KEY = "XNP_PurplePhoenix_IconY",
    TRIGGER_MAIN_DEFAULT = 0.20,
    INVULNERABILITY_SECONDS_DEFAULT = 0.0,
    COOLDOWN_DAYS_DEFAULT = 7,
    MINIMUM_COOLDOWN_DAYS_DEFAULT = 5,
    EARLY_RECHARGE_MAX_DAYS_DEFAULT = 2,
    WELL_FED_CREDIT_MAX_DAYS_DEFAULT = 1,
    HEALTHY_CREDIT_MAX_DAYS_DEFAULT = 1,
    WELL_FED_REQUIRED_HOURS_DEFAULT = 24,
    HEALTHY_REQUIRED_HOURS_DEFAULT = 24,
    HEALTHY_MIN_HEALTH_DEFAULT = 0.95,
    PROTECT_DURATION_DEFAULT = 0.0,
    PROTECT_RADIUS_DEFAULT = 2.0,
    PROTECT_PULSE_INTERVAL_DEFAULT = 0.0,
    PROTECT_TARGET_CAP = 4,
}

Core.PurplePhoenixConstants = PhoenixConstants
return PhoenixConstants
