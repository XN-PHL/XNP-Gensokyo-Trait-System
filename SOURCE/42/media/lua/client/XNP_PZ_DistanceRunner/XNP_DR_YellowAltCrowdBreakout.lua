require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery"
require "XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerClassifier"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"

local Core = XNP_PZ_DistanceRunner

local Breakout = {
    lastRunKeyDown = false,
    cooldownUntilMs = 0,
    triggerSerial = 0,
    activationCount = 0,
    holdRepeatCount = 0,
    noDangerActivationCount = 0,
    damageWriteCount = 0,
    healthRestoreCount = 0,
    biteRewindCount = 0,
    nonZombieTargetCount = 0,
    worldScanDuplicationCount = 0,
    lastResult = "NOT_TRIGGERED",
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function number(name, fallback, minimum, maximum)
    local tuning = Core.SandboxTuning
    if tuning and type(tuning.GetNumber) == "function" then
        return tuning.GetNumber(name, fallback, minimum, maximum)
    end
    return fallback
end

local function boolean(name, fallback)
    local tuning = Core.SandboxTuning
    if tuning and type(tuning.GetBoolean) == "function" then
        return tuning.GetBoolean(name, fallback)
    end
    return fallback
end

local function readRunKey()
    if type(getCore) ~= "function" then return false, "CORE_UNAVAILABLE" end
    local coreOk, core = pcall(getCore)
    if not coreOk or not core or type(core.getKey) ~= "function" then
        return false, "RUN_BINDING_UNAVAILABLE"
    end
    local keyOk, keyCode = pcall(function() return core:getKey("Run") end)
    if not keyOk or tonumber(keyCode) == nil then
        return false, "RUN_BINDING_UNAVAILABLE"
    end
    if type(isKeyDown) == "function" then
        local ok, down = pcall(isKeyDown, keyCode)
        if ok then return down == true, "GLOBAL_IS_KEY_DOWN" end
    end
    if Keyboard and type(Keyboard.isKeyDown) == "function" then
        local ok, down = pcall(Keyboard.isKeyDown, keyCode)
        if ok then return down == true, "KEYBOARD_IS_KEY_DOWN" end
    end
    return false, "KEY_STATE_UNAVAILABLE"
end

local function inputBlocked()
    if type(isGamePaused) == "function" then
        local ok, value = pcall(isGamePaused)
        if ok and value == true then return true, "PAUSED" end
    end
    if MainScreen and MainScreen.instance
        and MainScreen.instance.visible == true then
        return true, "MAIN_MENU"
    end
    if ISChat and ISChat.instance then
        local chat = ISChat.instance
        if chat.visible == true then return true, "CHAT_VISIBLE" end
        local entry = chat.textEntry
        if entry and type(entry.isFocused) == "function" then
            local ok, focused = pcall(function() return entry:isFocused() end)
            if ok and focused == true then return true, "CHAT_FOCUSED" end
        end
    end
    if UIManager and type(UIManager.getModal) == "function" then
        local ok, modal = pcall(UIManager.getModal)
        if ok and modal then return true, "MODAL_UI" end
    end
    return false, "CLEAR"
end

local function playerUnavailable(player)
    if not player then return true, "NO_PLAYER" end
    local checks = {
        { "isDead", "PLAYER_DEAD" },
        { "isOnFloor", "PLAYER_ON_FLOOR" },
        { "isKnockedDown", "PLAYER_KNOCKED_DOWN" },
        { "isDriving", "PLAYER_DRIVING" },
    }
    for index = 1, #checks do
        local ok, value = invoke(player, checks[index][1])
        if ok and value == true then return true, checks[index][2] end
    end
    return false, "READY"
end

local function isLiveZombie(object)
    if not object then return false end
    local zombie = false
    if type(instanceof) == "function" then
        local ok, value = pcall(instanceof, object, "IsoZombie")
        zombie = ok and value == true
    elseif type(object.isZombie) == "function" then
        local ok, value = invoke(object, "isZombie")
        zombie = ok and value == true
    end
    if not zombie then return false end
    local deadOk, dead = invoke(object, "isDead")
    local fakeOk, fake = invoke(object, "isFakeDead")
    return not (deadOk and dead == true) and not (fakeOk and fake == true)
end

local function collectTargets(player, radius)
    local entries = Core.CentralWorldQuery
        and Core.CentralWorldQuery.GetThreatCandidates
        and Core.CentralWorldQuery.GetThreatCandidates() or {}
    local radiusSq = radius * radius
    local result = {}
    for index = 1, #entries do
        local entry = entries[index]
        local zombie = entry and entry.zombie or nil
        local distanceSq = tonumber(entry and entry.distSq)
        if isLiveZombie(zombie) and distanceSq
            and distanceSq <= radiusSq then
            local sameZ = true
            local pzOk, pz = invoke(player, "getZ")
            local zzOk, zz = invoke(zombie, "getZ")
            if pzOk and zzOk then
                sameZ = math.abs((tonumber(pz) or 0)
                    - (tonumber(zz) or 0)) <= 0.50
            end
            if sameZ then result[#result + 1] = entry end
        end
    end
    table.sort(result, function(a, b)
        return (a.distSq or math.huge) < (b.distSq or math.huge)
    end)
    return result
end

local function strongControl(danger)
    if type(danger) ~= "table" then return false end
    local context = danger.context or {}
    if context.grabbed == true or context.onFloor == true
        or context.knocked == true or context.getup == true then
        return true
    end
    return danger.level == "TRUE_EMERGENCY"
        and (danger.attacking or 0) > 0
end

local function endurance(player)
    local statsOk, stats = invoke(player, "getStats")
    if not statsOk or not stats or not CharacterStat
        or not CharacterStat.ENDURANCE then return nil, nil end
    local readOk, value = invoke(stats, "get", CharacterStat.ENDURANCE)
    if not readOk or tonumber(value) == nil then return nil, nil end
    return stats, math.max(0, math.min(1, tonumber(value)))
end

local function chargeEndurance(player, cost)
    local stats, before = endurance(player)
    if not stats then return false, nil, nil end
    if Core.Authority and Core.Authority.CanWriteNonFoodStats
        and Core.Authority.CanWriteNonFoodStats(
            player, "YELLOW_ALT_CROWD_BREAKOUT") ~= true then
        return false, before, before
    end
    local after = math.max(0, before - cost)
    local ok = invoke(stats, "set", CharacterStat.ENDURANCE, after) == true
    return ok, before, after
end

local function squarePassable(x, y, z)
    if type(getCell) ~= "function" then return false end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell or type(cell.getGridSquare) ~= "function" then
        return false
    end
    local squareX = math.floor((tonumber(x) or 0) + 0.5)
    local squareY = math.floor((tonumber(y) or 0) + 0.5)
    local squareZ = math.floor((tonumber(z) or 0) + 0.5)
    local squareOk, square = pcall(function()
        return cell:getGridSquare(squareX, squareY, squareZ)
    end)
    if not squareOk or not square then return false end
    local solidOk, solid = invoke(square, "isSolid")
    if solidOk and solid == true then return false end
    return true
end

local function microNudge(player, entry, strength)
    local zombie = entry.zombie
    local pxOk, px = invoke(player, "getX")
    local pyOk, py = invoke(player, "getY")
    local zxOk, zx = invoke(zombie, "getX")
    local zyOk, zy = invoke(zombie, "getY")
    local zzOk, zz = invoke(zombie, "getZ")
    if not pxOk or not pyOk or not zxOk or not zyOk or not zzOk then
        return false, "POSITION_UNAVAILABLE"
    end
    local dx = (tonumber(zx) or 0) - (tonumber(px) or 0)
    local dy = (tonumber(zy) or 0) - (tonumber(py) or 0)
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.001 then return false, "DIRECTION_UNAVAILABLE" end
    local targetX = zx + (dx / length) * strength
    local targetY = zy + (dy / length) * strength
    if not squarePassable(targetX, targetY, zz) then
        return false, "TARGET_SQUARE_BLOCKED"
    end
    local xOk = invoke(zombie, "setX", targetX) == true
    local yOk = invoke(zombie, "setY", targetY) == true
    return xOk and yOk, xOk and yOk and "MICRO_NUDGE" or "NUDGE_WRITE_FAILED"
end

local function notify(player, key, fallback)
    if boolean("YellowAltCrowdBreakoutNotification", false) ~= true then
        return
    end
    local text = fallback
    if type(getText) == "function" then
        local ok, value = pcall(getText, key)
        if ok and value and value ~= key then text = tostring(value) end
    end
    if player and type(player.setHaloNote) == "function" then
        pcall(function() player:setHaloNote(text, 255, 225, 80, 240) end)
    end
end

function Breakout.Update(player)
    local down, inputRoute = readRunKey()
    local pressed = down and not Breakout.lastRunKeyDown
    Breakout.lastRunKeyDown = down
    if not pressed then return false, "NO_INPUT_EDGE" end
    if boolean("YellowAltCrowdBreakoutEnabled", false) ~= true then
        return false, "DISABLED"
    end
    if not Core.Trait or Core.Trait.PlayerHasTrait(player) ~= true then
        return false, "YELLOW_TRAIT_REQUIRED"
    end
    local blocked, blockedReason = inputBlocked()
    if blocked then return false, blockedReason end
    local unavailable, unavailableReason = playerUnavailable(player)
    if unavailable then return false, unavailableReason end

    local current = nowMs()
    if current < Breakout.cooldownUntilMs then
        Breakout.lastResult = "COOLDOWN"
        return false, "COOLDOWN"
    end

    local radius = number(
        "YellowAltCrowdBreakoutRadiusTiles", 1.75, 0.50, 4.00)
    local minimum = math.floor(number(
        "YellowAltCrowdBreakoutMinimumNearbyZombies", 3, 1, 12) + 0.5)
    local targets = collectTargets(player, radius)
    local danger = Core.DragdownDangerClassifier
        and Core.DragdownDangerClassifier.GetState
        and Core.DragdownDangerClassifier.GetState() or nil
    local controlled = boolean(
        "YellowAltCrowdBreakoutStrongControlOverride", false)
        and strongControl(danger)
    local dangerLevel = danger and tostring(danger.level) or "SAFE"
    local ordinarySurround = #targets >= minimum
        and dangerLevel ~= "SAFE"
    if not ordinarySurround and not (controlled and #targets >= 1) then
        Breakout.lastResult = "NO_DANGER"
        return false, "NO_DANGER"
    end

    local level = controlled and "TRUE_EMERGENCY" or "ASSIST"
    local canStart, busReason = true, "NO_BUS"
    if Core.BreakoutActionBus and Core.BreakoutActionBus.CanStart then
        canStart, busReason = Core.BreakoutActionBus.CanStart(
            "ALT_CROWD", level, targets, "STAGGER")
    end
    if not canStart then return false, busReason end

    local cost = number(
        "YellowAltCrowdBreakoutEnduranceCost", 0.12, 0, 1)
    local charged, before, after = chargeEndurance(player, cost)
    if not charged then return false, "ENDURANCE_WRITE_REJECTED" end
    local lowMultiplier = number(
        "YellowAltCrowdBreakoutLowEnduranceMultiplier", 0.60, 0.10, 1.00)
    local power = before < 0.25 and lowMultiplier or 1.0

    Breakout.triggerSerial = Breakout.triggerSerial + 1
    local actionId = Breakout.triggerSerial
    if Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
        actionId = Core.BreakoutActionBus.Accept(
            "ALT_CROWD", level, targets, "STAGGER")
    end

    local visibleCount = 0
    local nudgeCount = 0
    local effectType = controlled and "GRAB_PREBITE" or "CROWD"
    for index = 1, #targets do
        local entry = targets[index]
        local visible = false
        if Core.VerifiedStaggerControl
            and Core.VerifiedStaggerControl.Apply then
            visible = Core.VerifiedStaggerControl.Apply(
                player, entry.zombie, effectType, {
                    triggerId = actionId,
                    source = "YELLOW_ALT_CROWD_BREAKOUT",
                }) == true
        end
        local nudged = microNudge(player, entry, 0.22 * power) == true
        if visible then visibleCount = visibleCount + 1 end
        if nudged then nudgeCount = nudgeCount + 1 end
    end

    local cooldown = number(
        "YellowAltCrowdBreakoutCooldownSeconds", 8, 0.5, 60)
    Breakout.cooldownUntilMs = current + cooldown * 1000
    Breakout.activationCount = Breakout.activationCount + 1
    Breakout.lastResult = "TRIGGERED"
    print("[XNP YELLOW ALT BREAKOUT] trigger=true"
        .. " action_id=" .. tostring(actionId)
        .. " input_route=" .. tostring(inputRoute)
        .. " strong_control=" .. tostring(controlled)
        .. " danger_level=" .. tostring(dangerLevel)
        .. " selected_zombies=" .. tostring(#targets)
        .. " visible_reactions=" .. tostring(visibleCount)
        .. " micro_nudges=" .. tostring(nudgeCount)
        .. " endurance_before=" .. tostring(before)
        .. " endurance_after=" .. tostring(after)
        .. " endurance_cost=" .. tostring(cost)
        .. " power_multiplier=" .. tostring(power)
        .. " cooldown_seconds=" .. tostring(cooldown)
        .. " damage_writes=0 health_restores=0 bite_rewinds=0"
        .. " non_zombie_targets=0 world_scan_owner=CENTRAL_WORLD_QUERY"
        .. " strong_control_break_status=PARTIAL")
    notify(player, "UI_XNPYellowAltBreakout",
        "Emergency breakout: nearby zombies pushed back.")
    return true, "TRIGGERED"
end

function Breakout.Cleanup()
    Breakout.lastRunKeyDown = false
    Breakout.cooldownUntilMs = 0
end

function Breakout.GetAuditSnapshot()
    return {
        reachable = true,
        activation_count = Breakout.activationCount,
        hold_repeat_count = Breakout.holdRepeatCount,
        no_danger_activation_count = Breakout.noDangerActivationCount,
        damage_write_count = Breakout.damageWriteCount,
        health_restore_count = Breakout.healthRestoreCount,
        bite_rewind_count = Breakout.biteRewindCount,
        non_zombie_target_count = Breakout.nonZombieTargetCount,
        world_scan_duplication_count = Breakout.worldScanDuplicationCount,
        input_binding = "Run",
        input_edge_triggered = true,
        strong_control_break_status = "PARTIAL",
        default_knockdown_chance = 0,
        last_result = Breakout.lastResult,
    }
end

Core.YellowAltCrowdBreakout = Breakout
return Breakout
