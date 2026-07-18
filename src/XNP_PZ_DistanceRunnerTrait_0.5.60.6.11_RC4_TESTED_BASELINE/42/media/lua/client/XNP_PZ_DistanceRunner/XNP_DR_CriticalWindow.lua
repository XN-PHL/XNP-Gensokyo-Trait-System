require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner

local CriticalWindow = {
    active = false,
    reason = nil,
    enteredAt = 0,
    expiresAt = 0,
    maxExpiresAt = 0,
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        return getTimestampMs()
    end
    return os.time() * 1000
end

function CriticalWindow.Enter(reason, durationMs)
    local now = nowMs()
    durationMs = math.min(math.max(tonumber(durationMs) or 750, 1), 1000)
    CriticalWindow.active = true
    CriticalWindow.reason = tostring(reason or "EDGE")
    CriticalWindow.enteredAt = now
    CriticalWindow.maxExpiresAt = now + 2000
    CriticalWindow.expiresAt = math.min(now + durationMs, CriticalWindow.maxExpiresAt)
    return true
end

function CriticalWindow.Extend(reason, durationMs, maxTotalMs)
    if not CriticalWindow.IsActive() then
        return CriticalWindow.Enter(reason, durationMs)
    end
    local now = nowMs()
    maxTotalMs = math.min(math.max(tonumber(maxTotalMs) or 2000, 1), 2000)
    local hardEnd = math.min(CriticalWindow.enteredAt + maxTotalMs, CriticalWindow.maxExpiresAt)
    CriticalWindow.expiresAt = math.min(math.max(CriticalWindow.expiresAt, now + math.min(tonumber(durationMs) or 500, 1000)), hardEnd)
    CriticalWindow.reason = tostring(reason or CriticalWindow.reason)
    return true
end

function CriticalWindow.IsActive()
    if not CriticalWindow.active then
        return false
    end
    if nowMs() >= CriticalWindow.expiresAt then
        CriticalWindow.Exit("EXPIRED")
        return false
    end
    return true
end

function CriticalWindow.Exit(reason)
    CriticalWindow.active = false
    CriticalWindow.reason = tostring(reason or "EXIT")
    CriticalWindow.enteredAt = 0
    CriticalWindow.expiresAt = 0
    CriticalWindow.maxExpiresAt = 0
    return true
end

function CriticalWindow.GetReason()
    return CriticalWindow.reason
end

Core.CriticalWindow = CriticalWindow
return CriticalWindow
