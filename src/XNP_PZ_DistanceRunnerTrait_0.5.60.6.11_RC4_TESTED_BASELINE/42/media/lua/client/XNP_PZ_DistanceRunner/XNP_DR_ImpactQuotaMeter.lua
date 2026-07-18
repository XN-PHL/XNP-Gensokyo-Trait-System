require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local ImpactQuotaMeter = {
    windows = {},
    summaryFrame = 0,
    movementGateBlocked = 0,
}

XNP_DR_ImpactQuotaMeter = ImpactQuotaMeter

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function ensure(mode, window)
    local current = ImpactQuotaMeter.windows[mode]
    local now = nowSeconds()
    if not current or now - current.start >= window then
        current = { start = now, keys = {}, used = 0, blocked = 0, overflow = 0 }
        ImpactQuotaMeter.windows[mode] = current
    end
    return current, now
end

function ImpactQuotaMeter.TargetKey(zombie)
    if Core.BreakoutActionBus and Core.BreakoutActionBus.TargetKey then
        return Core.BreakoutActionBus.TargetKey(zombie)
    end
    return zombie and tostring(zombie) or "nil"
end

function ImpactQuotaMeter.Try(mode, zombie, quota, window)
    if Config.IMPACT_QUOTA_ENABLED ~= true then
        return true, "DISABLED"
    end
    local data = ensure(mode, window)
    local key = ImpactQuotaMeter.TargetKey(zombie)
    if data.keys[key] then
        return false, "DUPLICATE_TARGET"
    end
    if data.used >= quota then
        data.blocked = data.blocked + 1
        data.overflow = data.overflow + 1
        if mode == "JOG_BUMP" then
            print("[XNP IMPACT QUOTA] mode=JOG_BUMP used=" .. tostring(data.used) .. " quota=" .. tostring(quota) .. " result=OVERFLOW_TRIP")
        elseif mode == "SPRINT_VEHICLE" then
            print("[XNP IMPACT QUOTA] mode=SPRINT_VEHICLE interval=" .. tostring(window) .. " result=OVERFLOW_WALL_CRASH")
        else
            print("[XNP IMPACT QUOTA] mode=SKILL_ACTIVE used=" .. tostring(data.used) .. " quota=" .. tostring(quota) .. " result=BLOCK_KNOCKDOWN")
        end
        return false, "OVERFLOW"
    end
    data.used = data.used + 1
    data.keys[key] = true
    if mode == "JOG_BUMP" then
        print("[XNP IMPACT QUOTA] mode=JOG_BUMP used=" .. tostring(data.used) .. " quota=" .. tostring(quota) .. " result=ALLOW")
    elseif mode == "SPRINT_VEHICLE" then
        print("[XNP IMPACT QUOTA] mode=SPRINT_VEHICLE interval=" .. tostring(window) .. " result=ALLOW")
    else
        print("[XNP IMPACT QUOTA] mode=SKILL_ACTIVE used=" .. tostring(data.used) .. " quota=" .. tostring(quota) .. " result=ALLOW")
    end
    return true, "ALLOW"
end

function ImpactQuotaMeter.BlockedNotCounted(mode, reason)
    ImpactQuotaMeter.movementGateBlocked = ImpactQuotaMeter.movementGateBlocked + 1
    if Config.IMPACT_QUOTA_BLOCK_LOG_SUMMARY_ONLY ~= true then
        if Core.LogThrottle then Core.LogThrottle.Blocked("IMPACTQUOTAMETER", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    end
    return false, "BLOCKED_NOT_COUNTED"
end

function ImpactQuotaMeter.TrySkillActive(source, zombie, actionId)
    if Config.IMPACT_QUOTA_ENABLED ~= true then
        return true, "DISABLED"
    end
    local key = ImpactQuotaMeter.TargetKey(zombie)
    local quota = Config.SKILL_ACTIVE_KNOCKDOWN_QUOTA or 2
    local window = Config.SKILL_ACTIVE_QUOTA_WINDOW or 1.00
    if actionId == nil or actionId == false then
        if Core.LogThrottle then Core.LogThrottle.Blocked("IMPACTQUOTAMETER", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false, "BLOCKED_ACTION_NOT_COUNTED"
    end
    local data = ensure("SKILL_ACTIVE", window)
    if data.keys[key] then
        print("[XNP SKILL ACTIVE QUOTA] duplicate_target_skip target=" .. tostring(key))
        return true, "DUPLICATE_TARGET"
    end
    if data.used >= quota then
        data.blocked = data.blocked + 1
        data.overflow = data.overflow + 1
        print("[XNP IMPACT QUOTA] mode=SKILL_ACTIVE source=" .. tostring(source) .. " used=" .. tostring(data.used) .. " quota=" .. tostring(quota) .. " window=" .. string.format("%.2f", window) .. " target=" .. tostring(key) .. " result=BLOCK_KNOCKDOWN")
        print("[XNP SKILL ACTIVE QUOTA] downgrade target=" .. tostring(key) .. " from=KNOCKDOWN to=STAGGER_ONLY reason=QUOTA_EXCEEDED")
        return false, "QUOTA_EXCEEDED"
    end
    data.used = data.used + 1
    data.keys[key] = true
    print("[XNP IMPACT QUOTA] mode=SKILL_ACTIVE source=" .. tostring(source) .. " used=" .. tostring(data.used) .. " quota=" .. tostring(quota) .. " window=" .. string.format("%.2f", window) .. " target=" .. tostring(key) .. " result=ALLOW")
    return true, "ALLOW"
end

function ImpactQuotaMeter.SummaryTick()
    ImpactQuotaMeter.summaryFrame = ImpactQuotaMeter.summaryFrame + 1
    if ImpactQuotaMeter.summaryFrame < 60 then
        return
    end
    ImpactQuotaMeter.summaryFrame = 0
    local jog = ImpactQuotaMeter.windows.JOG_BUMP or { used = 0, overflow = 0 }
    local sprint = ImpactQuotaMeter.windows.SPRINT_VEHICLE or { used = 0, overflow = 0 }
    local skill = ImpactQuotaMeter.windows.SKILL_ACTIVE or { used = 0, overflow = 0 }
    if Core.LogThrottle then Core.LogThrottle.Blocked("IMPACTQUOTAMETER", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    ImpactQuotaMeter.movementGateBlocked = 0
end

Core.ImpactQuotaMeter = ImpactQuotaMeter
return ImpactQuotaMeter
