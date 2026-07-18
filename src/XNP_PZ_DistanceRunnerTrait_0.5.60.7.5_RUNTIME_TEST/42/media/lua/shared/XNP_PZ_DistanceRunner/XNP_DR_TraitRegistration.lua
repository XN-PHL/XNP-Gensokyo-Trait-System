require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local Registration = {
    status = "NOT_STARTED",
    targetTraitObject = nil,
    logged = false,
}

local function logOnce(message)
    if not Registration.logged then
        Registration.logged = true
        print("[XNP TRAIT] " .. tostring(message))
    end
end

local function resolveCharacterTrait()
    if Registration.targetTraitObject then
        return Registration.targetTraitObject
    end
    if not ResourceLocation or type(ResourceLocation.of) ~= "function" then
        Registration.status = "RESOURCE_LOCATION_UNAVAILABLE"
        return nil
    end
    if not CharacterTrait or type(CharacterTrait.get) ~= "function" then
        Registration.status = "CHARACTER_TRAIT_GET_UNAVAILABLE"
        return nil
    end
    local ok, trait_object = pcall(function()
        local location = ResourceLocation.of(Constants.TRAIT_FULL_ID)
        return CharacterTrait.get(location)
    end)
    if ok and trait_object then
        Registration.targetTraitObject = trait_object
        Registration.status = "TRAIT_OBJECT_RESOLVED"
        logOnce("CharacterTrait resolved")
        return trait_object
    end
    Registration.status = "TRAIT_OBJECT_MISSING"
    return nil
end

function Registration.GetCanonicalCharacterTrait()
    return resolveCharacterTrait()
end

function Registration.VerifyDistanceRunnerTrait()
    local trait_object = resolveCharacterTrait()
    if not trait_object then
        return false, Registration.status
    end
    Registration.status = "TRAIT_OBJECT_VISIBLE"
    return true, Registration.status
end

function Registration.RegisterDistanceRunnerTrait()
    return Registration.VerifyDistanceRunnerTrait()
end

function Registration.ResetCache()
    Registration.targetTraitObject = nil
    Registration.status = "NOT_STARTED"
    Registration.logged = false
end

function Registration.GetDistanceRunnerTraitRegistrationStatus()
    return {
        status = Registration.status,
        method = Constants.TRAIT_DEFINITION_METHOD,
    }
end

Core.TraitRegistration = Registration
Core.RegisterDistanceRunnerTrait = Registration.RegisterDistanceRunnerTrait
Core.VerifyDistanceRunnerTrait = Registration.VerifyDistanceRunnerTrait
Core.GetDistanceRunnerTraitRegistrationStatus = Registration.GetDistanceRunnerTraitRegistrationStatus
Core.GetCanonicalDistanceRunnerCharacterTrait = Registration.GetCanonicalCharacterTrait

if Events and Events.OnGameBoot then
    Events.OnGameBoot.Remove(Registration.RegisterDistanceRunnerTrait)
    Events.OnGameBoot.Add(Registration.RegisterDistanceRunnerTrait)
end

return Registration
