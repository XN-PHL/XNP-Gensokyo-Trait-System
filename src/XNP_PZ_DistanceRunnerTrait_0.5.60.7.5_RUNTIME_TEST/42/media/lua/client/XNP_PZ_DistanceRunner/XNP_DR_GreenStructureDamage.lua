require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_MeleeMode"

local Core = XNP_PZ_DistanceRunner

local Structure = {
    TOTAL_EQUIVALENT_HITS = 20,
    ADDITIONAL_EQUIVALENT_HITS = 19,
    registered = false,
    applyingFinalDoorHit = false,
    pending = {},
    recentTokens = {},
}

local function equivalentHits()
    if Core.SandboxTuning and Core.SandboxTuning.GetNumber then
        return Core.SandboxTuning.GetNumber("GreenStructureDamageMultiplier", 20, 1, 50)
    end
    return Structure.TOTAL_EQUIVALENT_HITS
end

local function nowMs()
    return type(getTimestampMs) == "function" and getTimestampMs() or os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function isType(object, className)
    if not object or type(instanceof) ~= "function" then return false end
    local ok, result = pcall(function() return instanceof(object, className) end)
    return ok and result == true
end

local function objectClass(target)
    for _, className in ipairs({ "IsoDoor", "IsoWindow", "IsoBarricade", "IsoThumpable" }) do
        if isType(target, className) then return className end
    end
    return nil
end

local function identity(object, methods)
    for _, method in ipairs(methods) do
        local ok, value = invoke(object, method)
        if ok and value ~= nil then return tostring(value) end
    end
    return tostring(object)
end

local function validAttacker(attacker)
    if not isType(attacker, "IsoPlayer") then return false, "ATTACKER_NOT_ISOPLAYER" end
    local ok, npc = invoke(attacker, "isNpc")
    if ok and npc == true then return false, "NPC_EXCLUDED" end
    ok, npc = invoke(attacker, "getVehicle")
    if ok and npc ~= nil then return false, "VEHICLE_EXCLUDED" end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(attacker, "GREEN") ~= true then
        return false, "GREEN_TRAIT_MISSING"
    end
    if not Core.GreenSkill.IsEnabled(attacker) then return false, "GREEN_MELEE_DISABLED" end
    return true, "OK"
end

local function verifiedMelee(attacker, weapon)
    if not isType(weapon, "HandWeapon") then return false, "NOT_HAND_WEAPON" end
    local ok, value = invoke(weapon, "isRanged")
    if not ok or value ~= false then return false, "RANGED_OR_UNVERIFIED" end
    ok, value = invoke(attacker, "isDoShove")
    if ok and value == true then return false, "SHOVE_EXCLUDED" end
    ok, value = invoke(weapon, "getType")
    if ok and value == "BareHands" then return false, "UNARMED_EXCLUDED" end
    ok, value = invoke(weapon, "getPhysicsObject")
    if ok and value ~= nil then return false, "THROWN_EXCLUDED" end
    ok, value = invoke(weapon, "isAimedFirearm")
    if ok and value == true then return false, "FIREARM_EXCLUDED" end
    return true, "VERIFIED_MELEE_HANDWEAPON"
end

local function cleanTokens(now)
    for token, stamp in pairs(Structure.recentTokens) do
        if now - stamp > 1000 then Structure.recentTokens[token] = nil end
    end
end

local function acceptToken(attacker, weapon, target, now)
    cleanTokens(now)
    local token = table.concat({
        identity(attacker, { "getOnlineID", "getPlayerNum", "getUsername" }),
        identity(weapon, { "getID", "getFullType" }),
        identity(target, { "getObjectIndex", "getX" }),
        tostring(math.floor(now / 100)),
    }, "|")
    if Structure.recentTokens[token] then return false end
    Structure.recentTokens[token] = now
    return true
end

local function currentHealth(target)
    local ok, health = invoke(target, "getHealth")
    health = ok and tonumber(health) or nil
    return health
end

local function restoreScalar(object, getMethod, setMethod, value)
    if value == nil or not object or type(object[setMethod]) ~= "function" then return false end
    return pcall(function() object[setMethod](object, value) end)
end

local function finishDoorDestruction(entry, healthAfter, additional)
    if type(entry.target.setHealth) ~= "function" then return false, "DOOR_SET_HEALTH_UNAVAILABLE" end
    local remaining = healthAfter - additional
    if remaining > 0 then
        local ok = pcall(function() entry.target:setHealth(math.floor(remaining)) end)
        return ok, ok and "DOOR_SET_HEALTH" or "DOOR_SET_HEALTH_FAILED"
    end

    local conditionOk, condition = invoke(entry.weapon, "getCondition")
    local statsOk, stats = invoke(entry.attacker, "getStats")
    local enduranceBefore = nil
    if statsOk and stats and CharacterStat and CharacterStat.ENDURANCE and type(stats.get) == "function" then
        local ok, value = pcall(function() return stats:get(CharacterStat.ENDURANCE) end)
        if ok then enduranceBefore = value end
    end
    pcall(function() entry.target:setHealth(1) end)
    Structure.applyingFinalDoorHit = true
    local hitOk = pcall(function() entry.target:WeaponHit(entry.attacker, entry.weapon) end)
    Structure.applyingFinalDoorHit = false
    if conditionOk then restoreScalar(entry.weapon, "getCondition", "setCondition", condition) end
    if enduranceBefore ~= nil and stats and type(stats.set) == "function" then
        pcall(function() stats:set(CharacterStat.ENDURANCE, enduranceBefore) end)
    end
    return hitOk, hitOk and "DOOR_FINAL_ENGINE_HIT" or "DOOR_FINAL_ENGINE_HIT_FAILED"
end

local function applyAdditionalDamage(entry, healthAfter, additional)
    if entry.className == "IsoDoor" then
        return finishDoorDestruction(entry, healthAfter, additional)
    end
    if type(entry.target.Damage) ~= "function" then return false, "DAMAGE_API_UNAVAILABLE" end
    local ok = pcall(function() entry.target:Damage(additional) end)
    return ok, ok and "PUBLIC_DAMAGE_FLOAT" or "PUBLIC_DAMAGE_FAILED"
end

function Structure.OnWeaponHitThumpable(attacker, weapon, target)
    if Structure.applyingFinalDoorHit then return end
    if Core.SandboxTuning.GetBoolean("GreenStructureDamageEnabled", true) ~= true then return end
    local valid, reason = validAttacker(attacker)
    if not valid then return end
    valid, reason = verifiedMelee(attacker, weapon)
    if not valid then return end
    local className = objectClass(target)
    if not className then return end
    if className == "IsoDoor" and Core.SandboxTuning.GetBoolean("GreenDoorDamageEnabled", true) ~= true then return end
    if className ~= "IsoDoor" and Core.SandboxTuning.GetBoolean("GreenThumpableDamageEnabled", true) ~= true then return end
    local healthBefore = currentHealth(target)
    if not healthBefore or healthBefore <= 0 then return end
    local ok, doorDamage = invoke(weapon, "getDoorDamage")
    doorDamage = ok and tonumber(doorDamage) or nil
    if not doorDamage or doorDamage <= 0 then return end
    local now = nowMs()
    if not acceptToken(attacker, weapon, target, now) then return end
    local tier = Core.GreenSkill.GetTier(attacker)
    Structure.pending[#Structure.pending + 1] = {
        attacker = attacker,
        weapon = weapon,
        target = target,
        className = className,
        healthBefore = healthBefore,
        weaponDoorDamage = doorDamage,
        tier = tier,
        readyAtMs = now + 1,
        expiresAtMs = now + 500,
    }
end

function Structure.Update(player)
    if #Structure.pending == 0 then return false end
    local now = nowMs()
    for index = #Structure.pending, 1, -1 do
        local entry = Structure.pending[index]
        if now > entry.expiresAtMs then
            table.remove(Structure.pending, index)
        elseif now >= entry.readyAtMs then
            local healthAfter = currentHealth(entry.target)
            local vanillaDamage = healthAfter and math.max(entry.healthBefore - healthAfter, 0) or 0
            if healthAfter and vanillaDamage > 0 then
                table.remove(Structure.pending, index)
                local totalEquivalentHits = equivalentHits()
                local additional = vanillaDamage * math.max(totalEquivalentHits - 1, 0)
                local destroyedOk, destroyed = invoke(entry.target, "isDestroyed")
                local applied, method = true, "VANILLA_ALREADY_DESTROYED"
                if not (destroyedOk and destroyed == true) and healthAfter > 0 then
                    applied, method = applyAdditionalDamage(entry, healthAfter, additional)
                end
                if applied then
                    local paid, before, after = Core.GreenSkill.DeductEndurance(entry.attacker, entry.tier.enduranceCost)
                    print("[XNP GREEN STRUCTURE] target_class=" .. tostring(entry.className)
                        .. " weapon=" .. identity(entry.weapon, { "getFullType", "getType" })
                        .. " base_structure_damage=" .. string.format("%.3f", vanillaDamage)
                        .. " total_equivalent_hits=" .. tostring(totalEquivalentHits)
                        .. " additional_damage=" .. string.format("%.3f", additional)
                        .. " method=" .. tostring(method)
                        .. " weapon_door_damage=" .. tostring(entry.weaponDoorDamage)
                        .. " endurance_cost=" .. string.format("%.2f", entry.tier.enduranceCost)
                        .. " cost_applied=" .. tostring(paid)
                        .. " endurance_before=" .. tostring(before)
                        .. " endurance_after=" .. tostring(after))
                end
            end
        end
    end
    return true
end

function Structure.Register()
    if Structure.registered then return true end
    if Core.MeleeMode and Core.MeleeMode.IsMultiplayerProcess() then
        return false, "MULTIPLAYER_STRUCTURE_AUTHORITY_NOT_VERIFIED"
    end
    if not Events or not Events.OnWeaponHitThumpable or type(Events.OnWeaponHitThumpable.Add) ~= "function" then
        return false, "ONWEAPONHITTHUMPABLE_UNAVAILABLE"
    end
    Events.OnWeaponHitThumpable.Add(Structure.OnWeaponHitThumpable)
    Structure.registered = true
    print("[XNP GREEN STRUCTURE] registered=true event=OnWeaponHitThumpable order=PRE_VANILLA_DAMAGE deferred_delta_multiplier=19")
    return true
end

function Structure.Cleanup(reason)
    Structure.pending = {}
    Structure.recentTokens = {}
    Structure.applyingFinalDoorHit = false
end

Structure.Register()
Core.GreenStructureDamage = Structure
return Structure
