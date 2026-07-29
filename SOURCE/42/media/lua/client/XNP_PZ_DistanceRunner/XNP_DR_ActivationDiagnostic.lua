require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_TraitRegistration"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local ActivationDiagnostic = {
    logged = false,
    lastActive = nil,
    lastReason = nil,
}

XNP_DR_ActivationDiagnostic = ActivationDiagnostic

local function boolText(value)
    return tostring(value == true)
end

local function join(values)
    if not values or #values == 0 then
        return "none"
    end
    local result = {}
    for i = 1, math.min(#values, 20) do
        result[#result + 1] = tostring(values[i])
    end
    if #values > 20 then
        result[#result + 1] = "..."
    end
    return table.concat(result, ",")
end

local function traitRegistered()
    if Core.GetCanonicalDistanceRunnerCharacterTrait then
        local ok, value = pcall(function()
            return Core.GetCanonicalDistanceRunnerCharacterTrait()
        end)
        return ok and value ~= nil
    end
    return false
end

function ActivationDiagnostic.Update(player, active)
    if not Config.ACTIVATION_DIAGNOSTIC_ENABLED then
        return active == true
    end
    local snapshot = Core.Trait and Core.Trait.GetDebugSnapshot and Core.Trait.GetDebugSnapshot(player) or nil
    local objectFound = snapshot and snapshot.objectFound == true
    local aliasFound = snapshot and snapshot.aliasFound == true
    local activeValue = active == true
    local reason = activeValue and "none" or "PLAYER_DOES_NOT_HAVE_TRAIT"
    if not player then
        reason = "RUNTIME_NOT_STARTED"
    elseif not Core.Trait then
        reason = "BOOTSTRAP_INCLUDE_MISSING"
    elseif Core.Trait and Core.Trait.detectorFailed then
        reason = "TRAIT_DETECTOR_BROKEN"
    end

    if not ActivationDiagnostic.logged or ActivationDiagnostic.lastActive ~= activeValue or ActivationDiagnostic.lastReason ~= reason then
        ActivationDiagnostic.logged = true
        ActivationDiagnostic.lastActive = activeValue
        ActivationDiagnostic.lastReason = reason
        print("[XNP ACTIVATION] build=" .. tostring(Constants.BUILD_ID))
        print("[XNP ACTIVATION] mod_loaded=true")
        print("[XNP ACTIVATION] player_found=" .. boolText(player ~= nil))
        print("[XNP ACTIVATION] trait_registered=" .. boolText(traitRegistered()))
        print("[XNP ACTIVATION] expected_trait_full_id=" .. tostring(Constants.TRAIT_FULL_ID))
        print("[XNP ACTIVATION] expected_trait_id=" .. tostring(Constants.TRAIT_ID))
        print("[XNP ACTIVATION] detector_method=" .. tostring(Constants.TRAIT_DETECTION_METHOD))
        print("[XNP ACTIVATION] has_trait_object=" .. boolText(objectFound))
        print("[XNP ACTIVATION] has_trait_full_id=" .. boolText(aliasFound and snapshot.matchedAlias == Constants.TRAIT_FULL_ID))
        print("[XNP ACTIVATION] has_trait_short_id=" .. boolText(aliasFound and snapshot.matchedAlias == Constants.TRAIT_ID))
        print("[XNP ACTIVATION] has_trait_any_alias=" .. boolText(aliasFound))
        if snapshot and Config.ACTIVATION_LOG_TRAIT_ALIASES then
            print("[XNP ACTIVATION] aliases_expected=" .. join(snapshot.aliases))
            print("[XNP ACTIVATION] player_trait_names=" .. join(snapshot.names))
        end
        print("[XNP ACTIVATION] active=" .. boolText(activeValue))
        if not activeValue then
            print("[XNP ACTIVATION FAIL] reason=" .. tostring(reason))
            if reason == "PLAYER_DOES_NOT_HAVE_TRAIT" then
                print("[XNP ACTIVATION HELP] create_new_character_with_trait=" .. tostring(Constants.TRAIT_FULL_ID))
                print("[XNP ACTIVATION HELP] if_trait_selected_then_detector_bug=true")
            end
        end
    end
    return activeValue
end

function ActivationDiagnostic.GetState()
    return {
        active = ActivationDiagnostic.lastActive == true,
        reason = ActivationDiagnostic.lastReason or "unknown",
    }
end

Core.ActivationDiagnostic = ActivationDiagnostic
return ActivationDiagnostic
