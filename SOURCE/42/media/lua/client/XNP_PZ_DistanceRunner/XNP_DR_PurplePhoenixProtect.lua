require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"

local Core = XNP_PZ_DistanceRunner

local Protect = {
    executionCount = 0,
    pulseExecutionCount = 0,
    extraPulseRejectedCount = 0,
    lastTargetCount = 0,
    lastMethods = {},
    pulseLedger = {},
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    return pcall(object[method], object, ...)
end

local function number(object, method)
    local ok, value = invoke(object, method)
    return ok and tonumber(value) or nil
end

local function isLiveZombie(object)
    if not object then return false end
    if type(instanceof) == "function" then
        local ok, result = pcall(instanceof, object, "IsoZombie")
        if not ok or result ~= true then return false end
    else
        local ok, result = invoke(object, "isZombie")
        if not ok or result ~= true then return false end
    end
    local _, dead = invoke(object, "isDead")
    local _, fakeDead = invoke(object, "isFakeDead")
    return dead ~= true and fakeDead ~= true
end

local function localCell(player)
    local ok, cell = invoke(player, "getCell")
    if ok and cell then return cell end
    if type(getCell) == "function" then
        ok, cell = pcall(getCell)
        if ok then return cell end
    end
    return nil
end

local function candidates(player, radius, cap)
    local px = number(player, "getX")
    local py = number(player, "getY")
    local pz = number(player, "getZ")
    local cell = localCell(player)
    if not px or not py or not pz or not cell
        or type(cell.getGridSquare) ~= "function" then
        return {}, "WORLD_QUERY_UNAVAILABLE"
    end
    local seen, entries = {}, {}
    local z = math.floor(pz + 0.5)
    local extent = math.ceil(radius)
    for sx = math.floor(px) - extent, math.floor(px) + extent do
        for sy = math.floor(py) - extent, math.floor(py) + extent do
            local squareOk, square =
                pcall(function() return cell:getGridSquare(sx, sy, z) end)
            local movingOk, moving =
                invoke(squareOk and square or nil, "getMovingObjects")
            local count = 0
            if movingOk and moving and type(moving.size) == "function" then
                local sizeOk, size = pcall(function() return moving:size() end)
                count = sizeOk and tonumber(size) or 0
            end
            for index = 0, count - 1 do
                local itemOk, zombie =
                    pcall(function() return moving:get(index) end)
                if itemOk and isLiveZombie(zombie) and not seen[zombie] then
                    seen[zombie] = true
                    local zx = number(zombie, "getX")
                    local zy = number(zombie, "getY")
                    if zx and zy then
                        local dx, dy = zx - px, zy - py
                        local distSq = dx * dx + dy * dy
                        if distSq <= radius * radius then
                            entries[#entries + 1] = {
                                zombie = zombie,
                                distSq = distSq,
                                dx = dx,
                                dy = dy,
                                zx = zx,
                                zy = zy,
                            }
                        end
                    end
                end
            end
        end
    end
    table.sort(entries, function(left, right)
        return left.distSq < right.distSq
    end)
    while #entries > cap do table.remove(entries) end
    return entries, "DIRECT_LOCAL_ZOMBIE_SCAN"
end

local function microNudge(entry)
    local distance = math.sqrt(entry.distSq)
    if distance < 0.001 then return false, "ZERO_DIRECTION" end
    local amount = 0.35
    local targetX = entry.zx + entry.dx / distance * amount
    local targetY = entry.zy + entry.dy / distance * amount
    local xOk = invoke(entry.zombie, "setX", targetX)
    local yOk = invoke(entry.zombie, "setY", targetY)
    if xOk and yOk then
        invoke(entry.zombie, "setLx", targetX)
        invoke(entry.zombie, "setLy", targetY)
        return true, "ZOMBIE_MICRO_NUDGE"
    end
    return false, "ZOMBIE_MICRO_NUDGE_UNAVAILABLE"
end

local function pulseReport(
    transactionId, pulse, scheduledDelayMs, actualDelayMs,
    freshScan, candidatesCount, affected, queryMethod, methods,
    safeSkipReason)
    print("[XNP PHOENIX SURVIVAL PUSH] transaction_id="
        .. tostring(transactionId)
        .. " pulse=" .. tostring(pulse) .. "/2"
        .. " scheduled_delay_ms=" .. tostring(scheduledDelayMs)
        .. " actual_delay_ms=" .. tostring(actualDelayMs)
        .. " fresh_scan=" .. tostring(freshScan == true)
        .. " candidates=" .. tostring(candidatesCount or 0)
        .. " affected=" .. tostring(affected or 0)
        .. " damage=0 player_coordinate_write=false"
        .. " query_method=" .. tostring(queryMethod or "NONE")
        .. " safe_skip_reason=" .. tostring(safeSkipReason or "NONE")
        .. " methods=" .. table.concat(methods or {}, "+"))
end

function Protect.TriggerPulse(
    player, transactionId, pulse, scheduledDelayMs, actualDelayMs)
    pulse = tonumber(pulse)
    scheduledDelayMs = tonumber(scheduledDelayMs) or 0
    actualDelayMs = tonumber(actualDelayMs) or 0
    if pulse ~= 1 and pulse ~= 2 then
        Protect.extraPulseRejectedCount =
            Protect.extraPulseRejectedCount + 1
        return false, "PULSE_OUT_OF_RANGE"
    end
    transactionId = tostring(transactionId)
    local ledger = Protect.pulseLedger[transactionId]
    if not ledger then
        ledger = { total = 0, pulses = {} }
        Protect.pulseLedger[transactionId] = ledger
    end
    if ledger.pulses[pulse] then
        return true, ledger.pulses[pulse].affected, {
            completed = true,
            duplicate_suppressed = true,
            pulse = pulse,
            fresh_scan = false,
            safe_skip_reason = "DUPLICATE_PULSE_SUPPRESSED",
        }
    end
    if ledger.total >= 2 then
        Protect.extraPulseRejectedCount =
            Protect.extraPulseRejectedCount + 1
        return false, "PULSE_LIMIT_REACHED"
    end

    local valid, identityReason =
        Core.CanonicalPlayerIdentity.Validate(player, true)
    if not valid then
        return false, "IDENTITY_REJECTED:" .. tostring(identityReason)
    end
    local config = Core.PurplePhoenixConfig.Get()
    if config.localZombiePushEnabled ~= true then
        local report = {
            completed = true,
            pulse = pulse,
            fresh_scan = false,
            candidates = 0,
            affected = 0,
            safe_skip_reason = "SANDBOX_DISABLED",
        }
        ledger.total = ledger.total + 1
        ledger.pulses[pulse] = report
        Protect.executionCount = Protect.executionCount + 1
        Protect.pulseExecutionCount = Protect.pulseExecutionCount + 1
        pulseReport(transactionId, pulse, scheduledDelayMs, actualDelayMs,
            false, 0, 0, "SKIPPED", {}, "SANDBOX_DISABLED")
        return true, 0, report
    end

    local radius = math.max(0, tonumber(config.protectRadius) or 3)
    local cap = tonumber(Core.PurplePhoenixConstants.PROTECT_TARGET_CAP) or 24
    local entries, queryMethod = candidates(player, radius, cap)
    local affected, methods = 0, {}
    for index = 1, #entries do
        local entry = entries[index]
        local staggerOk, visible, staggerMethod = false, false, "UNAVAILABLE"
        if Core.VerifiedStaggerControl
            and type(Core.VerifiedStaggerControl.Apply) == "function" then
            staggerOk, visible, staggerMethod = pcall(
                Core.VerifiedStaggerControl.Apply,
                player, entry.zombie, "SPRINT_PRECOLLISION", {
                    triggerId = tostring(transactionId)
                        .. ":phoenix-push-" .. tostring(pulse)
                        .. ":" .. tostring(index),
                })
        end
        local nudged, nudgeMethod = microNudge(entry)
        if (staggerOk and visible == true) or nudged then affected = affected + 1 end
        methods[#methods + 1] = tostring(
            staggerOk and staggerMethod or "STAGGER_PCALL_FAILED")
            .. "+" .. tostring(nudgeMethod)
    end
    Protect.executionCount = Protect.executionCount + 1
    Protect.pulseExecutionCount = Protect.pulseExecutionCount + 1
    Protect.lastTargetCount = affected
    Protect.lastMethods = methods
    local safeSkipReason = queryMethod ~= "DIRECT_LOCAL_ZOMBIE_SCAN"
        and tostring(queryMethod) or nil
    local report = {
        completed = true,
        pulse = pulse,
        fresh_scan = true,
        candidates = #entries,
        affected = affected,
        query_method = queryMethod,
        safe_skip_reason = safeSkipReason,
        radius = radius,
        target_cap = cap,
    }
    ledger.total = ledger.total + 1
    ledger.pulses[pulse] = report
    pulseReport(transactionId, pulse, scheduledDelayMs, actualDelayMs,
        true, #entries, affected, queryMethod, methods, safeSkipReason)
    return true, affected, report
end

function Protect.TriggerOnce(player, transactionId)
    return Protect.TriggerPulse(player, transactionId, 1, 0, 0)
end

function Protect.CompleteTransaction(transactionId)
    Protect.pulseLedger[tostring(transactionId)] = nil
    return true, "PULSE_LEDGER_RELEASED"
end

function Protect.IsActive() return false end
function Protect.GetRemainingSeconds() return 0 end
function Protect.Update() return false, "ONE_SHOT_ONLY" end
function Protect.Cleanup() return true, "NO_PERSISTENT_ZOMBIE_STATE" end
function Protect.DiscardTransient() return true, "NO_TRANSIENT_STATE" end

function Protect.GetAuditSnapshot()
    return {
        execution_count = Protect.executionCount,
        pulse_execution_count = Protect.pulseExecutionCount,
        configured_pulse_count = 2,
        second_pulse_delay_ms = 2000,
        extra_pulse_rejected_count = Protect.extraPulseRejectedCount,
        last_target_count = Protect.lastTargetCount,
        last_methods = Protect.lastMethods,
        damage = 0,
        mode = "TWO_PULSE_FRESH_SCAN_STAGGER_AND_MICRO_NUDGE",
        player_coordinate_write = false,
    }
end

Core.PurplePhoenixProtect = Protect
return Protect
