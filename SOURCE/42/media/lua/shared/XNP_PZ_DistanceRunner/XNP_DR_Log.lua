require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local Log = {
    once = {},
    counters = {},
}

local function realMs()
    if type(getTimestampMs) == "function" then
        return getTimestampMs()
    end
    return os.time() * 1000
end

local function frameCount()
    return math.floor(realMs() / 16)
end

function Log.Print(message)
    print(tostring(message))
end

function Log.Once(key, message)
    key = tostring(key)
    if Log.once[key] then
        return false
    end
    Log.once[key] = true
    Log.Print(message)
    return true
end

function Log.EveryFrames(key, frames, message)
    key = tostring(key)
    frames = tonumber(frames) or tonumber(Config.SUMMARY_LOG_INTERVAL_FRAMES) or 120
    local now = frameCount()
    local last = Log.counters[key] or -frames
    if now - last < frames then
        return false
    end
    Log.counters[key] = now
    Log.Print(message)
    return true
end

function Log.EveryRealMs(key, intervalMs, message)
    key = tostring(key)
    intervalMs = tonumber(intervalMs) or tonumber(Config.SUMMARY_INTERVAL_REAL_MS) or 10000
    local now = realMs()
    local last = Log.counters[key] or -intervalMs
    if now - last < intervalMs then
        return false
    end
    Log.counters[key] = now
    Log.Print(message)
    return true
end

function Log.EveryRealSeconds(key, seconds, message)
    return Log.EveryRealMs(key, (tonumber(seconds) or 10) * 1000, message)
end

function Log.Init()
    Log.Once("init_summary_interval", "[XNP LOG] summary_interval_real_ms=" .. tostring(Config.SUMMARY_INTERVAL_REAL_MS or 10000) .. " frame_based=false")
end

Core.Log = Log
Log.Init()
return Log
