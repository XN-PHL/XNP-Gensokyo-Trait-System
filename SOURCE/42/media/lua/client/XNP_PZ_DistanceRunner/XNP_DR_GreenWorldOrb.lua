require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenHumanSafeClassifier"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenVisibleProxy"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWorldLight"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenCenterFire"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenCenterStructureBreak"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"

local Core = XNP_PZ_DistanceRunner

local Orb = {
    FINAL_GREEN_MODE = "MAP_HIDE_RENDER_BUDGET_LIGHT_POOL_TTL_UNIFY",
    GREEN_MULTIPLAYER_SCOPE = "SINGLEPLAYER_ONLY_FAIL_CLOSED",
    GREEN_ACTIVE_SKILL_MULTIPLAYER_ENABLED = false,
    GREEN_RUNTIME_ENTITY_RENDERING_ENABLED = false,
    GREEN_PROJECTILE_VISUAL = "PER_PLAYER_ZOOM_VIEWPORT_PROJECTED_DRAW_PROOF",
    DAMAGE_TYPE = "XNP_GREEN_INSTANT_TIERED_BLAST",
    DAMAGE_WEAPON = "XNP_PZ_DistanceRunner.GreenOrbRadialShock",
    activeCastsByPlayer = {},
    activeCastsById = {},
    activeCountGlobal = 0,
    peakActiveCountGlobal = 0,
    reservedTargetByPlayer = {},
    serial = 0,
    mapHidden = false,
    cooldownByPlayer = setmetatable({}, { __mode = "k" }),
    outlineOwners = setmetatable({}, { __mode = "k" }),
    outlineSerial = 0,
    failureLogged = {},
    multiplayerNoticeLogged = false,
    missingSoundLogged = {},
    queryCache = {},
    queryCacheHits = 0,
    queryCacheMisses = 0,
    targetSquareReads = 0,
    realTargetScans = 0,
    scanBudgetEpochMs = -1,
    scanBudgetUsed = 0,
    peakScanBudgetUsed = 0,
    vehicleSnapshotEpochMs = -1,
    vehicleSnapshot = {},
    simulationSquareCacheEpochMs = -1,
    simulationSquareCache = {},
    simulationSquareCacheHits = 0,
    simulationSquareCacheMisses = 0,
    simulationWorldObjectCache = setmetatable({}, { __mode = "k" }),
    simulationWorldObjectCacheHits = 0,
    simulationWorldObjectCacheMisses = 0,
    pendingImpacts = {},
    peakPendingImpacts = 0,
    maximumPendingImpacts = 80,
    pendingImpactMaximumAgeMs = 2000,
    cleanupCount = 0,
    timeoutCleanupCount = 0,
    doubleCleanupAttempts = 0,
    lastSuccessfulCastMsByPlayer = setmetatable({}, { __mode = "k" }),
    simulationClockByPlayer = setmetatable({}, { __mode = "k" }),
    simulationStepCount = 0,
    simulationOwnerCount = 1,
    perCastSimulationEventCount = 0,
    maximumCatchupStepsObserved = 0,
    droppedCatchupMs = 0,
}

local TURN_LEVEL_MAP = { [1] = 45, [2] = 90, [3] = 135, [4] = 180 }
local MAXIMUM_CATCHUP_STEPS_PER_FRAME = 3

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function normalizeInputTimestamp(inputTimestampMs)
    local value = tonumber(inputTimestampMs)
    if value == nil or value < 0 then value = nowMs() end
    return math.floor(value + 0.5)
end

local function rapidCastHeading(fallbackX, fallbackY, castSerial)
    local randomUnit = nil
    local method = "DETERMINISTIC_FALLBACK"
    if type(ZombRandFloat) == "function" then
        local ok, value = pcall(ZombRandFloat, 0.0, 1.0)
        value = ok and tonumber(value) or nil
        if value and value >= 0 and value < 1 then
            randomUnit = value
            method = "ZOMB_RAND_FLOAT"
        end
    end
    if randomUnit == nil and type(ZombRand) == "function" then
        local ok, value = pcall(ZombRand, 1000000)
        value = ok and tonumber(value) or nil
        if value and value >= 0 then
            randomUnit = (value % 1000000) / 1000000
            method = "ZOMB_RAND_INTEGER"
        end
    end
    if randomUnit == nil then
        randomUnit = ((tonumber(castSerial) or 0) * 0.618033988749895) % 1
    end
    local angle = randomUnit * 6.283185307179586
    local x, y = math.cos(angle), math.sin(angle)
    if x ~= x or y ~= y then return fallbackX, fallbackY, "PLAYER_FORWARD_FALLBACK" end
    return x, y, method
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function isType(object, className)
    if not object or type(instanceof) ~= "function" then return false end
    local ok, result = pcall(function() return instanceof(object, className) end)
    return ok and result == true
end

local function coordinate(object, method)
    local ok, value = invoke(object, method)
    return ok and tonumber(value) or nil
end

local function tuningBoolean(name, fallback)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean then
        return Core.SandboxTuning.GetBoolean(name, fallback)
    end
    return fallback == true
end

local function tuningNumber(name, fallback, minimum, maximum)
    if Core.SandboxTuning and Core.SandboxTuning.GetNumber then
        return Core.SandboxTuning.GetNumber(name, fallback, minimum, maximum)
    end
    return fallback
end

-- Called only at admission. Every active cast owns this immutable snapshot.
local function settings()
    local soundsEnabled = tuningBoolean("EnableSounds", true)
    local runtimeTestMode = tuningBoolean("GreenRuntimeTestModeEnabled", false)
    local values = {
        cooldownMs = tuningNumber("GreenCooldownSeconds", 5.0, 0.5, 120.0) * 1000,
        cooldownEnabled = tuningBoolean("GreenCooldownEnabled", true),
        runtimeTestMode = runtimeTestMode,
        testNoCooldown = runtimeTestMode and tuningBoolean("GreenRuntimeTestNoCooldown", false),
        testIgnoreResourceAdmission = runtimeTestMode
            and tuningBoolean("GreenRuntimeTestIgnoreResourceAdmission", false),
        testStillApplyCosts = runtimeTestMode
            and tuningBoolean("GreenRuntimeTestStillApplyCosts", true),
        testAllowMaxFatigue = runtimeTestMode
            and tuningBoolean("GreenRuntimeTestAllowCastAtMaxFatigue", false),
        testAllowZeroEndurance = runtimeTestMode
            and tuningBoolean("GreenRuntimeTestAllowCastAtZeroEndurance", false),
        targetRadius = tuningNumber("GreenTargetSearchRadiusTiles", 19.2, 1.0, 30.0),
        reacquisitionRadius = tuningNumber("GreenTargetReacquisitionRadiusTiles", 19.2, 1.0, 30.0),
        noTargetMs = tuningNumber("GreenNoTargetSearchSeconds", 3.0, 0.1, 10.0) * 1000,
        maximumFlightMs = tuningNumber("GreenMaximumFlightSeconds", 15.0, 0.5, 30.0) * 1000,
        visualMaximumFps = math.floor(
            tuningNumber("GreenVisualMaximumFPS", 60, 15, 60) + 0.5),
        simulationUpdatesPerSecond = math.floor(
            tuningNumber("GreenSimulationUpdatesPerSecond", 30, 20, 60) + 0.5),
        impactDistance = tuningNumber("GreenImpactDistanceTiles", 0.55, 0.1, 2.0),
        projectileArmRenderFrames = math.floor(
            tuningNumber("GreenProjectileArmRenderFrames", 1, 1, 30) + 0.5),
        impactDamageDelayMs = tuningNumber("GreenImpactDamageDelayMs", 0, 0, 1000),
        impactVisualLifetimeMs = tuningNumber("GreenImpactVisualLifetimeMs", 140, 40, 1000),
        impactVisualScale = tuningNumber("GreenImpactVisualScale", 1.0, 0.25, 4.0),
        launchForwardOffset = tuningNumber("GreenLaunchForwardOffsetTiles", 0, 0, 2.0),
        spawnAtExactPlayerPosition = tuningBoolean("GreenSpawnAtExactPlayerPosition", true),
        rapidCastRandomDirectionEnabled = tuningBoolean("GreenRapidCastRandomDirectionEnabled", true),
        rapidCastWindowMs = tuningNumber("GreenRapidCastWindowMs", 1000, 100, 5000),
        rapidCastRandomDirectionMode = math.floor(
            tuningNumber("GreenRapidCastRandomDirectionMode", 1, 1, 1) + 0.5),
        rapidCastSpawnAtExactPlayerPosition = tuningBoolean(
            "GreenRapidCastSpawnAtExactPlayerPosition", true),
        preLockCruiseSpeed = tuningNumber("GreenPreLockCruiseSpeedTilesPerSecond", 2.0, 0.1, 12.0),
        targetScanIntervalMs = tuningNumber("GreenTargetScanIntervalMs", 150, 50, 1000),
        targetScanStaggerEnabled = tuningBoolean("GreenTargetScanStaggerEnabled", true),
        queryCacheMs = tuningNumber("GreenTargetQueryCacheMs", 100, 50, 500),
        maximumTargetScansPerFrame = math.floor(
            tuningNumber("GreenMaximumTargetScansPerFrame", 2, 1, 8) + 0.5),
        performanceStatisticsEnabled = tuningBoolean("GreenPerformanceStatisticsEnabled", false),
        uniqueTargetReservationEnabled = tuningBoolean("GreenUniqueTargetReservationEnabled", true),
        maximumConcurrentCastsPerPlayer = math.floor(
            tuningNumber("GreenMaximumConcurrentCastsPerPlayer", 20, 1, 20) + 0.5),
        maximumConcurrentCastsGlobal = math.floor(
            tuningNumber("GreenMaximumConcurrentCastsGlobal", 40, 1, 80) + 0.5),
        dynamicAccelerationEnabled = tuningBoolean("GreenDynamicAccelerationEnabled", true),
        lockedAcceleration = tuningNumber(
            "GreenLockedAccelerationTilesPerSecondSquared", 1.10, 0.0, 10.0),
        lockedMaxSpeed = tuningNumber("GreenLockedMaxSpeedTilesPerSecond", 12.0, 4.0, 20.0),
        virtualHardCap = tuningNumber(
            "GreenMaximumVirtualSpeedTilesPerSecond", 12.0, 0.5, 30.0),
        lockedConstantSpeed = tuningNumber(
            "GreenLockedConstantSpeedTilesPerSecond", 4.50, 0.1, 30.0),
        accelerationBlendMs = tuningNumber("GreenAccelerationBlendMs", 300, 1, 3000),
        accelerationTimeToMaxMs = tuningNumber(
            "GreenAccelerationTimeToMaxSeconds", 6.0, 0.5, 15.0) * 1000,
        accelerationNoticeableByMs = tuningNumber(
            "GreenAccelerationNoticeableBySeconds", 1.5, 0.1, 5.0) * 1000,
        accelerationCurveMode = math.floor(
            tuningNumber("GreenAccelerationCurveMode", 1, 1, 1) + 0.5),
        targetLostDecelerationEnabled = tuningBoolean("GreenTargetLostDecelerationEnabled", true),
        targetLostDecelerationMs = tuningNumber(
            "GreenTargetLostDecelerationSeconds", 2.0, 0.25, 10.0) * 1000,
        targetLostMinimumSpeed = tuningNumber(
            "GreenTargetLostMinimumSpeedTilesPerSecond", 2.0, 0.1, 12.0),
        guidanceInertiaEnabled = tuningBoolean("GreenGuidanceInertiaEnabled", true),
        guidanceSampleIntervalMs = tuningNumber(
            "GreenGuidanceTargetSampleIntervalMs", 150, 50, 500),
        guidanceTurnLevel = math.floor(tuningNumber("GreenGuidanceTurnLevel", 4, 1, 4) + 0.5),
        guidanceRetargetAdaptationMs = tuningNumber(
            "GreenGuidanceRetargetAdaptationMs", 350, 0, 1500),
        guidanceTargetLostBallisticMs = tuningNumber(
            "GreenGuidanceTargetLostBallisticMs", 250, 0, 1000),
        guidanceLeadPredictionSeconds = tuningNumber(
            "GreenGuidanceLeadPredictionSeconds", 0.20, 0, 1),
        targetFlashEnabled = tuningBoolean("GreenTargetFlashEnabled", true),
        targetFlashIntervalMs = tuningNumber("GreenTargetFlashIntervalMs", 500, 100, 5000),
        targetFlashDurationMs = tuningNumber("GreenTargetFlashDurationMs", 120, 30, 1000),
        targetFlashStaggerEnabled = tuningBoolean("GreenTargetFlashStaggerEnabled", true),
        lethalRadius = tuningNumber("GreenLethalRadiusTiles", 3.5, 0.1, 15.0),
        knockdownRadius = tuningNumber("GreenKnockdownRadiusTiles", 7.0, 0.1, 20.0),
        outerKnockdownEnabled = tuningBoolean("GreenOuterKnockdownEnabled", true),
        explosionDamage = tuningNumber("GreenExplosionBaseDamage", 10.0, 0.1, 100.0),
        maximumTargetCount = math.floor(
            tuningNumber("GreenMaximumTargetCount", 0, 0, 128) + 0.5),
        npcDamageEnabled = tuningBoolean("GreenNPCDamageEnabled", true),
        banditDamageEnabled = tuningBoolean("GreenBanditDamageEnabled", true),
        wallBlocking = tuningBoolean("GreenWallBlockingEnabled", true),
        anyValidCollisionDetonationEnabled = tuningBoolean(
            "GreenAnyValidCollisionDetonationEnabled", true),
        collisionCharactersEnabled = tuningBoolean("GreenCollisionCharactersEnabled", true),
        collisionWorldSolidsEnabled = tuningBoolean("GreenCollisionWorldSolidsEnabled", true),
        collisionVehiclesEnabled = tuningBoolean("GreenCollisionVehiclesEnabled", true),
        collisionArmingDelayMs = tuningNumber("GreenCollisionArmingDelayMs", 250, 0, 1000),
        collisionArmingMinimumTravelTiles = tuningNumber(
            "GreenCollisionArmingMinimumTravelTiles", 0.75, 0, 2.0),
        spawnSafetyRadiusTiles = tuningNumber("GreenSpawnSafetyRadiusTiles", 0.85, 0.10, 2.0),
        collisionRadius = tuningNumber("GreenCollisionRadiusTiles", 0.45, 0.1, 1.5),
        collisionSweptTestEnabled = tuningBoolean("GreenCollisionSweptTestEnabled", true),
        refundNoTarget = tuningBoolean("GreenRefundCooldownOnNoTarget", true),
        fatigueCostEnabled = tuningBoolean("GreenCastFatigueCostEnabled", true),
        fatigueCostPercent = tuningNumber("GreenCastFatigueCostPercent", 30, 0, 100),
        enduranceCostEnabled = tuningBoolean("GreenCastEnduranceCostEnabled", true),
        enduranceCostPercent = tuningNumber("GreenCastEnduranceCostPercent", 5, 0, 100),
        castSound = soundsEnabled and tuningBoolean("GreenCastSoundEnabled", true),
        impactSound = soundsEnabled and tuningBoolean("GreenImpactSoundEnabled", true),
        impactSoundVolumePercent = tuningNumber(
            "GreenImpactSoundVolumePercent", 100, 0, 100),
        spinEnabled = tuningBoolean("GreenOrbSpinEnabled", true),
        spinDegreesPerSecond = tuningNumber("GreenOrbSpinDegreesPerSecond", 220, 0, 1080),
        spinFrameCount = math.floor(tuningNumber("GreenOrbSpinFrameCount", 16, 1, 16) + 0.5),
        glowPulseEnabled = tuningBoolean("GreenOrbGlowPulseEnabled", true),
        glowPulseHz = tuningNumber("GreenOrbGlowPulseHz", 3.0, 0.1, 12.0),
        glowJitterEnabled = tuningBoolean("GreenOrbGlowJitterEnabled", true),
        glowJitterPixels = tuningNumber("GreenOrbGlowJitterPixels", 1.5, 0, 6.0),
        glowOrbitPixels = tuningNumber("GreenOrbGlowOrbitPixels", 1.0, 0, 6.0),
        glowMinAlpha = tuningNumber("GreenOrbGlowMinAlpha", 0.42, 0, 1),
        glowMaxAlpha = tuningNumber("GreenOrbGlowMaxAlpha", 0.90, 0, 1),
        inflightDiagnosticBorder = tuningBoolean("GreenInflightDiagnosticBorderEnabled", false),
        dynamicLightEnabled = tuningBoolean("GreenDynamicLightEnabled", true),
        dynamicLightFlightEnabled = tuningBoolean("GreenDynamicLightFlightEnabled", true),
        dynamicLightFollowEnabled = tuningBoolean("GreenDynamicLightFollowEnabled", true),
        dynamicLightImpactEnabled = tuningBoolean("GreenDynamicLightImpactEnabled", true),
        dynamicLightRadius = tuningNumber("GreenDynamicLightRadiusTiles", 3, 1, 12),
        dynamicLightIntensity = tuningNumber("GreenDynamicLightIntensityPercent", 70, 1, 100) / 100,
        dynamicLightUpdateIntervalMs = tuningNumber("GreenDynamicLightUpdateIntervalMs", 150, 50, 1000),
        maximumActiveDynamicLights = math.floor(
            tuningNumber("GreenMaximumActiveDynamicLights", 6, 1, 20) + 0.5),
        dynamicLightRed = tuningNumber("GreenDynamicLightRed", 0.08, 0, 1),
        dynamicLightGreen = tuningNumber("GreenDynamicLightGreen", 1.0, 0, 1),
        dynamicLightBlue = tuningNumber("GreenDynamicLightBlue", 0.18, 0, 1),
        impactDynamicLightRadius = tuningNumber("GreenImpactDynamicLightRadiusTiles", 5, 1, 15),
        impactDynamicLightIntensity = tuningNumber(
            "GreenImpactDynamicLightIntensityPercent", 100, 1, 100) / 100,
        impactDynamicLightLifetimeMs = tuningNumber(
            "GreenImpactDynamicLightLifetimeMs", 220, 50, 2000),
        centerFireEnabled = tuningBoolean("GreenCenterFireEnabled", true),
        centerFireSingleSquareOnly = tuningBoolean("GreenCenterFireSingleSquareOnly", true),
        centerFireAllowManualPropagation = tuningBoolean(
            "GreenCenterFireAllowManualPropagation", false),
        centerFireStrength = tuningNumber("GreenCenterFireStrength", 5, 5, 100),
        centerFireLifetimeSeconds = tuningNumber("GreenCenterFireLifetimeSeconds", 8.33, 1, 60),
        centerStructureBreakEnabled = tuningBoolean("GreenCenterStructureBreakEnabled", true),
        centerStructureBreakRadius = tuningNumber("GreenCenterStructureBreakRadiusTiles", 1.5, 0.5, 3),
        centerBreakWindowsEnabled = tuningBoolean("GreenCenterBreakWindowsEnabled", true),
        centerBreakGlassDoorsEnabled = tuningBoolean("GreenCenterBreakGlassDoorsEnabled", true),
        centerBreakDoorsEnabled = tuningBoolean("GreenCenterBreakDoorsEnabled", true),
        centerBreakWallsEnabled = false,
        centerBreakFurnitureEnabled = false,
    }
    values.guidanceMaxTurnRateDegPerSecond = TURN_LEVEL_MAP[values.guidanceTurnLevel] or 180
    values.lockedMaxSpeed = math.min(values.lockedMaxSpeed, values.virtualHardCap)
    return values
end

function Orb.IsRuntimeTestModeEnabled()
    return tuningBoolean("GreenRuntimeTestModeEnabled", false) == true
end

local function playerNumber(player)
    local ok, value = invoke(player, "getPlayerNum")
    if not ok then return 0 end
    return math.max(0, math.floor(tonumber(value) or 0))
end

local function tableCount(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
end

local function castBucket(playerNum, create)
    local bucket = Orb.activeCastsByPlayer[playerNum]
    if not bucket and create then
        bucket = {}
        Orb.activeCastsByPlayer[playerNum] = bucket
    end
    return bucket
end

local function reservationBucket(playerNum, create)
    local bucket = Orb.reservedTargetByPlayer[playerNum]
    if not bucket and create then
        bucket = {}
        Orb.reservedTargetByPlayer[playerNum] = bucket
    end
    return bucket
end

local function registerCast(state)
    local bucket = castBucket(state.playerNum, true)
    if bucket[state.id] ~= nil or Orb.activeCastsById[state.id] ~= nil then
        return false, "DUPLICATE_CAST_ID"
    end
    bucket[state.id] = state
    Orb.activeCastsById[state.id] = state
    Orb.activeCountGlobal = Orb.activeCountGlobal + 1
    Orb.peakActiveCountGlobal = math.max(Orb.peakActiveCountGlobal, Orb.activeCountGlobal)
    return true, "CAST_SLOT_RESERVED"
end

local function unregisterCast(state)
    if not state or state.id == nil then return false, "STATE_OR_ID_MISSING" end
    local removed = false
    local bucket = castBucket(state.playerNum, false)
    if bucket and bucket[state.id] == state then
        bucket[state.id] = nil
        removed = true
        if tableCount(bucket) == 0 then Orb.activeCastsByPlayer[state.playerNum] = nil end
    end
    if Orb.activeCastsById[state.id] == state then
        Orb.activeCastsById[state.id] = nil
        Orb.activeCountGlobal = math.max(0, Orb.activeCountGlobal - 1)
        removed = true
    end
    return removed, removed and "CAST_UNREGISTERED" or "IDENTITY_NOT_OWNED"
end

local function castSnapshot(playerNum)
    local result = {}
    for _, state in pairs(castBucket(playerNum, false) or {}) do result[#result + 1] = state end
    table.sort(result, function(a, b) return (a.id or 0) < (b.id or 0) end)
    return result
end

local function allCastSnapshot()
    local result = {}
    for _, state in pairs(Orb.activeCastsById) do result[#result + 1] = state end
    table.sort(result, function(a, b) return (a.id or 0) < (b.id or 0) end)
    return result
end

local function targetIdentity(target)
    for _, method in ipairs({ "getOnlineID", "getID" }) do
        local ok, value = invoke(target, method)
        if ok and value ~= nil and tonumber(value) ~= -1 then
            return method .. ":" .. tostring(value)
        end
    end
    return "object:" .. tostring(target)
end

local function releaseReservation(state)
    if not state or not state.reservedTargetIdentity then return false end
    local bucket = reservationBucket(state.playerNum, false)
    if bucket and bucket[state.reservedTargetIdentity] == state.id then
        bucket[state.reservedTargetIdentity] = nil
        if tableCount(bucket) == 0 then Orb.reservedTargetByPlayer[state.playerNum] = nil end
    end
    state.reservedTargetIdentity = nil
    return true
end

local function reserveTarget(state, target)
    if state.options.uniqueTargetReservationEnabled ~= true then return true, "RESERVATION_DISABLED" end
    local identity = targetIdentity(target)
    local bucket = reservationBucket(state.playerNum, true)
    local owner = bucket[identity]
    if owner ~= nil and owner ~= state.id then return false, "TARGET_RESERVED_BY_OTHER_CAST" end
    bucket[identity] = state.id
    state.reservedTargetIdentity = identity
    return true, "TARGET_RESERVED_PER_PLAYER"
end

local function normalized(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0.0001 then return nil, nil, 0 end
    return dx / length, dy / length, length
end

local function vectorComponent(vector, field, method)
    if not vector then return nil end
    local direct = tonumber(vector[field])
    if direct then return direct end
    local ok, value = invoke(vector, method)
    return ok and tonumber(value) or nil
end

local function playerForward(player)
    local aimingOk, aiming = invoke(player, "isAiming")
    local ok, vector = invoke(player, "getForwardDirection")
    if ok and vector then
        local x = vectorComponent(vector, "x", "getX")
        local y = vectorComponent(vector, "y", "getY")
        local nx, ny = normalized(x or 0, y or 0)
        if nx then
            return nx, ny, aimingOk and aiming == true
                and "AIM_FACING_DIRECTION_AT_RELEASE" or "PLAYER_FORWARD_DIRECTION_AT_RELEASE"
        end
    end
    return 1.0, 0.0, "SAFE_EAST_FALLBACK_AT_RELEASE"
end

local function damagePolicy(options)
    return {
        npcDamageEnabled = options and options.npcDamageEnabled == true,
        banditDamageEnabled = options and options.banditDamageEnabled == true,
        playerDamageEnabled = false,
    }
end

local function validTarget(target, options)
    if not target or isType(target, "IsoPlayer") then return false end
    if not isType(target, "IsoZombie") and not isType(target, "IsoGameCharacter") then return false end
    local fromZombieRegistry = isType(target, "IsoZombie")
    local classification = Core.GreenHumanSafeClassifier.Classify(target, fromZombieRegistry)
    if Core.GreenHumanSafeClassifier.IsDamageAllowed(classification, damagePolicy(options)) ~= true then
        return false
    end
    local ok, dead = invoke(target, "isDead")
    if ok and dead == true then return false end
    local health = coordinate(target, "getHealth")
    return health == nil or health > 0
end

local function candidateCacheKey(originX, originY, originZ, radius)
    return tostring(math.floor(originX * 2)) .. ":" .. tostring(math.floor(originY * 2))
        .. ":" .. tostring(math.floor(originZ)) .. ":" .. string.format("%.2f", radius)
end

local function copyAndMeasureCandidates(raw, originX, originY, originZ, radius, options)
    local entries = {}
    local policy = damagePolicy(options)
    for _, target in ipairs(raw or {}) do
        local x = coordinate(target, "getX")
        local y = coordinate(target, "getY")
        local z = coordinate(target, "getZ")
        if x and y and z and math.abs(z - originZ) < 0.6 then
            local dx, dy = x - originX, y - originY
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance <= radius then
                local classification = Core.GreenHumanSafeClassifier.Classify(
                    target, isType(target, "IsoZombie"))
                entries[#entries + 1] = {
                    target = target,
                    dx = dx,
                    dy = dy,
                    distance = distance,
                    classification = classification,
                    damageAllowed = Core.GreenHumanSafeClassifier.IsDamageAllowed(classification, policy),
                }
            end
        end
    end
    return entries
end

local function listItems(list)
    local items = {}
    if not list or type(list.size) ~= "function" or type(list.get) ~= "function" then
        return items
    end
    local sizeOk, size = pcall(function() return list:size() end)
    size = sizeOk and math.max(0, math.floor(tonumber(size) or 0)) or 0
    for index = 0, size - 1 do
        local itemOk, item = pcall(function() return list:get(index) end)
        if itemOk and item then items[#items + 1] = item end
    end
    return items
end

local function simulationSquareKey(x, y, z)
    return tostring(math.floor(x)) .. ":" .. tostring(math.floor(y)) .. ":" .. tostring(math.floor(z))
end

local function simulationSquareRecord(cell, x, y, z)
    local key = simulationSquareKey(x, y, z)
    local cached = Orb.simulationSquareCache[key]
    if cached then
        Orb.simulationSquareCacheHits = Orb.simulationSquareCacheHits + 1
        return cached
    end
    Orb.simulationSquareCacheMisses = Orb.simulationSquareCacheMisses + 1
    Orb.targetSquareReads = Orb.targetSquareReads + 1
    local squareOk, square = pcall(function()
        return cell:getGridSquare(math.floor(x), math.floor(y), math.floor(z))
    end)
    local moving = {}
    if squareOk and square then
        local listOk, list = invoke(square, "getMovingObjects")
        if listOk then moving = listItems(list) end
    end
    local record = { square = squareOk and square or nil, moving = moving }
    Orb.simulationSquareCache[key] = record
    return record
end

local function scanSquareTargets(originX, originY, originZ, radius)
    local targets = {}
    local seen = setmetatable({}, { __mode = "k" })
    if type(getCell) ~= "function" then return targets, "CELL_API_UNAVAILABLE" end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell or type(cell.getGridSquare) ~= "function" then
        return targets, "CELL_UNAVAILABLE"
    end
    local level = math.floor(originZ)
    for x = math.floor(originX - radius), math.ceil(originX + radius) do
        for y = math.floor(originY - radius), math.ceil(originY + radius) do
            local record = simulationSquareRecord(cell, x, y, level)
            for _, item in ipairs(record.moving) do
                if item and not seen[item] and not isType(item, "IsoPlayer")
                    and (isType(item, "IsoZombie") or isType(item, "IsoGameCharacter")) then
                    seen[item] = true
                    targets[#targets + 1] = item
                end
            end
        end
    end
    return targets, "PROJECTILE_CENTERED_LOCAL_SQUARE_SCAN"
end

local function resetScanBudget(now)
    if Orb.scanBudgetEpochMs ~= now then
        Orb.scanBudgetEpochMs = now
        Orb.scanBudgetUsed = 0
        Orb.simulationSquareCacheEpochMs = now
        Orb.simulationSquareCache = {}
        Orb.simulationWorldObjectCache = setmetatable({}, { __mode = "k" })
    end
end

local function candidateEntries(originX, originY, originZ, radius, options, now)
    local key = candidateCacheKey(originX, originY, originZ, radius)
    local cached = Orb.queryCache[key]
    if cached and now - cached.at <= options.queryCacheMs then
        Orb.queryCacheHits = Orb.queryCacheHits + 1
        return copyAndMeasureCandidates(cached.targets, originX, originY, originZ, radius, options),
            "SHARED_QUERY_CACHE"
    end
    if Orb.scanBudgetUsed >= options.maximumTargetScansPerFrame then
        return nil, "REAL_SCAN_BUDGET_DEFERRED"
    end
    Orb.scanBudgetUsed = Orb.scanBudgetUsed + 1
    Orb.peakScanBudgetUsed = math.max(Orb.peakScanBudgetUsed, Orb.scanBudgetUsed)
    Orb.queryCacheMisses = Orb.queryCacheMisses + 1
    Orb.realTargetScans = Orb.realTargetScans + 1
    local targets, method = scanSquareTargets(originX, originY, originZ, radius)
    Orb.queryCache[key] = { at = now, targets = targets }
    return copyAndMeasureCandidates(targets, originX, originY, originZ, radius, options), method
end

local function targetScore(entry)
    return -entry.distance
end

local function nearestTarget(state, now)
    local radius = state.everLocked and state.options.reacquisitionRadius
        or state.options.targetRadius
    local entries, scanMethod = candidateEntries(state.world_x, state.world_y, state.world_z,
        radius, state.options, now)
    if not entries then return nil, scanMethod end
    local selected, selectedScore = nil, nil
    local reserved = reservationBucket(state.playerNum, false) or {}
    for _, entry in ipairs(entries) do
        local identity = targetIdentity(entry.target)
        local occupied = reserved[identity]
        if entry.damageAllowed and validTarget(entry.target, state.options)
            and (occupied == nil or occupied == state.id) then
            local score = targetScore(entry)
            if selectedScore == nil or score > selectedScore then
                selected, selectedScore = entry.target, score
            end
        end
    end
    if selected then return selected, scanMethod .. ":UNRESERVED_NEAREST" end
    return nil, "NO_UNRESERVED_DAMAGE_ALLOWED_TARGET"
end

local function currentSquare(x, y, z)
    if type(getCell) ~= "function" then return nil end
    local okCell, cell = pcall(getCell)
    if not okCell or not cell or type(cell.getGridSquare) ~= "function" then return nil end
    return simulationSquareRecord(cell, x, y, z).square
end

local function blockedBetween(x, y, z, nextX, nextY)
    local current = currentSquare(x, y, z)
    local target = currentSquare(nextX, nextY, z)
    if not current or not target then return true end
    if current == target then return false end
    if type(current.isBlockedTo) ~= "function" then return false end
    local ok, blocked = pcall(function() return current:isBlockedTo(target) end)
    return ok and blocked == true
end

local function segmentPointDistance(x1, y1, x2, y2, px, py)
    local vx, vy = x2 - x1, y2 - y1
    local wx, wy = px - x1, py - y1
    local lengthSquared = vx * vx + vy * vy
    local t = 0
    if lengthSquared > 0.0000001 then
        t = math.max(0, math.min((wx * vx + wy * vy) / lengthSquared, 1))
    end
    local nearestX, nearestY = x1 + vx * t, y1 + vy * t
    local dx, dy = px - nearestX, py - nearestY
    return math.sqrt(dx * dx + dy * dy), t
end

local function firstBoolean(object, methods)
    for _, method in ipairs(methods) do
        local ok, value = invoke(object, method)
        if ok and type(value) == "boolean" then return value end
    end
    return nil
end

local function worldObjectKind(object, allowVehicle)
    if not object then return nil end
    if isType(object, "BaseVehicle") then
        return allowVehicle == true and "VEHICLE" or nil
    end
    if isType(object, "IsoDoor") then
        return firstBoolean(object, { "IsOpen", "isOpen" }) == true and nil or "DOOR"
    end
    if isType(object, "IsoWindow") then
        if firstBoolean(object, { "isSmashed" }) == true
            or firstBoolean(object, { "IsOpen", "isOpen" }) == true then return nil end
        return "WINDOW"
    end
    if isType(object, "IsoThumpable") then
        if firstBoolean(object, { "IsOpen", "isOpen" }) == true then return nil end
        if firstBoolean(object, { "isHoppable" }) == true then return "FENCE" end
        return "THUMPABLE"
    end
    if isType(object, "IsoBarricade") then return "OTHER_SOLID" end
    local spriteOk, sprite = invoke(object, "getSprite")
    local propsOk, props = false, nil
    if spriteOk then
        local actualPropsOk, actualProps = invoke(sprite, "getProperties")
        propsOk, props = actualPropsOk, actualProps
    end
    if propsOk and props then
        for _, flag in ipairs({ "WallN", "WallW", "WallNW", "collideN", "collideW" }) do
            local ok, present = invoke(props, "Is", flag)
            if ok and present == true then return "WALL" end
        end
    end
    return nil
end

local function firstWorldKindOnSquare(square, allowVehicle)
    if not square then return nil end
    local byMode = Orb.simulationWorldObjectCache[square]
    if not byMode then
        byMode = {}
        Orb.simulationWorldObjectCache[square] = byMode
    end
    local mode = allowVehicle == true and "WITH_VEHICLES" or "WITHOUT_VEHICLES"
    if byMode[mode] then
        Orb.simulationWorldObjectCacheHits = Orb.simulationWorldObjectCacheHits + 1
        return byMode[mode].kind, byMode[mode].object
    end
    Orb.simulationWorldObjectCacheMisses = Orb.simulationWorldObjectCacheMisses + 1
    local seen = setmetatable({}, { __mode = "k" })
    for _, method in ipairs({ "getSpecialObjects", "getObjects", "getMovingObjects" }) do
        local ok, list = invoke(square, method)
        if ok then
            for _, object in ipairs(listItems(list)) do
                if not seen[object] then
                    seen[object] = true
                    local kind = worldObjectKind(object, allowVehicle)
                    if kind then
                        byMode[mode] = { kind = kind, object = object }
                        return kind, object
                    end
                end
            end
        end
    end
    byMode[mode] = { kind = nil, object = nil }
    return nil
end

local function collisionCharacterKind(state, object)
    if not object or object == state.player then return nil end
    if not isType(object, "IsoZombie") and not isType(object, "IsoGameCharacter") then return nil end
    local deadOk, dead = invoke(object, "isDead")
    if deadOk and dead == true then return nil end
    local health = coordinate(object, "getHealth")
    if health ~= nil and health <= 0 then return nil end
    local classification = Core.GreenHumanSafeClassifier.Classify(
        object, isType(object, "IsoZombie"))
    if classification.kind == Core.GreenHumanSafeClassifier.BANDIT then return "BANDIT" end
    if classification.kind == Core.GreenHumanSafeClassifier.HUMAN_NPC then return "NPC" end
    if classification.kind == Core.GreenHumanSafeClassifier.PLAYER then return "HUMAN_CHARACTER" end
    if isType(object, "IsoZombie") then
        return object == state.target and "LOCKED_TARGET" or "UNLOCKED_ZOMBIE"
    end
    return "HUMAN_CHARACTER"
end

local function segmentCharacterCollision(state, x1, y1, x2, y2, armed, spawnSafetyExpired)
    if type(getCell) ~= "function" then return nil end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell or type(cell.getGridSquare) ~= "function" then return nil end
    local radius = state.options.collisionRadius
    local minX, maxX = math.floor(math.min(x1, x2) - radius), math.ceil(math.max(x1, x2) + radius)
    local minY, maxY = math.floor(math.min(y1, y2) - radius), math.ceil(math.max(y1, y2) + radius)
    local level = math.floor(state.world_z)
    local seen = setmetatable({}, { __mode = "k" })
    local best = nil
    for x = minX, maxX do
        for y = minY, maxY do
            local record = simulationSquareRecord(cell, x, y, level)
            if record.square then
                for _, object in ipairs(record.moving) do
                    if not seen[object] then
                        seen[object] = true
                        local kind = collisionCharacterKind(state, object)
                        local px, py = coordinate(object, "getX"), coordinate(object, "getY")
                        local spawnOverlap = state.spawnOverlapCharacters
                            and state.spawnOverlapCharacters[object] == true
                        if kind and spawnOverlap and spawnSafetyExpired ~= true then
                            kind = nil
                        elseif spawnOverlap and spawnSafetyExpired == true then
                            state.spawnOverlapCharacters[object] = nil
                        end
                        if kind and px and py then
                            local distance, fraction = segmentPointDistance(x1, y1, x2, y2, px, py)
                            if distance <= radius and (not best or fraction < best.fraction) then
                                best = { kind = kind, object = object, fraction = fraction,
                                    x = x1 + (x2 - x1) * fraction,
                                    y = y1 + (y2 - y1) * fraction }
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function vehicleItemsForEpoch(cell, now)
    if Orb.vehicleSnapshotEpochMs == now then return Orb.vehicleSnapshot end
    local listOk, vehicles = invoke(cell, "getVehicles")
    Orb.vehicleSnapshotEpochMs = now
    Orb.vehicleSnapshot = listOk and listItems(vehicles) or {}
    return Orb.vehicleSnapshot
end

local function segmentVehicleCollision(state, x1, y1, x2, y2, now)
    if state.options.collisionVehiclesEnabled ~= true or type(getCell) ~= "function" then return nil end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell then return nil end
    local best = nil
    for _, vehicle in ipairs(vehicleItemsForEpoch(cell, now)) do
        local vx, vy = coordinate(vehicle, "getX"), coordinate(vehicle, "getY")
        if vx and vy then
            local distance, fraction = segmentPointDistance(x1, y1, x2, y2, vx, vy)
            if distance <= state.options.collisionRadius + 0.75
                and (not best or fraction < best.fraction) then
                best = { kind = "VEHICLE", object = vehicle, fraction = fraction,
                    x = x1 + (x2 - x1) * fraction,
                    y = y1 + (y2 - y1) * fraction }
            end
        end
    end
    return best
end

local function segmentWorldCollision(state, x1, y1, x2, y2)
    if state.options.collisionWorldSolidsEnabled ~= true or state.options.wallBlocking ~= true then
        return nil
    end
    local _, _, length = normalized(x2 - x1, y2 - y1)
    local sampleStep = state.options.collisionSweptTestEnabled == true
        and math.max(0.10, math.min(state.options.collisionRadius * 0.5, 0.25))
        or math.max(length, 0.001)
    local steps = math.max(1, math.ceil(length / sampleStep))
    local previousX, previousY = x1, y1
    for index = 1, steps do
        local fraction = index / steps
        local x = x1 + (x2 - x1) * fraction
        local y = y1 + (y2 - y1) * fraction
        local previousTileX, previousTileY = math.floor(previousX), math.floor(previousY)
        local tileX, tileY = math.floor(x), math.floor(y)
        local changedSquare = previousTileX ~= tileX or previousTileY ~= tileY
        local blocked = changedSquare and blockedBetween(
            previousX, previousY, state.world_z, x, y)
        local kind, object = nil, nil
        if changedSquare then
            kind, object = firstWorldKindOnSquare(
                currentSquare(x, y, state.world_z), state.options.collisionVehiclesEnabled)
            if not kind then
                kind, object = firstWorldKindOnSquare(
                    currentSquare(previousX, previousY, state.world_z),
                    state.options.collisionVehiclesEnabled)
            end
        end
        if blocked or kind then
            return { kind = kind or "WALL",
                object = object, fraction = fraction, x = x, y = y }
        end
        previousX, previousY = x, y
    end
    return nil
end

local function collisionArmed(state, now, travelAfter)
    return now - state.startedMs >= state.options.collisionArmingDelayMs
        or travelAfter >= state.options.collisionArmingMinimumTravelTiles
end

local function collectSpawnOverlapCharacters(state)
    local overlaps = setmetatable({}, { __mode = "k" })
    if type(getCell) ~= "function" then return overlaps, 0 end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell or type(cell.getGridSquare) ~= "function" then return overlaps, 0 end
    local radius = state.options.spawnSafetyRadiusTiles
    local extent = math.ceil(radius)
    local z = math.floor(state.world_z + 0.5)
    local seen, count = setmetatable({}, { __mode = "k" }), 0
    for x = math.floor(state.spawn_x) - extent, math.floor(state.spawn_x) + extent do
        for y = math.floor(state.spawn_y) - extent, math.floor(state.spawn_y) + extent do
            local squareOk, square = pcall(function() return cell:getGridSquare(x, y, z) end)
            local movingOk, moving = invoke(squareOk and square or nil, "getMovingObjects")
            local size = 0
            if movingOk and moving and type(moving.size) == "function" then
                local sizeOk, value = pcall(function() return moving:size() end)
                size = sizeOk and tonumber(value) or 0
            end
            for index = 0, size - 1 do
                local itemOk, object = pcall(function() return moving:get(index) end)
                if itemOk and object and not seen[object] and isType(object, "IsoZombie") then
                    seen[object] = true
                    local ox, oy = coordinate(object, "getX"), coordinate(object, "getY")
                    if ox and oy then
                        local dx, dy = ox - state.spawn_x, oy - state.spawn_y
                        if dx * dx + dy * dy <= radius * radius then
                            overlaps[object] = true
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    return overlaps, count
end

local function firstValidCollision(state, x1, y1, x2, y2, now, travelAfter)
    if state.options.anyValidCollisionDetonationEnabled ~= true then return nil end
    local best = segmentWorldCollision(state, x1, y1, x2, y2)
    local vehicle = segmentVehicleCollision(state, x1, y1, x2, y2, now)
    if vehicle and (not best or vehicle.fraction < best.fraction) then best = vehicle end
    if state.options.collisionCharactersEnabled == true then
        local armed = collisionArmed(state, now, travelAfter)
        local spawnSafetyExpired = armed
            and travelAfter >= state.options.spawnSafetyRadiusTiles
        local character = segmentCharacterCollision(state, x1, y1, x2, y2,
            armed, spawnSafetyExpired)
        if character and (not best or character.fraction < best.fraction) then best = character end
    end
    if best then
        best.guidanceTargetMatch = best.object ~= nil and best.object == state.target
        best.swept = state.options.collisionSweptTestEnabled == true
    end
    return best
end

local function angleDelta(from, target)
    local delta = target - from
    while delta > math.pi do delta = delta - math.pi * 2 end
    while delta < -math.pi do delta = delta + math.pi * 2 end
    return delta
end

local function clearTargetFlash(state)
    local record = state and state.targetFlashRecord or nil
    if not record then return true, "NO_FLASH_OWNED" end
    state.targetFlashRecord = nil
    state.targetFlashEndsMs = nil
    if record.target and Orb.outlineOwners[record.target] == record.token then
        local highlightOk, highlighted = invoke(record.target, "isOutlineHighlight", record.playerNum)
        local colorOk, color = invoke(record.target, "getOutlineHighlightCol", record.playerNum)
        if highlightOk and highlighted == true and colorOk and color == record.ownedColor then
            invoke(record.target, "setOutlineHighlight", record.playerNum, false)
        end
        Orb.outlineOwners[record.target] = nil
    end
    return true, "OWNED_FLASH_RELEASED_OR_EXTERNAL_TAKEOVER_PRESERVED"
end

local function updateTargetFlash(state, now)
    if state.targetFlashEndsMs and now >= state.targetFlashEndsMs then clearTargetFlash(state) end
    if state.mapHidden == true then
        clearTargetFlash(state)
        return
    end
    if state.options.targetFlashEnabled ~= true or not state.target then return end
    if now < (state.nextTargetFlashMs or 0) then return end
    clearTargetFlash(state)
    state.nextTargetFlashMs = now + state.options.targetFlashIntervalMs
    local target = state.target
    local playerNum = state.playerNum
    local existingOk, existing = invoke(target, "isOutlineHighlight", playerNum)
    if not existingOk or existing == true then return end
    Orb.outlineSerial = Orb.outlineSerial + 1
    local token = "xnp-green-target-flash-" .. tostring(state.id) .. "-" .. tostring(Orb.outlineSerial)
    local colorOk = invoke(target, "setOutlineHighlightCol", playerNum, 0.08, 1.0, 0.18, 1.0)
    local outlineOk = invoke(target, "setOutlineHighlight", playerNum, true)
    local ownedColorOk, ownedColor = invoke(target, "getOutlineHighlightCol", playerNum)
    if colorOk and outlineOk and ownedColorOk then
        Orb.outlineOwners[target] = token
        state.targetFlashRecord = {
            target = target,
            token = token,
            playerNum = playerNum,
            ownedColor = ownedColor,
        }
        state.targetFlashEndsMs = now + state.options.targetFlashDurationMs
    elseif outlineOk then
        invoke(target, "setOutlineHighlight", playerNum, false)
    end
end

local function setTarget(state, target, source, now)
    if state.target == target then return true, "TARGET_UNCHANGED" end
    clearTargetFlash(state)
    releaseReservation(state)
    state.target = nil
    if not target then
        state.targetSource = source
        state.lostTargetStartedMs = now
        state.lostDecelStartSpeed = state.speed
        state.noTargetSinceMs = state.everLocked and nil or (state.noTargetSinceMs or now)
        state.phase = state.everLocked and "TARGET_LOST_DECELERATING" or "CRUISE_SEARCHING"
        return true, "TARGET_CLEARED"
    end
    local reserved, reason = reserveTarget(state, target)
    if not reserved then return false, reason end
    local previousIdentity = state.previousTargetIdentity
    local identity = targetIdentity(target)
    if previousIdentity and previousIdentity ~= identity then
        state.retargetCount = state.retargetCount + 1
        state.retargetStartedMs = now
    end
    state.previousTargetIdentity = identity
    state.target = target
    state.everLocked = true
    state.targetSource = source
    state.lostTargetStartedMs = nil
    state.noTargetSinceMs = nil
    state.nextTargetSampleMs = now
    if state.firstLockMs == nil then state.firstLockMs = now end
    state.lockSpeedRampStartedMs = now
    state.lockSpeedRampStartSpeed = state.speed
    state.phase = "LOCKED_HOMING"
    return true, reason
end

local function preflightCosts(state)
    local requested = {
        { name = "fatigue", percent = state.options.fatigueCostEnabled
                and state.options.fatigueCostPercent or 0,
            enum = CharacterStat and CharacterStat.FATIGUE or nil, direction = 1 },
        { name = "endurance", percent = state.options.enduranceCostEnabled
                and state.options.enduranceCostPercent or 0,
            enum = CharacterStat and CharacterStat.ENDURANCE or nil, direction = -1 },
    }
    state.costs = {}
    state.costResults = {
        fatigue = { result = "DISABLED", requestedDelta = 0 },
        endurance = { result = "DISABLED", requestedDelta = 0 },
    }
    if state.options.runtimeTestMode == true
        and state.options.testStillApplyCosts ~= true then
        return true, "TEST_MODE_COST_APPLICATION_DISABLED"
    end
    local any = false
    for _, item in ipairs(requested) do if item.percent > 0 then any = true end end
    if not any then return true, "ZERO_COST" end
    if not Core.Authority or type(Core.Authority.CanWriteNonFoodStats) ~= "function" then
        return false, "COST_AUTHORITY_API_UNAVAILABLE"
    end
    local allowed, authorityReason = Core.Authority.CanWriteNonFoodStats(state.player, "GREEN_CAST_COST")
    if allowed ~= true then return false, authorityReason end
    local statsOk, stats = invoke(state.player, "getStats")
    if not statsOk or not stats then return false, "STATS_API_UNAVAILABLE" end
    for _, item in ipairs(requested) do
        if item.percent > 0 then
            if not item.enum then return false, string.upper(item.name) .. "_STAT_ENUM_UNAVAILABLE" end
            local readOk, before = invoke(stats, "get", item.enum)
            before = readOk and tonumber(before) or nil
            if before == nil then return false, string.upper(item.name) .. "_READ_FAILED" end
            local delta = math.max(0, math.min(item.percent / 100, 1)) * item.direction
            local after = math.max(0, math.min(before + delta, 1))
            local saturatedNoOp = math.abs(after - before) <= 0.001
                and ((item.direction > 0 and before >= 0.999)
                    or (item.direction < 0 and before <= 0.001))
            local runtimeTest = state.options.runtimeTestMode == true
            local ignoreAllAdmission = runtimeTest
                and state.options.testIgnoreResourceAdmission == true
            local ignoreThisAdmission = ignoreAllAdmission
                or (runtimeTest and item.name == "fatigue"
                    and state.options.testAllowMaxFatigue == true)
                or (runtimeTest and item.name == "endurance"
                    and state.options.testAllowZeroEndurance == true)
            if not ignoreThisAdmission then
                if item.name == "fatigue" and after >= 1 and before >= 1 then
                    return false, "MAX_FATIGUE_RESOURCE_ADMISSION"
                end
                if item.name == "endurance" and after <= 0 and before <= 0 then
                    return false, "ZERO_ENDURANCE_RESOURCE_ADMISSION"
                end
            end
            state.costs[#state.costs + 1] = {
                name = item.name,
                stat = item.enum,
                stats = stats,
                before = before,
                after = after,
                requestedDelta = delta,
                saturatedNoOp = saturatedNoOp,
            }
            state.costResults[item.name] = {
                before = before,
                requestedDelta = delta,
                target = after,
                after = before,
                result = saturatedNoOp and "SATURATED_NO_OP_SUCCESS" or "PENDING",
            }
        end
    end
    state.costAuthorityReason = authorityReason
    return true, "COST_PREFLIGHT_READY"
end

local function costNumber(value)
    value = tonumber(value)
    return value and string.format("%.6f", value) or "nil"
end

local function logCostTransaction(state, castAccepted)
    local fatigue = state.costResults and state.costResults.fatigue or {}
    local endurance = state.costResults and state.costResults.endurance or {}
    print("[XNP GREEN COST] cast_id=" .. tostring(state.id)
        .. " fatigue_before=" .. costNumber(fatigue.before)
        .. " fatigue_requested_delta=" .. costNumber(fatigue.requestedDelta)
        .. " fatigue_target=" .. costNumber(fatigue.target)
        .. " fatigue_after=" .. costNumber(fatigue.after)
        .. " fatigue_result=" .. tostring(fatigue.result or "DISABLED")
        .. " endurance_before=" .. costNumber(endurance.before)
        .. " endurance_requested_delta=" .. costNumber(endurance.requestedDelta)
        .. " endurance_target=" .. costNumber(endurance.target)
        .. " endurance_after=" .. costNumber(endurance.after)
        .. " endurance_result=" .. tostring(endurance.result or "DISABLED")
        .. " authority=" .. tostring(state.costAuthorityReason or "ZERO_COST")
        .. " cast_accepted=" .. tostring(castAccepted == true))
end

local function restoreCommittedCosts(state)
    local restored = true
    for _, cost in ipairs(state.costs or {}) do
        if cost.committed or cost.writeAttempted then
            local ok, result = invoke(cost.stats, "set", cost.stat, cost.before)
            local readOk, readback = invoke(cost.stats, "get", cost.stat)
            if not ok or result == false or not readOk or tonumber(readback) == nil
                or math.abs(tonumber(readback) - cost.before) > 0.001 then
                restored = false
            end
        end
    end
    return restored
end

local function chargeCostsOnce(state)
    if state.costsCharged then return true, "ALREADY_CHARGED" end
    for _, cost in ipairs(state.costs or {}) do
        local summary = state.costResults[cost.name]
        if cost.saturatedNoOp == true then
            cost.readback = cost.before
            summary.after = cost.before
            summary.result = "SATURATED_NO_OP_SUCCESS"
        else
            cost.writeAttempted = true
            local writeOk, result = invoke(cost.stats, "set", cost.stat, cost.after)
            if writeOk and result ~= false then cost.committed = true end
            local readOk, readback = invoke(cost.stats, "get", cost.stat)
            local numericReadback = readOk and tonumber(readback) or nil
            if not writeOk or result == false or numericReadback == nil
                or math.abs(numericReadback - cost.after) > 0.001 then
                summary.after = numericReadback
                summary.result = "WRITE_FAILED"
                local rollbackOk = restoreCommittedCosts(state)
                logCostTransaction(state, false)
                return false, rollbackOk and "COST_WRITE_FAILED_ROLLED_BACK"
                    or "COST_ROLLBACK_INCOMPLETE"
            end
            cost.readback = numericReadback
            summary.after = numericReadback
            summary.result = "APPLIED"
        end
    end
    state.costsCharged = true
    logCostTransaction(state, true)
    return true, "COSTS_CHARGED_ONCE"
end

local function playerDead(player)
    local ok, value = invoke(player, "isDead")
    if ok and value == true then return true end
    ok, value = invoke(player, "isOnDeathDone")
    return ok and value == true
end

local function createDamageWeapon()
    if type(instanceItem) == "function" then
        local ok, weapon = pcall(instanceItem, Orb.DAMAGE_WEAPON)
        if ok and weapon and isType(weapon, "HandWeapon") then return weapon end
    end
    if InventoryItemFactory and type(InventoryItemFactory.CreateItem) == "function" then
        local ok, weapon = pcall(function() return InventoryItemFactory.CreateItem(Orb.DAMAGE_WEAPON) end)
        if ok and weapon and isType(weapon, "HandWeapon") then return weapon end
    end
    return nil
end

local function collectImpactTargets(state, now)
    local entries, method = candidateEntries(state.world_x, state.world_y, state.world_z,
        state.options.knockdownRadius, state.options, now)
    if not entries then return nil, method end
    table.sort(entries, function(a, b) return a.distance < b.distance end)
    return entries, method
end

local function applyImpactEntry(state, entry, counters, weaponHolder)
    local classification = entry.classification or Core.GreenHumanSafeClassifier.Classify(
        entry.target, isType(entry.target, "IsoZombie"))
    local allowed = Core.GreenHumanSafeClassifier.IsDamageAllowed(
        classification, damagePolicy(state.options)) == true
    if not allowed or not validTarget(entry.target, state.options) then
        Core.GreenHumanSafeClassifier.CountSkip(counters, classification)
        return 0, 0, 0
    end
    if entry.distance <= state.options.lethalRadius then
        weaponHolder.weapon = weaponHolder.weapon or createDamageWeapon()
        if not weaponHolder.weapon then counters.hit_failures = counters.hit_failures + 1; return 0, 0, 0 end
        local health = coordinate(entry.target, "getHealth") or 1
        local lethalDamage = math.max(state.options.explosionDamage, health + 1)
        local hitOk = pcall(function()
            entry.target:Hit(weaponHolder.weapon, state.player, lethalDamage, false, 1.0, false)
        end)
        if not hitOk then counters.hit_failures = counters.hit_failures + 1; return 0, 0, 0 end
        Core.GreenHumanSafeClassifier.CountDamaged(counters, classification)
        return 1, 0, 0
    end
    if state.options.outerKnockdownEnabled ~= true then return 0, 0, 0 end
    local healthBefore = coordinate(entry.target, "getHealth")
    local visible = false
    if Core.VerifiedStaggerControl and Core.VerifiedStaggerControl.Apply then
        local ok, result = pcall(function()
            return Core.VerifiedStaggerControl.Apply(state.player, entry.target,
                "SPRINT_PRECOLLISION", { triggerId = "green-impact-" .. tostring(state.id) })
        end)
        visible = ok and result == true
    end
    local healthAfter = coordinate(entry.target, "getHealth")
    local healthChanged = healthBefore and healthAfter
        and math.abs(healthAfter - healthBefore) > 0.0001
    print("[XNP GREEN OUTER KNOCKDOWN] cast_id=" .. tostring(state.id)
        .. " distance=" .. string.format("%.3f", entry.distance)
        .. " health_damage=" .. tostring(healthChanged and (healthBefore - healthAfter) or 0)
        .. " visible=" .. tostring(visible))
    return 0, visible and 1 or 0, healthChanged and 1 or 0
end

local function applyDirectTargetImpact(state)
    local counters = Core.GreenHumanSafeClassifier.NewCounters()
    local target = state.impactContactTarget
    if not target then return 0, 0, counters, 0, nil end
    local x, y, z = coordinate(target, "getX"), coordinate(target, "getY"), coordinate(target, "getZ")
    if not x or not y or not z or math.abs(z - state.world_z) >= 0.6 then
        return 0, 0, counters, 0, nil
    end
    local dx, dy = x - state.world_x, y - state.world_y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > state.options.knockdownRadius then return 0, 0, counters, 0, nil end
    local entry = { target = target, distance = distance,
        classification = Core.GreenHumanSafeClassifier.Classify(target, isType(target, "IsoZombie")) }
    local lethal, knockdown, healthChanged = applyImpactEntry(state, entry, counters, {})
    return lethal, knockdown, counters, healthChanged, targetIdentity(target)
end

local function applyTieredImpact(state, now, skipIdentity)
    local entries, method = collectImpactTargets(state, now)
    if not entries then
        return nil, 0, 0, Core.GreenHumanSafeClassifier.NewCounters(), method, 0
    end
    local counters = Core.GreenHumanSafeClassifier.NewCounters()
    local ledger = setmetatable({}, { __mode = "k" })
    local weaponHolder = {}
    local lethalCount, knockdownCount, outerHealthDamageCount = 0, 0, 0
    for _, entry in ipairs(entries) do
        if state.options.maximumTargetCount > 0
            and lethalCount + knockdownCount >= state.options.maximumTargetCount then break end
        if not ledger[entry.target] and targetIdentity(entry.target) ~= skipIdentity then
            ledger[entry.target] = true
            local lethal, knockdown, healthChanged = applyImpactEntry(
                state, entry, counters, weaponHolder)
            lethalCount = lethalCount + lethal
            knockdownCount = knockdownCount + knockdown
            outerHealthDamageCount = outerHealthDamageCount + healthChanged
        end
    end
    return outerHealthDamageCount == 0, lethalCount, knockdownCount, counters, method,
        outerHealthDamageCount
end

local logFailureOnce

local function impactSnapshot(state, skipIdentity)
    return {
        id = state.id,
        player = state.player,
        playerNum = state.playerNum,
        world_x = state.world_x,
        world_y = state.world_y,
        world_z = state.world_z,
        options = state.options,
        skipIdentity = skipIdentity,
        queuedAtMs = nowMs(),
    }
end

local function enqueueImpactScan(state, skipIdentity)
    if #Orb.pendingImpacts >= Orb.maximumPendingImpacts then
        local dropped = table.remove(Orb.pendingImpacts, 1)
        print("[XNP GREEN IMPACT SCAN] cast_id=" .. tostring(dropped and dropped.id)
            .. " queued=false completed=false reason=BOUNDED_QUEUE_EVICTION")
    end
    Orb.pendingImpacts[#Orb.pendingImpacts + 1] = impactSnapshot(state, skipIdentity)
    Orb.peakPendingImpacts = math.max(Orb.peakPendingImpacts, #Orb.pendingImpacts)
    print("[XNP GREEN IMPACT SCAN] cast_id=" .. tostring(state.id)
        .. " queued=true reason=REAL_SCAN_BUDGET_DEFERRED visual_audio_immediate=true")
end

local function processPendingImpacts(now)
    local processed = 0
    while #Orb.pendingImpacts > 0 do
        local pending = Orb.pendingImpacts[1]
        local expired = now - (pending.queuedAtMs or now) >= Orb.pendingImpactMaximumAgeMs
        if expired or not pending.player or playerDead(pending.player) then
            table.remove(Orb.pendingImpacts, 1)
            processed = processed + 1
            print("[XNP GREEN IMPACT SCAN] cast_id=" .. tostring(pending.id)
                .. " queued=false completed=false reason="
                .. (expired and "QUEUE_MAXIMUM_AGE" or "PLAYER_INVALID_OR_DEAD"))
        else
        local damageOk, lethalCount, knockdownCount, counters, method, outerHealthDamageCount =
            applyTieredImpact(pending, now, pending.skipIdentity)
        if damageOk == nil then break end
        table.remove(Orb.pendingImpacts, 1)
        processed = processed + 1
        print("[XNP GREEN IMPACT SCAN] cast_id=" .. tostring(pending.id)
            .. " queued=false completed=true method=" .. tostring(method)
            .. " lethal_count=" .. tostring(lethalCount)
            .. " outer_knockdown_count=" .. tostring(knockdownCount)
            .. " outer_health_damage_count=" .. tostring(outerHealthDamageCount)
            .. " players_skipped=" .. tostring(counters.players_skipped)
            .. " players_damaged=0 animals_damaged=0")
        if damageOk ~= true then
            logFailureOnce(pending, "OUTER_RING_HEALTH_CHANGED_DEFERRED")
        end
        end
    end
    return processed
end

local function removePendingImpactReferences(castId)
    local removed = 0
    for index = #Orb.pendingImpacts, 1, -1 do
        if Orb.pendingImpacts[index].id == castId then
            table.remove(Orb.pendingImpacts, index)
            removed = removed + 1
        end
    end
    return removed
end

local function clearFailureLogForCast(castId)
    local prefix = tostring(castId) .. ":"
    for key in pairs(Orb.failureLogged) do
        if string.sub(key, 1, #prefix) == prefix then Orb.failureLogged[key] = nil end
    end
end

logFailureOnce = function(state, reason)
    local key = tostring(state and state.id or "none") .. ":" .. tostring(reason)
    if Orb.failureLogged[key] then return end
    Orb.failureLogged[key] = true
    print("[XNP GREEN VIRTUAL FAIL] cast_id=" .. tostring(state and state.id or "none")
        .. " reason=" .. tostring(reason) .. " failure_log_once=true")
end

local function playConfigured(state, soundKey, eventToken, enabled, volumePercent)
    if enabled ~= true or not Core.Audio then return false, "DISABLED" end
    local fn = Core.Audio.PlayOnceConfigured or Core.Audio.PlayOnce
    if type(fn) ~= "function" then return false, "SOUND_API_UNAVAILABLE" end
    local ok, played, method = pcall(fn, state.player, soundKey,
        eventToken .. ":" .. tostring(state.id), enabled, volumePercent)
    if not ok or played ~= true then
        local reason = ok and method or played
        local key = tostring(soundKey) .. ":" .. tostring(reason)
        if not Orb.missingSoundLogged[key] then
            Orb.missingSoundLogged[key] = true
            print("[XNP GREEN AUDIO] degraded_once=true sound=" .. tostring(soundKey)
                .. " reason=" .. tostring(reason))
        end
        return false, reason
    end
    return true, method
end

local function notifyIcon(kind)
    if Core.GreenSkillUI and Core.GreenSkillUI.NotifyVirtualCast then
        Core.GreenSkillUI.NotifyVirtualCast(kind)
    end
end

local function finallyCleanupCast(state, reason)
    if not state then return false, "STATE_MISSING" end
    if state.cleanupComplete == true or state.cleanupStarted == true then
        Orb.doubleCleanupAttempts = Orb.doubleCleanupAttempts + 1
        return true, "ALREADY_CLEANED"
    end
    state.cleanupStarted = true
    local castId = state.id
    local spawnMs = state.startedMs
    local expireMs = state.expiresAtMs
    local expiredByTimeout = state.expiredByTimeout == true
    clearTargetFlash(state)
    releaseReservation(state)
    local lightRemoved = true
    if Core.GreenWorldLight then
        local ok, result = pcall(Core.GreenWorldLight.RemoveFlight, state.id, reason)
        lightRemoved = ok and result ~= false
    end
    local visualOk, visualReason = true, "VISUAL_MODULE_MISSING"
    if Core.GreenVisibleProxy and type(Core.GreenVisibleProxy.Cleanup) == "function" then
        local ok, result, detail = pcall(Core.GreenVisibleProxy.Cleanup, state)
        visualOk = ok and result ~= false
        visualReason = ok and detail or result
    end
    local renderProxyRemoved = true
    if Core.GreenSmoothVisual and type(Core.GreenSmoothVisual.Deactivate) == "function" then
        local ok, result = pcall(Core.GreenSmoothVisual.Deactivate, state)
        renderProxyRemoved = ok and result ~= false
    end
    local preserveDeferredImpact = reason == "ANY_VALID_COLLISION"
    local pendingRemoved = preserveDeferredImpact and 0 or removePendingImpactReferences(castId)
    local removed, unregisterReason = unregisterCast(state)
    state.cleanupComplete = true
    state.finished = true
    state.cleanupStarted = false
    state.timeoutHandle = nil
    state.expiresAtMs = nil
    Orb.cleanupCount = Orb.cleanupCount + 1
    if expiredByTimeout then Orb.timeoutCleanupCount = Orb.timeoutCleanupCount + 1 end
    print("[XNP GREEN GUIDANCE SUMMARY] cast_id=" .. tostring(state.id)
        .. " target_samples=" .. tostring(state.targetSamples or 0)
        .. " heading_updates=" .. tostring(state.headingUpdates or 0)
        .. " max_observed_turn_deg=" .. string.format("%.3f", state.maxObservedTurnDeg or 0)
        .. " retarget_count=" .. tostring(state.retargetCount or 0)
        .. " instant_heading_snap_count=0")
    print("[XNP GREEN VIRTUAL CLEANUP] cast_id=" .. tostring(state.id)
        .. " reason=" .. tostring(reason)
        .. " visual_ok=" .. tostring(visualOk)
        .. " visual_reason=" .. tostring(visualReason)
        .. " unregister_removed=" .. tostring(removed)
        .. " unregister_reason=" .. tostring(unregisterReason)
        .. " reservation_released=true light_removed=" .. tostring(lightRemoved)
        .. " render_proxy_removed=" .. tostring(renderProxyRemoved)
        .. " pending_effect_references_removed=" .. tostring(pendingRemoved)
        .. " deferred_impact_preserved=" .. tostring(preserveDeferredImpact)
        .. " idempotent=true cross_cast_removal=0")
    print("[XNP GREEN LIFETIME] cast_id=" .. tostring(castId)
        .. " spawn_ms=" .. tostring(spawnMs)
        .. " expire_ms=" .. tostring(expireMs)
        .. " expired_by_timeout=" .. tostring(expiredByTimeout)
        .. " cleanup_completed=true")
    state.target = nil
    state.player = nil
    state.costs = nil
    state.options = nil
    state.visibleProxy = nil
    clearFailureLogForCast(castId)
    return true, "CLEANED"
end

local function expireByLifetime(state, now)
    if not state or not state.options then return false end
    if now < (state.expiresAtMs or math.huge) then return false end
    state.resolved = true
    state.expiredByTimeout = true
    finallyCleanupCast(state, "PROJECTILE_LIFETIME_TIMEOUT")
    return true
end

local function refundCooldown(state)
    if state and state.player then Orb.cooldownByPlayer[state.player] = state.cooldownBefore or 0 end
end

local function abortVisualTransaction(state, reason, refund)
    if not state or state.resolved then return end
    state.resolved = true
    if refund == true then refundCooldown(state) end
    logFailureOnce(state, reason)
    finallyCleanupCast(state, reason)
end

local function completeImpactTransaction(state, reason, now)
    if not state or state.resolved then return false, "ALREADY_RESOLVED" end
    local proof = Core.GreenSmoothVisual.GetProof(state, state.options.projectileArmRenderFrames)
    if proof.ready ~= true then
        print("[XNP GREEN INFLIGHT] cast_id=" .. tostring(state.id)
            .. " proof_ready=false diagnostic_only=true impact_transaction_preserved=true")
    end
    clearTargetFlash(state)
    local visible, visibleMethod = Core.GreenVisibleProxy.ShowImpact(state)
    if visible ~= true or Core.GreenVisibleProxy.ConfirmImpact(state) ~= true then
        abortVisualTransaction(state, "SHOW_IMPACT_FAILED:" .. tostring(visibleMethod), true)
        return false, "IMPACT_VISUAL_NOT_CONFIRMED"
    end
    state.resolved = true
    notifyIcon("IMPACT")
    local lightOk, lightMethod = false, "LIGHT_MODULE_UNAVAILABLE"
    if Core.GreenWorldLight then
        local ok, result, detail = pcall(Core.GreenWorldLight.CreateImpact, state, now)
        lightOk, lightMethod = ok and result == true, ok and detail or result
    end
    local soundOk, soundMethod = playConfigured(state, "GREEN_BOMB_SKILL", "green-impact",
        state.options.impactSound, state.options.impactSoundVolumePercent)
    local directLethal, directKnockdown, directCounters, directHealthDamage, directIdentity =
        applyDirectTargetImpact(state)
    local damageOk, lethalCount, knockdownCount, counters, damageMethod, outerHealthDamageCount =
        applyTieredImpact(state, now, directIdentity)
    local damageDeferred = damageOk == nil
    if damageDeferred then
        enqueueImpactScan(state, directIdentity)
        damageOk = true
        lethalCount, knockdownCount, outerHealthDamageCount = 0, 0, 0
    end
    local fireOk, fireMethod = false, "FIRE_MODULE_UNAVAILABLE"
    if Core.GreenCenterFire then
        local ok, result, detail = pcall(Core.GreenCenterFire.Create, state)
        fireOk, fireMethod = ok and result == true, ok and detail or result
    end
    local structureOk, structureMethod = false, "STRUCTURE_MODULE_UNAVAILABLE"
    if Core.GreenCenterStructureBreak then
        local ok, result, detail = pcall(Core.GreenCenterStructureBreak.Apply, state)
        structureOk, structureMethod = ok and result == true, ok and detail or result
    end
    print("[XNP GREEN VISIBLE TRANSACTION] order=CONFIRM_CONTACT>SHOW_GREEN_IMPACT_VISUAL"
        .. ">CREATE_REAL_WORLD_IMPACT_LIGHT>PLAY_XNPGreenBombSkill"
        .. ">APPLY_DIRECT_EFFECTS>APPLY_OR_QUEUE_AOE>CENTER_FIRE>CENTER_DOOR_WINDOW_BREAK"
        .. ">CLEANUP_PROJECTILE"
        .. " cast_id=" .. tostring(state.id)
        .. " trigger=" .. tostring(reason)
        .. " contact_to_damage_same_update=true damage_delay_ms=0"
        .. " sound_ok=" .. tostring(soundOk)
        .. " sound_method=" .. tostring(soundMethod)
        .. " light_ok=" .. tostring(lightOk)
        .. " light_method=" .. tostring(lightMethod)
        .. " lethal_count=" .. tostring(lethalCount + directLethal)
        .. " outer_knockdown_count=" .. tostring(knockdownCount + directKnockdown)
        .. " outer_health_damage_count=" .. tostring(outerHealthDamageCount + directHealthDamage)
        .. " damage_method=" .. tostring(damageMethod)
        .. " damage_ok=" .. tostring(damageOk)
        .. " damage_deferred=" .. tostring(damageDeferred)
        .. " fire_ok=" .. tostring(fireOk)
        .. " fire_method=" .. tostring(fireMethod)
        .. " structure_ok=" .. tostring(structureOk)
        .. " structure_method=" .. tostring(structureMethod)
        .. " players_skipped=" .. tostring(counters.players_skipped + directCounters.players_skipped)
        .. " players_damaged=0 animals_damaged=0 walls_damaged=0 furniture_damaged=0 vehicles_damaged=0")
    if not damageOk or directHealthDamage > 0 then logFailureOnce(state, "OUTER_RING_HEALTH_CHANGED") end
    finallyCleanupCast(state, reason)
    return damageOk, "INSTANT_IMPACT_COMPLETE"
end

local function sampleGuidanceTarget(state, now)
    if not state.target then return false, "TARGET_MISSING" end
    local tx = coordinate(state.target, "getX")
    local ty = coordinate(state.target, "getY")
    if not tx or not ty then return false, "TARGET_COORDINATE_INVALID" end
    local identity = targetIdentity(state.target)
    local velocityX, velocityY = 0, 0
    if state.lastTargetSampleMs and state.lastSampleTargetIdentity == identity then
        local elapsed = (now - state.lastTargetSampleMs) / 1000
        if elapsed > 0.001 then
            velocityX = (tx - state.lastTargetSampleX) / elapsed
            velocityY = (ty - state.lastTargetSampleY) / elapsed
        end
    end
    local lead = state.options.guidanceLeadPredictionSeconds
    local predictedX = tx + velocityX * lead
    local predictedY = ty + velocityY * lead
    local desiredX, desiredY = normalized(predictedX - state.world_x, predictedY - state.world_y)
    if not desiredX then return false, "DESIRED_HEADING_DEGENERATE" end
    state.lastTargetSampleX = tx
    state.lastTargetSampleY = ty
    state.lastTargetSampleMs = now
    state.lastSampleTargetIdentity = identity
    state.desiredTargetX = predictedX
    state.desiredTargetY = predictedY
    state.desiredHeadingX = desiredX
    state.desiredHeadingY = desiredY
    state.targetSamples = state.targetSamples + 1
    state.nextTargetSampleMs = now + state.options.guidanceSampleIntervalMs
    return true, "TARGET_SAMPLED"
end

local function updateInertialHeading(state, delta, now)
    if state.options.guidanceInertiaEnabled ~= true then return end
    if not state.desiredHeadingX or not state.desiredHeadingY then return end
    local currentAngle = math.atan2(state.heading_y, state.heading_x)
    local desiredAngle = math.atan2(state.desiredHeadingY, state.desiredHeadingX)
    local requestedTurn = angleDelta(currentAngle, desiredAngle)
    local maximumTurn = math.rad(state.options.guidanceMaxTurnRateDegPerSecond) * delta
    if state.retargetStartedMs and state.options.guidanceRetargetAdaptationMs > 0 then
        local adaptation = math.max(0, math.min(
            (now - state.retargetStartedMs) / state.options.guidanceRetargetAdaptationMs, 1))
        maximumTurn = maximumTurn * math.max(0.05, adaptation)
        if adaptation >= 1 then state.retargetStartedMs = nil end
    end
    local appliedTurn = math.max(-maximumTurn, math.min(requestedTurn, maximumTurn))
    currentAngle = currentAngle + appliedTurn
    state.heading_x, state.heading_y = math.cos(currentAngle), math.sin(currentAngle)
    state.directionX, state.directionY = state.heading_x, state.heading_y
    state.headingUpdates = state.headingUpdates + 1
    state.maxObservedTurnDeg = math.max(state.maxObservedTurnDeg, math.deg(math.abs(appliedTurn)))
end

local function updateLockedSpeed(state, delta, now)
    if not state.target then
        if state.everLocked and state.options.targetLostDecelerationEnabled == true then
            local elapsed = math.max(0, now - (state.lostTargetStartedMs or now))
            local progress = math.max(0, math.min(
                elapsed / math.max(state.options.targetLostDecelerationMs, 1), 1))
            local curve = progress * progress * (3 - 2 * progress)
            local startSpeed = state.lostDecelStartSpeed or state.speed
            state.speed = startSpeed
                + (state.options.targetLostMinimumSpeed - startSpeed) * curve
            if progress >= 1 then
                state.speed = state.options.targetLostMinimumSpeed
                state.phase = "CRUISE_SEARCHING"
                state.speedStage = "TARGET_LOST_MINIMUM_CRUISE"
            else
                state.phase = "TARGET_LOST_DECELERATING"
                state.speedStage = "TARGET_LOST_SMOOTH_DECELERATION"
            end
            return
        end
        state.speed = state.options.preLockCruiseSpeed
        state.speedStage = "CRUISE_SEARCHING_FIXED_SPEED"
        return
    end
    if state.options.dynamicAccelerationEnabled == true then
        local elapsed = math.max(0, now - (state.lockSpeedRampStartedMs or now))
        local progress = math.max(0, math.min(
            elapsed / math.max(state.options.accelerationTimeToMaxMs, 1), 1))
        local noticeableProgress = math.max(0.05, math.min(
            state.options.accelerationNoticeableByMs
                / math.max(state.options.accelerationTimeToMaxMs, 1), 0.95))
        local noticeableGain = 0.35
        local curve = progress
        if state.options.accelerationCurveMode == 1 then
            if progress <= noticeableProgress then
                local early = progress / noticeableProgress
                curve = noticeableGain * (early * (2 - early))
            else
                local late = (progress - noticeableProgress) / (1 - noticeableProgress)
                local smoothLate = late * late * (3 - 2 * late)
                curve = noticeableGain + (1 - noticeableGain) * smoothLate
            end
        end
        local startSpeed = state.lockSpeedRampStartSpeed or state.speed
        state.speed = startSpeed + (state.options.lockedMaxSpeed - startSpeed) * curve
        state.speedStage = progress >= 1 and "LOCKED_MAX_SPEED"
            or "LOCKED_TIME_TO_MAX_SMOOTH_ACCELERATION"
        return
    end
    local targetSpeed = math.min(state.options.lockedConstantSpeed, state.options.lockedMaxSpeed)
    local blendSeconds = math.max(state.options.accelerationBlendMs / 1000, 0.001)
    local blend = math.max(0, math.min(delta / blendSeconds, 1))
    state.speed = state.speed + (targetSpeed - state.speed) * blend
    state.speedStage = "LOCKED_CONSTANT_SPEED_SMOOTH_BLEND"
end

local function acquireIfDue(state, now)
    if validTarget(state.target, state.options) then return true, "CURRENT_TARGET_VALID" end
    if state.target then setTarget(state, nil, "TARGET_INVALID", now) end
    if now < (state.nextSearchMs or 0) then return false, "SCAN_NOT_DUE" end
    local target, source = nearestTarget(state, now)
    if source == "REAL_SCAN_BUDGET_DEFERRED" then
        state.nextSearchMs = now + 1
        return false, source
    end
    state.nextSearchMs = now + state.options.targetScanIntervalMs
    if not target then return false, source end
    local assigned, reason = setTarget(state, target, source, now)
    if not assigned then return false, reason end
    print("[XNP GREEN TARGET] acquired=true cast_id=" .. tostring(state.id)
        .. " initial_target=false phase=LOCKED_HOMING"
        .. " source=" .. tostring(source)
        .. " target_identity=" .. tostring(state.reservedTargetIdentity)
        .. " unique_scope=PER_PLAYER")
    state.phase = "LOCKED_HOMING"
    return true, "TARGET_ACQUIRED"
end

local function cancelNoTarget(state)
    if state.options.refundNoTarget then refundCooldown(state) end
    notifyIcon("CANCEL")
    print("[XNP GREEN VIRTUAL] cancelled=true reason=NO_TARGET_TIMEOUT"
        .. " cast_id=" .. tostring(state.id)
        .. " impact_sound=false damage=false cooldown_refunded="
        .. tostring(state.options.refundNoTarget))
    finallyCleanupCast(state, "NO_TARGET_TIMEOUT")
end

local function updateFlight(state, now, fixedDelta)
    if expireByLifetime(state, now) then return end
    updateTargetFlash(state, now)
    acquireIfDue(state, now)
    if state.target and now >= (state.nextTargetSampleMs or 0) then
        local sampled = sampleGuidanceTarget(state, now)
        if sampled ~= true then setTarget(state, nil, "TARGET_COORDINATE_INVALID", now) end
    end
    local delta = tonumber(fixedDelta)
        or math.max(0, math.min((now - state.lastUpdateMs) / 1000, 0.10))
    state.lastUpdateMs = now
    if state.target then updateInertialHeading(state, delta, now) end
    updateLockedSpeed(state, delta, now)
    state.velocity_x = state.heading_x * state.speed
    state.velocity_y = state.heading_y * state.speed
    local nextX = state.world_x + state.velocity_x * delta
    local nextY = state.world_y + state.velocity_y * delta
    local stepX, stepY = nextX - state.world_x, nextY - state.world_y
    local stepDistance = math.sqrt(stepX * stepX + stepY * stepY)
    local travelAfter = (state.travelDistance or 0) + stepDistance
    local collision = firstValidCollision(state, state.world_x, state.world_y,
        nextX, nextY, now, travelAfter)
    if collision then
        state.world_x, state.world_y = collision.x, collision.y
        state.travelDistance = (state.travelDistance or 0) + stepDistance * collision.fraction
        if collision.kind == "LOCKED_TARGET" or collision.kind == "UNLOCKED_ZOMBIE"
            or collision.kind == "NPC" or collision.kind == "BANDIT"
            or collision.kind == "HUMAN_CHARACTER" then
            state.impactContactTarget = collision.object
        end
        print("[XNP GREEN COLLISION] cast_id=" .. tostring(state.id)
            .. " collision_kind=" .. tostring(collision.kind)
            .. " guidance_target_match=" .. tostring(collision.guidanceTargetMatch == true)
            .. " swept_test=" .. tostring(collision.swept == true)
            .. " contact_fraction=" .. string.format("%.6f", collision.fraction or 0)
            .. " detonation=true")
        completeImpactTransaction(state, "ANY_VALID_COLLISION", now)
        return
    end
    local previousWorldX = state.world_x
    local previousWorldY = state.world_y
    local previousWorldZ = state.world_z
    state.world_x, state.world_y = nextX, nextY
    state.travelDistance = travelAfter
    state.previous_simulation_x = state.current_simulation_x or previousWorldX
    state.previous_simulation_y = state.current_simulation_y or previousWorldY
    state.previous_simulation_z = state.current_simulation_z or previousWorldZ
    state.previous_simulation_ms = state.current_simulation_ms
        or (now - (1000 / math.max(20, state.options.simulationUpdatesPerSecond or 30)))
    state.current_simulation_x = state.world_x
    state.current_simulation_y = state.world_y
    state.current_simulation_z = state.world_z
    state.current_simulation_ms = now
    state.castSimulationSteps = (state.castSimulationSteps or 0) + 1
    if Core.GreenWorldLight then pcall(Core.GreenWorldLight.UpdateFlight, state, now) end
    local visible, visualMethod = Core.GreenVisibleProxy.Update(state)
    if visible ~= true then
        abortVisualTransaction(state, "TRACK_VISUAL_UPDATE_FAILED:" .. tostring(visualMethod), true)
        return
    end
end

local function updateCast(state, player, now, fixedDelta)
    if state.cleanupComplete then return false end
    if state.player ~= player then finallyCleanupCast(state, "PLAYER_REPLACED"); return false end
    if playerDead(player) then finallyCleanupCast(state, "PLAYER_DEATH"); return false end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then
        finallyCleanupCast(state, "PLAYER_TRAIT_INVALID")
        return false
    end
    updateFlight(state, now, fixedDelta)
    return true
end

local function updateProtected(player)
    local currentMs = nowMs()
    local snapshot = castSnapshot(playerNumber(player))
    if #snapshot == 0 then
        if Core.GreenWorldLight then pcall(Core.GreenWorldLight.Update, currentMs) end
        processPendingImpacts(currentMs)
        Orb.simulationClockByPlayer[player] = nil
        return false
    end
    local firstOptions = snapshot[1] and snapshot[1].options or nil
    local simulationHz = firstOptions and firstOptions.simulationUpdatesPerSecond or 30
    local stepMs = 1000 / math.max(20, math.min(simulationHz, 60))
    local clock = Orb.simulationClockByPlayer[player]
    if not clock then
        clock = { lastMs = currentMs, simulatedMs = currentMs - stepMs, accumulatorMs = stepMs }
        Orb.simulationClockByPlayer[player] = clock
    else
        local elapsed = math.max(0, currentMs - (clock.lastMs or currentMs))
        local admitted = math.min(elapsed, stepMs * MAXIMUM_CATCHUP_STEPS_PER_FRAME)
        Orb.droppedCatchupMs = Orb.droppedCatchupMs + math.max(0, elapsed - admitted)
        clock.accumulatorMs = (clock.accumulatorMs or 0) + admitted
        clock.lastMs = currentMs
    end
    local steps = 0
    while clock.accumulatorMs + 0.0001 >= stepMs
        and steps < MAXIMUM_CATCHUP_STEPS_PER_FRAME do
        clock.accumulatorMs = clock.accumulatorMs - stepMs
        clock.simulatedMs = (clock.simulatedMs or currentMs - stepMs) + stepMs
        steps = steps + 1
        Orb.simulationStepCount = Orb.simulationStepCount + 1
        resetScanBudget(clock.simulatedMs)
        if Core.GreenWorldLight then pcall(Core.GreenWorldLight.Update, clock.simulatedMs) end
        processPendingImpacts(clock.simulatedMs)
        local stepSnapshot = castSnapshot(playerNumber(player))
        for _, state in ipairs(stepSnapshot) do
            local ok, result = pcall(updateCast, state, player, clock.simulatedMs, stepMs / 1000)
            if not ok then
                logFailureOnce(state, "EXCEPTION_GUARD:" .. tostring(result))
                if state.cleanupStarted ~= true and state.cleanupComplete ~= true then
                    finallyCleanupCast(state, "EXCEPTION_GUARD")
                end
            end
        end
    end
    Orb.maximumCatchupStepsObserved = math.max(Orb.maximumCatchupStepsObserved, steps)
    if clock.accumulatorMs >= stepMs then
        Orb.droppedCatchupMs = Orb.droppedCatchupMs + clock.accumulatorMs
        clock.accumulatorMs = 0
        clock.simulatedMs = currentMs
    end
    return true
end

function Orb.CanActivate(player)
    if not player then return false, "PLAYER_INVALID" end
    local identityValid, identityReason = Core.CanonicalPlayerIdentity.Validate(player, true)
    if not identityValid then return false, "IDENTITY_REJECTED:" .. tostring(identityReason) end
    if tuningBoolean("GreenActiveSkillEnabled", true) ~= true then
        return false, "MOD_DISABLED"
    end
    if not Core.Authority or Core.Authority.IsSinglePlayer() ~= true then
        if not Orb.multiplayerNoticeLogged then
            Orb.multiplayerNoticeLogged = true
            print("[XNP GREEN MULTIPLAYER] active_skill_enabled=false scope=SINGLEPLAYER_ONLY_FAIL_CLOSED"
                .. " cost=false damage=false cast_created=false")
        end
        return false, "MULTIPLAYER_FAIL_CLOSED"
    end
    if playerDead(player) then return false, "PLAYER_INVALID" end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then
        return false, "TRAIT_MISSING"
    end
    local options = settings()
    local playerNum = playerNumber(player)
    if tableCount(castBucket(playerNum, false)) >= options.maximumConcurrentCastsPerPlayer then
        return false, "MAX_CONCURRENT_CASTS"
    end
    if Orb.activeCountGlobal >= options.maximumConcurrentCastsGlobal then
        return false, "MAX_CONCURRENT_CASTS"
    end
    local cooldownBypassed = options.runtimeTestMode == true and options.testNoCooldown == true
    if options.cooldownEnabled == true and not cooldownBypassed
        and nowMs() < (Orb.cooldownByPlayer[player] or 0) then
        return false, "COOLDOWN_ACTIVE"
    end
    return true, "READY", options
end

local function requestActivateTransaction(transaction)
    local player = transaction.player
    local source = transaction.source
    local allowed, reason, options = Orb.CanActivate(player)
    if not allowed then
        print("[XNP GREEN CAST BLOCKED] reason=" .. tostring(reason)
            .. " existing_casts_preserved=true cost=false cooldown=false sound=false")
        return false, reason
    end
    local x = coordinate(player, "getX")
    local y = coordinate(player, "getY")
    local z = coordinate(player, "getZ")
    if not x or not y or not z then return false, "PLAYER_COORDINATE_UNAVAILABLE" end
    local now = transaction.inputTimestampMs
    local fx, fy, directionSource = playerForward(player)
    local lastSuccessful = Orb.lastSuccessfulCastMsByPlayer[player]
    local elapsedSinceSuccess = lastSuccessful and (now - lastSuccessful) or nil
    local rapid = options.rapidCastRandomDirectionEnabled == true and lastSuccessful ~= nil
        and elapsedSinceSuccess >= 0 and elapsedSinceSuccess < options.rapidCastWindowMs
    local randomMethod = "NOT_RAPID"
    if rapid and options.rapidCastRandomDirectionMode == 1 then
        fx, fy, randomMethod = rapidCastHeading(fx, fy, Orb.serial + 1)
        directionSource = randomMethod == "PLAYER_FORWARD_FALLBACK"
            and "RAPID_CAST_FALLBACK_HEADING" or "RAPID_CAST_RANDOM_DIRECTION"
    end
    Orb.serial = Orb.serial + 1
    local exactSpawn = (rapid and options.rapidCastSpawnAtExactPlayerPosition == true)
        or (not rapid and options.spawnAtExactPlayerPosition == true)
    local launchOffset = exactSpawn and 0 or options.launchForwardOffset
    local state = {
        id = Orb.serial,
        player = player,
        playerNum = playerNumber(player),
        options = options,
        phase = "CRUISE_SEARCHING",
        initial_target = false,
        target = nil,
        world_x = x + fx * launchOffset,
        world_y = y + fy * launchOffset,
        world_z = z,
        heading_x = fx,
        heading_y = fy,
        directionX = fx,
        directionY = fy,
        velocity_x = fx * options.preLockCruiseSpeed,
        velocity_y = fy * options.preLockCruiseSpeed,
        speed = options.preLockCruiseSpeed,
        speedStage = "CRUISE_SEARCHING_FIXED_SPEED",
        startedMs = now,
        expiresAtMs = now + options.maximumFlightMs,
        expiredByTimeout = false,
        lastUpdateMs = now,
        nextTargetSampleMs = now,
        noTargetSinceMs = now,
        targetSamples = 0,
        headingUpdates = 0,
        maxObservedTurnDeg = 0,
        retargetCount = 0,
        mapHidden = Orb.mapHidden,
        cooldownBefore = Orb.cooldownByPlayer[player] or 0,
        source = source,
        rapidCast = rapid,
        inputTimestampMs = now,
        randomDirectionMethod = randomMethod,
        travelDistance = 0,
        impactContactTarget = nil,
        spawnTileX = math.floor(x),
        spawnTileY = math.floor(y),
        spawn_x = x,
        spawn_y = y,
        previous_simulation_x = x + fx * launchOffset,
        previous_simulation_y = y + fy * launchOffset,
        previous_simulation_z = z,
        previous_simulation_ms = now - (1000 / math.max(20, options.simulationUpdatesPerSecond)),
        current_simulation_x = x + fx * launchOffset,
        current_simulation_y = y + fy * launchOffset,
        current_simulation_z = z,
        current_simulation_ms = now,
        castSimulationSteps = 0,
    }
    state.spawnOverlapCharacters, state.spawnOverlapCharacterCount = collectSpawnOverlapCharacters(state)
    transaction.state = state
    local scanStagger = options.targetScanStaggerEnabled
        and ((state.id - 1) % options.maximumConcurrentCastsPerPlayer)
            * (options.targetScanIntervalMs / options.maximumConcurrentCastsPerPlayer) or 0
    state.nextSearchMs = now + scanStagger
    local flashStagger = options.targetFlashStaggerEnabled
        and ((state.id - 1) % options.maximumConcurrentCastsPerPlayer)
            * (options.targetFlashIntervalMs / options.maximumConcurrentCastsPerPlayer) or 0
    state.nextTargetFlashMs = now + flashStagger
    local costReady, costReason = preflightCosts(state)
    if costReady ~= true then return false, costReason end
    if Core.GreenSmoothVisual and Core.GreenSmoothVisual.SetRuntimeOptions then
        Core.GreenSmoothVisual.SetRuntimeOptions(options)
    end
    local createOk, visualReady, visualReason = pcall(Core.GreenVisibleProxy.Create, state)
    if createOk ~= true then
        pcall(Core.GreenVisibleProxy.Cleanup, state)
        return false, "VISIBLE_PROXY_CREATE_EXCEPTION:" .. tostring(visualReady)
    end
    if visualReady ~= true then return false, "VISIBLE_PROXY_CREATE_FAILED:" .. tostring(visualReason) end
    transaction.visualCreated = true
    local registered, registerReason = registerCast(state)
    if registered ~= true then
        pcall(Core.GreenVisibleProxy.Cleanup, state)
        return false, registerReason
    end
    transaction.registered = true
    local charged, chargeReason = chargeCostsOnce(state)
    if charged ~= true then
        finallyCleanupCast(state, chargeReason)
        return false, chargeReason
    end
    transaction.costsCharged = true
    local cooldownBypassed = options.runtimeTestMode == true and options.testNoCooldown == true
    Orb.cooldownByPlayer[player] = (options.cooldownEnabled ~= true or cooldownBypassed)
        and 0 or (now + options.cooldownMs)
    local soundOk, soundMethod = playConfigured(state, "GREEN_PROJECTILE_CAST", "green-cast",
        options.castSound, 100)
    pcall(notifyIcon, "CAST")
    Orb.lastSuccessfulCastMsByPlayer[player] = now
    if Core.GreenWorldLight then pcall(Core.GreenWorldLight.CreateFlight, state, now) end
    print("[XNP GREEN CAST ACCEPTED] cast_id=" .. tostring(state.id)
        .. " source=" .. tostring(source)
        .. " phase=CRUISE_SEARCHING initial_target=false"
        .. " direction_source=" .. tostring(directionSource)
        .. " launch_offset=" .. tostring(launchOffset)
        .. " exact_player_position=" .. tostring(exactSpawn)
        .. " spawn_overlap_zombies=" .. tostring(state.spawnOverlapCharacterCount)
        .. " spawn_safety_radius=" .. tostring(options.spawnSafetyRadiusTiles)
        .. " rapid_cast=" .. tostring(rapid)
        .. " input_timestamp_ms=" .. tostring(now)
        .. " random_method=" .. tostring(randomMethod)
        .. " cruise_speed=" .. tostring(options.preLockCruiseSpeed)
        .. " active_casts_player=" .. tostring(tableCount(castBucket(state.playerNum, false)))
        .. " active_casts_global=" .. tostring(Orb.activeCountGlobal)
        .. " maximum_per_player=" .. tostring(options.maximumConcurrentCastsPerPlayer)
        .. " maximum_global=" .. tostring(options.maximumConcurrentCastsGlobal)
        .. " lifetime_source=GreenMaximumFlightSeconds"
        .. " lifetime_seconds=" .. tostring(options.maximumFlightMs / 1000)
        .. " expire_ms=" .. tostring(state.expiresAtMs)
        .. " sound_ok=" .. tostring(soundOk)
        .. " sound_method=" .. tostring(soundMethod))
    return true, "CAST_ACCEPTED", state.id
end

function Orb.RequestActivate(player, source, inputTimestampMs)
    local identityValid, identityReason = Core.CanonicalPlayerIdentity.Validate(player, true)
    if not identityValid then return false, "IDENTITY_REJECTED:" .. tostring(identityReason) end
    local transaction = {
        player = player,
        source = source or "GREEN_UI",
        inputTimestampMs = normalizeInputTimestamp(inputTimestampMs),
        state = nil,
        visualCreated = false,
        registered = false,
        costsCharged = false,
    }
    local ok, accepted, reason, castId = pcall(requestActivateTransaction, transaction)
    if ok then return accepted, reason, castId end
    local state = transaction.state
    if state and transaction.costsCharged == true then
        restoreCommittedCosts(state)
        state.costsCharged = false
    end
    if state and state.player then
        Orb.cooldownByPlayer[state.player] = state.cooldownBefore or 0
    end
    if state and transaction.registered == true then
        finallyCleanupCast(state, "ACTIVATION_EXCEPTION")
    elseif state and transaction.visualCreated == true and Core.GreenVisibleProxy then
        pcall(Core.GreenVisibleProxy.Cleanup, state)
    end
    print("[XNP GREEN CAST CREATION FAIL] reason=INTERNAL_EXCEPTION"
        .. " detail=" .. tostring(accepted)
        .. " existing_casts_preserved=true cost=false cooldown=false sound=false"
        .. " activation_lock=false")
    return false, "INTERNAL_EXCEPTION"
end

function Orb.Update(player)
    if not player or Core.CanonicalPlayerIdentity.Validate(player, true) ~= true then return false end
    return updateProtected(player)
end

function Orb.InitializePlayer(player, source)
    if not player or Core.CanonicalPlayerIdentity.Validate(player, true) ~= true then return false end
    local preflight = Core.GreenVisibleProxy.Preflight()
    local options = settings()
    print("[XNP GREEN CONFIG] loaded=true version=0.5.60.7.15"
        .. " mode=" .. Orb.FINAL_GREEN_MODE
        .. " multiplayer_scope=" .. Orb.GREEN_MULTIPLAYER_SCOPE
        .. " initial_target=false cruise_searching=true"
        .. " turn_level_default=" .. tostring(options.guidanceTurnLevel)
        .. " turn_rate_default_deg_per_sec="
        .. tostring(options.guidanceMaxTurnRateDegPerSecond)
        .. " prelock_speed=" .. tostring(options.preLockCruiseSpeed)
        .. " target_lost_minimum_speed=" .. tostring(options.targetLostMinimumSpeed)
        .. " locked_max_speed=" .. tostring(options.lockedMaxSpeed)
        .. " virtual_hard_cap=" .. tostring(options.virtualHardCap)
        .. " acceleration_source=" .. (options.dynamicAccelerationEnabled
            and "TIME_TO_MAX_DYNAMIC_CURVE" or "FIXED_SPEED_BLEND")
        .. " expected_time_to_max_seconds="
        .. tostring(options.accelerationTimeToMaxMs / 1000)
        .. " any_valid_collision=" .. tostring(options.anyValidCollisionDetonationEnabled)
        .. " collision_characters=" .. tostring(options.collisionCharactersEnabled)
        .. " collision_world_solids=" .. tostring(options.collisionWorldSolidsEnabled)
        .. " collision_vehicles=" .. tostring(options.collisionVehiclesEnabled)
        .. " maximum_casts_per_player=" .. tostring(options.maximumConcurrentCastsPerPlayer)
        .. " maximum_casts_global=" .. tostring(options.maximumConcurrentCastsGlobal)
        .. " projectile_lifetime_source=GreenMaximumFlightSeconds"
        .. " projectile_lifetime_seconds=" .. tostring(options.maximumFlightMs / 1000)
        .. " visual_maximum_fps=" .. tostring(options.visualMaximumFps)
        .. " simulation_updates_per_second=" .. tostring(options.simulationUpdatesPerSecond)
        .. " maximum_catchup_steps_per_frame=" .. tostring(MAXIMUM_CATCHUP_STEPS_PER_FRAME)
        .. " flight_light_follow_enabled=" .. tostring(options.dynamicLightFollowEnabled)
        .. " preflight_ready=" .. tostring(preflight.ready)
        .. " source=" .. tostring(source))
    return preflight.ready == true
end

function Orb.SetMapHidden(hidden)
    Orb.mapHidden = hidden == true
    for _, state in ipairs(allCastSnapshot()) do
        state.mapHidden = Orb.mapHidden
        if Orb.mapHidden then clearTargetFlash(state) end
    end
    if Core.GreenVisibleProxy and Core.GreenVisibleProxy.SetMapHidden then
        Core.GreenVisibleProxy.SetMapHidden(Orb.mapHidden)
    end
    if Core.GreenWorldLight and Core.GreenWorldLight.SetMapHidden then
        pcall(Core.GreenWorldLight.SetMapHidden, Orb.mapHidden, nowMs())
    end
end

function Orb.GetDiagnostics()
    local visualMetrics = Core.GreenSmoothVisual and Core.GreenSmoothVisual.GetMetrics
        and Core.GreenSmoothVisual.GetMetrics() or {}
    local lightMetrics = Core.GreenWorldLight and Core.GreenWorldLight.GetMetrics
        and Core.GreenWorldLight.GetMetrics() or {}
    return {
        activeCastCount = tableCount(Orb.activeCastsById),
        activeCastCounter = Orb.activeCountGlobal,
        peakActiveCastCount = Orb.peakActiveCountGlobal,
        pendingImpactCount = #Orb.pendingImpacts,
        peakPendingImpactCount = Orb.peakPendingImpacts,
        pendingImpactLimit = Orb.maximumPendingImpacts,
        activeRenderProxyCount = visualMetrics.activeCount or 0,
        activeImpactProxyCount = visualMetrics.impactCount or 0,
        activeFlightLightCount = lightMetrics.activeFlightCount or 0,
        activeDynamicLightCount = lightMetrics.activeCount or 0,
        peakDynamicLightCount = lightMetrics.peakActiveCount or 0,
        flightLightFollowUpdates = lightMetrics.followUpdates or 0,
        cleanupCount = Orb.cleanupCount,
        timeoutCleanupCount = Orb.timeoutCleanupCount,
        doubleCleanupAttempts = Orb.doubleCleanupAttempts,
        simulationStepCount = Orb.simulationStepCount,
        simulationOwnerCount = Orb.simulationOwnerCount,
        perCastSimulationEventCount = Orb.perCastSimulationEventCount,
        maximumCatchupStepsObserved = Orb.maximumCatchupStepsObserved,
        droppedCatchupMs = Orb.droppedCatchupMs,
    }
end

function Orb.Cleanup(player, reason)
    if not player then return 0 end
    local snapshot = castSnapshot(playerNumber(player))
    for _, state in ipairs(snapshot) do finallyCleanupCast(state, reason or "PLAYER_CLEANUP") end
    return #snapshot
end

function Orb.Shutdown(reason)
    local snapshot = allCastSnapshot()
    for _, state in ipairs(snapshot) do finallyCleanupCast(state, reason or "WORLD_EXIT") end
    if Core.GreenSmoothVisual and Core.GreenSmoothVisual.Shutdown then
        pcall(Core.GreenSmoothVisual.Shutdown)
    end
    if Core.GreenWorldLight then pcall(Core.GreenWorldLight.Shutdown, reason or "WORLD_EXIT") end
    if Core.GreenCenterFire then pcall(Core.GreenCenterFire.Shutdown, reason or "WORLD_EXIT") end
    if Core.GreenCenterStructureBreak then
        pcall(Core.GreenCenterStructureBreak.Shutdown, reason or "WORLD_EXIT")
    end
    print("[XNP GREEN PERFORMANCE] peak_casts=" .. tostring(Orb.peakActiveCountGlobal)
        .. " real_target_scans=" .. tostring(Orb.realTargetScans)
        .. " query_cache_hits=" .. tostring(Orb.queryCacheHits)
        .. " query_cache_misses=" .. tostring(Orb.queryCacheMisses)
        .. " target_square_reads=" .. tostring(Orb.targetSquareReads)
        .. " simulation_square_cache_hits=" .. tostring(Orb.simulationSquareCacheHits)
        .. " simulation_square_cache_misses=" .. tostring(Orb.simulationSquareCacheMisses)
        .. " simulation_world_object_cache_hits=" .. tostring(Orb.simulationWorldObjectCacheHits)
        .. " simulation_world_object_cache_misses=" .. tostring(Orb.simulationWorldObjectCacheMisses)
        .. " real_target_scans_peak_per_frame=" .. tostring(Orb.peakScanBudgetUsed)
        .. " impact_scan_queue_peak=" .. tostring(Orb.peakPendingImpacts)
        .. " impact_scan_queue_after_idle=0"
        .. " stale_cast_count_after_cleanup=" .. tostring(tableCount(Orb.activeCastsById))
        .. " cleanup_count=" .. tostring(Orb.cleanupCount)
        .. " timeout_cleanup_count=" .. tostring(Orb.timeoutCleanupCount)
        .. " double_cleanup_attempts=" .. tostring(Orb.doubleCleanupAttempts)
        .. " simulation_steps=" .. tostring(Orb.simulationStepCount)
        .. " maximum_catchup_steps_observed=" .. tostring(Orb.maximumCatchupStepsObserved)
        .. " dropped_catchup_ms=" .. tostring(Orb.droppedCatchupMs)
        .. " area_outline_scans=0 per_frame_sandbox_reads=0 per_frame_texture_loads=0")
    Orb.activeCastsByPlayer = {}
    Orb.activeCastsById = {}
    Orb.activeCountGlobal = 0
    Orb.peakActiveCountGlobal = 0
    Orb.reservedTargetByPlayer = {}
    Orb.cooldownByPlayer = setmetatable({}, { __mode = "k" })
    Orb.outlineOwners = setmetatable({}, { __mode = "k" })
    Orb.failureLogged = {}
    Orb.queryCache = {}
    Orb.queryCacheHits = 0
    Orb.queryCacheMisses = 0
    Orb.targetSquareReads = 0
    Orb.realTargetScans = 0
    Orb.scanBudgetEpochMs = -1
    Orb.scanBudgetUsed = 0
    Orb.peakScanBudgetUsed = 0
    Orb.vehicleSnapshotEpochMs = -1
    Orb.vehicleSnapshot = {}
    Orb.simulationSquareCacheEpochMs = -1
    Orb.simulationSquareCache = {}
    Orb.simulationSquareCacheHits = 0
    Orb.simulationSquareCacheMisses = 0
    Orb.simulationWorldObjectCache = setmetatable({}, { __mode = "k" })
    Orb.simulationWorldObjectCacheHits = 0
    Orb.simulationWorldObjectCacheMisses = 0
    Orb.pendingImpacts = {}
    Orb.peakPendingImpacts = 0
    Orb.cleanupCount = 0
    Orb.timeoutCleanupCount = 0
    Orb.doubleCleanupAttempts = 0
    Orb.lastSuccessfulCastMsByPlayer = setmetatable({}, { __mode = "k" })
    Orb.simulationClockByPlayer = setmetatable({}, { __mode = "k" })
    Orb.simulationStepCount = 0
    Orb.maximumCatchupStepsObserved = 0
    Orb.droppedCatchupMs = 0
    return #snapshot
end

Core.GreenWorldOrb = Orb
return Orb
