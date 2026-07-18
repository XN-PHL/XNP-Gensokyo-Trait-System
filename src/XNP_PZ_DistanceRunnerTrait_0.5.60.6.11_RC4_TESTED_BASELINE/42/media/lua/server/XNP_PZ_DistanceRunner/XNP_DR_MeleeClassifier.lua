require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"

local Core = XNP_PZ_DistanceRunner

local Classifier = {}

local function call(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        if ok then return value end
    end
    return nil
end

local function isType(obj, className)
    if not obj or type(instanceof) ~= "function" then return false end
    local ok, value = pcall(function()
        return instanceof(obj, className)
    end)
    return ok and value == true
end

function Classifier.IsValidAttacker(attacker)
    if not isType(attacker, "IsoPlayer") then return false, "ATTACKER_NOT_ISOPLAYER" end
    if call(attacker, "isNpc") == true then return false, "NPC_EXCLUDED" end
    if call(attacker, "getVehicle") ~= nil then return false, "VEHICLE_IMPACT_EXCLUDED" end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(attacker, "GREEN") ~= true then
        return false, "GREEN_TRAIT_MISSING"
    end
    return true, "OK"
end

function Classifier.IsValidZombieTarget(target)
    if not isType(target, "IsoZombie") then return false, "TARGET_NOT_ZOMBIE" end
    if call(target, "isDead") == true then return false, "TARGET_ALREADY_DEAD" end
    return true, "OK"
end

function Classifier.IsVerifiedMeleeWeapon(attacker, weapon)
    if not isType(weapon, "HandWeapon") then return false, "NOT_HAND_WEAPON" end
    if call(weapon, "isRanged") ~= false then return false, "RANGED_OR_UNVERIFIED_EXCLUDED" end
    if call(attacker, "isDoShove") == true then return false, "PUSH_SHOVE_EXCLUDED" end
    if call(attacker, "isPerformingGrappleGrabAnimation") == true then return false, "GRAPPLE_EXCLUDED" end
    if call(attacker, "isAimAtFloor") == true and call(attacker, "isDoShove") == true then return false, "STOMP_EXCLUDED" end
    if call(weapon, "getType") == "BareHands" then return false, "UNARMED_EXCLUDED" end
    if call(weapon, "getPhysicsObject") ~= nil then return false, "THROWN_PROJECTILE_EXCLUDED" end
    if call(weapon, "isAimedFirearm") == true then return false, "FIREARM_EXCLUDED" end
    return true, "VERIFIED_MELEE_HANDWEAPON"
end

function Classifier.Classify(attacker, weapon, target)
    local ok, reason = Classifier.IsValidAttacker(attacker)
    if not ok then return false, reason end
    ok, reason = Classifier.IsValidZombieTarget(target)
    if not ok then return false, reason end
    return Classifier.IsVerifiedMeleeWeapon(attacker, weapon)
end

Core.MeleeClassifier = Classifier
return Classifier
