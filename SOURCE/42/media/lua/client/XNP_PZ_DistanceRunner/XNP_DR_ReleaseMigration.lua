require "XNP_PZ_DistanceRunner/XNP_DR_YellowToggle"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"

local Core = XNP_PZ_DistanceRunner
local P = Core.PurplePhoenixConstants

local Migration = {
    VERSION = "0.5.60.7.24",
    MODDATA_KEY = "XNP_DR_MIGRATION_VERSION",
}

local function dataFor(player)
    if not player or type(player.getModData) ~= "function" then return nil end
    local ok, data = pcall(function() return player:getModData() end)
    return ok and type(data) == "table" and data or nil
end

function Migration.ApplyPlayer(player, source)
    local data = dataFor(player)
    if not data then return false, "NO_PLAYER_MODDATA" end
    if data[Migration.MODDATA_KEY] == Migration.VERSION then
        return true, "ALREADY_MIGRATED"
    end

    -- Old diagnostic locks were never valid saved gameplay state. Ignore and
    -- remove only known XNP-owned residue; character identity is revalidated.
    local staleKeys = {
        "XNP_DR_PLAYER_WRITES_SUSPENDED",
        "XNP_DR_GLOBAL_IDENTITY_MISMATCH",
        "XNP_DR_UNKNOWN_PLAYER_LOCK",
    }
    local staleCleared = 0
    for _, key in ipairs(staleKeys) do
        if data[key] ~= nil then
            data[key] = nil
            staleCleared = staleCleared + 1
        end
    end

    if data[Core.YellowToggle.MODDATA_KEY] == nil then
        data[Core.YellowToggle.MODDATA_KEY] = data[Core.YellowToggle.LEGACY_MODDATA_KEY] ~= false
    end
    if data[Core.GreenSkill.ENABLED_KEY] == nil then
        data[Core.GreenSkill.ENABLED_KEY] = true
    end
    local purpleMigrated, purpleReason = false, "PURPLE_STATE_UNAVAILABLE"
    if Core.PurplePhoenixState
        and type(Core.PurplePhoenixState.EnsureDefaultMigration) == "function" then
        purpleMigrated, purpleReason =
            Core.PurplePhoenixState.EnsureDefaultMigration(
                player, source or "RELEASE_MIGRATION")
    end
    if purpleMigrated then
        data[Migration.MODDATA_KEY] = Migration.VERSION
    end
    print("[XNP RELEASE MIGRATION] MigrationVersion=" .. Migration.VERSION
        .. " source=" .. tostring(source or "UNKNOWN")
        .. " stale_identity_flags_cleared=" .. tostring(staleCleared)
        .. " purple_default_mode_migrated=" .. tostring(purpleMigrated == true)
        .. " purple_default_mode_reason=" .. tostring(purpleReason)
        .. " items_copied=0 corpse_writes=0 player_recreated=false")
    return purpleMigrated == true,
        purpleMigrated and "MIGRATED" or tostring(purpleReason)
end

Core.ReleaseMigration = Migration
return Migration
