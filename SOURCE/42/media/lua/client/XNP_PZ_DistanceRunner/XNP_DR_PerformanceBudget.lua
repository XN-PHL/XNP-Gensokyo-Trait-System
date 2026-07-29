require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Log"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local PerformanceBudget = {
    frames = 0,
    last = {},
    logged = false,
}

function PerformanceBudget.Update()
    PerformanceBudget.frames = PerformanceBudget.frames + 1
    if not PerformanceBudget.logged then
        PerformanceBudget.logged = true
    Core.LogThrottle.Event("[XNP PERFORMANCE] mode=RELEASE")
        print("[XNP PERFORMANCE] stamina_tick_interval=" .. tostring(Config.LONG_MIGRATION_TICK_INTERVAL_FRAMES or 15) .. " ui_tick_interval=" .. tostring(Config.STAMINA_ICON_UPDATE_INTERVAL_FRAMES or 10) .. " zombie_cache_ttl=" .. tostring(Config.NEARBY_ZOMBIE_CACHE_TTL_FRAMES or 12))
        print("[XNP LOG SILENCE] release_summary_only=true")
    end
    return PerformanceBudget.frames
end

function PerformanceBudget.ShouldRun(key, interval)
    interval = tonumber(interval) or 1
    if interval <= 1 then
        return true
    end
    key = tostring(key)
    local last = PerformanceBudget.last[key] or -interval
    if PerformanceBudget.frames - last < interval then
        return false
    end
    PerformanceBudget.last[key] = PerformanceBudget.frames
    return true
end

function PerformanceBudget.Frame()
    return PerformanceBudget.frames
end

Core.PerformanceBudget = PerformanceBudget
return PerformanceBudget
