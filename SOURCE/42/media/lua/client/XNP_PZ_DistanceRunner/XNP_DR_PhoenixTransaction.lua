require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixLifeGate"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixMedicalStabilizer"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixProtect"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixInvulnerability"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"

local Core = XNP_PZ_DistanceRunner
local P = Core.PurplePhoenixConstants

local Transaction = {
    STATE_READY_ENABLED_BLUE = "READY_ENABLED_BLUE",
    STATE_TRIGGER_COMMITTING = "TRIGGER_COMMITTING",
    STATE_VERIFYING_SURVIVAL = "VERIFYING_SURVIVAL",
    STATE_COOLDOWN_WHITE = "COOLDOWN_WHITE",
    STATE_READY_DISABLED_GREEN = "READY_DISABLED_GREEN",
    STATE_DEAD_TOMBSTONED = "DEAD_TOMBSTONED",
    runtime = setmetatable({}, { __mode = "k" }),
    serial = 0,
    successfulRecoveries = 0,
    falseSuccessCount = 0,
    tokenCreatedCount = 0,
    tokenConsumedCount = 0,
}

local FALL_ACCELERATION = 5.0010414
local FALL_LETHAL_HEIGHT = 3.5
local FALL_ARM_MAX_HEIGHT = 3.0
local SAME_FRAME_WINDOW_MS = 50
local BURST_GUARD_MAX_MS =
    tonumber(P.BURST_GUARD_MAX_MS) or 250
local BURST_GUARD_MAX_FRAMES =
    tonumber(P.BURST_GUARD_MAX_FRAMES) or 2
local VERIFY_MIN_FRAMES = tonumber(P.VERIFY_MIN_FRAMES) or 2
local VERIFY_OBSERVATION_MS = tonumber(P.VERIFY_OBSERVATION_MS) or 5000
local SECOND_PUSH_DELAY_MS =
    tonumber(P.PROTECT_SECOND_PULSE_DELAY_MS) or 2000
local PUSH_PULSE_COUNT = tonumber(P.PROTECT_PULSE_COUNT) or 2
local HEALTH_STABILITY_TOLERANCE =
    tonumber(P.HEALTH_STABILITY_TOLERANCE) or 0.02

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function normalizeHealth(value)
    if type(value) ~= "number" then return nil end
    return value > 1 and value / 100 or value
end

local function nextId(prefix)
    Transaction.serial = Transaction.serial + 1
    return tostring(prefix) .. "-" .. tostring(nowMs())
        .. "-" .. tostring(Transaction.serial)
end

local function runtimeFor(player)
    local runtime = Transaction.runtime[player]
    if runtime then return runtime end
    runtime = {
        state = Transaction.STATE_READY_ENABLED_BLUE,
        triggerInProgress = false,
        lastTriggerMs = 0,
        lastTransactionId = nil,
        successfulTriggerCount = 0,
        avoidDamageResetPending = false,
        avoidDamageResetAtMs = 0,
        avoidDamageResetAtFrame = 0,
        avoidDamageTransactionId = nil,
        avoidDamageStartedAtMs = 0,
        avoidDamageStartedAtFrame = 0,
        updateFrame = 0,
        damageEventSerial = 0,
        verification = nil,
        deathLogged = false,
    }
    Transaction.runtime[player] = runtime
    return runtime
end

local function livingSnapshot(player)
    return Core.PhoenixLifeGate.IsLivingPlayer(player)
end

local function persistentState(player)
    local state = Core.PurplePhoenixState.GetState(player)
    if state == Core.PurplePhoenixState.STATE_COOLDOWN_WHITE then
        return Transaction.STATE_COOLDOWN_WHITE
    end
    if state == Core.PurplePhoenixState.STATE_READY_ENABLED_BLUE then
        return Transaction.STATE_READY_ENABLED_BLUE
    end
    if state == Core.PurplePhoenixState.STATE_DEAD_TOMBSTONED then
        return Transaction.STATE_DEAD_TOMBSTONED
    end
    return Transaction.STATE_READY_DISABLED_GREEN
end

local function freshCycleSource(source)
    return source == "POST_DEATH_NEW_CHARACTER"
        or source == "POST_RESTORE_CURRENT_PLAYER"
end

function Transaction.InitializePlayer(player, source)
    if not player then return false, "PLAYER_MISSING" end
    local gateReady, gateReason =
        Core.PhoenixLifeGate.InitializePlayer(player, source)
    if not gateReady then return false, gateReason end
    if freshCycleSource(source) then
        Core.PurplePhoenixState.ResetForNewCharacterCycle(player, source)
    else
        Core.PurplePhoenixState.EnsureDefaultMigration(
            player, source or "PHOENIX_INITIALIZE")
    end
    local runtime = runtimeFor(player)
    if Core.PurplePhoenixInvulnerability
        and Core.PurplePhoenixInvulnerability.IsActive()
        and not Core.PurplePhoenixInvulnerability.IsActive(player) then
        Core.PurplePhoenixInvulnerability.Cleanup(
            nil, "INITIALIZE_PLAYER_REFERENCE_CHANGED")
    end
    if runtime.avoidDamageResetPending
        and not Core.PurplePhoenixInvulnerability.IsActive(player)
        and type(player.setAvoidDamage) == "function" then
        pcall(function() player:setAvoidDamage(false) end)
    end
    runtime.state = persistentState(player)
    runtime.triggerInProgress = false
    runtime.avoidDamageResetPending = false
    runtime.avoidDamageResetAtMs = 0
    runtime.avoidDamageResetAtFrame = 0
    runtime.avoidDamageTransactionId = nil
    runtime.avoidDamageStartedAtMs = 0
    runtime.avoidDamageStartedAtFrame = 0
    runtime.verification = nil
    runtime.deathLogged = false
    print("[XNP PHOENIX SURVIVAL] initialized=true"
        .. " state=" .. runtime.state
        .. " source=" .. tostring(source or "UNKNOWN")
        .. " phoenix_survival_reachable=true"
        .. " predeath_intercept_reachable=true"
        .. " life_stock_gated_by_phoenix=false"
        .. " invulnerability_runtime_reachable="
        .. tostring(Core.PurplePhoenixConfig.Get()
            .invulnerabilitySeconds > 0))
    return true, runtime.state
end

function Transaction.OnManualReenabled(player)
    local runtime = runtimeFor(player)
    if runtime.state == Transaction.STATE_DEAD_TOMBSTONED then
        return false, "DEAD_TOMBSTONED"
    end
    runtime.state = Transaction.STATE_READY_ENABLED_BLUE
    return true, runtime.state
end

function Transaction.OnManualDisabled(player)
    local runtime = runtimeFor(player)
    if runtime.state == Transaction.STATE_DEAD_TOMBSTONED then
        return false, "DEAD_TOMBSTONED"
    end
    runtime.state = Transaction.STATE_READY_DISABLED_GREEN
    runtime.triggerInProgress = false
    return true, runtime.state
end

function Transaction.OnCooldownFinished(player)
    local runtime = runtimeFor(player)
    if runtime.state == Transaction.STATE_DEAD_TOMBSTONED then
        return false, "DEAD_TOMBSTONED"
    end
    runtime.state = Transaction.STATE_READY_DISABLED_GREEN
    print("[XNP PHOENIX SURVIVAL] cooldown_finished=true"
        .. " next_state=" .. runtime.state
        .. " auto_rearm=false")
    return true, runtime.state
end

local function readStat(stats, stat)
    if not stats or not stat then return nil end
    local ok, value = invoke(stats, "get", stat)
    return ok and tonumber(value) or nil
end

local function writeStat(stats, stat, value)
    if not stats or not stat then return false end
    return invoke(stats, "set", stat, value)
end

local function readInfection(body, firstMethod, secondMethod)
    local ok, value = invoke(body, firstMethod)
    if ok then return value == true end
    ok, value = invoke(body, secondMethod)
    return ok and value == true or nil
end

local function validateRecovery(player, snapshot, config)
    local body = snapshot and snapshot.body or nil
    if not body or type(body.getOverallBodyHealth) ~= "function"
        or type(body.setOverallBodyHealth) ~= "function"
        or type(body.RestoreToFullHealth) ~= "function"
        or type(body.getBodyParts) ~= "function"
        or type(player.getHealth) ~= "function"
        or type(player.setHealth) ~= "function" then
        return false, "RECOVERY_API_INCOMPLETE"
    end
    local okStats, stats = invoke(player, "getStats")
    if not okStats or not stats or not CharacterStat
        or not CharacterStat.ENDURANCE then
        return false, "ENDURANCE_API_INCOMPLETE"
    end
    if type(config.enduranceRestore) ~= "number"
        or config.enduranceRestore < 0 or config.enduranceRestore > 1 then
        return false, "ILLEGAL_ENDURANCE_TARGET"
    end
    if type(config.recoveryHealth) ~= "number"
        or config.recoveryHealth <= 0 or config.recoveryHealth > 1 then
        return false, "ILLEGAL_HEALTH_TARGET"
    end
    local stateReady, stateReason =
        Core.PurplePhoenixState.ValidateBeginRecovery(player)
    if not stateReady then return false, stateReason end
    local zombieStat = CharacterStat.ZOMBIE_INFECTION
    return true, {
        player = player,
        body = body,
        stats = stats,
        healthTarget = 1.0,
        configuredHealthTarget = config.recoveryHealth,
        enduranceTarget = config.enduranceRestore,
        infectedBefore = readInfection(body, "IsInfected", "isInfected"),
        fakeInfectedBefore =
            readInfection(body, "IsFakeInfected", "isFakeInfected"),
        zombieStat = zombieStat,
        zombificationBefore = readStat(stats, zombieStat),
    }
end

local function applyInfectionPolicy(contract, config)
    if config.clearZombieInfection == true then
        invoke(contract.body, "setInfected", false)
        invoke(contract.body, "setInfectionTime", -1)
    elseif contract.infectedBefore ~= nil then
        invoke(contract.body, "setInfected", contract.infectedBefore)
    end

    if config.clearFakeInfection == true then
        invoke(contract.body, "setIsFakeInfected", false)
        invoke(contract.body, "setReduceFakeInfection", false)
    elseif contract.fakeInfectedBefore ~= nil then
        invoke(contract.body, "setIsFakeInfected",
            contract.fakeInfectedBefore)
    end

    if contract.zombieStat then
        if config.clearZombification == true then
            writeStat(contract.stats, contract.zombieStat, 0)
        elseif contract.zombificationBefore ~= nil then
            writeStat(contract.stats, contract.zombieStat,
                contract.zombificationBefore)
        end
    end
end

local function commitRecovery(player, contract, config, transactionId)
    if contract.player ~= player then
        return false, "PLAYER_OBJECT_CHANGED_BEFORE_RECOVERY"
    end
    local identityValid, identityReason =
        Core.CanonicalPlayerIdentity.Validate(player, true)
    if not identityValid then
        return false, "IDENTITY_REJECTED:" .. tostring(identityReason)
    end

    local medicalPass, medical =
        Core.PhoenixMedicalStabilizer.Stabilize(
            contract.body, transactionId, "PRIMARY_FULL_RECOVERY", player)
    if not medicalPass then
        return false, "FULL_BODY_RECOVERY_FAILED:"
            .. tostring(medical and medical.reason or "UNKNOWN")
    end

    local ok, err = pcall(function()
        contract.body:setOverallBodyHealth(contract.healthTarget * 100)
        player:setHealth(contract.healthTarget)
        contract.stats:set(CharacterStat.ENDURANCE, contract.enduranceTarget)
        applyInfectionPolicy(contract, config)
    end)
    if not ok then return false, "RECOVERY_WRITE_FAILED:" .. tostring(err) end

    local living, livingReason, snapshot = livingSnapshot(player)
    local enduranceReadback =
        readStat(contract.stats, CharacterStat.ENDURANCE)
    local minimumHealth = 0.99
    local healthPass = living and snapshot
        and snapshot.directHealth >= minimumHealth
        and snapshot.bodyHealth >= minimumHealth
    local endurancePass = enduranceReadback ~= nil
        and math.abs(enduranceReadback - contract.enduranceTarget) <= 0.01
    if not healthPass or not endurancePass then
        return false, livingReason or "RECOVERY_READBACK_FAILED"
    end
    local recoveryReadOk, recoveryReadback =
        Core.PhoenixMedicalStabilizer.ReadEvidence(contract.body, player)
    if not recoveryReadOk
        or not Core.PhoenixMedicalStabilizer.IsFullRecoveryEvidence(
            recoveryReadback) then
        return false, "FULL_BODY_POST_HEALTH_READBACK_FAILED"
    end
    medical.final = recoveryReadback
    print("[XNP PHOENIX FULL BODY READBACK]"
        .. " transaction_id=" .. tostring(transactionId)
        .. " body_part_count=" .. tostring(recoveryReadback.body_part_count)
        .. " body_part_health_min_before="
        .. tostring(medical.before.body_part_health_min)
        .. " body_part_health_min_after="
        .. tostring(recoveryReadback.body_part_health_min)
        .. " deep_wound_count_before="
        .. tostring(medical.before.deep_wound_count)
        .. " deep_wound_count_after="
        .. tostring(recoveryReadback.deep_wound_count)
        .. " cut_count_before=" .. tostring(medical.before.cut_count)
        .. " cut_count_after=" .. tostring(recoveryReadback.cut_count)
        .. " scratch_count_before="
        .. tostring(medical.before.scratch_count)
        .. " scratch_count_after="
        .. tostring(recoveryReadback.scratch_count)
        .. " bite_count_before=" .. tostring(medical.before.bite_count)
        .. " bite_count_after=" .. tostring(recoveryReadback.bite_count)
        .. " burn_count_before=" .. tostring(medical.before.burn_count)
        .. " burn_count_after=" .. tostring(recoveryReadback.burn_count)
        .. " bullet_count_before="
        .. tostring(medical.before.bullet_count)
        .. " bullet_count_after="
        .. tostring(recoveryReadback.bullet_count)
        .. " glass_count_before=" .. tostring(medical.before.glass_count)
        .. " glass_count_after=" .. tostring(recoveryReadback.glass_count)
        .. " fracture_count_before="
        .. tostring(medical.before.fracture_count)
        .. " fracture_count_after="
        .. tostring(recoveryReadback.fracture_count)
        .. " overall_health_before="
        .. tostring(medical.before.overall_health)
        .. " overall_health_after="
        .. tostring(recoveryReadback.overall_health)
        .. " player_health_before="
        .. tostring(medical.before.player_health)
        .. " player_health_after="
        .. tostring(recoveryReadback.player_health)
        .. " visible_wound_count_after="
        .. tostring(recoveryReadback.visible_wound_count)
        .. " pass=true")
    return true, {
        direct_health = snapshot.directHealth,
        body_health = snapshot.bodyHealth,
        endurance = enduranceReadback,
        medical = medical,
        active_bleed_parts = recoveryReadback.active_bleed_parts,
        bleeding_severity = recoveryReadback.bleeding_severity,
        visible_wound_count = recoveryReadback.visible_wound_count,
        body_part_count = recoveryReadback.body_part_count,
        body_part_health_min = recoveryReadback.body_part_health_min,
        full_recovery = recoveryReadback,
    }
end

local function classifySource(request)
    local sourceType = tostring(request and request.sourceType or "UNKNOWN")
    local accepted = {
        PROJECTILE_FATAL_EDGE = true,
        FALL_FATAL_EDGE = true,
        EXPLOSION_FATAL_EDGE = true,
        MELEE_FATAL_EDGE = true,
        DAMAGE_THRESHOLD_EDGE = true,
        BLEED_OR_CONTINUOUS_EDGE = true,
    }
    return accepted[sourceType] and sourceType or "UNKNOWN"
end

local function projectedHealth(snapshot, request)
    local health = math.min(
        tonumber(snapshot.directHealth) or 1,
        tonumber(snapshot.bodyHealth) or 1)
    if request.forceFatalEdge == true then return 0, health end
    if request.preDamage == true then
        local damage = tonumber(request.anticipatedDamage)
        if damage and damage > 1 then damage = damage / 100 end
        if damage then
            return math.max(0, health - math.max(0, damage)), health
        end
    end
    return health, health
end

local function captureDeathEvidence(player)
    local evidence = {
        death_serial = nil,
        death_auto_token_count = nil,
        death_auto_created_count = nil,
    }
    local registry = Core.PurpleLifeStockRegistry
    if registry and type(registry.GetLineage) == "function"
        and type(registry.CaptureLineageState) == "function" then
        local lineage = registry.GetLineage(player, false)
        if lineage then
            local saved = registry.CaptureLineageState(lineage)
            if type(saved) == "table" then
                local lineageState = saved.lineage
                if type(lineageState) == "table" then
                    evidence.death_serial =
                        tonumber(lineageState.death_serial) or 0
                end
                local count = 0
                for tokenId, token in pairs(saved.tokens or {}) do
                    if string.sub(tostring(tokenId), 1, 11) == "death-auto-"
                        or (type(token) == "table"
                            and tostring(token.issued_source) == "DEATH_AUTO") then
                        count = count + 1
                    end
                end
                evidence.death_auto_token_count = count
            end
        end
    end
    local deathAuto = Core.PurpleDeathAuto
    if deathAuto and type(deathAuto.GetAuditSnapshot) == "function" then
        local audit = deathAuto.GetAuditSnapshot()
        if type(audit) == "table" then
            evidence.death_auto_created_count =
                tonumber(audit.death_auto_created_count) or 0
        end
    end
    return evidence
end

local function evidenceDelta(before, after, key)
    local left = before and tonumber(before[key]) or nil
    local right = after and tonumber(after[key]) or nil
    if left == nil or right == nil then return 0 end
    return right - left
end

local function neutralizeCurrentTransaction(
    player, runtime, sourceType, request)
    if sourceType == "FALL_FATAL_EDGE" then
        if type(player.setLastFallSpeed) ~= "function" then
            return false, "FALL_SPEED_WRITE_API_UNAVAILABLE"
        end
        local ok = pcall(function() player:setLastFallSpeed(0) end)
        return ok, ok and "CURRENT_FALL_IMPACT_SPEED_ZEROED"
            or "FALL_SPEED_WRITE_FAILED"
    end
    if request.preDamage == true and request.allowAvoidDamage == true then
        if type(player.setAvoidDamage) ~= "function" then
            return false, "AVOID_DAMAGE_API_UNAVAILABLE"
        end
        local ok = pcall(function() player:setAvoidDamage(true) end)
        if ok then
            runtime.avoidDamageResetPending = true
            runtime.avoidDamageStartedAtMs = nowMs()
            runtime.avoidDamageStartedAtFrame = runtime.updateFrame
            runtime.avoidDamageResetAtMs =
                runtime.avoidDamageStartedAtMs + BURST_GUARD_MAX_MS
            runtime.avoidDamageResetAtFrame =
                runtime.updateFrame + BURST_GUARD_MAX_FRAMES
            runtime.avoidDamageTransactionId =
                tostring(request.transactionId or "UNSPECIFIED")
        end
        return ok, ok and "CURRENT_BATCH_BURST_GUARD"
            or "AVOID_DAMAGE_WRITE_FAILED"
    end
    return true, "POST_DAMAGE_RECOVERY_TENTATIVE"
end

local function resetCurrentHitNeutralizer(player, runtime, force)
    if not runtime.avoidDamageResetPending then return false end
    if not force and nowMs() < runtime.avoidDamageResetAtMs
        and runtime.updateFrame < runtime.avoidDamageResetAtFrame then
        return false
    end
    local persistentActive =
        Core.PurplePhoenixInvulnerability.IsActive(player)
    if not persistentActive
        and type(player.setAvoidDamage) == "function" then
        pcall(function() player:setAvoidDamage(false) end)
    end
    runtime.avoidDamageResetPending = false
    runtime.avoidDamageResetAtMs = 0
    runtime.avoidDamageResetAtFrame = 0
    runtime.avoidDamageTransactionId = nil
    runtime.avoidDamageStartedAtMs = 0
    runtime.avoidDamageStartedAtFrame = 0
    print("[XNP PHOENIX SURVIVAL] current_batch_burst_guard_reset=true"
        .. " max_ms=" .. tostring(BURST_GUARD_MAX_MS)
        .. " max_frames=" .. tostring(BURST_GUARD_MAX_FRAMES)
        .. " persistent_invulnerability="
        .. tostring(persistentActive)
        .. " defense_restore_delegated="
        .. tostring(persistentActive))
    return true
end

function Transaction.IsBurstGuardActive(player)
    if not player then return false, nil end
    local runtime = runtimeFor(player)
    if not runtime.avoidDamageResetPending then return false, nil end
    local withinTime = nowMs() < runtime.avoidDamageResetAtMs
    local withinFrames =
        runtime.updateFrame < runtime.avoidDamageResetAtFrame
    if not withinTime or not withinFrames then
        resetCurrentHitNeutralizer(player, runtime, false)
        return false, nil
    end
    return true, runtime.avoidDamageTransactionId
end

local function clearTrigger(runtime)
    runtime.triggerInProgress = false
end

local function gamePaused()
    if type(isGamePaused) ~= "function" then return false end
    local ok, paused = pcall(isGamePaused)
    return ok and paused == true
end

local function sampleVerification(player, verification)
    local living, livingReason, snapshot = livingSnapshot(player)
    if not living then return false, livingReason end
    local recoveryOk, recovery =
        Core.PhoenixMedicalStabilizer.ReadEvidence(snapshot.body, player)
    if not recoveryOk then return false, recovery end
    local endurance = nil
    local contract = verification and verification.contract or nil
    if contract and contract.stats and CharacterStat
        and CharacterStat.ENDURANCE then
        endurance = readStat(contract.stats, CharacterStat.ENDURANCE)
    end
    local sample = {
        at_ms = nowMs(),
        direct_health = snapshot.directHealth,
        body_health = snapshot.bodyHealth,
        endurance = endurance,
        active_bleed_parts = recovery.active_bleed_parts,
        bleeding_severity = recovery.bleeding_severity,
        visible_wound_count = recovery.visible_wound_count,
        body_part_count = recovery.body_part_count,
        body_part_health_min = recovery.body_part_health_min,
        full_recovery_readback = recovery.full_recovery_readback,
        recovery = recovery,
        damage_event_serial = runtimeFor(player).damageEventSerial,
    }
    verification.healthSamples[#verification.healthSamples + 1] =
        sample.direct_health
    verification.bodyHealthSamples[
        #verification.bodyHealthSamples + 1] = sample.body_health
    verification.activeBleedSamples[
        #verification.activeBleedSamples + 1] = sample.active_bleed_parts
    verification.visibleWoundSamples[
        #verification.visibleWoundSamples + 1] = sample.visible_wound_count
    verification.bodyPartHealthMinSamples[
        #verification.bodyPartHealthMinSamples + 1] =
        sample.body_part_health_min
    verification.lastSample = sample
    return true, sample
end

local function rewriteRecoveryTargets(player, verification, medical)
    local contract = verification.contract
    if not contract or contract.player ~= player then
        return false, "SECONDARY_CONTRACT_PLAYER_CHANGED"
    end
    local ok, err = pcall(function()
        contract.body:setOverallBodyHealth(contract.healthTarget * 100)
        player:setHealth(contract.healthTarget)
        contract.stats:set(CharacterStat.ENDURANCE, contract.enduranceTarget)
        applyInfectionPolicy(contract, verification.config)
    end)
    if not ok then
        return false, "SECONDARY_RECOVERY_WRITE_FAILED:" .. tostring(err)
    end
    local living, livingReason, snapshot = livingSnapshot(player)
    if not living then return false, livingReason end
    verification.stabilityBaselineDirect = snapshot.directHealth
    verification.stabilityBaselineBody = snapshot.bodyHealth
    verification.secondaryStabilization = medical
    print("[XNP PHOENIX MEDICAL STABILIZE]"
        .. " transaction_id=" .. tostring(verification.transactionId)
        .. " mode=SECONDARY_FULL_RECOVERY"
        .. " old_injury_reasserted=true"
        .. " post_trigger_damage_event_count=0"
        .. " recovery_target_rewritten_once=true"
        .. " direct_health_after=" .. tostring(snapshot.directHealth)
        .. " body_health_after=" .. tostring(snapshot.bodyHealth))
    return true, "SECONDARY_FULL_RECOVERY_COMMITTED"
end

local function stabilizeIncompleteRecovery(player, verification, sample)
    local healthDeclined =
        sample.direct_health
            < verification.stabilityBaselineDirect
                - HEALTH_STABILITY_TOLERANCE
        or sample.body_health
            < verification.stabilityBaselineBody
                - HEALTH_STABILITY_TOLERANCE
        or sample.direct_health < 0.99
        or sample.body_health < 0.99
    local incomplete = sample.full_recovery_readback ~= true
        or healthDeclined
    if incomplete then
        if verification.postTriggerDamageEventCount == 0
            and not verification.secondaryAttempted then
            verification.secondaryAttempted = true
            local stabilized, medical =
                Core.PhoenixMedicalStabilizer.Stabilize(
                    verification.contract.body,
                    verification.transactionId,
                    "SECONDARY_FULL_RECOVERY",
                    player)
            if not stabilized then
                return false, "SECONDARY_FULL_RECOVERY_FAILED:"
                    .. tostring(medical and medical.reason or "UNKNOWN")
            end
            local rewritten, rewriteReason =
                rewriteRecoveryTargets(player, verification, medical)
            if not rewritten then return false, rewriteReason end
            local readOk, readback = sampleVerification(player, verification)
            if not readOk or readback.full_recovery_readback ~= true then
                return false, "SECONDARY_FULL_RECOVERY_READBACK_FAILED"
            end
        elseif verification.postTriggerDamageEventCount == 0
            and verification.secondaryAttempted then
            return false, "OLD_INJURY_REASSERTED_AFTER_SECONDARY"
        elseif verification.postTriggerDamageEventCount > 0 then
            verification.newDamageFreeHealBlocked = true
            print("[XNP PHOENIX MEDICAL STABILIZE]"
                .. " transaction_id=" .. verification.transactionId
                .. " mode=SECONDARY_FULL_RECOVERY"
                .. " skipped=true reason=NEW_DAMAGE_RECORDED"
                .. " post_trigger_damage_event_count="
                .. tostring(verification.postTriggerDamageEventCount)
                .. " free_heal=false")
        end
    end
    return true, "FULL_RECOVERY_STABILITY_CHECK_COMPLETE"
end

local function executeSecondPulse(player, runtime, verification, elapsed)
    if verification.pulse2Completed then
        return true, "SECOND_PULSE_ALREADY_COMPLETED"
    end
    if gamePaused() then
        verification.pulse2DeferredForPause = true
        return true, "SECOND_PULSE_DEFERRED_GAME_PAUSED"
    end

    local pulseOk, pulseCount, pulseReport =
        Core.PurplePhoenixProtect.TriggerPulse(
            player, verification.transactionId, 2,
            SECOND_PUSH_DELAY_MS, elapsed)
    if not pulseOk then
        return false, "SECOND_PUSH_FAILED:" .. tostring(pulseCount)
    end
    verification.pulse2Completed = true
    verification.pulse2Affected = tonumber(pulseCount) or 0
    verification.pulse2Report = pulseReport
    verification.pulse2ActualDelayMs = elapsed
    verification.completedPulseCount =
        verification.completedPulseCount + 1
    return true, "SECOND_PUSH_COMPLETED"
end

function Transaction.NoteDamageEvent(
    player, source, damage, sourceTransactionId)
    if not player then return false, "PLAYER_MISSING" end
    if Core.PurplePhoenixInvulnerability.IsActive(player) then
        local protected, protectReason =
            Core.PurplePhoenixInvulnerability.ProtectDamage(
                player, source, nil)
        return protected, protectReason
    end
    local runtime = runtimeFor(player)
    local sourceText = tostring(source or "UNKNOWN")
    local guardActive, guardTransactionId =
        Transaction.IsBurstGuardActive(player)
    if guardActive and runtime.verification
        and tostring(guardTransactionId)
            == tostring(runtime.verification.transactionId)
        and string.find(
            sourceText, "OnWeaponHitCharacter", 1, true) ~= nil then
        print("[XNP PHOENIX BURST GUARD]"
            .. " transaction_id=" .. tostring(guardTransactionId)
            .. " source=" .. sourceText
            .. " suppressed_current_batch_callback=true"
            .. " max_ms=" .. tostring(BURST_GUARD_MAX_MS)
            .. " max_frames=" .. tostring(BURST_GUARD_MAX_FRAMES)
            .. " persistent_invulnerability=INACTIVE_FOR_NOTIFICATION")
        return true, "CURRENT_BATCH_DAMAGE_CALLBACK_SUPPRESSED"
    end
    runtime.damageEventSerial = runtime.damageEventSerial + 1
    local verification = runtime.verification
    if not verification then
        return true, "DAMAGE_EVENT_RECORDED_OUTSIDE_VERIFY"
    end
    if sourceTransactionId
        and tostring(sourceTransactionId)
            == tostring(verification.transactionId) then
        return true, "TRIGGER_DAMAGE_EVENT_IGNORED"
    end
    local provenNewAttack =
        string.find(sourceText, "OnWeaponHitCharacter", 1, true) ~= nil
        or string.find(sourceText, "PROJECTILE_FATAL_EDGE", 1, true) ~= nil
        or string.find(sourceText, "MELEE_FATAL_EDGE", 1, true) ~= nil
        or string.find(sourceText, "EXPLOSION_FATAL_EDGE", 1, true) ~= nil
        or string.find(sourceText, "FALL_FATAL_EDGE", 1, true) ~= nil
    if not provenNewAttack then
        verification.postTriggerDamageNotificationCount =
            verification.postTriggerDamageNotificationCount + 1
        print("[XNP PHOENIX SURVIVAL]"
            .. " transaction_id=" .. verification.transactionId
            .. " post_trigger_damage_notification=true"
            .. " proven_new_attack=false"
            .. " notification_count="
            .. tostring(verification.postTriggerDamageNotificationCount)
            .. " source=" .. sourceText
            .. " damage=" .. tostring(damage))
        return true, "CONTINUOUS_OR_UNCLASSIFIED_DAMAGE_RECORDED"
    end
    verification.postTriggerDamageEventCount =
        verification.postTriggerDamageEventCount + 1
    verification.lastPostTriggerDamage = {
        source = sourceText,
        damage = tonumber(damage),
        at_ms = nowMs(),
        serial = runtime.damageEventSerial,
    }
    print("[XNP PHOENIX SURVIVAL]"
        .. " transaction_id=" .. verification.transactionId
        .. " post_trigger_damage_event=true"
        .. " post_trigger_damage_event_count="
        .. tostring(verification.postTriggerDamageEventCount)
        .. " source=" .. sourceText
        .. " damage=" .. tostring(damage)
        .. " free_heal=false")
    return true, "POST_TRIGGER_DAMAGE_RECORDED"
end

local function recordFalseSuccess(player, runtime, reason)
    local verification = runtime.verification
    if not verification then return false, "NO_PENDING_VERIFICATION" end
    local damageSerialDelta = runtime.damageEventSerial
        - (tonumber(verification.damageEventSerial)
            or runtime.damageEventSerial)
    local currentEvidence = captureDeathEvidence(player)
    local serialDelta = evidenceDelta(
        verification.deathEvidence, currentEvidence, "death_serial")
    local tokenDelta = evidenceDelta(
        verification.deathEvidence, currentEvidence,
        "death_auto_token_count")
    local deathAutoDelta = evidenceDelta(
        verification.deathEvidence, currentEvidence,
        "death_auto_created_count")
    resetCurrentHitNeutralizer(player, runtime, true)
    if Core.PurplePhoenixProtect
        and type(Core.PurplePhoenixProtect.CompleteTransaction) == "function" then
        Core.PurplePhoenixProtect.CompleteTransaction(
            verification.transactionId)
    end
    runtime.verification = nil
    runtime.triggerInProgress = false
    Transaction.falseSuccessCount = Transaction.falseSuccessCount + 1
    print("[XNP PHOENIX SURVIVAL] PHOENIX_FALSE_SUCCESS=true"
        .. " transaction_id=" .. tostring(verification.transactionId)
        .. " reason=" .. tostring(reason or "SURVIVAL_VERIFICATION_FAILED")
        .. " elapsed_ms=" .. tostring(nowMs() - verification.startedAtMs)
        .. " observed_update_frames=" .. tostring(verification.frames)
        .. " death_serial_delta=" .. tostring(serialDelta)
        .. " life_stock_token_created_delta=" .. tostring(tokenDelta)
        .. " death_auto_created_delta=" .. tostring(deathAutoDelta)
        .. " damage_event_serial_delta="
        .. tostring(damageSerialDelta)
        .. " completed_push_pulses="
        .. tostring(verification.completedPulseCount or 0)
        .. " active_bleed_parts="
        .. tostring(verification.lastSample
            and verification.lastSample.active_bleed_parts or "UNKNOWN")
        .. " visible_wound_count="
        .. tostring(verification.lastSample
            and verification.lastSample.visible_wound_count or "UNKNOWN")
        .. " body_part_health_min="
        .. tostring(verification.lastSample
            and verification.lastSample.body_part_health_min or "UNKNOWN")
        .. " post_trigger_damage_event_count="
        .. tostring(verification.postTriggerDamageEventCount or 0)
        .. " post_trigger_damage_notification_count="
        .. tostring(verification.postTriggerDamageNotificationCount or 0)
        .. " final_success_counted=false")
    return true, "PHOENIX_FALSE_SUCCESS_RECORDED"
end

local function invalidateVerificationForNewDamage(player, runtime, reason)
    local verification = runtime.verification
    if not verification then return false, "NO_PENDING_VERIFICATION" end
    local damageSerialDelta = runtime.damageEventSerial
        - (tonumber(verification.damageEventSerial)
            or runtime.damageEventSerial)
    resetCurrentHitNeutralizer(player, runtime, true)
    if Core.PurplePhoenixProtect
        and type(Core.PurplePhoenixProtect.CompleteTransaction) == "function" then
        Core.PurplePhoenixProtect.CompleteTransaction(
            verification.transactionId)
    end
    runtime.verification = nil
    runtime.triggerInProgress = false
    runtime.state = persistentState(player)
    print("[XNP PHOENIX SURVIVAL]"
        .. " PHOENIX_VERIFICATION_INVALIDATED=true"
        .. " transaction_id=" .. tostring(verification.transactionId)
        .. " reason=" .. tostring(reason or "POST_TRIGGER_NEW_DAMAGE")
        .. " elapsed_ms=" .. tostring(nowMs() - verification.startedAtMs)
        .. " damage_event_serial_delta=" .. tostring(damageSerialDelta)
        .. " post_trigger_damage_event_count="
        .. tostring(verification.postTriggerDamageEventCount or 0)
        .. " active_bleed_parts="
        .. tostring(verification.lastSample
            and verification.lastSample.active_bleed_parts or "UNKNOWN")
        .. " free_heal=false"
        .. " PHOENIX_FINAL_SUCCESS=false"
        .. " PHOENIX_FALSE_SUCCESS=false")
    return true, "PHOENIX_VERIFICATION_INVALIDATED_BY_NEW_DAMAGE"
end

local function finalSuccess(player, runtime)
    local verification = runtime.verification
    if not verification then return false, "NO_PENDING_VERIFICATION" end
    local damageSerialDelta = runtime.damageEventSerial
        - (tonumber(verification.damageEventSerial)
            or runtime.damageEventSerial)
    resetCurrentHitNeutralizer(player, runtime, false)
    if Core.PurplePhoenixProtect
        and type(Core.PurplePhoenixProtect.CompleteTransaction) == "function" then
        Core.PurplePhoenixProtect.CompleteTransaction(
            verification.transactionId)
    end
    runtime.verification = nil
    runtime.lastTransactionId = verification.transactionId
    runtime.successfulTriggerCount = runtime.successfulTriggerCount + 1
    Transaction.successfulRecoveries =
        Transaction.successfulRecoveries + 1
    runtime.state = persistentState(player)
    print("[XNP PHOENIX SURVIVAL] PHOENIX_FINAL_SUCCESS=true"
        .. " transaction_id=" .. tostring(verification.transactionId)
        .. " source=" .. tostring(verification.sourceType)
        .. " elapsed_ms=" .. tostring(nowMs() - verification.startedAtMs)
        .. " observed_update_frames=" .. tostring(verification.frames)
        .. " same_player_object=true"
        .. " death_serial_delta=0"
        .. " damage_event_serial_delta="
        .. tostring(damageSerialDelta)
        .. " life_stock_token_created=0"
        .. " on_player_death_within_verify_window=0"
        .. " completed_push_pulses="
        .. tostring(verification.completedPulseCount)
        .. " pulse_2_actual_delay_ms="
        .. tostring(verification.pulse2ActualDelayMs)
        .. " active_bleed_parts=0"
        .. " bleeding_severity=0"
        .. " visible_wound_count=0"
        .. " body_part_count="
        .. tostring(verification.lastSample
            and verification.lastSample.body_part_count or "UNKNOWN")
        .. " body_part_health_min="
        .. tostring(verification.lastSample
            and verification.lastSample.body_part_health_min or "UNKNOWN")
        .. " full_body_recovery_readback=true"
        .. " post_trigger_damage_event_count="
        .. tostring(verification.postTriggerDamageEventCount)
        .. " post_trigger_damage_notification_count="
        .. tostring(verification.postTriggerDamageNotificationCount)
        .. " new_damage_free_heal=false"
        .. " persistent_invulnerability="
        .. tostring(Core.PurplePhoenixInvulnerability.IsActive(player))
        .. " invulnerability_remaining_seconds="
        .. tostring(Core.PurplePhoenixInvulnerability
            .GetRemainingSeconds(player))
        .. " state=" .. tostring(runtime.state)
        .. " successful_recovery_count="
        .. tostring(Transaction.successfulRecoveries))
    print("[XNP PHOENIX] revive_success"
        .. " transaction_id=" .. tostring(verification.transactionId)
        .. " same_player_object=true"
        .. " verification_ms=" .. tostring(VERIFY_OBSERVATION_MS)
        .. " full_body_recovery=true"
        .. " visible_wound_count=0"
        .. " completed_push_pulses="
        .. tostring(verification.completedPulseCount))
    return true, verification.transactionId
end

local function updateVerification(player, runtime)
    local verification = runtime.verification
    if not verification then return true, "NO_PENDING_VERIFICATION" end
    verification.frames = verification.frames + 1
    resetCurrentHitNeutralizer(player, runtime, false)

    local living, livingReason = livingSnapshot(player)
    local currentEvidence = captureDeathEvidence(player)
    local serialDelta = evidenceDelta(
        verification.deathEvidence, currentEvidence, "death_serial")
    local tokenDelta = evidenceDelta(
        verification.deathEvidence, currentEvidence,
        "death_auto_token_count")
    local deathAutoDelta = evidenceDelta(
        verification.deathEvidence, currentEvidence,
        "death_auto_created_count")
    if not living then
        recordFalseSuccess(player, runtime,
            "PLAYER_NOT_LIVING:" .. tostring(livingReason))
        runtime.state = Transaction.STATE_DEAD_TOMBSTONED
        Core.PurplePhoenixState.CancelPendingForDeath(player)
        return false, livingReason
    end
    if serialDelta ~= 0 or tokenDelta ~= 0 or deathAutoDelta ~= 0 then
        recordFalseSuccess(player, runtime,
            "DEATH_EVIDENCE_CHANGED_DURING_VERIFY")
        runtime.state = Transaction.STATE_READY_DISABLED_GREEN
        Core.PurplePhoenixState.ForceDisabledAfterConsumedRecovery(
            player, "DEATH_EVIDENCE_CHANGED_DURING_VERIFY")
        return false, "DEATH_EVIDENCE_CHANGED_DURING_VERIFY"
    end

    local elapsed = nowMs() - verification.startedAtMs
    local sampleOk, sample = sampleVerification(player, verification)
    if not sampleOk then
        recordFalseSuccess(player, runtime,
            "MEDICAL_OR_HEALTH_SAMPLE_FAILED:" .. tostring(sample))
        return false, sample
    end

    if verification.postTriggerDamageEventCount > 0 then
        invalidateVerificationForNewDamage(
            player, runtime, "POST_TRIGGER_NEW_ATTACK")
        return false, "POST_TRIGGER_NEW_DAMAGE_INVALIDATED_VERIFY"
    end

    if elapsed >= SECOND_PUSH_DELAY_MS
        and (sample.full_recovery_readback ~= true
            or sample.direct_health
                < verification.stabilityBaselineDirect
                    - HEALTH_STABILITY_TOLERANCE
            or sample.body_health
                < verification.stabilityBaselineBody
                    - HEALTH_STABILITY_TOLERANCE
            or sample.direct_health < 0.99
            or sample.body_health < 0.99) then
        if gamePaused() then
            runtime.state = Transaction.STATE_VERIFYING_SURVIVAL
            return true, "FULL_RECOVERY_STABILITY_DEFERRED_GAME_PAUSED"
        end
        local stableOk, stableReason =
            stabilizeIncompleteRecovery(player, verification, sample)
        if not stableOk then
            recordFalseSuccess(player, runtime, stableReason)
            return false, stableReason
        end
    end

    if elapsed >= SECOND_PUSH_DELAY_MS
        and not verification.pulse2Completed then
        local pulseOk, pulseReason =
            executeSecondPulse(player, runtime, verification, elapsed)
        if not pulseOk then
            recordFalseSuccess(player, runtime, pulseReason)
            return false, pulseReason
        end
        if not verification.pulse2Completed then
            runtime.state = Transaction.STATE_VERIFYING_SURVIVAL
            return true, pulseReason
        end
    end

    if verification.frames >= VERIFY_MIN_FRAMES
        and elapsed >= VERIFY_OBSERVATION_MS then
        if verification.completedPulseCount ~= PUSH_PULSE_COUNT
            or not verification.pulse1Completed
            or not verification.pulse2Completed then
            recordFalseSuccess(player, runtime,
                "PUSH_PULSE_CONTRACT_INCOMPLETE")
            return false, "PUSH_PULSE_CONTRACT_INCOMPLETE"
        end
        local finalSampleOk, finalSample =
            sampleVerification(player, verification)
        if not finalSampleOk then
            recordFalseSuccess(player, runtime,
                "FINAL_MEDICAL_SAMPLE_FAILED:" .. tostring(finalSample))
            return false, finalSample
        end
        if finalSample.full_recovery_readback ~= true then
            recordFalseSuccess(player, runtime,
                "FULL_BODY_RECOVERY_READBACK_FAILED_AT_FINAL_VERIFY")
            return false, "BODY_PART_OR_VISIBLE_WOUND_REMAINS"
        end
        if finalSample.direct_health < 0.99
            or finalSample.body_health < 0.99 then
            recordFalseSuccess(player, runtime,
                "PLAYER_OR_OVERALL_HEALTH_NOT_FULL_AT_FINAL_VERIFY")
            return false, "HEALTH_NOT_FULL_AT_FINAL_VERIFY"
        end
        local healthStable = true
        if verification.postTriggerDamageEventCount == 0 then
            healthStable =
                finalSample.direct_health
                    >= verification.stabilityBaselineDirect
                        - HEALTH_STABILITY_TOLERANCE
                and finalSample.body_health
                    >= verification.stabilityBaselineBody
                        - HEALTH_STABILITY_TOLERANCE
        end
        if not healthStable then
            recordFalseSuccess(player, runtime,
                "HEALTH_DECLINED_WITHOUT_NEW_DAMAGE")
            return false, "HEALTH_NOT_STABLE_AFTER_FULL_RECOVERY"
        end
        return finalSuccess(player, runtime)
    end
    runtime.state = Transaction.STATE_VERIFYING_SURVIVAL
    return true, "SURVIVAL_VERIFICATION_PENDING"
end

local function validateWeaponEventVictimRole(player, request)
    if request.sourceEvent ~= "OnWeaponHitCharacter" then
        return true
    end
    if request.victimRoleVerified ~= true
        or request.controlledPlayerRole ~= "TARGET"
        or request.targetRef ~= player
        or request.attackerRef == nil
        or request.attackerRef == player then
        return false
    end
    return true
end

function Transaction.TryPredeathIntercept(player, request)
    request = request or {}
    if not validateWeaponEventVictimRole(player, request) then
        print("[XNP PHOENIX WEAPON ROLE GATE]"
            .. " accepted=false"
            .. " reason=WEAPON_EVENT_VICTIM_ROLE_UNVERIFIED"
            .. " transaction_layer=true"
            .. " phoenix_transaction_created=false")
        return false, "WEAPON_EVENT_VICTIM_ROLE_UNVERIFIED"
    end
    local identityValid, identityReason =
        Core.CanonicalPlayerIdentity.Validate(player, true)
    if not identityValid then
        return false, "IDENTITY_REJECTED:" .. tostring(identityReason)
    end
    if Core.PurplePhoenixInvulnerability.IsActive(player) then
        local protected, protectReason =
            Core.PurplePhoenixInvulnerability.ProtectDamage(
                player, request.sourceEvent or request.sourceType, nil)
        return protected, protected
            and "INVULNERABILITY_ACTIVE_NO_SECOND_TRANSACTION"
            or protectReason
    end
    local living, livingReason, snapshot = livingSnapshot(player)
    if not living then
        Core.PhoenixLifeGate.LogCommittedCancellationOnce(
            player, request.sourceEvent, livingReason)
        return false, "DEATH_ALREADY_COMMITTED"
    end
    if not Core.PurplePhoenixTrait.PlayerHasTrait(player) then
        return false, "PURPLE_TRAIT_REQUIRED"
    end

    local runtime = runtimeFor(player)
    local now = nowMs()
    if runtime.triggerInProgress or runtime.verification then
        return false, "TRANSACTION_IN_PROGRESS"
    end
    if runtime.lastTriggerMs > 0
        and now - runtime.lastTriggerMs < SAME_FRAME_WINDOW_MS then
        return false, "DUPLICATE_SAME_FRAME"
    end
    local stateReady, stateReason =
        Core.PurplePhoenixState.ValidateBeginRecovery(player)
    if not stateReady then return false, stateReason end

    local sourceType = classifySource(request)
    if sourceType == "UNKNOWN" then return false, "SOURCE_NOT_PROVEN" end
    local config = Core.PurplePhoenixConfig.Get()
    if config.enabled ~= true then return false, "DISABLED_BY_SANDBOX" end
    if config.maximumTriggerCount > 0
        and runtime.successfulTriggerCount >= config.maximumTriggerCount then
        return false, "MAXIMUM_TRIGGER_COUNT_REACHED"
    end
    local invulnerabilitySnapshot =
        Core.PurplePhoenixConfig.GetInvulnerabilityTransactionSnapshot()
    invulnerabilitySnapshot.defense_state_before_trigger =
        Core.PurplePhoenixInvulnerability.CaptureDefenseState(player)

    local projected, healthBefore = projectedHealth(snapshot, request)
    if projected > config.triggerHealth
        and healthBefore > config.triggerHealth then
        return false, "ABOVE_TRIGGER_THRESHOLD"
    end

    local transactionId = request.transactionId
        or nextId(string.lower(sourceType))
    runtime.triggerInProgress = true
    runtime.state = Transaction.STATE_TRIGGER_COMMITTING

    local valid, contract = validateRecovery(player, snapshot, config)
    if not valid then
        clearTrigger(runtime)
        runtime.state = persistentState(player)
        return false, contract
    end

    local deathEvidence = captureDeathEvidence(player)
    local neutralized, neutralizeReason =
        neutralizeCurrentTransaction(player, runtime, sourceType, request)
    if not neutralized then
        clearTrigger(runtime)
        runtime.state = persistentState(player)
        return false, neutralizeReason
    end

    local committed, readback =
        commitRecovery(player, contract, config, transactionId)
    if not committed then
        resetCurrentHitNeutralizer(player, runtime, true)
        clearTrigger(runtime)
        runtime.state = persistentState(player)
        return false, readback
    end

    local cooldownOk, cooldownReason =
        Core.PurplePhoenixState.BeginRecovery(player)
    if not cooldownOk then
        resetCurrentHitNeutralizer(player, runtime, true)
        clearTrigger(runtime)
        Core.PurplePhoenixState.ForceDisabledAfterConsumedRecovery(
            player, "COOLDOWN_START_FAILED")
        runtime.state = Transaction.STATE_READY_DISABLED_GREEN
        return false, cooldownReason
    end

    local invulnerabilityOk, invulnerabilityReason =
        Core.PurplePhoenixInvulnerability.Start(
            player, invulnerabilitySnapshot, transactionId)

    local pushOk, pushCount, pushReport =
        Core.PurplePhoenixProtect.TriggerPulse(
            player, transactionId, 1, 0, 0)
    local soundOk, soundReason = Core.Audio.PlayOnce(
        player, "PHOENIX_REVIVE", "phoenix-survival:" .. transactionId)
    runtime.triggerInProgress = false
    runtime.lastTriggerMs = now
    runtime.lastTransactionId = transactionId
    runtime.verification = {
        player = player,
        transactionId = transactionId,
        sourceType = sourceType,
        startedAtMs = now,
        frames = 0,
        deathEvidence = deathEvidence,
        contract = contract,
        healthSamples = {},
        bodyHealthSamples = {},
        activeBleedSamples = {},
        visibleWoundSamples = {},
        bodyPartHealthMinSamples = {},
        stabilityBaselineDirect = readback.direct_health,
        stabilityBaselineBody = readback.body_health,
        config = config,
        postTriggerDamageEventCount = 0,
        postTriggerDamageNotificationCount = 0,
        damageEventSerial = runtime.damageEventSerial,
        lastPostTriggerDamage = nil,
        pulse1Completed = pushOk == true,
        pulse1Affected = tonumber(pushCount) or 0,
        pulse1Report = pushReport,
        pulse2Completed = false,
        pulse2Affected = 0,
        pulse2Report = nil,
        pulse2ActualDelayMs = nil,
        pulse2DeferredForPause = false,
        completedPulseCount = pushOk == true and 1 or 0,
        secondaryAttempted = false,
        secondaryStabilization = nil,
        newDamageFreeHealBlocked = false,
        invulnerabilityStarted = invulnerabilityOk == true,
        invulnerabilityStartReason = invulnerabilityReason,
        invulnerabilitySnapshot = invulnerabilitySnapshot,
    }
    runtime.state = Transaction.STATE_VERIFYING_SURVIVAL

    print("[XNP PHOENIX SURVIVAL] transaction_id=" .. transactionId
        .. " source=" .. sourceType
        .. " pre_damage=" .. tostring(request.preDamage == true)
        .. " health_before=" .. tostring(healthBefore)
        .. " projected_health=" .. tostring(projected)
        .. " threshold=" .. tostring(config.triggerHealth)
        .. " health_after=" .. tostring(readback.direct_health)
        .. " body_health_after=" .. tostring(readback.body_health)
        .. " endurance_after=" .. tostring(readback.endurance)
        .. " active_bleed_parts_before="
        .. tostring(readback.medical.active_bleed_parts_before)
        .. " active_bleed_parts_after="
        .. tostring(readback.active_bleed_parts)
        .. " bleeding_severity_after="
        .. tostring(readback.bleeding_severity)
        .. " body_part_count=" .. tostring(readback.body_part_count)
        .. " body_part_health_min_before="
        .. tostring(readback.medical.body_part_health_min_before)
        .. " body_part_health_min_after="
        .. tostring(readback.body_part_health_min)
        .. " visible_wound_count_before="
        .. tostring(readback.medical.visible_wound_count_before)
        .. " visible_wound_count_after="
        .. tostring(readback.visible_wound_count)
        .. " neutralize=" .. tostring(neutralizeReason)
        .. " push_1_ok=" .. tostring(pushOk == true)
        .. " push_1_count=" .. tostring(pushCount or 0)
        .. " push_2_scheduled_delay_ms="
        .. tostring(SECOND_PUSH_DELAY_MS)
        .. " sound_ok=" .. tostring(soundOk == true)
        .. " sound_reason=" .. tostring(soundReason)
        .. " cooldown_started=true"
        .. " cooldown_result=" .. tostring(cooldownReason)
        .. " invulnerability_started="
        .. tostring(invulnerabilityOk == true)
        .. " invulnerability_result="
        .. tostring(invulnerabilityReason)
        .. " invulnerability_seconds_snapshot="
        .. tostring(invulnerabilitySnapshot
            .invulnerability_seconds_snapshot)
        .. " visible_color=WHITE"
        .. " verification_window_ms=" .. tostring(VERIFY_OBSERVATION_MS)
        .. " PHOENIX_FINAL_SUCCESS=false"
        .. " result=TENTATIVE_VERIFYING")
    print("[XNP PHOENIX PREDEATH] intercepted=true"
        .. " transaction_id=" .. transactionId
        .. " source=" .. sourceType
        .. " neutralize=RECOVERY_COMMITTED_BEFORE_THRESHOLD"
        .. " current_batch_guard_ms=" .. tostring(BURST_GUARD_MAX_MS)
        .. " current_batch_guard_frames="
        .. tostring(BURST_GUARD_MAX_FRAMES)
        .. " full_body_recovery_readback=true")
    print("[XNP PHOENIX ROUND] state=WHITE visible=true"
        .. " transaction_id=" .. transactionId
        .. " final_success=false")
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
    if persistentState(player) ~= Transaction.STATE_READY_ENABLED_BLUE
        or not falling(player) then
        return false, "NOT_ARMED_FALL"
    end
    local heightOk, height = invoke(player, "getHeightAboveFloor")
    local speedOk, speed = invoke(player, "getLastFallSpeed")
    if not heightOk or not speedOk
        or type(height) ~= "number" or type(speed) ~= "number" then
        return false, "FALL_PREDICTOR_API_UNAVAILABLE"
    end
    height = math.max(0, height)
    speed = math.abs(speed)
    if height > FALL_ARM_MAX_HEIGHT then
        return false, "FALL_NOT_AT_PRELANDING_EDGE"
    end
    local severityOk, severity = invoke(player, "getFallSpeedSeverity")
    local severityText =
        severityOk and string.upper(tostring(severity)) or "UNKNOWN"
    local predictedSquared =
        speed * speed + 2 * FALL_ACCELERATION * height
    local lethalSquared = 2 * FALL_ACCELERATION * FALL_LETHAL_HEIGHT
    if predictedSquared < lethalSquared
        and not string.find(severityText, "LETHAL", 1, true) then
        return false, "FALL_NOT_LETHAL"
    end
    return Transaction.TryPredeathIntercept(player, {
        sourceType = "FALL_FATAL_EDGE",
        sourceEvent = "OnPlayerUpdatePrelandingPredictor",
        transactionId = "fall-edge-" .. tostring(math.floor(nowMs() / 50)),
        forceFatalEdge = true,
        preDamage = true,
    })
end

function Transaction.OnDamageNotification(player, damageType)
    return Transaction.TryPredeathIntercept(player, {
        sourceType = "BLEED_OR_CONTINUOUS_EDGE",
        sourceEvent = "OnPlayerGetDamage:" .. tostring(damageType),
        preDamage = false,
    })
end

function Transaction.Update(player)
    local runtime = runtimeFor(player)
    runtime.updateFrame = runtime.updateFrame + 1
    Core.PurplePhoenixInvulnerability.Update(player)
    Core.PurplePhoenixState.UpdateRecovery(player)
    if runtime.verification then
        return updateVerification(player, runtime)
    end
    resetCurrentHitNeutralizer(player, runtime, false)
    if runtime.state ~= Transaction.STATE_DEAD_TOMBSTONED then
        runtime.state = persistentState(player)
    end
    return true, runtime.state
end

function Transaction.OnDeath(player, reason)
    if not player then return false, "PLAYER_MISSING" end
    local runtime = runtimeFor(player)
    if Core.PurplePhoenixInvulnerability.IsActive(player) then
        local protected =
            Core.PurplePhoenixInvulnerability.ProtectDamage(
                player, "ON_PLAYER_DEATH_LEAK", nil)
        local living = livingSnapshot(player)
        if protected and living then
            print("[XNP PHOENIX INVULNERABILITY] death_event_leak_recovered=true"
                .. " transaction_id="
                .. tostring(runtime.lastTransactionId)
                .. " new_transaction=false")
            return true, "INVULNERABILITY_DEATH_EVENT_LEAK_RECOVERED"
        end
    end
    if runtime.verification then
        recordFalseSuccess(player, runtime,
            "ON_PLAYER_DEATH_DURING_VERIFY:"
                .. tostring(reason or "PLAYER_DEATH"))
    end
    resetCurrentHitNeutralizer(player, runtime, true)
    Core.PurplePhoenixInvulnerability.Cleanup(
        player, "PLAYER_DEATH:" .. tostring(reason or "UNKNOWN"))
    runtime.triggerInProgress = false
    runtime.state = Transaction.STATE_DEAD_TOMBSTONED
    runtime.deathLogged = true
    Core.PurplePhoenixState.CancelPendingForDeath(player)
    Core.PhoenixLifeGate.MarkDead(player, reason or "PLAYER_DEATH")
    return true, "PHOENIX_SURVIVAL_TOMBSTONED"
end

function Transaction.Cleanup(player, reason)
    if player then
        local runtime = Transaction.runtime[player]
        if runtime then
            if runtime.verification then
                recordFalseSuccess(player, runtime,
                    "SESSION_ENDED_BEFORE_VERIFICATION:"
                        .. tostring(reason or "CLEANUP"))
            end
            resetCurrentHitNeutralizer(player, runtime, true)
            runtime.triggerInProgress = false
        end
        Core.PhoenixLifeGate.ReleasePlayer(player)
    end
    Core.PurplePhoenixInvulnerability.Cleanup(
        player, reason or "TRANSACTION_CLEANUP")
    return true, tostring(reason or "CLEANUP")
end

function Transaction.GetState(player)
    local runtime = runtimeFor(player)
    if runtime.verification then
        runtime.state = Transaction.STATE_VERIFYING_SURVIVAL
    elseif runtime.state ~= Transaction.STATE_DEAD_TOMBSTONED then
        runtime.state = persistentState(player)
    end
    return runtime.state
end

function Transaction.GetAuditSnapshot(player)
    local runtime = runtimeFor(player)
    return {
        state = runtime.state,
        successful_recoveries = Transaction.successfulRecoveries,
        false_success_count = Transaction.falseSuccessCount,
        successful_trigger_count = runtime.successfulTriggerCount,
        last_transaction_id = runtime.lastTransactionId,
        same_frame_window_ms = SAME_FRAME_WINDOW_MS,
        burst_guard_max_ms = BURST_GUARD_MAX_MS,
        burst_guard_max_frames = BURST_GUARD_MAX_FRAMES,
        verification_min_frames = VERIFY_MIN_FRAMES,
        verification_observation_ms = VERIFY_OBSERVATION_MS,
        second_push_delay_ms = SECOND_PUSH_DELAY_MS,
        configured_push_pulse_count = PUSH_PULSE_COUNT,
        verification_pending = runtime.verification ~= nil,
        verification_completed_push_pulses = runtime.verification
            and runtime.verification.completedPulseCount or 0,
        post_trigger_damage_event_count = runtime.verification
            and runtime.verification.postTriggerDamageEventCount or 0,
        post_trigger_damage_notification_count = runtime.verification
            and runtime.verification.postTriggerDamageNotificationCount or 0,
        secondary_stabilization_attempted = runtime.verification
            and runtime.verification.secondaryAttempted == true or false,
        full_body_recovery_required = true,
        all_visible_wounds_zero_required = true,
        new_damage_free_heal_blocked = runtime.verification
            and runtime.verification.newDamageFreeHealBlocked == true or false,
        token_created_count = Transaction.tokenCreatedCount,
        token_consumed_count = Transaction.tokenConsumedCount,
        invulnerability_runtime_reachable =
            Core.PurplePhoenixConfig.Get().invulnerabilitySeconds > 0
                and 1 or 0,
        persistent_invulnerability =
            Core.PurplePhoenixInvulnerability.IsActive(player),
        invulnerability =
            Core.PurplePhoenixInvulnerability.GetAuditSnapshot(),
        writes_player_coordinates = false,
    }
end

Core.PhoenixTransaction = Transaction
return Transaction
