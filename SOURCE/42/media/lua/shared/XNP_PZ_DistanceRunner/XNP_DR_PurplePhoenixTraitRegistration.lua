require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"

local Core = XNP_PZ_DistanceRunner
local PhoenixConstants = Core.PurplePhoenixConstants

local Registration = {
    cachedObject = nil,
    status = "NOT_STARTED",
    logged = false,
}

-- Resolves the native CharacterTrait object created by registries.lua. Runtime
-- detection compares object identity first and uses aliases only as a fallback.
local function resolveTraitObject()
    if Registration.cachedObject then
        return Registration.cachedObject
    end
    if not ResourceLocation or type(ResourceLocation.of) ~= "function" then
        Registration.status = "RESOURCE_LOCATION_UNAVAILABLE"
        return nil
    end
    if not CharacterTrait or type(CharacterTrait.get) ~= "function" then
        Registration.status = "CHARACTER_TRAIT_GET_UNAVAILABLE"
        return nil
    end
    local ok, traitObject = pcall(function()
        return CharacterTrait.get(ResourceLocation.of(PhoenixConstants.TRAIT_FULL_ID))
    end)
    if ok and traitObject then
        Registration.cachedObject = traitObject
        Registration.status = "TRAIT_OBJECT_RESOLVED"
        if not Registration.logged then
            Registration.logged = true
            print("[XNP PHOENIX TRAIT] CharacterTrait resolved full_id=" .. PhoenixConstants.TRAIT_FULL_ID)
        end
        return traitObject
    end
    Registration.status = "TRAIT_OBJECT_MISSING"
    return nil
end

-- Public getter used by the player detector. It returns nil rather than throwing
-- when the Build 42 registry is not yet ready.
function Registration.GetCanonicalTrait()
    return resolveTraitObject()
end

-- OnGameBoot verification records whether the character-creation definition and
-- native registry agree on the same full ID.
function Registration.Verify()
    local traitObject = resolveTraitObject()
    if not traitObject then
        return false, Registration.status
    end
    Registration.status = "TRAIT_OBJECT_VISIBLE"
    return true, Registration.status
end

-- Clears only resolution caches when a player/save changes. No player state or
-- cooldown data is stored in this module.
function Registration.ResetCache()
    Registration.cachedObject = nil
    Registration.status = "NOT_STARTED"
    Registration.logged = false
end

Core.PurplePhoenixTraitRegistration = Registration

local function onGameBootAdapter()
    return Registration.Verify()
end

if Events and Events.OnGameBoot then
    Events.OnGameBoot.Remove(onGameBootAdapter)
    Events.OnGameBoot.Add(onGameBootAdapter)
end

return Registration
