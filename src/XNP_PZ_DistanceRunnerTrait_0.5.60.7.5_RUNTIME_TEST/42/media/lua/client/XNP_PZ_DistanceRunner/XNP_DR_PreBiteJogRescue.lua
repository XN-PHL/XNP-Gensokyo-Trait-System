require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local PreBite = {
    cooldownUntil = 0,
    handledWindows = {},
    history = setmetatable({}, { __mode = "k" }),
    triggerSeq = 0,
    startupLogged = false,
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function fmt(value)
    if not Constants.IsFiniteNumber(value) then
        return "NA"
    end
    return string.format("%.4f", value)
end

local function safeCall(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function() return obj[method](obj) end)
        if ok then return value end
    end
    return nil
end

local function safeBool(obj, method)
    return safeCall(obj, method) == true
end

local function safeString(obj, method)
    local value = safeCall(obj, method)
    if value == nil then return "" end
    return string.lower(tostring(value))
end

local function liveZombie(obj)
    if not obj or type(instanceof) ~= "function" then return false end
    local ok, zombie = pcall(function() return instanceof(obj, "IsoZombie") end)
    if not ok or zombie ~= true then return false end
    return not safeBool(obj, "isDead") and not safeBool(obj, "isFakeDead")
end

local function targetKey(zombie)
    if Core.BreakoutActionBus and Core.BreakoutActionBus.TargetKey then
        return Core.BreakoutActionBus.TargetKey(zombie)
    end
    return "local:" .. tostring(zombie)
end

local function forward(player)
    local v = safeCall(player, "getForwardDirection")
    if v then
        local x = Constants.IsFiniteNumber(v.x) and v.x or (type(v.getX) == "function" and v:getX() or nil)
        local y = Constants.IsFiniteNumber(v.y) and v.y or (type(v.getY) == "function" and v:getY() or nil)
        if Constants.IsFiniteNumber(x) and Constants.IsFiniteNumber(y) then
            local len = math.sqrt(x * x + y * y)
            if len > 0.0001 then return x / len, y / len end
        end
    end
    return nil, nil
end

local function playerMovementText(player)
    return safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
end

local function biteCommitted(player)
    local text = playerMovementText(player)
    return string.find(text, "hitreaction-bite", 1, true) ~= nil
        or string.find(text, "bite", 1, true) ~= nil
end

local function zombieAttackState(zombie)
    local text = safeString(zombie, "getActionStateName") .. " " .. safeString(zombie, "getAnimationStateName")
    return string.find(text, "attack", 1, true) ~= nil
        or string.find(text, "grab", 1, true) ~= nil
        or string.find(text, "bite", 1, true) ~= nil
end

local function sameZ(player, zombie)
    local pz = safeCall(player, "getZ")
    local zz = safeCall(zombie, "getZ")
    if not Constants.IsFiniteNumber(pz) or not Constants.IsFiniteNumber(zz) then return false end
    return math.abs(pz - zz) <= 0.50
end

local function updateClosing(zombie, dist)
    local h = PreBite.history[zombie]
    if not h then
        h = { lastDist = dist, closing = 0 }
        PreBite.history[zombie] = h
        return 0
    end
    if h.lastDist - dist >= (Config.PRECOLLISION_MIN_DISTANCE_DELTA or 0.015) then
        h.closing = math.min((h.closing or 0) + 1, 20)
    else
        h.closing = 0
    end
    h.lastDist = dist
    return h.closing or 0
end

local function collectTargets(player)
    local result = {}
    if not Core.ThreatSnapshot then return result end
    local fx, fy = forward(player)
    if not fx then return result end
    local px = safeCall(player, "getX")
    local py = safeCall(player, "getY")
    if not Constants.IsFiniteNumber(px) or not Constants.IsFiniteNumber(py) then return result end
    local entries = Core.ThreatSnapshot.GetThreatEntries(Config.PREBITE_JOG_RESCUE_RADIUS or 1.05)
    local seen = {}
    for i = 1, #entries do
        local zombie = entries[i].zombie
        if liveZombie(zombie) and not seen[zombie] and sameZ(player, zombie) then
            seen[zombie] = true
            local zx = safeCall(zombie, "getX")
            local zy = safeCall(zombie, "getY")
            if Constants.IsFiniteNumber(zx) and Constants.IsFiniteNumber(zy) then
            local dx = zx - px
            local dy = zy - py
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= (Config.PREBITE_JOG_RESCUE_RADIUS or 1.05) then
                local dot = dist > 0 and ((dx / dist) * fx + (dy / dist) * fy) or 1.0
                local attacking = zombieAttackState(zombie)
                local closing = updateClosing(zombie, dist)
                if attacking or dot >= (Config.PREBITE_JOG_RESCUE_DOT_MIN or 0.25) or closing >= (Config.PREBITE_JOG_RESCUE_CLOSING_FRAMES or 1) then
                    result[#result + 1] = {
                        zombie = zombie,
                        key = targetKey(zombie),
                        dist = dist,
                        dot = dot,
                        closing = closing,
                        attacking = attacking,
                    }
                end
            end
            end
        end
    end
    table.sort(result, function(a, b)
        if a.attacking ~= b.attacking then return a.attacking end
        if a.dist ~= b.dist then return a.dist < b.dist end
        if a.dot ~= b.dot then return a.dot > b.dot end
        return a.closing > b.closing
    end)
    return result
end

local function logStartupOnce()
    if PreBite.startupLogged then return end
    PreBite.startupLogged = true
    print("[XNP PREBITE RESCUE] enabled=true max_targets=3 radius=1.05 no_bite_rollback=true no_heal=true")
end

local function nextTriggerId()
    PreBite.triggerSeq = PreBite.triggerSeq + 1
    return "PREBITE_" .. tostring(PreBite.triggerSeq)
end

function PreBite.Update(player, danger)
    logStartupOnce()
    if Config.ENABLE_PREBITE_JOG_RESCUE ~= true then return false end
    if not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then return false end
    if safeBool(player, "isDead") or safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown") then return false end
    if biteCommitted(player) then
        Core.LogThrottle.Blocked("PREBITE_RESCUE", "TOO_LATE_BITE_ALREADY_COMMITTED")
        return false
    end

    local band = Core.EnduranceBandState and Core.EnduranceBandState.GetStableState and Core.EnduranceBandState.GetStableState(player) or nil
    local state = band and band.state or "GREEN_READY"
    if state == "GREEN_READY" then return false end

    local gateOk, _, intent = true, "ALLOW", nil
    if Core.MovementIntentGate and Core.MovementIntentGate.GetIntent then
        intent = Core.MovementIntentGate.GetIntent(player, { source = "PRE_BITE_JOG_RESCUE", controlled = false })
        gateOk = intent and (intent.intent == "JOG_INTENT" or intent.intent == "SPRINT_INTENT" or intent.intent == "CONTROLLED_ESCAPE_INTENT")
    end
    if not gateOk then return false end

    local now = nowSeconds()
    if now < PreBite.cooldownUntil then
        return false
    end
    local windowKey = tostring(danger and danger.reason or "UNKNOWN") .. "|" .. tostring(danger and danger.inner or 0) .. "|" .. tostring(danger and danger.outer or 0)
    if PreBite.handledWindows[windowKey] and now - PreBite.handledWindows[windowKey] < (Config.PREBITE_JOG_RESCUE_WINDOW_COOLDOWN or 0.75) then
        return false
    end

    local targets = collectTargets(player)
    local maxTargets = Config.PREBITE_JOG_RESCUE_MAX_TARGETS or 3
    if #targets <= 0 then return false end
    local selected = {}
    for i = 1, math.min(#targets, maxTargets) do
        selected[#selected + 1] = targets[i]
    end

    if Core.BreakoutActionBus and Core.BreakoutActionBus.CanStart then
        local busOk = Core.BreakoutActionBus.CanStart("PRE_BITE_JOG_RESCUE", "TRUE_EMERGENCY", selected, "KNOCKDOWN")
        if not busOk then return false end
    end
    local actionId = nil
    if Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
        actionId = Core.BreakoutActionBus.Accept("PRE_BITE_JOG_RESCUE", "TRUE_EMERGENCY", selected, "KNOCKDOWN")
    end

    local triggerId = nextTriggerId()
    print("[XNP PREBITE RESCUE] trigger=PRE_BITE_JOG_RESCUE")
    print("[XNP PREBITE RESCUE] movement_intent=RUN_OR_SPRINT")
    print("[XNP PREBITE RESCUE] targets=" .. tostring(#selected) .. " max_targets=3")
    print("[XNP PREBITE RESCUE] third_target_stagger_only=true")
    print("[XNP PREBITE RESCUE] bite_rollback=false infection_rollback=false heal=false")

    if Core.EmergencyBreakoutCost then
        Core.EmergencyBreakoutCost.Apply(player, triggerId, "PRE_BITE_JOG_RESCUE", actionId)
    end

    local applied = 0
    for i = 1, #selected do
        local controlType = i <= 2 and "SPRINT_PRECOLLISION" or "CONTACT"
        local visible = Core.VerifiedStaggerControl.Apply(player, selected[i].zombie, controlType, { triggerId = triggerId })
        if visible then applied = applied + 1 end
        print("[XNP PREBITE RESCUE TARGET] index=" .. tostring(i)
            .. " key=" .. tostring(selected[i].key)
            .. " dist=" .. fmt(selected[i].dist)
            .. " dot=" .. fmt(selected[i].dot)
            .. " closing=" .. tostring(selected[i].closing)
            .. " stagger_only=" .. tostring(i == 3))
    end

    PreBite.cooldownUntil = now + (Config.PREBITE_JOG_RESCUE_COOLDOWN or 0.75)
    PreBite.handledWindows[windowKey] = now
    if applied > 0 then
        Core.YellowRedSignals.PulseImpact("PREBITE_JOG_RESCUE")
    end
    print("[XNP PREBITE RESCUE SUMMARY] applied=" .. tostring(applied) .. " selected=" .. tostring(#selected) .. " cooldown=0.75")
    return applied > 0
end

function PreBite.Cleanup()
    PreBite.cooldownUntil = 0
    PreBite.handledWindows = {}
end

Core.PreBiteJogRescue = PreBite
return PreBite
