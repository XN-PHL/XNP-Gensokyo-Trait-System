require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixLifeGate"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixTransaction"

local Core = XNP_PZ_DistanceRunner
local Guard = {
    registered = false,
    eventNames = {},
    handling = false,
    eventSerial = 0,
    pendingWeaponTransaction = nil,
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function localPlayer()
    if type(getSpecificPlayer) == "function" then return getSpecificPlayer(0) end
    if type(getPlayer) == "function" then return getPlayer() end
    return nil
end

local function safeBoolean(object, method)
    if not object or type(object[method]) ~= "function" then return nil end
    local ok, value = pcall(function() return object[method](object) end)
    if not ok then return nil end
    return value == true
end

local function classifyWeapon(weapon)
    if safeBoolean(weapon, "isExplosive") == true then return "EXPLOSION_FATAL_EDGE" end
    if safeBoolean(weapon, "isRanged") == true then return "PROJECTILE_FATAL_EDGE" end
    if weapon and safeBoolean(weapon, "isRanged") == false then return "MELEE_FATAL_EDGE" end
    return "UNKNOWN"
end

local function classifyDamageType(damageType)
    local value = string.upper(tostring(damageType or "UNKNOWN"))
    if value == "FALLDOWN" then return "FALL_LATE_NOTIFICATION" end
    if value == "CARHITDAMAGE" or value == "CARCRASHDAMAGE" then return "UNKNOWN" end
    if value == "FIRE" then return "UNKNOWN" end
    if string.find(value, "EXPLOS", 1, true) then return "EXPLOSION_FATAL_EDGE" end
    return "DAMAGE_THRESHOLD_EDGE"
end

local function newTransactionId(sourceType)
    Guard.eventSerial = Guard.eventSerial + 1
    return "weapon-edge-" .. tostring(nowMs()) .. "-" .. tostring(Guard.eventSerial) .. "-" .. tostring(sourceType)
end

function Guard.OnWeaponHitCharacter(attacker, target, weapon, damage)
    if not target or target ~= localPlayer() then return false, "NOT_LOCAL_PLAYER" end
    if Guard.handling then return false, "TRANSACTION_IN_PROGRESS" end
    local sourceType = classifyWeapon(weapon)
    if sourceType == "UNKNOWN" then return false, "SOURCE_NOT_PROVEN" end
    local transactionId = newTransactionId(sourceType)
    Guard.handling = true
    local triggered, result = Core.PhoenixTransaction.TryPredeathIntercept(target, {
        sourceEvent = "OnWeaponHitCharacter",
        sourceType = sourceType,
        anticipatedDamage = damage,
        damageScale = "PLAYER_HEALTH",
        preDamage = true,
        allowAvoidDamage = true,
        transactionId = transactionId,
        attacker = attacker,
        weapon = weapon,
    })
    Guard.handling = false
    Guard.pendingWeaponTransaction = {
        player = target,
        transactionId = transactionId,
        atMs = nowMs(),
        triggered = triggered == true,
        sourceType = sourceType,
    }
    return triggered, result
end

function Guard.OnPlayerGetDamage(player, damageType, damage)
    if not player or player ~= localPlayer() then return false, "NOT_LOCAL_PLAYER" end
    Core.PhoenixTransaction.OnDamageNotification(player, damageType)
    local normalizedType = string.upper(tostring(damageType or ""))
    if normalizedType == "WEAPONHIT" then
        local pending = Guard.pendingWeaponTransaction
        Guard.pendingWeaponTransaction = nil
        if pending and pending.player == player and nowMs() - pending.atMs <= 1000 then
            if pending.triggered then
                print("[XNP PHOENIX PREDEATH] duplicate_callback_blocked=true transaction_id=" .. pending.transactionId)
            end
            return false, pending.triggered and "TRANSACTION_ALREADY_CONSUMED" or "WEAPON_EDGE_ALREADY_EVALUATED"
        end
        return false, "WEAPON_SOURCE_NOT_PROVEN_WITHOUT_WEAPON_EVENT"
    end
    if normalizedType == "FALLDOWN" then return false, "FALL_LATE_NOTIFICATION_ONLY" end
    local sourceType = classifyDamageType(damageType)
    if sourceType == "UNKNOWN" then return false, "SOURCE_NOT_PROVEN" end
    return Core.PhoenixTransaction.TryPredeathIntercept(player, {
        sourceEvent = "OnPlayerGetDamage",
        sourceType = sourceType,
        anticipatedDamage = damage,
        damageScale = "BODY_HEALTH",
        preDamage = false,
        transactionId = newTransactionId(sourceType),
    })
end

function Guard.CancelForDeath(player, reason)
    Guard.handling = false
    Guard.pendingWeaponTransaction = nil
    if player then Core.PhoenixTransaction.OnDeath(player, reason or "PLAYER_DEATH") end
end

local function addEvent(name, callback)
    local event = Events and Events[name] or nil
    if not event or type(event.Add) ~= "function" then
        print("[XNP PHOENIX DAMAGE GUARD] event_missing=" .. tostring(name))
        return false
    end
    event.Add(callback)
    Guard.eventNames[#Guard.eventNames + 1] = name
    return true
end

function Guard.RegisterEvents()
    if Guard.registered then return true end
    local weaponAdded = addEvent("OnWeaponHitCharacter", Guard.OnWeaponHitCharacter)
    local damageAdded = addEvent("OnPlayerGetDamage", Guard.OnPlayerGetDamage)
    Guard.registered = weaponAdded and damageAdded
    print("[XNP PHOENIX DAMAGE GUARD] candidate_events=" .. table.concat(Guard.eventNames, ",")
        .. " ranged_source=WEAPON_IS_RANGED predeath_order=PROVEN central_entrypoint=1")
    return Guard.registered
end

Core.PurplePhoenixDamageGuard = Guard
return Guard
