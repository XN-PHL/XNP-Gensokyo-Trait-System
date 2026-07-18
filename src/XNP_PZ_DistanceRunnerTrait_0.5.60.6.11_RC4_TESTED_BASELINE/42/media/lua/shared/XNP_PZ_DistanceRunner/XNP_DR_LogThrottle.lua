require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local LogThrottle = {
    startupLogged = false,
    blocked = {},
    lastSummary = 0,
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

function LogThrottle.Startup()
    if LogThrottle.startupLogged then
        return
    end
    LogThrottle.startupLogged = true
    if Core.LogThrottle then Core.LogThrottle.Blocked("LOGTHROTTLE", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
end

function LogThrottle.Blocked(category, reason, count)
    local key = tostring(category or "GENERAL") .. "|" .. tostring(reason or "UNKNOWN")
    LogThrottle.blocked[key] = (LogThrottle.blocked[key] or 0) + (count or 1)
    return false
end

function LogThrottle.Event(message)
    if message then
        print(tostring(message))
    end
end

function LogThrottle.SummaryTick()
    local now = nowSeconds()
    local interval = Config.LOG_THROTTLE_SUMMARY_SECONDS or 10.0
    if now - LogThrottle.lastSummary < interval then
        return
    end
    LogThrottle.lastSummary = now
    local parts = {}
    for key, count in pairs(LogThrottle.blocked) do
        if count > 0 then
            parts[#parts + 1] = tostring(key) .. "=" .. tostring(count)
            LogThrottle.blocked[key] = 0
        end
    end
    if #parts > 0 then
        print("[XNP LOG THROTTLE SUMMARY] " .. table.concat(parts, " "))
    end
end

Core.LogThrottle = LogThrottle
return LogThrottle
