require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery"
require "XNP_PZ_DistanceRunner/XNP_DR_PlayerSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_CriticalWindow"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactCandidateSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_VehicleVerifiedEvaluator"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local Scheduler = {
    startupLogged = false,
    last = { light = 0, threat = 0, critical = 0, impact = 0, ui = 0, food = 0, sandbox = 0, summary = 0 },
    counters = { frames = 0, light = 0, threat = 0, critical = 0, impact = 0, ui = 0, food = 0, sandbox = 0 },
    previous = { sprinting = false, nearby = 0, onFloor = false },
    gameHourTasks = {},
    gameHourTaskOrder = {},
    lastGameHourBucketByPlayer = {},
    activeSecondTasks = {},
    activeSecondTaskOrder = {},
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function due(now, key, interval)
    if now - Scheduler.last[key] >= interval then
        Scheduler.last[key] = now
        Scheduler.counters[key] = Scheduler.counters[key] + 1
        return true
    end
    return false
end

local function worldHours()
    if type(getGameTime) ~= "function" then return nil end
    local ok, value = pcall(function()
        return getGameTime():getWorldAgeHours()
    end)
    return ok and tonumber(value) or nil
end

function Scheduler.RegisterGameHourTask(taskId, callback)
    if type(taskId) ~= "string" or taskId == "" or type(callback) ~= "function" then
        return false, "invalid_task"
    end
    local existing = Scheduler.gameHourTasks[taskId]
    if existing then
        -- Lua reloads may produce a new function object. Replace the callback in
        -- place while retaining exactly one ordered task for this stable ID.
        existing.callback = callback
        return true, "already_registered"
    end
    Scheduler.gameHourTasks[taskId] = {
        id = taskId,
        callback = callback,
    }
    Scheduler.gameHourTaskOrder[#Scheduler.gameHourTaskOrder + 1] = taskId
    return true, "registered"
end

function Scheduler.DispatchGameHourTasks(player)
    if not player then return false end
    local now = worldHours()
    if not now then return false end
    local bucket = math.floor(now)
    if Scheduler.lastGameHourBucketByPlayer[player] == bucket then
        return false
    end
    -- Commit before callbacks so a failing task cannot be repeated every frame.
    Scheduler.lastGameHourBucketByPlayer[player] = bucket
    for _, taskId in ipairs(Scheduler.gameHourTaskOrder) do
        local task = Scheduler.gameHourTasks[taskId]
        if task and type(task.callback) == "function" then
            local ok, err = pcall(task.callback, player, now, bucket)
            if not ok then
                print("[XNP PERFORMANCE] central_game_hour_task_failed id=" .. tostring(taskId) .. " error=" .. tostring(err))
            end
        end
    end
    return true
end

function Scheduler.GetGameHourTaskCount()
    return #Scheduler.gameHourTaskOrder
end

function Scheduler.RegisterActiveSecondTask(taskId, delaySeconds, callback)
    if type(taskId) ~= "string" or taskId == "" or type(callback) ~= "function" then
        return false, "invalid_task"
    end
    local delay = tonumber(delaySeconds)
    if not delay or delay <= 0 then return false, "invalid_delay" end
    if Scheduler.activeSecondTasks[taskId] then return false, "task_already_registered" end
    Scheduler.activeSecondTasks[taskId] = {
        id = taskId,
        remaining = delay,
        callback = callback,
    }
    Scheduler.activeSecondTaskOrder[#Scheduler.activeSecondTaskOrder + 1] = taskId
    return true, "registered"
end

function Scheduler.AdvanceActiveSecondTasks(player)
    if #Scheduler.activeSecondTaskOrder == 0 then return false end
    if type(isGamePaused) == "function" and isGamePaused() then
        return false
    end
    if type(getGameTime) ~= "function" then return false end
    local gameTime = getGameTime()
    if not gameTime or type(gameTime.getRealworldSecondsSinceLastUpdate) ~= "function" then return false end
    local delta = tonumber(gameTime:getRealworldSecondsSinceLastUpdate()) or 0
    if delta <= 0 then return false end
    -- A resume or debugger gap is not active play time. Capping a single frame
    -- prevents a pause/background stall from consuming the whole four seconds.
    delta = math.min(delta, 0.25)
    for index = #Scheduler.activeSecondTaskOrder, 1, -1 do
        local taskId = Scheduler.activeSecondTaskOrder[index]
        local task = Scheduler.activeSecondTasks[taskId]
        if not task then
            table.remove(Scheduler.activeSecondTaskOrder, index)
        else
            task.remaining = task.remaining - delta
            if task.remaining <= 0 then
                Scheduler.activeSecondTasks[taskId] = nil
                table.remove(Scheduler.activeSecondTaskOrder, index)
                local ok, err = pcall(task.callback, player, taskId)
                if not ok then
                    print("[XNP PERFORMANCE] active_second_task_failed id=" .. tostring(taskId) .. " error=" .. tostring(err))
                end
            end
        end
    end
    return true
end

function Scheduler.GetActiveSecondTaskCount()
    return #Scheduler.activeSecondTaskOrder
end

function Scheduler.CancelActiveSecondTask(taskId)
    if not Scheduler.activeSecondTasks[taskId] then return false, "task_missing" end
    Scheduler.activeSecondTasks[taskId] = nil
    for index = #Scheduler.activeSecondTaskOrder, 1, -1 do
        if Scheduler.activeSecondTaskOrder[index] == taskId then
            table.remove(Scheduler.activeSecondTaskOrder, index)
            break
        end
    end
    return true, "cancelled"
end

function Scheduler.ClearActiveSecondTasks(reason)
    Scheduler.activeSecondTasks = {}
    Scheduler.activeSecondTaskOrder = {}
    if reason then print("[XNP PERFORMANCE] active_second_tasks_cleared reason=" .. tostring(reason)) end
end

function Scheduler.ReleasePlayer(player)
    if player then Scheduler.lastGameHourBucketByPlayer[player] = nil end
    Scheduler.previous.sprinting = false
    Scheduler.previous.nearby = 0
    Scheduler.previous.onFloor = false
end

local function applyEdges(snapshot)
    local sprinting = snapshot.isSprinting == true
    local nearby = snapshot.nearbyZombieCount or 0
    local onFloor = snapshot.onFloor == true
    if sprinting and not Scheduler.previous.sprinting then
        Core.CriticalWindow.Enter("SPRINT_EDGE", 750)
    end
    if nearby > Scheduler.previous.nearby then
        if Core.CriticalWindow.IsActive() then
            Core.CriticalWindow.Extend("THREAT_COUNT_EDGE", 750, 2000)
        else
            Core.CriticalWindow.Enter("THREAT_COUNT_EDGE", 750)
        end
    end
    if onFloor and not Scheduler.previous.onFloor then
        Core.CriticalWindow.Enter("PLAYER_DOWN_EDGE", 500)
    end
    if not sprinting and nearby == 0 and not onFloor then
        Core.CriticalWindow.Exit("DANGER_CLEARED")
    end
    Scheduler.previous.sprinting = sprinting
    Scheduler.previous.nearby = nearby
    Scheduler.previous.onFloor = onFloor
end

local function logStartup()
    if Scheduler.startupLogged then return end
    Scheduler.startupLogged = true
    Core.LogThrottle.Event("[XNP PERFORMANCE] scheduler_enabled=true central_gameplay_scheduler_count=1 candidate_cap=16 critical_max_total_ms=2000")
end

function Scheduler.Begin(player)
    logStartup()
    local now = nowSeconds()
    Scheduler.counters.frames = Scheduler.counters.frames + 1
    local snapshot = Core.PlayerSnapshot.RefreshLight(player)
    if Core.CentralWorldQuery then
        Core.CentralWorldQuery.BuildPlayerFrame(player, snapshot.frame)
    end
    local moving = snapshot.isMoving == true
    local active = snapshot.isSprinting == true or (snapshot.speed or 0) > 1.0
    local threatInterval = Config.PERFORMANCE_IDLE_THREAT_INTERVAL or 0.50
    if active then
        threatInterval = Config.PERFORMANCE_ACTIVE_THREAT_INTERVAL or 0.10
    elseif moving then
        threatInterval = Config.PERFORMANCE_MOVING_THREAT_INTERVAL or 0.25
    end
    local threatDue = due(now, "threat", threatInterval)
    if threatDue then
        snapshot = Core.PlayerSnapshot.RefreshThreat(player)
    end
    applyEdges(snapshot)
    local critical = false
    if Core.CriticalWindow.IsActive() then
        critical = due(now, "critical", math.max(Config.PERFORMANCE_CRITICAL_INTERVAL or 0.05, 0.05))
    end
    local impactActive = Core.BreakoutPush
        and Core.BreakoutPush.HasMovementIntent
        and Core.BreakoutPush.HasMovementIntent(player)
    if not impactActive then
        impactActive = snapshot.isSprinting == true
            or (snapshot.speed or 0) >= (Config.PRECOLLISION_SPRINT_MIN_SPEED or 3.25)
    end
    local impact = impactActive == true and due(now, "impact", 0.05)
    if impact then
        Core.ImpactCandidateSnapshot.BuildNow(player, "SPRINT_IMPACT", true)
    end
    return {
        light = due(now, "light", active and 0.05 or (moving and 0.15 or 0.25)),
        threat = threatDue,
        critical = critical,
        impact = impact,
        ui = due(now, "ui", Config.PERFORMANCE_UI_INTERVAL or 0.25),
        food = due(now, "food", Config.PERFORMANCE_FOOD_INTERVAL or 1.0),
        sandbox = due(now, "sandbox", Config.PERFORMANCE_SANDBOX_INTERVAL or 2.0),
        snapshot = snapshot,
    }
end

function Scheduler.RunVehicleEvaluator(player)
    if not Core.VehicleVerifiedEvaluator then return false end
    return Core.VehicleVerifiedEvaluator.Execute(player) == true
end

function Scheduler.VehicleSummaryTick()
    if Core.VehicleVerifiedEvaluator then
        Core.VehicleVerifiedEvaluator.SummaryTick()
    end
end

function Scheduler.SummaryTick()
    local now = nowSeconds()
    if now - Scheduler.last.summary < 10.0 then return end
    Scheduler.last.summary = now
    local total = Scheduler.counters.light + Scheduler.counters.threat + Scheduler.counters.critical + Scheduler.counters.impact + Scheduler.counters.ui + Scheduler.counters.food + Scheduler.counters.sandbox
    if total > 0 and Config.DEBUG == true then
        print("[XNP PERFORMANCE SUMMARY] frames=" .. tostring(Scheduler.counters.frames) .. " light=" .. tostring(Scheduler.counters.light) .. " threat=" .. tostring(Scheduler.counters.threat) .. " critical=" .. tostring(Scheduler.counters.critical) .. " impact=" .. tostring(Scheduler.counters.impact) .. " ui=" .. tostring(Scheduler.counters.ui) .. " food=" .. tostring(Scheduler.counters.food) .. " sandbox=" .. tostring(Scheduler.counters.sandbox))
    end
    for key in pairs(Scheduler.counters) do Scheduler.counters[key] = 0 end
end

Core.PerformanceScheduler = Scheduler
return Scheduler
