XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Constants = {
    REGISTRY_NAMESPACE = "XNP_PurpleLifeStockBackupRegistry_v1",
    REGISTRY_VERSION = 4,
    SNAPSHOT_SCHEMA = "XNP_PURPLE_LIFE_STOCK_SNAPSHOT_V1",
    TOKEN_SCHEMA = "XNP_PURPLE_LIFE_STOCK_TOKEN_V1",
    MIGRATION_MARKER = "XNP_0560720_PurpleTraitObjectSnapshotMigration",
    PREVIOUS_MIGRATION_MARKER = "XNP_0560719_PurpleCanonicalSnapshotMigration",
    LEGACY_MIGRATION_MARKER = "XNP_0560718_PurpleInteractionRespawnMigration",

    RECORDER_ITEM = "XNP_PZ_DistanceRunner.PurpleLifeStockRecorder",
    BACKUP_ITEM = "XNP_PZ_DistanceRunner.PurpleLifeStockBackup",
    PURPLE_TRAIT = "XNPPhoenixTrait:XNPPurplePhoenix",

    LINEAGE_MODDATA_KEY = "XNP_PurpleLifeStock_LineageId_v1",
    ITEM_SNAPSHOT_ID_KEY = "xnp_snapshot_id",
    ITEM_SCHEMA_KEY = "xnp_schema_version",
    ITEM_LINEAGE_KEY = "xnp_lineage_id",
    ITEM_CREATED_GAME_TIME_KEY = "xnp_created_game_time",
    ITEM_SOURCE_KEY = "xnp_snapshot_source",
    ITEM_CHECKSUM_KEY = "xnp_snapshot_checksum",
    ITEM_TOKEN_ID_KEY = "xnp_token_id",
    ITEM_ISSUED_SOURCE_KEY = "xnp_issued_source",
    ITEM_CONSUMED_KEY = "xnp_consumed",
    ITEM_VALID_KEY = "xnp_token_valid",
    ITEM_MIGRATION_KEY = "xnp_0560719_migrated",
    ITEM_INVALID_REASON_KEY = "xnp_invalid_reason",

    STATUS_ACTIVE = "ACTIVE_LIVING_BACKUP",
    STATUS_CLAIMABLE = "CLAIMABLE_AFTER_DEATH",
    STATUS_DELIVERED = "DELIVERED_TO_SUCCESSOR",
    STATUS_CLAIMED = "CLAIMED_BY_SUCCESSOR",

    SOURCE_MANUAL = "MANUAL",
    SOURCE_AUTO = "AUTO_WEEKLY",
    SOURCE_INITIAL = "INITIAL_BOOTSTRAP",
    SOURCE_DEATH_FINAL = "FINAL_DEATH_SNAPSHOT",
    SOURCE_DEATH_FALLBACK = "LAST_VALID_FALLBACK",
    ISSUED_STARTER = "STARTER",
    ISSUED_MANUAL = "MANUAL",
    ISSUED_WEEKLY = "WEEKLY",
    ISSUED_LEGACY = "LEGACY_MIGRATION",
    ISSUED_REHOME = "SUCCESSOR_REHOME_EXISTING_TOKEN",
    ISSUED_DEATH_AUTO = "DEATH_AUTO",
    DEATH_GATE_REPAIR_MIGRATION =
        "0.5.60.7.23_LifeStockDeathGateRepair",
    AUTO_INTERVAL_GAME_DAYS_DEFAULT = 7,
    MAXIMUM_INVENTORY_COPIES_DEFAULT = 1,

    RECORD_BOREDOM_POINTS_DEFAULT = 50,
    RECORD_UNHAPPINESS_POINTS_DEFAULT = 50,
    RECORD_ENDURANCE_POINTS_DEFAULT = 80,
    RECORD_HUNGER_POINTS_DEFAULT = 10,
    CRAFT_DURATION_SECONDS_DEFAULT = 4,
    RESTORE_DURATION_SECONDS_DEFAULT = 4,

    XNP_TRAIT_FULL_IDS = {
        "XNPDistanceRunnerTrait:XNPDistanceRunner",
        "XNPPhoenixTrait:XNPPurplePhoenix",
        "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
        "XNPFeastGuardianTrait:XNPFeastGuardian",
    },
}

XNP_PZ_DistanceRunner.PurpleLifeStockConstants = Constants
return Constants
