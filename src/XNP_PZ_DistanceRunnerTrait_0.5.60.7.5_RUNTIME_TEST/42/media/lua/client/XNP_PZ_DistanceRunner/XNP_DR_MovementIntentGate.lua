require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local MovementIntentGate = {
    configLogged = false,
    summaryFrame = 0,
    walkBlocked = 0,
    jogAllowed = 0,
    sprintAllowed = 0,
    escapeAllowed = 0,
    escapeBlocked = 0,
    lastImmediateKey = nil,
}

XNP_DR_MovementIntentGate = MovementIntentGate

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

local function movementText(player)
    return safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
end

local function inputInfo(player)
    if Core.EmergencyInput and Core.EmergencyInput.Update then
        local ok, info = pcall(function()
            return Core.EmergencyInput.Update(player)
        end)
        if ok and info then
            return info
        end
    end
    local text = movementText(player)
    local running = safeBool(player, "isRunning")
    local sprinting = safeBool(player, "isSprinting")
    local down = running or sprinting or string.find(text, "run", 1, true) ~= nil or string.find(text, "sprint", 1, true) ~= nil or string.find(text, "jog", 1, true) ~= nil
    return {
        down = down,
        recentPress = down,
        running = running,
        sprinting = sprinting,
        movement = text,
        state = "UNKNOWN",
    }
end

local function controlledText(text)
    return string.find(text, "grab", 1, true) ~= nil
        or string.find(text, "attack", 1, true) ~= nil
        or string.find(text, "bite", 1, true) ~= nil
        or string.find(text, "bumped", 1, true) ~= nil
        or string.find(text, "fall", 1, true) ~= nil
        or string.find(text, "trip", 1, true) ~= nil
        or string.find(text, "getup", 1, true) ~= nil
        or string.find(text, "recover", 1, true) ~= nil
end

local function classifiedControlled()
    local danger = Core.DragdownDangerClassifier and Core.DragdownDangerClassifier.GetState and Core.DragdownDangerClassifier.GetState() or nil
    if danger and (danger.level == "TRUE_EMERGENCY" or danger.level == "FATAL_SURROUNDED" or danger.level == "DRAGDOWN_DANGER") then
        return true, danger.level
    end
    local drag = Core.DragdownDangerBreakout and Core.DragdownDangerBreakout.GetState and Core.DragdownDangerBreakout.GetState() or nil
    if drag and (drag.level == "DRAGDOWN_DANGER" or drag.level == "FATAL_SURROUNDED" or drag.level == "TRUE_EMERGENCY") then
        return true, drag.level
    end
    return false, "NO_CONTROL_CLASSIFIER"
end

function MovementIntentGate.LogConfigOnce()
    if MovementIntentGate.configLogged then
        return
    end
    MovementIntentGate.configLogged = true
    print("[XNP MOVEMENT GATE] enabled=" .. tostring(Config.MOVEMENT_INTENT_GATE_ENABLED == true or Config.movement_intent_gate_enabled == true))
    print("[XNP WALK NO IMPACT] enabled=" .. tostring(Config.WALK_NO_IMPACT_ENABLED == true or Config.walk_no_impact_enabled == true))
    print("[XNP CONTROLLED ESCAPE] enabled=" .. tostring(Config.CONTROLLED_ESCAPE_ENABLED == true or Config.controlled_escape_enabled == true) .. " input=RUN_OR_SPRINT")
end

function MovementIntentGate.GetIntent(player, context)
    MovementIntentGate.LogConfigOnce()
    local info = inputInfo(player)
    local text = info.movement or movementText(player)
    local sprinting = info.sprinting == true or safeBool(player, "isSprinting")
    local running = info.running == true or safeBool(player, "isRunning")
    local hasJogText = string.find(text, "run", 1, true) ~= nil or string.find(text, "jog", 1, true) ~= nil
    local hasSprintText = string.find(text, "sprint", 1, true) ~= nil
    local onFloor = safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown")
    local textControlled = controlledText(text)
    local classifierControlled, classifierReason = classifiedControlled()
    local contextControlled = context and context.controlled == true
    local controlled = onFloor or textControlled or classifierControlled or contextControlled or info.state == "CONTROLLED" or info.state == "ON_FLOOR" or info.state == "GETUP"
    local inputDown = info.down == true or info.recentPress == true

    if (Config.CONTROLLED_ESCAPE_ENABLED == true or Config.controlled_escape_enabled == true) and controlled and inputDown then
        return {
            intent = "CONTROLLED_ESCAPE_INTENT",
            movement = text,
            input = "RUN_OR_SPRINT",
            controlled = true,
            controlReason = context and context.reason or classifierReason,
            speed = context and context.speed or nil,
        }
    end
    if sprinting or hasSprintText then
        return { intent = "SPRINT_INTENT", movement = text, input = "SPRINT", controlled = controlled, speed = context and context.speed or nil }
    end
    if running or hasJogText then
        return { intent = "JOG_INTENT", movement = text, input = "RUN_OR_SPRINT", controlled = controlled, speed = context and context.speed or nil }
    end
    return { intent = "WALK_IDLE_OR_MOVEMENT", movement = text, input = "NONE", controlled = controlled, speed = context and context.speed or nil }
end

local function block(source, reason, info)
    MovementIntentGate.walkBlocked = MovementIntentGate.walkBlocked + 1
    if Core.LogThrottle then
        Core.LogThrottle.Blocked("MOVEMENT_GATE", tostring(source) .. "_" .. tostring(reason))
    elseif Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
        local key = tostring(source) .. "|" .. tostring(reason) .. "|" .. tostring(info.intent)
        if Config.MOVEMENT_GATE_LOG_ON_STATE_CHANGE_ONLY ~= true or key ~= MovementIntentGate.lastImmediateKey then
            MovementIntentGate.lastImmediateKey = key
            print("[XNP MOVEMENT GATE] intent=" .. tostring(info.intent) .. " movement=" .. tostring(info.movement) .. " speed=" .. tostring(info.speed or "NA") .. " result=BLOCK_ACTIVE_IMPACT")
            print("[XNP MOVEMENT GATE] block source=" .. tostring(source) .. " reason=" .. tostring(reason))
        end
    end
    return false, reason, info
end

function MovementIntentGate.CanJogBump(player, context)
    local info = MovementIntentGate.GetIntent(player, context)
    if Config.WALK_BLOCKS_JOG_BUMP ~= false and info.intent == "WALK_IDLE_OR_MOVEMENT" then
        return block("JOG_BUMP", "WALKING_NOT_JOGGING", info)
    end
    if info.intent == "JOG_INTENT" then
        MovementIntentGate.jogAllowed = MovementIntentGate.jogAllowed + 1
        if Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            print("[XNP MOVEMENT GATE] intent=JOG_INTENT result=ALLOW_JOG_BUMP")
        end
        return true, "ALLOW_JOG_BUMP", info
    end
    if info.intent == "CONTROLLED_ESCAPE_INTENT" then
        if Core.LogThrottle then
            Core.LogThrottle.Blocked("MOVEMENT_GATE", "CONTROLLED_ESCAPE_ROUTE_REQUIRED_JOG_BUMP")
        elseif Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            print("[XNP MOVEMENT GATE] block source=JOG_BUMP reason=CONTROLLED_ESCAPE_ROUTE_REQUIRED")
        end
        return false, "CONTROLLED_ESCAPE_ROUTE_REQUIRED", info
    end
    return false, "NOT_JOG_INTENT", info
end

function MovementIntentGate.CanContactPush(player, context)
    local info = MovementIntentGate.GetIntent(player, context)
    if Config.WALK_BLOCKS_CONTACT ~= false and info.intent == "WALK_IDLE_OR_MOVEMENT" then
        return block("CONTACT", "WALKING_NOT_JOGGING", info)
    end
    if info.intent == "JOG_INTENT" then
        MovementIntentGate.jogAllowed = MovementIntentGate.jogAllowed + 1
        if Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            print("[XNP MOVEMENT GATE] intent=JOG_INTENT result=ALLOW_CONTACT")
        end
        return true, "ALLOW_CONTACT", info
    end
    if info.intent == "CONTROLLED_ESCAPE_INTENT" then
        if Core.LogThrottle then
            Core.LogThrottle.Blocked("MOVEMENT_GATE", "CONTROLLED_ESCAPE_ROUTE_REQUIRED_CONTACT")
        elseif Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            print("[XNP MOVEMENT GATE] block source=CONTACT reason=CONTROLLED_ESCAPE_ROUTE_REQUIRED")
        end
        return false, "CONTROLLED_ESCAPE_ROUTE_REQUIRED", info
    end
    return false, "NOT_CONTACT_INTENT", info
end

function MovementIntentGate.CanSprintVehicle(player, context)
    local info = MovementIntentGate.GetIntent(player, context)
    if Config.WALK_BLOCKS_VEHICLE_IMPACT ~= false and info.intent == "WALK_IDLE_OR_MOVEMENT" then
        return block("SPRINT_VEHICLE", "WALKING_NOT_SPRINTING", info)
    end
    if info.intent == "SPRINT_INTENT" then
        MovementIntentGate.sprintAllowed = MovementIntentGate.sprintAllowed + 1
        if Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            print("[XNP MOVEMENT GATE] intent=SPRINT_INTENT result=ALLOW_SPRINT_VEHICLE")
        end
        return true, "ALLOW_SPRINT_VEHICLE", info
    end
    return false, "NOT_SPRINT_INTENT", info
end

function MovementIntentGate.CanControlledEscape(player, context)
    local info = MovementIntentGate.GetIntent(player, context)
    if info.intent == "CONTROLLED_ESCAPE_INTENT" then
        MovementIntentGate.escapeAllowed = MovementIntentGate.escapeAllowed + 1
        if Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            print("[XNP MOVEMENT GATE] intent=CONTROLLED_ESCAPE_INTENT result=ALLOW_ESCAPE reason=CONTROLLED_OR_TOUCHING input=RUN_OR_SPRINT")
            print("[XNP CONTROLLED ESCAPE] input=RUN_OR_SPRINT state=CONTROLLED result=ALLOW")
        end
        return true, "CONTROLLED_OR_TOUCHING", info
    end
    MovementIntentGate.escapeBlocked = MovementIntentGate.escapeBlocked + 1
    if info.controlled then
        if Core.LogThrottle then
            Core.LogThrottle.Blocked("CONTROLLED_ESCAPE", "NO_RUN_OR_SPRINT_INPUT")
        elseif Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
            if Core.LogThrottle then Core.LogThrottle.Blocked("MOVEMENTINTENTGATE", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        end
        return false, "NO_RUN_OR_SPRINT_INPUT", info
    end
    if Core.LogThrottle then
        Core.LogThrottle.Blocked("CONTROLLED_ESCAPE", "NOT_CONTROLLED_ENOUGH")
    elseif Config.MOVEMENT_GATE_IMMEDIATE_LOG == true then
        if Core.LogThrottle then Core.LogThrottle.Blocked("MOVEMENTINTENTGATE", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    end
    return false, "NOT_CONTROLLED_ENOUGH", info
end

function MovementIntentGate.BlockReason(player, context)
    local info = MovementIntentGate.GetIntent(player, context)
    if info.intent == "WALK_IDLE_OR_MOVEMENT" then
        return "WALKING_NOT_JOGGING", info
    end
    return "NONE", info
end

function MovementIntentGate.SummaryTick()
    if Config.MOVEMENT_GATE_SUMMARY_ENABLED ~= true and Config.movement_gate_summary_enabled ~= true then
        return
    end
    MovementIntentGate.summaryFrame = MovementIntentGate.summaryFrame + 1
    local interval = Config.MOVEMENT_GATE_SUMMARY_INTERVAL_FRAMES or 120
    if MovementIntentGate.summaryFrame >= interval then
        if Core.LogThrottle then Core.LogThrottle.Blocked("MOVEMENTINTENTGATE", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        MovementIntentGate.summaryFrame = 0
        MovementIntentGate.walkBlocked = 0
        MovementIntentGate.jogAllowed = 0
        MovementIntentGate.sprintAllowed = 0
        MovementIntentGate.escapeAllowed = 0
        MovementIntentGate.escapeBlocked = 0
    end
end

Core.MovementIntentGate = MovementIntentGate
return MovementIntentGate
