require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local EmergencyInput = {
    configLogged = false,
    lastDown = false,
    lastPressTime = -999,
    lastState = nil,
    stateEnterTime = 0,
    stateEnterHeld = false,
    frameCount = 0,
    noInput = 0,
    heldAccept = 0,
    recentAccept = 0,
    edgeAccept = 0,
    stateEnterAccept = 0,
    autoDangerAccept = 0,
    lastAcceptedLogKey = nil,
}

XNP_DR_EmergencyInput = EmergencyInput

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function safeBool(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        return ok and value == true
    end
    return false
end

local function safeString(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        if ok and value ~= nil then
            return string.lower(tostring(value))
        end
    end
    return ""
end

local function keyboardDown()
    local checked = false
    local down = false
    if Keyboard and type(Keyboard.isKeyDown) == "function" then
        local keys = {
            "KEY_LSHIFT", "KEY_RSHIFT", "KEY_LCONTROL", "KEY_RCONTROL",
            "KEY_SPACE", "KEY_LMENU", "KEY_RMENU",
        }
        for _, name in ipairs(keys) do
            local code = Keyboard[name]
            if code ~= nil then
                checked = true
                local ok, value = pcall(function()
                    return Keyboard.isKeyDown(code)
                end)
                down = down or (ok and value == true)
            end
        end
    end
    return checked, down
end

local function movementIntent(player)
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    local running = safeBool(player, "isRunning")
    local sprinting = safeBool(player, "isSprinting")
    local intent = running or sprinting or string.find(text, "run", 1, true) ~= nil or string.find(text, "sprint", 1, true) ~= nil
    return intent, text, running, sprinting
end

local function logConfigOnce()
    if EmergencyInput.configLogged then
        return
    end
    EmergencyInput.configLogged = true
    Core.LogThrottle.Blocked("EMERGENCY_INPUT", "HELD_STATE_STATUS")
end

local function dangerAutoAllowed(dangerInfo)
    if Config.EMERGENCY_INPUT_ALLOW_AUTO_DRAGDOWN ~= true or not dangerInfo then
        return false
    end
    local classified = Core.DragdownDangerClassifier and Core.DragdownDangerClassifier.GetState and Core.DragdownDangerClassifier.GetState() or nil
    if classified and classified.level == "TRUE_EMERGENCY" then
        return true
    end
    return dangerInfo.level == "FATAL_SURROUNDED"
end

function EmergencyInput.Update(player)
    logConfigOnce()
    local currentTime = nowSeconds()
    local checked, keyDown = keyboardDown()
    local intent, text, running, sprinting = movementIntent(player)
    local down = (checked and keyDown) or intent
    local edge = down and not EmergencyInput.lastDown
    if edge then
        EmergencyInput.lastPressTime = currentTime
    end
    EmergencyInput.lastDown = down
    local state = "NORMAL"
    if safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown") then
        state = "ON_FLOOR"
    elseif string.find(text, "getup", 1, true) or string.find(text, "recover", 1, true) then
        state = "GETUP"
    elseif string.find(text, "grab", 1, true) or string.find(text, "attack", 1, true) or string.find(text, "fall", 1, true) or string.find(text, "trip", 1, true) then
        state = "CONTROLLED"
    end
    if state ~= EmergencyInput.lastState then
        EmergencyInput.lastState = state
        EmergencyInput.stateEnterTime = currentTime
        EmergencyInput.stateEnterHeld = down
    end
    return {
        down = down,
        edge = edge,
        checked = checked,
        method = checked and "KEYBOARD_DIRECT_OR_HELD" or "PLAYER_STATE_FALLBACK",
        movement = text,
        running = running,
        sprinting = sprinting,
        state = state,
        stateEnterHeld = EmergencyInput.stateEnterHeld,
        recentPress = currentTime - EmergencyInput.lastPressTime <= Config.EMERGENCY_INPUT_RECENT_PRESS_WINDOW,
    }
end

function EmergencyInput.Evaluate(player, state, dangerInfo)
    local info = EmergencyInput.Update(player)
    local accepted = false
    local reason = "NO_INPUT"
    if dangerAutoAllowed(dangerInfo) then
        accepted = true
        reason = "AUTO_DRAGDOWN"
        EmergencyInput.autoDangerAccept = EmergencyInput.autoDangerAccept + 1
    elseif Config.EMERGENCY_INPUT_EDGE_REQUIRED ~= true and info.edge then
        accepted = true
        reason = "EDGE"
        EmergencyInput.edgeAccept = EmergencyInput.edgeAccept + 1
    elseif Config.EMERGENCY_INPUT_ALLOW_HELD and info.down and (state ~= "CHECK_NEARBY" or info.state ~= "NORMAL") then
        accepted = true
        reason = "HELD"
        EmergencyInput.heldAccept = EmergencyInput.heldAccept + 1
    elseif Config.EMERGENCY_INPUT_ALLOW_RECENT_PRESS and info.recentPress and state ~= "CHECK_NEARBY" then
        accepted = true
        reason = "RECENT_PRESS"
        EmergencyInput.recentAccept = EmergencyInput.recentAccept + 1
    elseif Config.EMERGENCY_INPUT_ALLOW_STATE_ENTER_HELD and info.stateEnterHeld and state ~= "CHECK_NEARBY" then
        accepted = true
        reason = "STATE_ENTER_HELD"
        EmergencyInput.stateEnterAccept = EmergencyInput.stateEnterAccept + 1
    else
        EmergencyInput.noInput = EmergencyInput.noInput + 1
    end

    EmergencyInput.frameCount = EmergencyInput.frameCount + 1
    if Config.DEBUG_EMERGENCY_INPUT_SUMMARY and EmergencyInput.frameCount >= 60 then
            print("[XNP EMERGENCY INPUT SUMMARY] no_input=" .. tostring(EmergencyInput.noInput) .. " held_accept=" .. tostring(EmergencyInput.heldAccept) .. " recent_accept=" .. tostring(EmergencyInput.recentAccept) .. " edge_accept=" .. tostring(EmergencyInput.edgeAccept) .. " auto_danger=" .. tostring(EmergencyInput.autoDangerAccept) .. " window=sampled")
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYINPUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        EmergencyInput.frameCount = 0
        EmergencyInput.noInput = 0
        EmergencyInput.heldAccept = 0
        EmergencyInput.recentAccept = 0
        EmergencyInput.edgeAccept = 0
        EmergencyInput.stateEnterAccept = 0
        EmergencyInput.autoDangerAccept = 0
    end

    if accepted then
        local acceptedKey = tostring(reason) .. "|" .. tostring(state) .. "|" .. tostring(info.movement)
        if acceptedKey ~= EmergencyInput.lastAcceptedLogKey then
            EmergencyInput.lastAcceptedLogKey = acceptedKey
        print("[XNP EMERGENCY INPUT] accepted reason=" .. tostring(reason) .. " down=" .. tostring(info.down) .. " edge=" .. tostring(info.edge) .. " state=" .. tostring(state) .. " movement=" .. tostring(info.movement))
        end
    else
        EmergencyInput.lastAcceptedLogKey = nil
    end
    return accepted, reason, info
end

Core.EmergencyInput = EmergencyInput
return EmergencyInput
