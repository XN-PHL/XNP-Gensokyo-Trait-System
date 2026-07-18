require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_MeleeMode"

local Core = XNP_PZ_DistanceRunner

local Orb = {
    FINAL_GREEN_MODE = "VIRTUAL_TRACKING_BLAST",
    GREEN_RUNTIME_ENTITY_RENDERING_ENABLED = false,
    GREEN_PROJECTILE_VISUAL = "DISABLED_FOR_RENDER_SAFETY",
    DAMAGE_TYPE = "XNP_GREEN_VIRTUAL_TRACKING_RADIAL_SHOCK",
    DAMAGE_WEAPON = "XNP_PZ_DistanceRunner.GreenOrbRadialShock",
    TARGET_SEARCH_INTERVAL_MS = 250,
    WALK_SPEED_FALLBACK_TPS = 1.45,
    WALK_SPEED_MIN_TPS = 0.50,
    WALK_SPEED_MAX_TPS = 3.00,
    active = nil,
    serial = 0,
    mapHidden = false,
    cooldownByPlayer = setmetatable({}, { __mode = "k" }),
    walkSamples = setmetatable({}, { __mode = "k" }),
    failureLogged = {},
}

local MODE = {
    [1] = "OFF",
    [2] = "VIRTUAL_TRACKING_BLAST",
    [3] = "LOCAL_BLAST",
}

local SHUTDOWN_REASON = {
    game_exit = "WORLD_EXIT",
    main_menu = "MAIN_MENU",
    player_death = "PLAYER_DEATH",
    player_replaced = "PLAYER_REPLACED",
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
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

local function coordinate(object, method)
    local ok, value = invoke(object, method)
    return ok and tonumber(value) or nil
end

local function tuningBoolean(name, fallback)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean then
        return Core.SandboxTuning.GetBoolean(name, fallback)
    end
    return fallback == true
end

local function tuningNumber(name, fallback, minimum, maximum)
    if Core.SandboxTuning and Core.SandboxTuning.GetNumber then
        return Core.SandboxTuning.GetNumber(name, fallback, minimum, maximum)
    end
    return fallback
end

local function activeMode()
    local index = math.floor(tuningNumber("GreenActiveMode", 2, 1, 3) + 0.5)
    return MODE[index] or "VIRTUAL_TRACKING_BLAST"
end

local function settings()
    return {
        mode = activeMode(),
        cooldownMs = tuningNumber("GreenCooldownRealSeconds", 5.0, 0.5, 120.0) * 1000,
        targetRadius = tuningNumber("GreenTargetSearchRadiusTiles", 12.0, 1.0, 30.0),
        noTargetMs = tuningNumber("GreenNoTargetSearchSeconds", 0.75, 0.1, 10.0) * 1000,
        initialMultiplier = tuningNumber("GreenInitialSpeedMultiplier", 1.0, 0.1, 5.0),
        accelerationStart = tuningNumber("GreenAccelerationStartSeconds", 3.0, 0.0, 10.0),
        accelerationPerSecond = tuningNumber("GreenAccelerationMultiplierPerSecond", 1.5, 1.0, 3.0),
        speedCap = tuningNumber("GreenMaximumVirtualSpeedTilesPerSecond", 8.0, 0.5, 30.0),
        maximumFlightMs = tuningNumber("GreenMaximumFlightSeconds", 8.0, 0.5, 30.0) * 1000,
        impactDistance = tuningNumber("GreenImpactDistanceTiles", 0.55, 0.1, 2.0),
        explosionRadius = tuningNumber("GreenExplosionRadiusTiles", 7.0, 0.5, 15.0),
        explosionDamage = tuningNumber("GreenExplosionBaseDamage", 10.0, 0.1, 100.0),
        falloff = tuningBoolean("GreenExplosionFalloffEnabled", true),
        targetOutline = tuningBoolean("EnableTargetOutline", true)
            and tuningBoolean("GreenTargetOutlineEnabled", true),
        castSound = tuningBoolean("EnableSounds", true)
            and tuningBoolean("GreenCastSoundEnabled", true),
        impactSound = tuningBoolean("EnableSounds", true)
            and tuningBoolean("GreenImpactSoundEnabled", true),
        refundNoTarget = tuningBoolean("GreenRefundCooldownOnNoTarget", true),
    }
end

local function playerDead(player)
    local ok, value = invoke(player, "isDead")
    if ok and value == true then return true end
    ok, value = invoke(player, "isOnDeathDone")
    return ok and value == true
end

local function validZombie(zombie)
    if not isType(zombie, "IsoZombie") then return false end
    local ok, dead = invoke(zombie, "isDead")
    if ok and dead == true then return false end
    local health = coordinate(zombie, "getHealth")
    return health == nil or health > 0
end

local function zombieList()
    if type(getCell) ~= "function" then return nil end
    local cell = getCell()
    if not cell or type(cell.getZombieList) ~= "function" then return nil end
    local ok, list = pcall(function() return cell:getZombieList() end)
    if not ok or not list or type(list.size) ~= "function" or type(list.get) ~= "function" then return nil end
    return list
end

local function nearestTarget(originX, originY, originZ, radius)
    local list = zombieList()
    if not list then return nil, "ZOMBIE_LIST_UNAVAILABLE" end
    local nearest, nearestDistance = nil, nil
    local ok, size = pcall(function() return list:size() end)
    size = ok and tonumber(size) or 0
    for index = 0, size - 1 do
        local itemOk, zombie = pcall(function() return list:get(index) end)
        if itemOk and validZombie(zombie) then
            local x = coordinate(zombie, "getX")
            local y = coordinate(zombie, "getY")
            local z = coordinate(zombie, "getZ")
            if x and y and z and math.abs(z - originZ) < 0.6 then
                local dx, dy = x - originX, y - originY
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance <= radius and (not nearestDistance or distance < nearestDistance) then
                    nearest, nearestDistance = zombie, distance
                end
            end
        end
    end
    if nearest then return nearest, "NEAREST_ALIVE_FROM_VIRTUAL_POSITION" end
    return nil, "NO_ZOMBIE_TARGET_YET"
end

local function normalized(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0.0001 then return nil, nil, 0 end
    return dx / length, dy / length, length
end

local function vectorComponent(vector, field, method)
    if not vector then return nil end
    local direct = tonumber(vector[field])
    if direct then return direct end
    local ok, value = invoke(vector, method)
    return ok and tonumber(value) or nil
end

local function playerForward(player)
    local ok, vector = invoke(player, "getForwardDirection")
    if ok and vector then
        local x = vectorComponent(vector, "x", "getX")
        local y = vectorComponent(vector, "y", "getY")
        local nx, ny = normalized(x or 0, y or 0)
        if nx then return nx, ny, "PLAYER_FORWARD_DIRECTION" end
    end
    return 1.0, 0.0, "SAFE_EAST_FALLBACK"
end

local function angleDelta(from, target)
    local delta = target - from
    while delta > math.pi do delta = delta - math.pi * 2 end
    while delta < -math.pi do delta = delta + math.pi * 2 end
    return delta
end

local function sampleWalkingSpeed(player, now)
    local x = coordinate(player, "getX")
    local y = coordinate(player, "getY")
    if not x or not y then return end
    local sample = Orb.walkSamples[player]
    if not sample then
        Orb.walkSamples[player] = { x = x, y = y, at = now, observed = nil }
        return
    end
    local elapsed = (now - sample.at) / 1000
    if elapsed < 0.05 then return end
    local dx, dy = x - sample.x, y - sample.y
    local tps = math.sqrt(dx * dx + dy * dy) / elapsed
    sample.x, sample.y, sample.at = x, y, now
    local _, sprinting = invoke(player, "isSprinting")
    local _, running = invoke(player, "isRunning")
    if sprinting == true or running == true or elapsed > 0.50 then return end
    if tps >= Orb.WALK_SPEED_MIN_TPS and tps <= Orb.WALK_SPEED_MAX_TPS then
        sample.observed = sample.observed and (sample.observed * 0.75 + tps * 0.25) or tps
    end
end

local function walkingSpeed(player)
    local sample = Orb.walkSamples[player]
    if sample and sample.observed then
        return math.max(Orb.WALK_SPEED_MIN_TPS, math.min(sample.observed, Orb.WALK_SPEED_MAX_TPS)),
            "OBSERVED_PLAYER_WORLD_WALK_DISPLACEMENT_TPS"
    end
    return Orb.WALK_SPEED_FALLBACK_TPS, "CONSERVATIVE_WALK_TPS_FALLBACK_NO_VALID_SAMPLE"
end

local function currentSquare(x, y, z)
    if type(getCell) ~= "function" then return nil end
    local cell = getCell()
    if not cell or type(cell.getGridSquare) ~= "function" then return nil end
    local ok, square = pcall(function() return cell:getGridSquare(math.floor(x), math.floor(y), math.floor(z)) end)
    return ok and square or nil
end

local function blockedBetween(x, y, z, nextX, nextY)
    local current = currentSquare(x, y, z)
    local target = currentSquare(nextX, nextY, z)
    if not current or not target then return true end
    if current == target then return false end
    if type(current.isBlockedTo) ~= "function" then return false end
    local ok, blocked = pcall(function() return current:isBlockedTo(target) end)
    return ok and blocked == true
end

local function clearTargetOutline(state)
    if not state or not state.outlineZombie then return end
    if state.outlineOwned then invoke(state.outlineZombie, "setOutlineHighlight", 0, false) end
    state.outlineZombie = nil
    state.outlineOwned = false
end

local function setTarget(state, zombie, source, now)
    if state.target == zombie then return end
    clearTargetOutline(state)
    state.target = zombie
    state.targetSource = source
    if not zombie then
        state.noTargetSinceMs = state.noTargetSinceMs or now
        return
    end
    state.noTargetSinceMs = nil
    if not state.options.targetOutline then return end
    local alreadyOk, already = invoke(zombie, "isOutlineHighlight", 0)
    if alreadyOk and already == true then
        state.outlineZombie = zombie
        state.outlineOwned = false
        return
    end
    local colorOk = invoke(zombie, "setOutlineHighlightCol", 0, 0.08, 1.0, 0.18, 1.0)
    local outlineOk = invoke(zombie, "setOutlineHighlight", 0, true)
    if colorOk and outlineOk then
        state.outlineZombie = zombie
        state.outlineOwned = true
    end
end

local function createDamageWeapon()
    if type(instanceItem) == "function" then
        local ok, weapon = pcall(instanceItem, Orb.DAMAGE_WEAPON)
        if ok and weapon and isType(weapon, "HandWeapon") then return weapon end
    end
    if InventoryItemFactory and type(InventoryItemFactory.CreateItem) == "function" then
        local ok, weapon = pcall(function() return InventoryItemFactory.CreateItem(Orb.DAMAGE_WEAPON) end)
        if ok and weapon and isType(weapon, "HandWeapon") then return weapon end
    end
    return nil
end

local function collectDamageTargets(state)
    local list = zombieList()
    if not list then return nil, "ZOMBIE_LIST_UNAVAILABLE" end
    local targets = {}
    local seen = setmetatable({}, { __mode = "k" })
    local ok, size = pcall(function() return list:size() end)
    size = ok and tonumber(size) or 0
    for index = 0, size - 1 do
        local itemOk, zombie = pcall(function() return list:get(index) end)
        if itemOk and validZombie(zombie) and not seen[zombie] then
            seen[zombie] = true
            local x = coordinate(zombie, "getX")
            local y = coordinate(zombie, "getY")
            local z = coordinate(zombie, "getZ")
            if x and y and z and math.abs(z - state.world_z) < 0.6 then
                local dx, dy = x - state.world_x, y - state.world_y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance <= state.options.explosionRadius then
                    targets[#targets + 1] = { zombie = zombie, distance = distance }
                end
            end
        end
    end
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    return targets, "ZOMBIE_ONLY_RADIUS_FILTER"
end

local function applyZombieOnlyDamage(state)
    local targets, reason = collectDamageTargets(state)
    if not targets then return false, 0, reason end
    if #targets == 0 then return true, 0, "NO_ZOMBIE_IN_RADIUS" end
    local weapon = createDamageWeapon()
    if not weapon then return false, 0, "DEDICATED_HANDWEAPON_CREATE_FAILED" end
    local hitCount = 0
    state.damageLedger = setmetatable({}, { __mode = "k" })
    for _, entry in ipairs(targets) do
        if not state.damageLedger[entry.zombie] then
            state.damageLedger[entry.zombie] = true
            local fraction = math.max(0, math.min(entry.distance / state.options.explosionRadius, 1.0))
            local damage = state.options.explosionDamage
            if state.options.falloff then damage = damage * (1.0 - 0.75 * fraction) end
            local hitOk = pcall(function()
                entry.zombie:Hit(weapon, state.player, damage, false, 1.0, false)
            end)
            if not hitOk then return false, hitCount, "ISO_ZOMBIE_HIT_FAILED_NO_HEALTH_FALLBACK" end
            hitCount = hitCount + 1
        end
    end
    return true, hitCount, "DEDICATED_HANDWEAPON_ISO_ZOMBIE_HIT"
end

local function logFailureOnce(state, reason)
    local key = tostring(state and state.id or "none") .. ":" .. tostring(reason)
    if Orb.failureLogged[key] then return end
    Orb.failureLogged[key] = true
    print("[XNP GREEN VIRTUAL FAIL] cast_id=" .. tostring(state and state.id or "none")
        .. " reason=" .. tostring(reason) .. " failure_log_once=true")
end

local function finallyCleanupCast(state, reason)
    if not state then return end
    clearTargetOutline(state)
    if Orb.active == state then Orb.active = nil end
    state.target = nil
    state.player = nil
    state.damageLedger = nil
    state.options = nil
    state.finished = true
    print("[XNP GREEN VIRTUAL CLEANUP] cast_id=" .. tostring(state.id)
        .. " reason=" .. tostring(reason)
        .. " virtual_state_removed=true target_outline_removed=true java_world_objects=0")
end

local function refundCooldown(state)
    if state and state.player then Orb.cooldownByPlayer[state.player] = 0 end
end

local function playOnce(state, route, key, enabled)
    if enabled ~= true or not Core.Audio or not Core.Audio.PlayOnce then return false, "DISABLED" end
    return Core.Audio.PlayOnce(state.player, route, key .. ":" .. tostring(state.id))
end

local function notifyIcon(kind)
    if Core.GreenSkillUI and Core.GreenSkillUI.NotifyVirtualCast then
        Core.GreenSkillUI.NotifyVirtualCast(kind)
    end
end

local function impactTransaction(state, reason)
    if not state or state.resolved then return end
    state.resolved = true
    local soundOk, soundMethod = playOnce(state, "GREEN_BOMB_SKILL", "green-virtual-impact", state.options.impactSound)
    local damageOk, damaged, damageMethod = applyZombieOnlyDamage(state)
    if not damageOk then
        refundCooldown(state)
        logFailureOnce(state, "DAMAGE_TRANSACTION_FAILED:" .. tostring(damageMethod))
        print("[XNP GREEN VIRTUAL TRANSACTION] damage=false partial_hits=" .. tostring(damaged)
            .. " cooldown_refunded=true java_world_objects=0")
        finallyCleanupCast(state, "DAMAGE_TRANSACTION_FAILED")
        return
    end
    notifyIcon("IMPACT")
    print("[XNP GREEN VIRTUAL TRANSACTION] order=PLAY_SOUND>APPLY_ZOMBIE_DAMAGE>CLEANUP_VIRTUAL_CAST"
        .. " cast_id=" .. tostring(state.id)
        .. " trigger=" .. tostring(reason)
        .. " sound_ok=" .. tostring(soundOk)
        .. " sound_method=" .. tostring(soundMethod)
        .. " damage_type=" .. Orb.DAMAGE_TYPE
        .. " zombies_damaged=" .. tostring(damaged)
        .. " damage_method=" .. tostring(damageMethod)
        .. " players_damaged=0 npc_humans_damaged=0 animals_damaged=0"
        .. " structures_damaged=0 vehicles_damaged=0 fires_started=0"
        .. " native_trap_damage=0 set_health_route=0 java_world_objects=0")
    finallyCleanupCast(state, reason)
end

function Orb.CanActivate(player)
    if not player then return false, "PLAYER_MISSING" end
    if tuningBoolean("EnableGreenTraitSystem", true) ~= true then return false, "GREEN_SYSTEM_DISABLED" end
    if tuningBoolean("GreenActiveSkillEnabled", true) ~= true then return false, "GREEN_ACTIVE_DISABLED" end
    if activeMode() == "OFF" then return false, "GREEN_ACTIVE_MODE_OFF" end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then return false, "GREEN_TRAIT_MISSING" end
    if not Core.GreenSkill or Core.GreenSkill.IsEnabled(player) ~= true then return false, "GREEN_MODE_WHITE" end
    if playerDead(player) then return false, "PLAYER_DEAD" end
    if type(isGamePaused) == "function" and isGamePaused() then return false, "GAME_PAUSED" end
    if Core.MeleeMode and Core.MeleeMode.IsMultiplayerProcess() then return false, "MULTIPLAYER_GREEN_ACTIVE_AUTHORITY_NOT_VERIFIED" end
    if Orb.active then return false, "GREEN_VIRTUAL_CAST_ALREADY_ACTIVE" end
    if nowMs() < (Orb.cooldownByPlayer[player] or 0) then return false, "GREEN_ACTIVE_COOLDOWN" end
    return true, "READY"
end

function Orb.RequestActivate(player, source)
    if Orb.active then
        finallyCleanupCast(Orb.active, "NEW_CAST_PREEMPT")
        return false, "GREEN_CAST_PREEMPTED_COOLDOWN_RETAINED"
    end
    local allowed, reason = Orb.CanActivate(player)
    if not allowed then return false, reason end
    local x = coordinate(player, "getX")
    local y = coordinate(player, "getY")
    local z = coordinate(player, "getZ")
    if not x or not y or not z then return false, "PLAYER_COORDINATE_UNAVAILABLE" end
    local options = settings()
    local target, targetSource = nil, "LOCAL_BLAST_NO_TARGET_REQUIRED"
    if options.mode == "VIRTUAL_TRACKING_BLAST" then
        target, targetSource = nearestTarget(x, y, z, options.targetRadius)
    end
    local directionX, directionY, directionSource
    if target then
        local tx = coordinate(target, "getX")
        local ty = coordinate(target, "getY")
        directionX, directionY = normalized((tx or x) - x, (ty or y) - y)
        directionSource = "INITIAL_TARGET"
    end
    if not directionX then directionX, directionY, directionSource = playerForward(player) end
    local baseSpeed, speedSource = walkingSpeed(player)
    local now = nowMs()
    Orb.serial = Orb.serial + 1
    local state = {
        id = Orb.serial,
        player = player,
        mode = options.mode,
        options = options,
        world_x = x,
        world_y = y,
        world_z = z,
        directionX = directionX,
        directionY = directionY,
        directionSource = directionSource,
        baseSpeed = baseSpeed * options.initialMultiplier,
        speed = baseSpeed * options.initialMultiplier,
        speedSource = speedSource,
        startedMs = now,
        lastUpdateMs = now,
        nextSearchMs = now,
        noTargetSinceMs = target and nil or now,
    }
    Orb.active = state
    setTarget(state, target, targetSource, now)
    Orb.cooldownByPlayer[player] = now + options.cooldownMs
    playOnce(state, "GREEN_PROJECTILE_CAST", "green-virtual-cast", options.castSound)
    notifyIcon("CAST")
    print("[XNP GREEN VIRTUAL] cast_accepted=true cast_id=" .. tostring(state.id)
        .. " mode=" .. tostring(options.mode)
        .. " projectile_visual=DISABLED_FOR_RENDER_SAFETY java_world_objects=0"
        .. " initial_target=" .. tostring(target ~= nil)
        .. " target_outline=" .. tostring(state.outlineZombie ~= nil)
        .. " base_speed_tps=" .. string.format("%.3f", state.baseSpeed)
        .. " speed_cap_tps=" .. string.format("%.2f", options.speedCap)
        .. " no_target_search_sec=" .. string.format("%.2f", options.noTargetMs / 1000)
        .. " cooldown_sec=" .. string.format("%.2f", options.cooldownMs / 1000)
        .. " source=" .. tostring(source or "GREEN_LEFT_DOUBLE_CLICK"))
    if options.mode == "LOCAL_BLAST" then impactTransaction(state, "TARGET_REACHED") end
    return true, state.id
end

local function acquireIfNeeded(state, now)
    if validZombie(state.target) then return true end
    if state.target then setTarget(state, nil, "TARGET_INVALID", now) end
    if now < state.nextSearchMs then return false end
    state.nextSearchMs = now + Orb.TARGET_SEARCH_INTERVAL_MS
    local target, source = nearestTarget(state.world_x, state.world_y, state.world_z, state.options.targetRadius)
    if target then
        setTarget(state, target, source, now)
        print("[XNP GREEN VIRTUAL] target_acquired=true cast_id=" .. tostring(state.id)
            .. " age_seconds=" .. string.format("%.2f", (now - state.startedMs) / 1000)
            .. " source=" .. tostring(source))
        return true
    end
    state.noTargetSinceMs = state.noTargetSinceMs or now
    return false
end

local function stagedSpeed(state, ageSeconds)
    if ageSeconds <= state.options.accelerationStart then return state.baseSpeed, "LOW_SPEED_STAGE" end
    local elapsed = ageSeconds - state.options.accelerationStart
    local accelerated = state.baseSpeed * math.pow(state.options.accelerationPerSecond, elapsed)
    if accelerated >= state.options.speedCap then return state.options.speedCap, "ACCELERATED_CAP" end
    return accelerated, "ACCELERATED_PER_SECOND"
end

local function cancelNoTarget(state)
    if state.options.refundNoTarget then refundCooldown(state) end
    local cancelSound, cancelMethod = playOnce(state, "MARKER_TOGGLE", "green-virtual-cancel",
        tuningBoolean("EnableSounds", true))
    notifyIcon("CANCEL")
    print("[XNP GREEN VIRTUAL] cancelled=true reason=NO_TARGET damage=false cooldown_refunded="
        .. tostring(state.options.refundNoTarget)
        .. " cancel_sound=" .. tostring(cancelSound)
        .. " cancel_method=" .. tostring(cancelMethod)
        .. " java_world_objects=0")
    finallyCleanupCast(state, "NO_TARGET")
end

local function updateFlight(state, now)
    acquireIfNeeded(state, now)
    if not state.target and state.noTargetSinceMs and now - state.noTargetSinceMs >= state.options.noTargetMs then
        cancelNoTarget(state)
        return
    end
    if not state.target then return end

    local tx = coordinate(state.target, "getX")
    local ty = coordinate(state.target, "getY")
    if not tx or not ty then
        setTarget(state, nil, "TARGET_COORDINATE_INVALID", now)
        return
    end
    local desiredX, desiredY, distance = normalized(tx - state.world_x, ty - state.world_y)
    if distance <= state.options.impactDistance then
        impactTransaction(state, "TARGET_REACHED")
        return
    end

    local delta = math.max(0, math.min((now - state.lastUpdateMs) / 1000, 0.10))
    state.lastUpdateMs = now
    if desiredX then
        local currentAngle = math.atan2(state.directionY, state.directionX)
        local desiredAngle = math.atan2(desiredY, desiredX)
        local turn = angleDelta(currentAngle, desiredAngle)
        local maxTurn = math.pi * 3.0 * delta
        turn = math.max(-maxTurn, math.min(turn, maxTurn))
        currentAngle = currentAngle + turn
        state.directionX, state.directionY = math.cos(currentAngle), math.sin(currentAngle)
    end

    local ageSeconds = (now - state.startedMs) / 1000
    state.speed, state.speedStage = stagedSpeed(state, ageSeconds)
    local step = state.speed * delta
    local nextX = state.world_x + state.directionX * step
    local nextY = state.world_y + state.directionY * step
    if blockedBetween(state.world_x, state.world_y, state.world_z, nextX, nextY) then
        impactTransaction(state, "WALL_COLLISION")
        return
    end
    state.world_x, state.world_y = nextX, nextY
    if now - state.startedMs >= state.options.maximumFlightMs then
        impactTransaction(state, "TIMEOUT")
    end
end

local function updateProtected(player)
    local now = nowMs()
    sampleWalkingSpeed(player, now)
    local state = Orb.active
    if not state then return false end
    if state.player ~= player then finallyCleanupCast(state, "PLAYER_REPLACED"); return false end
    if playerDead(player) then finallyCleanupCast(state, "PLAYER_DEATH"); return false end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then
        finallyCleanupCast(state, "PLAYER_TRAIT_INVALID")
        return false
    end
    if type(isGamePaused) == "function" and isGamePaused() then
        finallyCleanupCast(state, "WORLD_EXIT")
        return false
    end
    updateFlight(state, now)
    return true
end

function Orb.Update(player)
    local ok, result = pcall(updateProtected, player)
    if not ok then
        local state = Orb.active
        if state then
            logFailureOnce(state, "EXCEPTION_GUARD:" .. tostring(result))
            finallyCleanupCast(state, "EXCEPTION_GUARD")
        end
        return false
    end
    return result
end

function Orb.InitializePlayer(player, source)
    if Orb.active and Orb.active.player ~= player then finallyCleanupCast(Orb.active, "PLAYER_REPLACED") end
    print("[XNP GREEN VIRTUAL] initialize=true source=" .. tostring(source or "PLAYER_LOAD")
        .. " stale_java_entity_cleanup_required=false")
    return true
end

function Orb.SetMapHidden(hidden)
    Orb.mapHidden = hidden == true
end

function Orb.Cleanup(player, reason)
    if Orb.active then finallyCleanupCast(Orb.active, reason or "WORLD_EXIT") end
end

function Orb.Shutdown(reason)
    local rawReason = tostring(reason or "WORLD_EXIT")
    local cleanupReason = SHUTDOWN_REASON[string.lower(rawReason)] or string.upper(rawReason)
    if Orb.active then finallyCleanupCast(Orb.active, cleanupReason) end
    Orb.cooldownByPlayer = setmetatable({}, { __mode = "k" })
    Orb.walkSamples = setmetatable({}, { __mode = "k" })
    Orb.failureLogged = {}
end

Core.GreenWorldOrb = Orb
if not Core.green_virtual_056068_startup_logged then
    Core.green_virtual_056068_startup_logged = true
    print("[XNP GREEN VIRTUAL] mode=VIRTUAL_TRACKING_BLAST projectile_visual=DISABLED_FOR_RENDER_SAFETY"
        .. " java_world_entity_count=0 custom_world_render=0 world_ispanel_render=0")
end
return Orb
