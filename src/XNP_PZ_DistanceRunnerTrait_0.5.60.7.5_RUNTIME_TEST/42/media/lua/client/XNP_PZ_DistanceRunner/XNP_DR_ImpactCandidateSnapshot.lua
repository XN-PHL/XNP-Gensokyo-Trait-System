require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PlayerSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Impact = {
    candidates = {},
    sampleFrame = -1,
    sampleTime = 0,
    rawCount = 0,
    identityCount = 0,
    duplicateCount = 0,
    evaluationClaims = {},
    precollisionEligibleCandidates = {},
    startupLogged = false,
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then return getTimestampMs() / 1000 end
    return os.time()
end

local function safeCall(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function() return obj[method](obj) end)
        if ok then return value end
    end
    return nil
end

local function currentFrame()
    local snapshot = Core.PlayerSnapshot.GetCurrent()
    return snapshot and snapshot.frame or -1
end

local function logContractOnce()
    if Impact.startupLogged then return end
    Impact.startupLogged = true
    Core.LogThrottle.Event("[XNP IMPACT SNAPSHOT] source=LOCAL_SAME_TICK")
    Core.LogThrottle.Event("[XNP IMPACT SNAPSHOT] prefilter_cap=NONE")
    Core.LogThrottle.Event("[XNP IMPACT SNAPSHOT] generic_threat_cap_applied=false")
    Core.LogThrottle.Event("[XNP IMPACT SNAPSHOT] loaded_zombie_list_used=false")
    Core.LogThrottle.Event("[XNP IMPACT SNAPSHOT] reused_across_tick=false")
    Core.LogThrottle.Event("[XNP IMPACT DEDUPE] identity_mode=OBJECT_REFERENCE_OR_VERIFIED_ID")
    Core.LogThrottle.Event("[XNP IMPACT DEDUPE] before_sort=true before_quota=true")
    Core.LogThrottle.Event("[XNP IMPACT DEDUPE] duplicate_effect=false")
    Core.LogThrottle.Event("[XNP IMPACT DEDUPE] duplicate_cost=false")
    Core.LogThrottle.Event("[XNP IMPACT FRESHNESS] cross_tick_cache_reuse=false")
    Core.LogThrottle.Event("[XNP IMPACT FRESHNESS] low_fps_contract=FRAME_CORRECT")
end

function Impact.BuildNow(player, route, impactActive)
    logContractOnce()
    local frame = currentFrame()
    if not player or frame < 0 then return false, "NO_PLAYER_OR_FRAME" end
    if impactActive ~= true then return false, "IMPACT_GATE_INACTIVE" end
    if Impact.sampleFrame == frame then return true, "ALREADY_BUILT_THIS_TICK" end
    if not Core.CentralWorldQuery or Core.CentralWorldQuery.GetFrame() ~= frame then
        return false, "CENTRAL_WORLD_QUERY_NOT_FRESH"
    end

    local candidates = Core.CentralWorldQuery.GetImpactCandidates and Core.CentralWorldQuery.GetImpactCandidates() or {}
    Impact.candidates = candidates
    Impact.sampleFrame = frame
    Impact.sampleTime = nowSeconds()
    Impact.rawCount = Core.CentralWorldQuery.rawCount or #candidates
    Impact.identityCount = #candidates
    Impact.duplicateCount = Core.CentralWorldQuery.duplicateCount or 0
    Impact.evaluationClaims = {}
    Impact.precollisionEligibleCandidates = {}

    if Config.DEBUG == true then
        print("[XNP IMPACT DEDUPE] raw=" .. tostring(Impact.rawCount) .. " unique=" .. tostring(#candidates) .. " duplicates=" .. tostring(Impact.duplicateCount))
        print("[XNP IMPACT FRESHNESS] sample_frame=" .. tostring(frame) .. " evaluation_frame=pending same_tick=pending route=" .. tostring(route))
    end
    return true, "BUILT_FROM_CENTRAL_WORLD_QUERY"
end

function Impact.ValidateFreshSameTick()
    return Impact.sampleFrame >= 0 and Impact.sampleFrame == currentFrame()
end

function Impact.ClaimEvaluation(route)
    route = tostring(route or "UNKNOWN")
    if not Impact.ValidateFreshSameTick() or Impact.evaluationClaims[route] then
        return false
    end
    Impact.evaluationClaims[route] = true
    if Config.DEBUG == true then
        print("[XNP IMPACT FRESHNESS] sample_frame=" .. tostring(Impact.sampleFrame) .. " evaluation_frame=" .. tostring(currentFrame()) .. " same_tick=true route=" .. route)
    end
    return true
end

function Impact.RecordPrecollisionEligible(candidate)
    if Impact.ValidateFreshSameTick() and candidate then
        Impact.precollisionEligibleCandidates[#Impact.precollisionEligibleCandidates + 1] = candidate
    end
end

function Impact.GetPrecollisionEligibleCandidates()
    if not Impact.ValidateFreshSameTick() then return {} end
    return Impact.precollisionEligibleCandidates
end

function Impact.GetCandidates()
    if not Impact.ValidateFreshSameTick() then return {} end
    return Impact.candidates
end

function Impact.GetRawLocalImpactCandidates()
    return Impact.GetCandidates()
end

function Impact.GetSampleFrame() return Impact.sampleFrame end
function Impact.GetSampleTime() return Impact.sampleTime end
function Impact.GetIdentityCount() return Impact.identityCount end

Core.ImpactCandidateSnapshot = Impact
return Impact
