require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local GreenSkill = {}

local ENABLED_KEY = "XNP_DR_GREEN_ENABLED"
local MIGRATION_KEY = "XNP_DR_GREEN_ENABLED_MIGRATED_05606"

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function playerData(player)
    local ok, data = invoke(player, "getModData")
    return ok and type(data) == "table" and data or nil
end

local function endurance(player)
    local ok, stats = invoke(player, "getStats")
    if not ok or not stats or not CharacterStat or not CharacterStat.ENDURANCE then return nil end
    ok, stats = pcall(function() return stats:get(CharacterStat.ENDURANCE) end)
    return ok and tonumber(stats) or nil
end

local function hasGreenTrait(player)
    return Core.ExtraTraits and Core.ExtraTraits.PlayerHas(player, "GREEN") == true
end

function GreenSkill.EnsureMigrated(player)
    if not hasGreenTrait(player) then return false, "GREEN_TRAIT_MISSING" end
    local data = playerData(player)
    if not data then return false, "NO_PLAYER_MODDATA" end
    if data[ENABLED_KEY] == nil then
        data[ENABLED_KEY] = Core.SandboxTuning.GetBoolean("GreenMeleeEnabledByDefault", true)
    end
    if data[MIGRATION_KEY] ~= true then
        data[MIGRATION_KEY] = true
        print("[XNP GREEN MELEE] default_enabled=true migration=0.5.60.6 persisted_value="
            .. tostring(data[ENABLED_KEY] == true))
    end
    return true, data[ENABLED_KEY] == true
end

function GreenSkill.IsEnabled(player)
    if not hasGreenTrait(player) then return false end
    local migrated = GreenSkill.EnsureMigrated(player)
    if not migrated then return false end
    local data = playerData(player)
    return data ~= nil and data[ENABLED_KEY] == true
end

function GreenSkill.SetEnabled(player, enabled)
    if enabled == true and not hasGreenTrait(player) then return false, "GREEN_TRAIT_MISSING" end
    local data = playerData(player)
    if not data then return false, "NO_PLAYER_MODDATA" end
    data[ENABLED_KEY] = enabled == true
    data[MIGRATION_KEY] = true
    return true, data[ENABLED_KEY]
end

function GreenSkill.GetTier(player)
    local value = endurance(player)
    if not GreenSkill.IsEnabled(player) then
        return { name = "WHITE", multiplier = 1.0, enduranceCost = 0.0, enabled = false, endurance = value }
    end
    if value == nil then
        return { name = "WHITE", multiplier = 1.0, enduranceCost = 0.0, enabled = true,
            endurance = nil, reason = "ENDURANCE_UNAVAILABLE" }
    end
    local highThreshold = Core.SandboxTuning.GetNumber("GreenHighTierEndurancePercent", 80, 1, 100) / 100
    local midThreshold = Core.SandboxTuning.GetNumber("GreenMidTierEndurancePercent", 40, 1, 100) / 100
    if value >= highThreshold then
        return { name = "GREEN",
            multiplier = Core.SandboxTuning.GetNumber("GreenHighTierDamageMultiplier", 8.0, 1.0, 20.0),
            enduranceCost = Core.SandboxTuning.GetNumber("GreenHighTierEnduranceCost", 3.0, 0.0, 25.0) / 100,
            enabled = true, endurance = value }
    end
    if value >= midThreshold then
        return { name = "YELLOW",
            multiplier = Core.SandboxTuning.GetNumber("GreenMidTierDamageMultiplier", 5.0, 1.0, 20.0),
            enduranceCost = Core.SandboxTuning.GetNumber("GreenMidTierEnduranceCost", 2.0, 0.0, 25.0) / 100,
            enabled = true, endurance = value }
    end
    return { name = "RED",
        multiplier = Core.SandboxTuning.GetNumber("GreenLowTierDamageMultiplier", 2.5, 1.0, 20.0),
        enduranceCost = Core.SandboxTuning.GetNumber("GreenLowTierEnduranceCost", 1.0, 0.0, 25.0) / 100,
        enabled = true, endurance = value }
end

function GreenSkill.ToggleEnabled(player)
    if not hasGreenTrait(player) then return false, "GREEN_TRAIT_MISSING" end
    GreenSkill.EnsureMigrated(player)
    local changed, enabled = GreenSkill.SetEnabled(player, not GreenSkill.IsEnabled(player))
    if changed then
        local tier = GreenSkill.GetTier(player)
        print("[XNP GREEN MELEE] toggle=true enabled=" .. tostring(enabled)
            .. " endurance=" .. tostring(tier.endurance)
            .. " tier=" .. tostring(tier.name))
    end
    return changed, enabled
end

function GreenSkill.DeductEndurance(player, amount)
    local ok, stats = invoke(player, "getStats")
    if not ok or not stats or not CharacterStat or not CharacterStat.ENDURANCE then
        return false, nil, nil
    end
    local before = endurance(player)
    if type(before) ~= "number" then return false, nil, nil end
    local target = math.max(0.0, before - math.max(0.0, tonumber(amount) or 0.0))
    local wrote = pcall(function() stats:set(CharacterStat.ENDURANCE, target) end)
    return wrote, before, target
end

function GreenSkill.GetVisualState(player)
    return GreenSkill.GetTier(player).name
end

GreenSkill.ENABLED_KEY = ENABLED_KEY
GreenSkill.MIGRATION_KEY = MIGRATION_KEY
GreenSkill.DEFAULT_MELEE_ENABLED = true

XNPGreenSkill = GreenSkill
Core.GreenSkill = GreenSkill
return GreenSkill
