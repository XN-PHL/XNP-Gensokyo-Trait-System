require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local StaminaTrendMeter = {
    samples = {},
    lastResult = { result = "UNKNOWN", delta = 0, netRecovery = 0, window = 0 },
}

local function maxSamples()
    return Config.RED_STRAIN_NO_RECOVERY_WINDOW_TICKS or 4
end

function StaminaTrendMeter.Record(endurance, hunger, enduranceWriteApplied, hungerWriteApplied)
    local sample = {
        endurance = Constants.IsFiniteNumber(endurance) and endurance or nil,
        hunger = Constants.IsFiniteNumber(hunger) and hunger or nil,
        enduranceWriteApplied = enduranceWriteApplied == true,
        hungerWriteApplied = hungerWriteApplied == true,
    }
    StaminaTrendMeter.samples[#StaminaTrendMeter.samples + 1] = sample
    while #StaminaTrendMeter.samples > maxSamples() do
        table.remove(StaminaTrendMeter.samples, 1)
    end
    return StaminaTrendMeter.Evaluate()
end

function StaminaTrendMeter.Evaluate()
    local count = #StaminaTrendMeter.samples
    if count < maxSamples() then
        StaminaTrendMeter.lastResult = { result = "WARMUP", delta = 0, netRecovery = 0, window = count }
        return StaminaTrendMeter.lastResult
    end
    local first = StaminaTrendMeter.samples[1].endurance
    local last = StaminaTrendMeter.samples[count].endurance
    local delta = 0
    if Constants.IsFiniteNumber(first) and Constants.IsFiniteNumber(last) then
        delta = last - first
    end
    local netRecovery = math.max(0, delta)
    local minRecovery = Config.RED_STRAIN_MIN_NET_RECOVERY or 0.005
    local result = netRecovery <= minRecovery and "NO_RECOVERY" or "RECOVERING"
    StaminaTrendMeter.lastResult = { result = result, delta = delta, netRecovery = netRecovery, window = count }
    if Core.Log and Core.Log.EveryFrames then
        Core.Log.EveryFrames("stamina_trend", Config.STAMINA_ASSIST_SUMMARY_INTERVAL_FRAMES or 120, string.format("[XNP STAMINA TREND] window=%d delta=%.6f net_recovery=%.6f result=%s", count, delta, netRecovery, result))
    end
    return StaminaTrendMeter.lastResult
end

function StaminaTrendMeter.Get()
    return StaminaTrendMeter.lastResult
end

function StaminaTrendMeter.Cleanup()
    StaminaTrendMeter.samples = {}
    StaminaTrendMeter.lastResult = { result = "UNKNOWN", delta = 0, netRecovery = 0, window = 0 }
end

Core.StaminaTrendMeter = StaminaTrendMeter
return StaminaTrendMeter
