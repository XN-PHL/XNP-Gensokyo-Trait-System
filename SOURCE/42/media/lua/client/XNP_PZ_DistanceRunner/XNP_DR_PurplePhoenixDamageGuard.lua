require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixTransaction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixInvulnerability"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"

local Core = XNP_PZ_DistanceRunner
local Guard = {
    registered = false,
    eventNames = {},
    handling = false,
    eventSerial = 0,
    pendingWeaponTransaction = nil,
    rawWeaponEventLogged = false,
    normalizerEvidenceLogged = false,
    weaponRoleGateLogKeys = {},
    normalizedWeaponEventCount = 0,
    rejectedWeaponEventCount = 0,
    playerAttackerRejectedCount = 0,
    playerTargetAcceptedCount = 0,
    weaponTransactionCreatedCount = 0,
    hardCodedArgumentOrder = true,
    banditsBridgeInstalled = false,
    banditsBridgeInstallAttempts = 0,
    banditsBridgeInterceptCount = 0,
    banditsBridgeProtectedCount = 0,
    banditsOriginalBulletHit = nil,
    banditsWrapper = nil,
}

local BANDITS_MAX_SINGLE_BULLET_HEALTH_DROP = 75

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function invoke(object, method, ...)
    local objectType = type(object)
    if not object
        or (objectType ~= "table" and objectType ~= "userdata")
        or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function safeBoolean(object, method)
    local ok, value = invoke(object, method)
    return ok and value == true or nil
end

local function isZombie(object)
    if not object then return false end
    if type(instanceof) == "function" then
        local ok, value = pcall(instanceof, object, "IsoZombie")
        if ok then return value == true end
    end
    return safeBoolean(object, "isZombie") == true
end

local function isControlledPlayer(object)
    local objectType = type(object)
    if not object
        or (objectType ~= "table" and objectType ~= "userdata")
        or type(object.getBodyDamage) ~= "function"
        or type(object.getModData) ~= "function" then
        return false
    end
    local ok, valid = pcall(function()
        return Core.CanonicalPlayerIdentity.Validate(object, true)
    end)
    return ok and valid == true
end

local function looksLikeWeapon(object)
    local objectType = type(object)
    if not object
        or (objectType ~= "table" and objectType ~= "userdata") then
        return false
    end
    return type(object.isRanged) == "function"
        or type(object.isExplosive) == "function"
        or type(object.getMaxDamage) == "function"
        or type(object.getWeaponPart) == "function"
end

local function looksLikeCharacter(object)
    local objectType = type(object)
    if not object
        or (objectType ~= "table" and objectType ~= "userdata")
        or looksLikeWeapon(object) then return false end
    return type(object.getX) == "function"
        and type(object.getY) == "function"
end

local function classifyWeapon(attacker, weapon)
    if safeBoolean(weapon, "isExplosive") == true then
        return "EXPLOSION_FATAL_EDGE"
    end
    if safeBoolean(weapon, "isRanged") == true then
        return "PROJECTILE_FATAL_EDGE"
    end
    if safeBoolean(weapon, "isRanged") == false or isZombie(attacker) then
        return "MELEE_FATAL_EDGE"
    end
    return "DAMAGE_THRESHOLD_EDGE"
end

local function classifyDamageType(damageType)
    local value = string.upper(tostring(damageType or "UNKNOWN"))
    if value == "FALLDOWN" or string.find(value, "FALL", 1, true) then
        return "FALL_FATAL_EDGE"
    end
    if string.find(value, "EXPLOS", 1, true)
        or string.find(value, "FIRE", 1, true) then
        return "EXPLOSION_FATAL_EDGE"
    end
    if string.find(value, "BLEED", 1, true)
        or string.find(value, "POISON", 1, true)
        or string.find(value, "SICK", 1, true) then
        return "BLEED_OR_CONTINUOUS_EDGE"
    end
    return "DAMAGE_THRESHOLD_EDGE"
end

local function newTransactionId(sourceType)
    Guard.eventSerial = Guard.eventSerial + 1
    return "damage-edge-" .. tostring(nowMs()) .. "-"
        .. tostring(Guard.eventSerial) .. "-" .. tostring(sourceType)
end

local function captureDeathCandidate(player, source)
    local controller = Core.PurpleLifeStockController
    if controller and type(controller.CaptureDeathCandidate) == "function" then
        pcall(controller.CaptureDeathCandidate, player, source)
    end
end

local function describeArgument(value)
    local kind = type(value)
    if kind ~= "table" and kind ~= "userdata" then return kind end
    local capabilities = {}
    if isControlledPlayer(value) then
        capabilities[#capabilities + 1] = "CONTROLLED_PLAYER"
    end
    if looksLikeWeapon(value) then
        capabilities[#capabilities + 1] = "WEAPON"
    end
    if looksLikeCharacter(value) then
        capabilities[#capabilities + 1] = "CHARACTER"
    end
    if #capabilities == 0 then capabilities[1] = "OBJECT" end
    return kind .. ":" .. table.concat(capabilities, "+")
end

local function collectArguments(...)
    local count = select("#", ...)
    local values = {}
    for index = 1, count do
        values[index] = select(index, ...)
    end
    return values, count
end

local function normalizeWeaponArguments(eventName, ...)
    local values, count = collectArguments(...)
    local target, weapon, attacker, damage
    local targetIndex, weaponIndex, attackerIndex, damageIndex
    for index = 1, count do
        local value = values[index]
        if not target and isControlledPlayer(value) then
            target, targetIndex = value, index
        elseif not weapon and looksLikeWeapon(value) then
            weapon, weaponIndex = value, index
        elseif type(value) == "number" then
            damage, damageIndex = value, index
        end
    end
    for index = 1, count do
        local value = values[index]
        if value ~= target and value ~= weapon
            and looksLikeCharacter(value) then
            attacker, attackerIndex = value, index
            break
        end
    end
    local evidence = {
        count = count,
        target_index = targetIndex,
        weapon_index = weaponIndex,
        attacker_index = attackerIndex,
        damage_index = damageIndex,
        hard_coded_argument_order = false,
    }
    if not Guard.rawWeaponEventLogged then
        Guard.rawWeaponEventLogged = true
        local fields = {
            "[XNP PHOENIX WEAPON EVENT RAW]",
            "event=" .. tostring(eventName or "UNKNOWN"),
            "arg_count=" .. tostring(count),
        }
        for index = 1, count do
            fields[#fields + 1] = "arg_" .. tostring(index)
                .. "_type=" .. describeArgument(values[index])
        end
        fields[#fields + 1] = "controlled_player_arg_index="
            .. tostring(targetIndex or 0)
        fields[#fields + 1] = "weapon_arg_index="
            .. tostring(weaponIndex or 0)
        fields[#fields + 1] = "damage_arg_index="
            .. tostring(damageIndex or 0)
        fields[#fields + 1] = "object_dump=false"
        fields[#fields + 1] = "one_time=true"
        print(table.concat(fields, " "))
    end
    if not target then
        return nil, nil, nil, nil, evidence,
            "CONTROLLED_PLAYER_ARGUMENT_NOT_FOUND"
    end
    Guard.normalizedWeaponEventCount =
        Guard.normalizedWeaponEventCount + 1
    return attacker, target, weapon, damage, evidence, nil
end

local function logWeaponRoleGate(accepted, reason, evidence)
    local key = tostring(accepted == true) .. ":" .. tostring(reason)
    if Guard.weaponRoleGateLogKeys[key] then return end
    Guard.weaponRoleGateLogKeys[key] = true
    print("[XNP PHOENIX WEAPON ROLE GATE]"
        .. " accepted=" .. tostring(accepted == true)
        .. " reason=" .. tostring(reason)
        .. " attacker_index=" .. tostring(evidence.attacker_index or 0)
        .. " target_index=" .. tostring(evidence.target_index or 0)
        .. " weapon_index=" .. tostring(evidence.weapon_index or 0)
        .. " damage_index=" .. tostring(evidence.damage_index or 0)
        .. " controlled_player_role="
        .. tostring(evidence.controlledPlayerRole or "NONE")
        .. " victim_role_verified="
        .. tostring(evidence.victimRoleVerified == true)
        .. " phoenix_transaction_created="
        .. tostring(evidence.phoenixTransactionCreated == true)
        .. " throttled_once_per_result=true")
end

local function normalizeOnWeaponHitCharacterArguments(...)
    local values, count = collectArguments(...)
    local evidence = {
        count = count,
        attacker_index = 1,
        target_index = 2,
        weapon_index = 3,
        damage_index = 4,
        hard_coded_argument_order = true,
        victimRoleVerified = false,
        controlledPlayerRole = "NONE",
        phoenixTransactionCreated = false,
    }

    if not Guard.rawWeaponEventLogged then
        Guard.rawWeaponEventLogged = true
        local fields = {
            "[XNP PHOENIX WEAPON EVENT RAW]",
            "event=OnWeaponHitCharacter",
            "arg_count=" .. tostring(count),
        }
        for index = 1, count do
            fields[#fields + 1] = "arg_" .. tostring(index)
                .. "_type=" .. describeArgument(values[index])
        end
        fields[#fields + 1] = "verified_position_contract="
            .. "attacker,target,weapon,damage"
        fields[#fields + 1] = "object_dump=false"
        fields[#fields + 1] = "one_time=true"
        print(table.concat(fields, " "))
    end

    if count < 4 then
        return nil, nil, nil, nil, evidence,
            "AMBIGUOUS_WEAPON_EVENT_ROLE"
    end
    local attacker = values[1]
    local target = values[2]
    local weapon = values[3]
    local damage = values[4]
    if not looksLikeCharacter(attacker)
        or not looksLikeCharacter(target)
        or attacker == target
        or weapon == nil
        or looksLikeCharacter(weapon)
        or type(damage) ~= "number" then
        return nil, nil, nil, nil, evidence,
            "AMBIGUOUS_WEAPON_EVENT_ROLE"
    end
    if isControlledPlayer(attacker) then
        evidence.controlledPlayerRole = "ATTACKER"
        Guard.playerAttackerRejectedCount =
            Guard.playerAttackerRejectedCount + 1
        return nil, nil, nil, nil, evidence,
            "CONTROLLED_PLAYER_IS_ATTACKER"
    end
    if not isControlledPlayer(target) then
        return nil, nil, nil, nil, evidence,
            "CONTROLLED_PLAYER_NOT_VICTIM"
    end

    evidence.victimRoleVerified = true
    evidence.controlledPlayerRole = "TARGET"
    evidence.attackerRef = attacker
    evidence.targetRef = target
    Guard.normalizedWeaponEventCount =
        Guard.normalizedWeaponEventCount + 1
    Guard.playerTargetAcceptedCount =
        Guard.playerTargetAcceptedCount + 1
    return attacker, target, weapon, damage, evidence, nil
end

function Guard.OnWeaponHitCharacter(
    attacker, target, weapon, damage, roleEvidence)
    if type(roleEvidence) ~= "table"
        or roleEvidence.victimRoleVerified ~= true
        or roleEvidence.controlledPlayerRole ~= "TARGET"
        or roleEvidence.attackerRef ~= attacker
        or roleEvidence.targetRef ~= target
        or attacker == target then
        return false, "WEAPON_EVENT_VICTIM_ROLE_UNVERIFIED"
    end
    local valid, identityReason =
        Core.CanonicalPlayerIdentity.Validate(target, true)
    if not valid then
        return false, "IDENTITY_REJECTED:" .. tostring(identityReason)
    end
    if Core.PurplePhoenixInvulnerability.IsActive(target) then
        return Core.PurplePhoenixInvulnerability.ProtectDamage(
            target, "OnWeaponHitCharacter", nil)
    end
    local burstActive, burstTransactionId =
        Core.PhoenixTransaction.IsBurstGuardActive(target)
    if burstActive then
        print("[XNP PHOENIX BURST GUARD]"
            .. " transaction_id=" .. tostring(burstTransactionId)
            .. " event=OnWeaponHitCharacter"
            .. " suppressed_current_batch_callback=true")
        return true, "CURRENT_BATCH_BURST_GUARD_ACTIVE"
    end
    if Guard.handling then return false, "TRANSACTION_IN_PROGRESS" end
    captureDeathCandidate(target, "PRE_WEAPON_HIT")
    local sourceType = classifyWeapon(attacker, weapon)
    if sourceType == "PROJECTILE_FATAL_EDGE"
        and Core.PurplePhoenixConfig.Get()
            .rangedPredeathProtectionEnabled ~= true then
        return false, "RANGED_PREDEATH_PROTECTION_DISABLED_BY_SANDBOX"
    end

    local transactionId = newTransactionId(sourceType)
    Guard.weaponTransactionCreatedCount =
        Guard.weaponTransactionCreatedCount + 1
    Core.PhoenixTransaction.NoteDamageEvent(
        target, "OnWeaponHitCharacter:" .. sourceType,
        damage, transactionId)
    Guard.handling = true
    local triggered, result = Core.PhoenixTransaction.TryPredeathIntercept(
        target, {
            sourceEvent = "OnWeaponHitCharacter",
            sourceType = sourceType,
            anticipatedDamage = damage,
            damageScale = "PLAYER_HEALTH",
            preDamage = true,
            allowAvoidDamage = true,
            transactionId = transactionId,
            victimRoleVerified = true,
            controlledPlayerRole = "TARGET",
            attackerRef = attacker,
            targetRef = target,
        })
    Guard.handling = false
    Guard.pendingWeaponTransaction = {
        player = target,
        transactionId = transactionId,
        atMs = nowMs(),
        triggered = triggered == true,
    }
    return triggered, result
end

function Guard.OnPlayerGetDamage(player, damageType, damage)
    local valid, identityReason =
        Core.CanonicalPlayerIdentity.Validate(player, true)
    if not valid then
        return false, "IDENTITY_REJECTED:" .. tostring(identityReason)
    end
    if Core.PurplePhoenixInvulnerability.IsActive(player) then
        return Core.PurplePhoenixInvulnerability.ProtectDamage(
            player, "OnPlayerGetDamage:" .. tostring(damageType), nil)
    end
    captureDeathCandidate(player, "DAMAGE_NOTIFICATION")
    local sourceType = classifyDamageType(damageType)
    local pending = Guard.pendingWeaponTransaction
    local pendingTransactionId = pending and pending.player == player
        and nowMs() - pending.atMs <= 1000
        and pending.transactionId or nil
    Core.PhoenixTransaction.NoteDamageEvent(
        player, "OnPlayerGetDamage:" .. sourceType,
        damage, pendingTransactionId)
    if pending and pending.player == player
        and nowMs() - pending.atMs <= 1000 then
        Guard.pendingWeaponTransaction = nil
        if pending.triggered then
            return false, "TRANSACTION_ALREADY_CONSUMED"
        end
    end
    return Core.PhoenixTransaction.TryPredeathIntercept(player, {
        sourceEvent = "OnPlayerGetDamage",
        sourceType = sourceType,
        anticipatedDamage = damage,
        preDamage = false,
        transactionId = newTransactionId(sourceType),
    })
end

local function bodyHealth(player)
    local bodyOk, body = invoke(player, "getBodyDamage")
    local healthOk, health = invoke(bodyOk and body or nil,
        "getOverallBodyHealth")
    if not healthOk or tonumber(health) == nil then return nil end
    health = tonumber(health)
    return health > 1 and health / 100 or health
end

local function callOriginal(original, values, count)
    return original(unpack(values, 1, count))
end

local function handleBanditsBulletHit(original, values, count)
    local attacker, target, weapon, _, evidence =
        normalizeWeaponArguments(
            "Bandits2.PlayerDamageModel.BulletHit",
            unpack(values, 1, count))
    if not target then return callOriginal(original, values, count) end

    if Core.PurplePhoenixInvulnerability.IsActive(target) then
        Guard.banditsBridgeProtectedCount =
            Guard.banditsBridgeProtectedCount + 1
        Core.PurplePhoenixInvulnerability.ProtectDamage(
            target, "BANDITS2_BULLET_HIT_ACTIVE_WINDOW", nil)
        print("[XNP PHOENIX BANDITS2 BRIDGE] active_window_block=true"
            .. " selected_player_index=" .. tostring(evidence.target_index)
            .. " original_bullet_function_called=false")
        return nil
    end

    local currentHealth = bodyHealth(target)
    local config = Core.PurplePhoenixConfig.Get()
    local projected = currentHealth and
        math.max(0, currentHealth
            - BANDITS_MAX_SINGLE_BULLET_HEALTH_DROP / 100) or nil
    local shouldBridge = config.rangedPredeathProtectionEnabled == true
        and projected ~= nil and projected <= config.triggerHealth
    if not shouldBridge then return callOriginal(original, values, count) end

    captureDeathCandidate(target, "BANDITS2_PRE_BULLET_HIT")
    local transactionId = newTransactionId("PROJECTILE_FATAL_EDGE")
    Guard.banditsBridgeInterceptCount =
        Guard.banditsBridgeInterceptCount + 1
    local triggered, result =
        Core.PhoenixTransaction.TryPredeathIntercept(target, {
            sourceEvent = "Bandits2.PlayerDamageModel.BulletHit",
            sourceType = "PROJECTILE_FATAL_EDGE",
            anticipatedDamage = BANDITS_MAX_SINGLE_BULLET_HEALTH_DROP,
            preDamage = true,
            allowAvoidDamage = true,
            transactionId = transactionId,
        })
    print("[XNP PHOENIX BANDITS2 BRIDGE] intercept_attempt=true"
        .. " transaction_id=" .. tostring(transactionId)
        .. " current_health=" .. tostring(currentHealth)
        .. " worst_case_projected_health=" .. tostring(projected)
        .. " trigger_threshold=" .. tostring(config.triggerHealth)
        .. " triggered=" .. tostring(triggered == true)
        .. " result=" .. tostring(result)
        .. " original_bullet_function_called="
        .. tostring(triggered ~= true))
    if triggered then return nil end
    return callOriginal(original, values, count)
end

function Guard.TryInstallBandits2Bridge()
    Guard.banditsBridgeInstallAttempts =
        Guard.banditsBridgeInstallAttempts + 1
    local model = PlayerDamageModel
    if type(model) ~= "table"
        or type(model.BulletHit) ~= "function" then
        return false, "PLAYER_DAMAGE_MODEL_NOT_LOADED"
    end
    if Guard.banditsWrapper
        and model.BulletHit == Guard.banditsWrapper then
        Guard.banditsBridgeInstalled = true
        return true, "ALREADY_INSTALLED"
    end
    if Guard.banditsBridgeInstalled then
        return false, "BANDITS_FUNCTION_REPLACED_AFTER_INSTALL"
    end

    local original = model.BulletHit
    Guard.banditsOriginalBulletHit = original
    Guard.banditsWrapper = function(...)
        local values, count = collectArguments(...)
        local ok, a, b, c, d = pcall(
            handleBanditsBulletHit, original, values, count)
        if ok then return a, b, c, d end
        print("[XNP PHOENIX BANDITS2 BRIDGE] fail_closed=true"
            .. " reason=" .. tostring(a)
            .. " original_bullet_function_called=true")
        return callOriginal(original, values, count)
    end
    model.BulletHit = Guard.banditsWrapper
    Guard.banditsBridgeInstalled = true
    print("[XNP PHOENIX BANDITS2 BRIDGE] installed=true"
        .. " source=Bandits2.PlayerDamageModel.BulletHit"
        .. " verified_local_signature=shooter,item,player"
        .. " runtime_normalizer=CAPABILITY_BASED"
        .. " bandits_files_modified=0")
    return true, "BANDITS2_BRIDGE_INSTALLED"
end

function Guard.Update()
    if not Guard.banditsBridgeInstalled then
        return Guard.TryInstallBandits2Bridge()
    end
    return true, "BANDITS2_BRIDGE_STABLE"
end

function Guard.CancelForDeath(player, reason)
    Guard.handling = false
    Guard.pendingWeaponTransaction = nil
    if player then
        return Core.PhoenixTransaction.OnDeath(
            player, reason or "PLAYER_DEATH")
    end
    return true, "NO_PLAYER"
end

local function addEvent(name, callback)
    local event = Events and Events[name] or nil
    if not event or type(event.Add) ~= "function" then
        print("[XNP PHOENIX SURVIVAL GUARD] event_missing="
            .. tostring(name))
        return false
    end
    event.Add(callback)
    Guard.eventNames[#Guard.eventNames + 1] = name
    return true
end

function Guard.OnWeaponHitCharacterEvent(...)
    local attacker, target, weapon, damage, evidence, normalizeReason =
        normalizeOnWeaponHitCharacterArguments(...)
    if not target then
        Guard.rejectedWeaponEventCount =
            Guard.rejectedWeaponEventCount + 1
        logWeaponRoleGate(false, normalizeReason, evidence)
        return false, normalizeReason
    end
    logWeaponRoleGate(true, "CONTROLLED_PLAYER_IS_TARGET", evidence)
    local ok, triggered, result = pcall(
        Guard.OnWeaponHitCharacter,
        attacker, target, weapon, damage, evidence)
    Guard.handling = false
    if not ok then
        print("[XNP PHOENIX SURVIVAL FAIL CLOSED]"
            .. " reason=WEAPON_EVENT_EXCEPTION detail="
            .. tostring(triggered))
        return false, "INTERNAL_EXCEPTION"
    end
    return triggered, result
end

function Guard.OnPlayerGetDamageEvent(player, damageType, damage)
    local ok, triggered, result = pcall(
        Guard.OnPlayerGetDamage, player, damageType, damage)
    Guard.handling = false
    if not ok then
        print("[XNP PHOENIX SURVIVAL FAIL CLOSED]"
            .. " reason=DAMAGE_EVENT_EXCEPTION detail="
            .. tostring(triggered))
        return false, "INTERNAL_EXCEPTION"
    end
    return triggered, result
end

function Guard.RegisterEvents()
    if Guard.registered then return true, "ALREADY_REGISTERED" end
    local weaponAdded = addEvent(
        "OnWeaponHitCharacter", Guard.OnWeaponHitCharacterEvent)
    local damageAdded = addEvent(
        "OnPlayerGetDamage", Guard.OnPlayerGetDamageEvent)
    Guard.TryInstallBandits2Bridge()
    Guard.registered = weaponAdded and damageAdded
    print("[XNP PHOENIX SURVIVAL GUARD] candidate_events="
        .. table.concat(Guard.eventNames, ",")
        .. " predeath_order=SELECTIVELY_PORTED_FROM_0.5.60.7.6"
        .. " proven_ranged_source=0.5.60.7.6"
        .. " predeath_intercept_reachable="
        .. tostring(weaponAdded == true)
        .. " postdamage_final_success_allowed=false"
        .. " invulnerability=true"
        .. " central_entrypoint=1"
        .. " hard_coded_argument_order=true")
    return Guard.registered, Guard.registered
        and "PHOENIX_DAMAGE_EVENTS_REGISTERED"
        or "PHOENIX_DAMAGE_EVENT_REGISTRATION_INCOMPLETE"
end

function Guard.GetAuditSnapshot()
    return {
        registered = Guard.registered,
        predeath_intercept_reachable =
            Guard.registered and #Guard.eventNames >= 1,
        candidate_events = table.concat(Guard.eventNames, ","),
        postdamage_final_success_allowed = false,
        transient_current_hit_neutralizer = true,
        burst_guard_max_ms = 250,
        burst_guard_max_frames = 2,
        same_batch_only = true,
        persistent_invulnerability = true,
        raw_weapon_event_logged = Guard.rawWeaponEventLogged,
        normalized_weapon_event_count =
            Guard.normalizedWeaponEventCount,
        rejected_weapon_event_count =
            Guard.rejectedWeaponEventCount,
        player_attacker_rejected_count =
            Guard.playerAttackerRejectedCount,
        player_target_accepted_count =
            Guard.playerTargetAcceptedCount,
        weapon_transaction_created_count =
            Guard.weaponTransactionCreatedCount,
        pending_weapon_transaction =
            Guard.pendingWeaponTransaction ~= nil,
        hard_coded_argument_order =
            Guard.hardCodedArgumentOrder,
        bandits_bridge_installed =
            Guard.banditsBridgeInstalled,
        bandits_bridge_install_attempts =
            Guard.banditsBridgeInstallAttempts,
        bandits_bridge_intercept_count =
            Guard.banditsBridgeInterceptCount,
        bandits_bridge_protected_count =
            Guard.banditsBridgeProtectedCount,
        bandits_files_modified = 0,
    }
end

Core.PurplePhoenixDamageGuard = Guard
return Guard
