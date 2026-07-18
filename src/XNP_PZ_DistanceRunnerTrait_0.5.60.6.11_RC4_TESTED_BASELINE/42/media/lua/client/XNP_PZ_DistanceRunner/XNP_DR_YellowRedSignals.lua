require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame

local Signals = {
    IMPACT_SIGNAL = "XNP_YELLOW_RED_IMPACT_PULSE",
    MAX_RECOVERY_SIGNAL = "XNP_YELLOW_RED_MAX_RECOVERY_ACTIVE",
    PULSE_MS = 600,
    HUNGER_LEVEL_THRESHOLD = 3,
    impactUntilMs = 0,
    maxRecoveryUntilMs = 0,
    impactSource = "NONE",
    maxRecoverySource = "NONE",
}

local function extendUntil(currentValue)
    return math.max(tonumber(currentValue) or 0, Frame.NowMs() + Signals.PULSE_MS)
end

function Signals.PulseImpact(source)
    Signals.impactUntilMs = extendUntil(Signals.impactUntilMs)
    Signals.impactSource = tostring(source or "ACTUAL_EFFECT_COMMIT")
    return true
end

function Signals.PulseMaxRecovery(source)
    Signals.maxRecoveryUntilMs = extendUntil(Signals.maxRecoveryUntilMs)
    Signals.maxRecoverySource = tostring(source or "ACTUAL_MAX_RECOVERY_WRITE")
    return true
end

function Signals.IsSevereHunger(player)
    if not player then return false end
    local moodles = player:getMoodles()
    if not moodles then return false end
    return moodles:getMoodleLevel(MoodleType.HUNGRY) >= Signals.HUNGER_LEVEL_THRESHOLD
end

function Signals.Resolve(player)
    local now = Frame.NowMs()
    if now < Signals.impactUntilMs then
        return true, Signals.IMPACT_SIGNAL .. ":" .. Signals.impactSource
    end
    if Signals.IsSevereHunger(player) then
        return true, "VANILLA_HUNGRY_MOODLE_LEVEL_GTE_3"
    end
    if now < Signals.maxRecoveryUntilMs then
        return true, Signals.MAX_RECOVERY_SIGNAL .. ":" .. Signals.maxRecoverySource
    end
    return false, "NO_RED_SIGNAL"
end

function Signals.Cleanup(reason)
    Signals.impactUntilMs = 0
    Signals.maxRecoveryUntilMs = 0
    Signals.impactSource = "NONE"
    Signals.maxRecoverySource = "NONE"
end

Core.YellowRedSignals = Signals
return Signals
