require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixLifeGate"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"

local Core = XNP_PZ_DistanceRunner

local Transaction = {
    STATE_READY_ENABLED_BLUE = "READY_ENABLED_BLUE",
    STATE_TRIGGER_COMMITTING = "TRIGGER_COMMITTING",
    STATE_COOLDOWN_WHITE = "COOLDOWN_WHITE",
    STATE_READY_DISABLED_GREEN = "READY_DISABLED_GREEN",
    STATE_DEAD_TOMBSTONED = "DEAD_TOMBSTONED",
    runtime = setmetatable({}, { __mode = "k" }),
    serial = 0,
    successfulRecoveries = 0,
}

local FALL_ACCELERATION = 5.0010414
local FALL_LETHAL_HEIGHT = 3.5
local FALL_ARM_MAX_HEIGHT = 3.0
local FALL_GUARD_TIMEOUT_MS = 1500

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    local ok, value = pcall(function() return object[method](object, unpack(args)) end)
    return ok, value
end

local function normalizeHealth(value)
    if type(value) ~= "number" then return nil end
    return value > 1 and value / 100 or value
end

local function identityOf(player)
    if Core.PhoenixLifeGate and Core.PhoenixLifeGate.IdentityOf then
        return Core.PhoenixLifeGate.IdentityOf(player)
    end
    return tostring(player)
end

local function nextId(prefix)
    Transaction.serial = Transaction.serial + 1
    return tostring(prefix) .. "-" .. tostring(nowMs()) .. "-" .. tostring(Transaction.serial)
end

local function freshCycle(player, generation, state)
    return {
        cycle_id = identityOf(player) .. ":cycle:" .. tostring(generation),
        player_identity = identityOf(player),
        arm_generation = generation,
        armed_state = state == Transaction.STATE_READY_ENABLED_BLUE,
        damage_transaction_id = nil,
        trigger_source = nil,
        trigger_started_at = nil,
        recovery_committed = false,
        cooldown_started_at = nil,
        cooldown_finished_at = nil,
        manual_reenabled_at = generation > 1 and nowMs() or nil,
        terminal_state = state,
    }
end

local function runtimeFor(player)
    local runtime = Transaction.runtime[player]
    if runtime then return runtime end
    runtime = {
        generation = 1,
        state = Transaction.STATE_READY_ENABLED_BLUE,
        cycle = freshCycle(player, 1, Transaction.STATE_READY_ENABLED_BLUE),
        activeTransaction = nil,
        duplicateCallbacks = {},
        recoveryValidation = nil,
        triggerInProgress = false,
        fallGuard = nil,
        deathLogged = false,
        successfulTriggerCount = 0,
        history = {},
    }
    Transaction.runtime[player] = runtime
    return runtime
end

local function releaseFallGuard(player, runtime, reason)
    local guard = runtime and runtime.fallGuard or nil
    if not guard then return false end
    runtime.fallGuard = nil
    print("[XNP PHOENIX FALL] transaction_guard_released=true reason=" .. tostring(reason)
        .. " transaction_id=" .. tostring(guard.transactionId))
    return true
end

local function clearCycleTransients(player, runtime, reason)
    releaseFallGuard(player, runtime, reason)
    runtime.activeTransaction = nil
    runtime.duplicateCallbacks = {}
    runtime.recoveryValidation = nil
    runtime.triggerInProgress = false
    if Core.Audio and Core.Audio.ReleasePrefix then
        Core.Audio.ReleasePrefix("PHOENIX_REVIVE:phoenix:" .. tostring(runtime.cycle.cycle_id))
    end
end

function Transaction.InitializePlayer(player, source)
    if not player then return false, "PLAYER_MISSING" end
    local runtime = runtimeFor(player)
    runtime.deathLogged = false
    local recharge = Core.PurplePhoenixState and Core.PurplePhoenixState.GetRecharge(player) or "READY"
    local enabled = Core.PurplePhoenixState and Core.PurplePhoenixState.IsEnabled(player) ~= false
    if recharge == "COOLDOWN" then
        runtime.state = Transaction.STATE_COOLDOWN_WHITE
    else
        runtime.state = enabled and Transaction.STATE_READY_ENABLED_BLUE or Transaction.STATE_READY_DISABLED_GREEN
    end
    runtime.cycle.armed_state = runtime.state == Transaction.STATE_READY_ENABLED_BLUE
    runtime.cycle.terminal_state = runtime.state
    print("[XNP PHOENIX CYCLE] initialized=true cycle_id=" .. runtime.cycle.cycle_id
        .. " state=" .. runtime.state .. " source=" .. tostring(source or "UNKNOWN"))
    return true, runtime.cycle.cycle_id
end

function Transaction.OnManualReenabled(player)
    local runtime = runtimeFor(player)
    if runtime.state == Transaction.STATE_DEAD_TOMBSTONED then return false, "DEAD_TOMBSTONED" end
    if runtime.state ~= Transaction.STATE_READY_DISABLED_GREEN then return false, "NOT_GREEN" end
    runtime.history[#runtime.history + 1] = runtime.cycle
    if #runtime.history > 5 then table.remove(runtime.history, 1) end
    clearCycleTransients(player, runtime, "MANUAL_REENABLE")
    runtime.generation = runtime.generation + 1
    runtime.state = Transaction.STATE_READY_ENABLED_BLUE
    runtime.cycle = freshCycle(player, runtime.generation, runtime.state)
    runtime.cycle.manual_reenabled_at = nowMs()
    print("[XNP PHOENIX CYCLE] rearmed=true cycle_id=" .. runtime.cycle.cycle_id
        .. " arm_generation=" .. tostring(runtime.generation))
    return true, runtime.cycle.cycle_id
end

function Transaction.OnManualDisabled(player)
    local runtime = runtimeFor(player)
    if runtime.state == Transaction.STATE_DEAD_TOMBSTONED then return false end
    clearCycleTransients(player, runtime, "MANUAL_DISABLE")
    runtime.state = Transaction.STATE_READY_DISABLED_GREEN
    runtime.cycle.armed_state = false
    runtime.cycle.terminal_state = runtime.state
    return true
end

function Transaction.OnCooldownFinished(player)
    local runtime = runtimeFor(player)
    if runtime.state ~= Transaction.STATE_COOLDOWN_WHITE then return false, "NOT_COOLDOWN" end
    clearCycleTransients(player, runtime, "COOLDOWN_FINISHED")
    runtime.state = Transaction.STATE_READY_DISABLED_GREEN
    runtime.cycle.armed_state = false
    runtime.cycle.cooldown_finished_at = nowMs()
    runtime.cycle.terminal_state = runtime.state
    print("[XNP PHOENIX CYCLE] cooldown_finished=true cycle_id=" .. runtime.cycle.cycle_id
        .. " next_state=" .. runtime.state)
    return true
end

local function livingSnapshot(player)
    if not Core.PhoenixLifeGate then return false, "LIFE_GATE_UNAVAILABLE" end
    return Core.PhoenixLifeGate.IsLivingPlayer(player)
end

local function validateRecovery(player, snapshot, config)
    local body = snapshot and snapshot.body or nil
    if not body or type(body.getOverallBodyHealth) ~= "function"
        or type(body.RestoreToFullHealth) ~= "function"
        or type(player.getHealth) ~= "function"
        or type(player.setHealth) ~= "function" then
        return false, "RECOVERY_API_INCOMPLETE"
    end
    if config.clearZombieInfection and type(body.setInfected) ~= "function" then
        return false, "INFECTION_RECOVERY_API_INCOMPLETE"
    end
    if config.clearFakeInfection and type(body.setIsFakeInfected) ~= "function" then
        return false, "FAKE_INFECTION_RECOVERY_API_INCOMPLETE"
    end
    if type(config.enduranceRestore) ~= "number" or config.enduranceRestore < 0 or config.enduranceRestore > 1 then
        return false, "ILLEGAL_ENDURANCE_TARGET"
    end
    if type(config.recoveryHealth) ~= "number" or config.recoveryHealth <= 0 or config.recoveryHealth > 1 then
        return false, "ILLEGAL_HEALTH_TARGET"
    end
    local valid, reason = Core.PurplePhoenixState.ValidateBeginRecovery(player)
    if not valid then return false, reason end
    return true, { body = body, endurance = config.enduranceRestore, health = config.recoveryHealth }
end

local function setEndurance(player, value)
    local ok, stats = invoke(player, "getStats")
    if not ok or not stats then return end
    if CharacterStat and CharacterStat.ENDURANCE and type(stats.set) == "function" then
        pcall(function() stats:set(CharacterStat.ENDURANCE, value) end)
    end
end

-- The only Phoenix health-write owner. Callers may classify and request an
-- intercept, but they never write player or BodyDamage health themselves.
local function commitRecovery(player, contract, config)
    local ok, err = pcall(function()
        contract.body:RestoreToFullHealth()
        if config.clearZombieInfection then
            contract.body:setInfected(false)
        end
        if config.clearFakeInfection then
            contract.body:setIsFakeInfected(false)
        end
        if contract.health < 1.0 and type(contract.body.setOverallBodyHealth) == "function" then
            contract.body:setOverallBodyHealth(contract.health * 100.0)
        end
        player:setHealth(contract.health)
        setEndurance(player, contract.endurance)
    end)
    if not ok then return false, "RECOVERY_WRITE_FAILED:" .. tostring(err) end
    local living, reason, snapshot = livingSnapshot(player)
    local minimumVerifiedHealth = math.max(0.01, contract.health - 0.05)
    if not living or not snapshot or snapshot.directHealth < minimumVerifiedHealth or snapshot.bodyHealth < minimumVerifiedHealth then
        return false, reason or "RECOVERY_VERIFY_FAILED"
    end
    return true, "RECOVERY_VERIFIED"
end

local function classifySource(request)
    local sourceType = tostring(request and request.sourceType or "UNKNOWN")
    local accepted = {
        PROJECTILE_FATAL_EDGE = true,
        FALL_FATAL_EDGE = true,
        EXPLOSION_FATAL_EDGE = true,
        MELEE_FATAL_EDGE = true,
        DAMAGE_THRESHOLD_EDGE = true,
    }
    return accepted[sourceType] and sourceType or "UNKNOWN"
end

local function projectedHealth(snapshot, request)
    local health = math.min(snapshot.directHealth or 1, snapshot.bodyHealth or 1)
    if request and request.forceFatalEdge == true then return 0, health end
    local damage = tonumber(request and request.anticipatedDamage)
    if damage and request.damageScale ~= "PLAYER_HEALTH" and damage > 1 then damage = damage / 100 end
    if damage then return math.max(0, health - math.max(0, damage)), health end
    return health, health
end

local function validateNeutralizer(player, sourceType, request)
    if sourceType == "FALL_FATAL_EDGE" and type(player.setLastFallSpeed) ~= "function" then
        return false, "FALL_SPEED_WRITE_API_UNAVAILABLE"
    end
    if request and request.preDamage == true and request.allowAvoidDamage == true
        and type(player.setAvoidDamage) ~= "function" then
        return false, "AVOID_DAMAGE_API_UNAVAILABLE"
    end
    return true, "NEUTRALIZER_READY"
end

local function neutralizeCurrentTransaction(player, runtime, transactionId, sourceType, request)
    if sourceType == "FALL_FATAL_EDGE" then
        if type(player.setLastFallSpeed) ~= "function" then return false, "FALL_SPEED_WRITE_API_UNAVAILABLE" end
        local setOk = pcall(function() player:setLastFallSpeed(0) end)
        if not setOk then return false, "FALL_SPEED_WRITE_FAILED" end
        return true, "CURRENT_FALL_IMPACT_SPEED_ZEROED"
    end
    if request and request.preDamage == true and request.allowAvoidDamage == true then
        if type(player.setAvoidDamage) ~= "function" then return false, "AVOID_DAMAGE_API_UNAVAILABLE" end
        local ok = pcall(function() player:setAvoidDamage(true) end)
        return ok, ok and "CURRENT_WEAPON_HIT_AVOID_DAMAGE" or "AVOID_DAMAGE_WRITE_FAILED"
    end
    return true, "RECOVERY_COMMITTED_BEFORE_THRESHOLD"
end

function Transaction.TryPredeathIntercept(player, request)
    request = request or {}
    local living, livingReason, snapshot = livingSnapshot(player)
    if not living then
        if Core.PhoenixLifeGate then
            Core.PhoenixLifeGate.LogCommittedCancellationOnce(player, request.sourceEvent, livingReason)
        end
        return false, "DEATH_ALREADY_COMMITTED"
    end

    local runtime = runtimeFor(player)
    if runtime.state ~= Transaction.STATE_READY_ENABLED_BLUE or runtime.cycle.armed_state ~= true then
        return false, "PHOENIX_NOT_BLUE"
    end
    if not Core.PurplePhoenixTrait.PlayerHasTrait(player) then return false, "TRAIT_MISSING" end
    if runtime.triggerInProgress then return false, "TRANSACTION_IN_PROGRESS" end

    local sourceType = classifySource(request)
    if sourceType == "UNKNOWN" then return false, "SOURCE_NOT_PROVEN" end
    local neutralizerReady, neutralizerReason = validateNeutralizer(player, sourceType, request)
    if not neutralizerReady then return false, neutralizerReason end
    local transactionId = request.transactionId or nextId(string.lower(sourceType))
    if runtime.duplicateCallbacks[transactionId] then return false, "TRANSACTION_ALREADY_CONSUMED" end

    local config = Core.PurplePhoenixConfig.Get()
    if config.enabled ~= true then return false, "DISABLED_BY_SANDBOX" end
    if config.maximumTriggerCount > 0 and runtime.successfulTriggerCount >= config.maximumTriggerCount then
        return false, "MAXIMUM_TRIGGER_COUNT_REACHED"
    end
    local projected, health = projectedHealth(snapshot, request)
    if projected > config.triggerHealth and health > config.triggerHealth then
        return false, "ABOVE_TRIGGER_THRESHOLD"
    end

    runtime.triggerInProgress = true
    runtime.activeTransaction = transactionId
    runtime.duplicateCallbacks[transactionId] = true
    runtime.state = Transaction.STATE_TRIGGER_COMMITTING
    runtime.cycle.damage_transaction_id = transactionId
    runtime.cycle.trigger_source = sourceType
    runtime.cycle.trigger_started_at = nowMs()
    runtime.cycle.terminal_state = runtime.state

    local valid, contract = validateRecovery(player, snapshot, config)
    if not valid then
        runtime.state = Transaction.STATE_READY_ENABLED_BLUE
        runtime.cycle.terminal_state = runtime.state
        runtime.activeTransaction = nil
        runtime.triggerInProgress = false
        runtime.duplicateCallbacks[transactionId] = nil
        return false, contract
    end
    runtime.recoveryValidation = contract

    local committed, commitReason = commitRecovery(player, contract, config)
    if not committed then
        runtime.state = Transaction.STATE_READY_ENABLED_BLUE
        runtime.cycle.terminal_state = runtime.state
        runtime.activeTransaction = nil
        runtime.recoveryValidation = nil
        runtime.triggerInProgress = false
        runtime.duplicateCallbacks[transactionId] = nil
        return false, commitReason
    end
    runtime.cycle.recovery_committed = true

    local neutralized, neutralizeReason = neutralizeCurrentTransaction(player, runtime, transactionId, sourceType, request)
    if not neutralized then
        -- Recovery has already committed. Consume this arm even if an engine
        -- setter unexpectedly throws; returning to BLUE could recover twice.
        local began = Core.PurplePhoenixState.BeginRecovery(player)
        runtime.state = began and Transaction.STATE_COOLDOWN_WHITE or Transaction.STATE_READY_DISABLED_GREEN
        runtime.cycle.armed_state = false
        runtime.cycle.cooldown_started_at = began and nowMs() or nil
        runtime.cycle.terminal_state = runtime.state
        runtime.activeTransaction = nil
        runtime.duplicateCallbacks = {}
        runtime.recoveryValidation = nil
        runtime.triggerInProgress = false
        print("[XNP PHOENIX PREDEATH] neutralize_failed=true transaction_id=" .. transactionId
            .. " reason=" .. tostring(neutralizeReason) .. " rearmed=false")
        return false, neutralizeReason
    end

    local began, cooldownOrReason = Core.PurplePhoenixState.BeginRecovery(player)
    if not began then
        releaseFallGuard(player, runtime, "COOLDOWN_START_FAILED")
        runtime.state = Transaction.STATE_READY_DISABLED_GREEN
        runtime.cycle.armed_state = false
        runtime.cycle.terminal_state = runtime.state
        runtime.activeTransaction = nil
        runtime.recoveryValidation = nil
        runtime.triggerInProgress = false
        return false, cooldownOrReason
    end

    runtime.state = Transaction.STATE_COOLDOWN_WHITE
    runtime.cycle.cooldown_started_at = nowMs()
    runtime.cycle.terminal_state = runtime.state
    runtime.activeTransaction = nil
    runtime.duplicateCallbacks = {}
    runtime.recoveryValidation = nil
    runtime.triggerInProgress = false
    Transaction.successfulRecoveries = Transaction.successfulRecoveries + 1
    runtime.successfulTriggerCount = runtime.successfulTriggerCount + 1
    Core.Audio.PlayOnce(player, "PHOENIX_REVIVE", "phoenix:" .. runtime.cycle.cycle_id .. ":" .. transactionId)
    print("[XNP PHOENIX PREDEATH] intercepted=true cycle_id=" .. runtime.cycle.cycle_id
        .. " transaction_id=" .. transactionId .. " source=" .. sourceType
        .. " neutralize=" .. neutralizeReason)
    print("[XNP PHOENIX] revive_success count=" .. tostring(Transaction.successfulRecoveries)
        .. " cycle_id=" .. runtime.cycle.cycle_id)
    return true, transactionId
end

local function falling(player)
    local ok, value = invoke(player, "isFalling")
    if ok then return value == true end
    ok, value = invoke(player, "isbFalling")
    return ok and value == true
end

function Transaction.UpdateFallPredeathEdge(player)
    if Core.PurplePhoenixConfig.Get().fallProtectionEnabled ~= true then
        return false, "FALL_PROTECTION_DISABLED_BY_SANDBOX"
    end
    local runtime = runtimeFor(player)
    if runtime.fallGuard then
        local age = nowMs() - runtime.fallGuard.armedAtMs
        if age > FALL_GUARD_TIMEOUT_MS then releaseFallGuard(player, runtime, "FALL_GUARD_TIMEOUT") end
    end
    if runtime.state ~= Transaction.STATE_READY_ENABLED_BLUE or not falling(player) then return false, "NOT_ARMED_FALL" end

    local heightOk, height = invoke(player, "getHeightAboveFloor")
    local speedOk, speed = invoke(player, "getLastFallSpeed")
    if not heightOk or not speedOk or type(height) ~= "number" or type(speed) ~= "number" then
        return false, "FALL_PREDICTOR_API_UNAVAILABLE"
    end
    height = math.max(0, height)
    speed = math.abs(speed)
    if height > FALL_ARM_MAX_HEIGHT then return false, "FALL_NOT_AT_PRELANDING_EDGE" end

    local severityOk, severity = invoke(player, "getFallSpeedSeverity")
    local severityText = severityOk and string.upper(tostring(severity)) or "UNKNOWN"
    local predictedSquared = speed * speed + 2 * FALL_ACCELERATION * height
    local lethalSquared = 2 * FALL_ACCELERATION * FALL_LETHAL_HEIGHT
    if predictedSquared < lethalSquared and not string.find(severityText, "LETHAL", 1, true) then
        return false, "FALL_NOT_LETHAL"
    end

    local landingId = runtime.cycle.cycle_id .. ":fall:" .. tostring(math.floor(nowMs() / 50))
    return Transaction.TryPredeathIntercept(player, {
        sourceType = "FALL_FATAL_EDGE",
        sourceEvent = "OnPlayerUpdatePrelandingPredictor",
        transactionId = landingId,
        forceFatalEdge = true,
        predictedImpactSpeedSquared = predictedSquared,
        heightAboveFloor = height,
    })
end

function Transaction.OnDamageNotification(player, damageType)
    local runtime = Transaction.runtime[player]
    local normalized = string.upper(tostring(damageType or ""))
    if normalized == "FALLDOWN" and runtime and runtime.fallGuard then
        return releaseFallGuard(player, runtime, "FALLDOWN_CALLBACK")
    end
    return false
end

function Transaction.OnDeath(player, reason)
    if not player then return false end
    local runtime = runtimeFor(player)
    if runtime.state == Transaction.STATE_DEAD_TOMBSTONED then return false, "ALREADY_TOMBSTONED" end
    clearCycleTransients(player, runtime, reason or "PLAYER_DEATH")
    runtime.state = Transaction.STATE_DEAD_TOMBSTONED
    runtime.cycle.armed_state = false
    runtime.cycle.terminal_state = runtime.state
    runtime.deathLogged = true
    if Core.PurplePhoenixConfig.Get().diagnosticDeathLogEnabled == true then
        print("[XNP PHOENIX DIAGNOSTIC] tombstoned=true reason=" .. tostring(reason or "PLAYER_DEATH")
            .. " successful_trigger_count=" .. tostring(runtime.successfulTriggerCount))
    end
    return true
end

function Transaction.Cleanup(player, reason)
    local runtime = player and Transaction.runtime[player] or nil
    if runtime then clearCycleTransients(player, runtime, reason or "CLEANUP") end
    return true
end

function Transaction.GetState(player)
    local runtime = runtimeFor(player)
    return runtime.state, runtime.cycle
end

function Transaction.GetAuditSnapshot(player)
    local runtime = runtimeFor(player)
    return {
        state = runtime.state,
        generation = runtime.generation,
        cycle = runtime.cycle,
        history = runtime.history,
        successfulRecoveries = Transaction.successfulRecoveries,
        successfulTriggerCount = runtime.successfulTriggerCount,
        activeTransaction = runtime.activeTransaction,
        fallGuardActive = runtime.fallGuard ~= nil,
    }
end

Core.PhoenixTransaction = Transaction
return Transaction
