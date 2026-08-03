require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Load = {
    PULSE_ID = "RED_CRAFT_PHYSICAL_LOAD_PULSE_A",
    states = setmetatable({}, { __mode = "k" }),
    activePlayer = nil,
    summaryCount = 0,
    duplicateTransactionCount = 0,
    cancelledWriteCount = 0,
    failedWriteCount = 0,
    duplicateFatigueWriteCount = 0,
    dangerousOverheatCount = 0,
    permanentTemperatureLockCount = 0,
}

local WETNESS_DELTAS = { 6, 8, 12 }
local ENDURANCE_DELTAS = { 0.08, 0.13, 0.18 }
local WETNESS_SAFE_CAP = 100
local ENDURANCE_SAFE_FLOOR = 0.05
local UPDATE_INTERVAL_SECONDS = 0.25
local HEAT_PULSE_MAXIMUM_SECONDS = 5
local HEAT_SUCCESS_DELTA_C = 0.3

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    local args = { ... }
    return pcall(function()
        return object[method](object, unpack(args))
    end)
end

local function finite(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function clamp(value, minimum, maximum)
    value = tonumber(value)
    if not finite(value) then return minimum end
    return math.max(minimum, math.min(maximum, value))
end

local function closeEnough(left, right, tolerance)
    return finite(left) and finite(right)
        and math.abs(left - right) <= (tolerance or 0.001)
end

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and finite(tonumber(value)) then
            return tonumber(value) / 1000
        end
    end
    return tonumber(os.time()) or 0
end

local function sandboxBoolean(name, fallback)
    local tuning = Core.SandboxTuning
    if tuning and type(tuning.GetBoolean) == "function" then
        local ok, value = pcall(tuning.GetBoolean, name, fallback)
        if ok then return value == true end
    end
    return fallback
end

local function sandboxNumber(name, fallback, minimum, maximum)
    local tuning = Core.SandboxTuning
    if tuning and type(tuning.GetNumber) == "function" then
        local ok, value = pcall(
            tuning.GetNumber, name, fallback, minimum, maximum)
        if ok and finite(tonumber(value)) then return tonumber(value) end
    end
    return fallback
end

local function roundedOption(name, fallback, minimum, maximum)
    return math.floor(sandboxNumber(
        name, fallback, minimum, maximum) + 0.5)
end

local function readStats(player)
    local ok, stats = invoke(player, "getStats")
    return ok and stats or nil
end

local function readStat(stats, stat)
    if not stats or not stat then return nil end
    local ok, value = invoke(stats, "get", stat)
    value = tonumber(value)
    return ok and finite(value) and value or nil
end

local function writeStat(stats, stat, value)
    if not stats or not stat or not finite(value) then
        return false, nil
    end
    local ok = invoke(stats, "set", stat, value)
    if not ok then return false, readStat(stats, stat) end
    local readback = readStat(stats, stat)
    return closeEnough(readback, value, 0.001), readback
end

local function readBodyDamage(player)
    local ok, body = invoke(player, "getBodyDamage")
    return ok and body or nil
end

local function readThermoregulator(player)
    local body = readBodyDamage(player)
    local ok, thermoregulator = invoke(body, "getThermoregulator")
    return ok and thermoregulator or nil
end

local function readThermalValue(thermoregulator, method)
    local ok, value = invoke(thermoregulator, method)
    value = tonumber(value)
    return ok and finite(value) and value or nil
end

local function isDead(player)
    local ok, value = invoke(player, "isDead")
    return player == nil or (ok and value == true)
end

local function stateFor(player)
    local state = Load.states[player]
    if not state then
        state = {
            layers = {},
            seenTransactions = {},
            nextHeatUpdate = 0,
            heatPulse = nil,
        }
        Load.states[player] = state
    end
    return state
end

local function pruneLayers(state, now)
    local kept = {}
    for index = 1, #(state and state.layers or {}) do
        local layer = state.layers[index]
        if tonumber(layer.expiresAt) and layer.expiresAt > now then
            kept[#kept + 1] = layer
        end
    end
    state.layers = kept
    return #kept
end

local function metabolicSelection(intensity, stackCount)
    if not Metabolics then return nil, nil, nil end
    local level = clamp(intensity + (stackCount >= 2 and 1 or 0), 1, 3)
    local names = { "LightWork", "MediumWork", "HeavyWork" }
    local name = names[level]
    local value = Metabolics[name]
    if not value then return nil, name, nil end
    local ok, numeric = invoke(value, "getMet")
    numeric = tonumber(numeric)
    return value, name, ok and finite(numeric) and numeric or nil
end

local function applyHeat(player, stackCount, now)
    local result = {
        route = "B_BOUNDED_METABOLIC",
        before = nil,
        after = nil,
        coreRate = nil,
        metabolicBefore = nil,
        metabolicAfter = nil,
        readbackPass = false,
        changed = false,
        safeCapHit = false,
        pulse = nil,
    }
    if not sandboxBoolean("RedCraftBodyHeatEnabled", true) then
        return result
    end
    local thermoregulator = readThermoregulator(player)
    local intensity = roundedOption(
        "RedCraftHeatFeedbackIntensity", 2, 1, 3)
    local target, targetName, targetNumeric =
        metabolicSelection(intensity, stackCount)
    if not thermoregulator or not target or not finite(targetNumeric)
        or type(player.setMetabolicTarget) ~= "function" then
        result.route = "B_API_UNAVAILABLE"
        return result
    end

    result.before = readThermalValue(thermoregulator, "getCoreTemperature")
    result.metabolicBefore =
        readThermalValue(thermoregulator, "getMetabolicTarget")
    local requested = (Metabolics and Metabolics.HeavyWork) or target
    local requestedName = "HeavyWork"
    local requestedNumeric = targetNumeric
    local requestedOk, requestedMet = invoke(requested, "getMet")
    if requestedOk and finite(tonumber(requestedMet)) then
        requestedNumeric = tonumber(requestedMet)
    else
        requested = target
        requestedName = targetName
    end
    if finite(result.metabolicBefore)
        and result.metabolicBefore > requestedNumeric then
        result.metabolicAfter = result.metabolicBefore
        result.readbackPass = true
        result.route = "B_BOUNDED_METABOLIC_PRESERVED_HIGHER_TARGET"
    else
        local metabolicWriteOk = invoke(player, "setMetabolicTarget", requested)
        result.metabolicAfter =
            readThermalValue(thermoregulator, "getMetabolicTarget")
        result.readbackPass = metabolicWriteOk == true
            and finite(result.metabolicAfter)
            and result.metabolicAfter + 0.001 >= requestedNumeric
        result.route = "B_BOUNDED_METABOLIC_" .. requestedName
    end
    local increase = sandboxNumber(
        "RedCraftImmediateTemperatureIncreaseC", 0.5, 0, 1.5)
    local maximum = sandboxNumber(
        "RedCraftMaximumBodyTemperatureC", 38.5, 37, 40)
    result.after = readThermalValue(thermoregulator, "getCoreTemperature")
    result.coreRate = readThermalValue(thermoregulator, "getCoreRateOfChange")
    if result.readbackPass and finite(result.before) then
        result.pulse = {
            route = result.route,
            startedAt = now,
            expiresAt = now + HEAT_PULSE_MAXIMUM_SECONDS,
            coreBefore = result.before,
            targetCore = math.min(maximum, result.before + increase),
            restoreMetabolic = result.metabolicBefore,
            targetMetabolic = requestedNumeric,
            success = false,
            restored = false,
            nextLogAt = 0.5,
        }
    end
    return result
end

local function desiredWetnessTarget(before, intensity, stackCount, mode)
    if sandboxBoolean("RedCraftImmediateFullSweatEnabled", true) then
        return clamp(sandboxNumber(
            "RedCraftImmediateSweatPercent", 100, 0, 100), 0, WETNESS_SAFE_CAP)
    end
    local target = before + (WETNESS_DELTAS[intensity] or 8)
    if mode == 1 and stackCount >= 2 then
        target = math.max(target, 16)
    elseif mode == 2 then
        target = math.max(target, 16)
    elseif mode >= 3 then
        target = math.max(target, 25)
    end
    return math.min(target, WETNESS_SAFE_CAP)
end

local function applyWetness(player, stackCount, addLayer)
    local result = {
        route = "DISABLED",
        before = nil,
        after = nil,
        readbackPass = false,
        changed = false,
        safeCapHit = false,
    }
    if not sandboxBoolean("RedCraftSweatEnabled", true) then
        return result
    end
    if addLayer ~= true then
        result.route = "STACK_LIMIT_REFRESH_NO_PEAK_INCREASE"
        return result
    end
    local stats = readStats(player)
    local stat = CharacterStat and CharacterStat.WETNESS or nil
    local before = readStat(stats, stat)
    if before == nil then
        result.route = "FAIL_CLOSED_CHARACTER_STAT_WETNESS_UNAVAILABLE"
        return result
    end
    result.before = before
    local intensity = roundedOption("RedCraftSweatIntensity", 2, 1, 3)
    local visibleMode = roundedOption(
        "RedCraftMinimumVisibleFeedbackMode", 1, 1, 3)
    local target = desiredWetnessTarget(
        before, intensity, stackCount, visibleMode)
    local delta = math.max(0, target - before)
    if delta <= 0 then
        result.route = "BODY_WETNESS_SAFE_CAP"
        result.after = before
        result.readbackPass = true
        result.safeCapHit = true
        return result
    end

    local body = readBodyDamage(player)
    if body and type(body.increaseBodyWetness) == "function" then
        local writeOk = invoke(body, "increaseBodyWetness", delta)
        result.after = readStat(stats, stat)
        result.route = "BODY_DAMAGE_INCREASE_BODY_WETNESS"
        result.readbackPass = writeOk == true
            and closeEnough(result.after, target, 0.01)
    else
        result.readbackPass, result.after = writeStat(stats, stat, target)
        result.route = result.readbackPass
            and "CHARACTER_STAT_WETNESS_VERIFIED_FALLBACK"
            or "FAIL_CLOSED_WETNESS_WRITE_UNAVAILABLE"
    end
    result.changed = result.readbackPass
        and finite(result.after) and result.after > before + 0.001
    result.safeCapHit = target >= WETNESS_SAFE_CAP - 0.001
    return result
end

local function desiredEnduranceTarget(before, intensity, stackCount, mode)
    local percentage = sandboxNumber(
        "RedCraftImmediateEnduranceTargetPercent", 10, 5, 50)
    return math.max(0, math.min(before, percentage / 100.0))
end

local function applyExertion(player, stackCount, addLayer)
    local result = {
        route = "DISABLED",
        before = nil,
        after = nil,
        readbackPass = false,
        changed = false,
        safeCapHit = false,
    }
    if not sandboxBoolean("RedCraftExertionFeedbackEnabled", true) then
        return result
    end
    if addLayer ~= true then
        result.route = "STACK_LIMIT_REFRESH_NO_PEAK_INCREASE"
        return result
    end
    local stats = readStats(player)
    local stat = CharacterStat and CharacterStat.ENDURANCE or nil
    local before = readStat(stats, stat)
    if before == nil then
        result.route = "FAIL_CLOSED_CHARACTER_STAT_ENDURANCE_UNAVAILABLE"
        return result
    end
    result.before = before
    local intensity = roundedOption(
        "RedCraftExertionFeedbackIntensity", 2, 1, 3)
    local visibleMode = roundedOption(
        "RedCraftMinimumVisibleFeedbackMode", 1, 1, 3)
    local target = desiredEnduranceTarget(
        before, intensity, stackCount, visibleMode)
    local delta = math.max(0, before - target)
    if delta <= 0 then
        result.route = "ENDURANCE_SAFE_FLOOR"
        result.after = before
        result.readbackPass = true
        result.safeCapHit = true
        return result
    end

    local writeOk = false
    if stats and type(stats.remove) == "function" then
        writeOk = invoke(stats, "remove", stat, delta)
        result.route = "CHARACTER_STAT_ENDURANCE_REMOVE"
        result.after = readStat(stats, stat)
        result.readbackPass = writeOk == true
            and closeEnough(result.after, target, 0.001)
    else
        result.readbackPass, result.after = writeStat(stats, stat, target)
        result.route = result.readbackPass
            and "CHARACTER_STAT_ENDURANCE_SET_VERIFIED_FALLBACK"
            or "FAIL_CLOSED_ENDURANCE_WRITE_UNAVAILABLE"
    end
    result.changed = result.readbackPass
        and finite(result.after) and result.after < before - 0.001
    result.safeCapHit = target <= ENDURANCE_SAFE_FLOOR + 0.001
    return result
end

local function moodleLevel(player, moodleType)
    local okMoodles, moodles = invoke(player, "getMoodles")
    if not okMoodles or not moodles or not moodleType then return nil end
    local ok, level = invoke(moodles, "getMoodleLevel", moodleType)
    level = tonumber(level)
    return ok and finite(level) and level or nil
end

local function visibleFeedbackDetected(player, wetness, endurance)
    local wetLevel = moodleLevel(
        player, MoodleType and MoodleType.WET or nil)
    local enduranceLevel = moodleLevel(
        player, MoodleType and MoodleType.ENDURANCE or nil)
    local heatLevel = moodleLevel(
        player, MoodleType and MoodleType.HYPERTHERMIA or nil)
    local visible = (finite(wetLevel) and wetLevel > 0)
        or (finite(enduranceLevel) and enduranceLevel > 0)
        or (finite(heatLevel) and heatLevel > 0)
        or (finite(wetness) and wetness >= 15)
        or (finite(endurance) and endurance <= 0.75)
    return visible == true, wetLevel, enduranceLevel, heatLevel
end

local function boolText(value)
    return value == true and "true" or "false"
end

local function logTemperatureCapability(player)
    local body = readBodyDamage(player)
    local thermoregulator = readThermoregulator(player)
    print("[XNP RED TEMPERATURE CAPABILITY]"
        .. " body_getter_available="
        .. boolText(body and type(body.getTemperature) == "function")
        .. " body_setter_available="
        .. boolText(body and type(body.setTemperature) == "function")
        .. " thermo_core_getter_available="
        .. boolText(thermoregulator
            and type(thermoregulator.getCoreTemperature) == "function")
        .. " metabolic_target_available="
        .. boolText(type(player and player.setMetabolicTarget) == "function")
        .. " route_selected=B_BOUNDED_METABOLIC")
end

local function restoreHeatPulse(player, state, reason)
    local pulse = state and state.heatPulse
    if not pulse or pulse.restored then return false end
    pulse.restored = true
    local restored = false
    if finite(pulse.restoreMetabolic)
        and type(player and player.setMetabolicTarget) == "function" then
        restored = invoke(player, "setMetabolicTarget", pulse.restoreMetabolic)
    end
    print("[XNP RED TEMPERATURE ROUTE] route=B_BOUNDED_METABOLIC"
        .. " phase=restore reason=" .. tostring(reason)
        .. " metabolic_restored=" .. boolText(restored))
    state.heatPulse = nil
    return restored
end

local function updateHeatPulse(player, state, now)
    local pulse = state and state.heatPulse
    if not pulse then return false, "NO_HEAT_PULSE" end
    local thermoregulator = readThermoregulator(player)
    if not thermoregulator then
        restoreHeatPulse(player, state, "THERMOREGULATOR_UNAVAILABLE")
        return false, "THERMOREGULATOR_UNAVAILABLE"
    end
    local core = readThermalValue(thermoregulator, "getCoreTemperature")
    local rate = readThermalValue(thermoregulator, "getCoreRateOfChange")
    local delta = finite(core) and finite(pulse.coreBefore)
        and core - pulse.coreBefore or nil
    local success = finite(delta) and delta >= HEAT_SUCCESS_DELTA_C
    local elapsed = math.max(0, now - pulse.startedAt)
    if success or elapsed + 0.001 >= (pulse.nextLogAt or math.huge) then
        print("[XNP RED TEMPERATURE READBACK] route=B_BOUNDED_METABOLIC"
            .. " elapsed_seconds=" .. tostring(elapsed)
            .. " core_temperature_before=" .. tostring(pulse.coreBefore)
            .. " core_temperature_now=" .. tostring(core)
            .. " core_rate_of_change=" .. tostring(rate)
            .. " temperature_effect_success=" .. boolText(success))
        if pulse.nextLogAt <= 0.5 then
            pulse.nextLogAt = 1
        elseif pulse.nextLogAt <= 1 then
            pulse.nextLogAt = 3
        elseif pulse.nextLogAt <= 3 then
            pulse.nextLogAt = 5
        else
            pulse.nextLogAt = math.huge
        end
    end
    if success then pulse.success = true end
    if (finite(core) and core >= pulse.targetCore)
        or now >= pulse.expiresAt then
        restoreHeatPulse(player, state,
            success and "TARGET_REACHED" or "PULSE_TIMEOUT")
        return success, success and "TEMPERATURE_DELTA_REACHED"
            or "CORE_TEMPERATURE_DID_NOT_RISE_ENOUGH"
    end
    return true, "HEAT_PULSE_ACTIVE"
end

local function logSummary(summary)
    Load.summaryCount = Load.summaryCount + 1
    print("[XNP RED PHYSICAL LOAD]"
        .. " transaction_id=" .. tostring(summary.transaction_id)
        .. " stack_before=" .. tostring(summary.stack_before)
        .. " stack_after=" .. tostring(summary.stack_after)
        .. " duration_seconds=" .. tostring(summary.duration_seconds)
        .. " temperature_route=" .. tostring(summary.temperature_route)
        .. " temperature_before=" .. tostring(summary.temperature_before)
        .. " temperature_after=" .. tostring(summary.temperature_after)
        .. " temperature_readback_pass="
        .. boolText(summary.temperature_readback_pass)
        .. " metabolic_before=" .. tostring(summary.metabolic_before)
        .. " metabolic_after=" .. tostring(summary.metabolic_after)
        .. " sweat_route=" .. tostring(summary.sweat_route)
        .. " wetness_before=" .. tostring(summary.wetness_before)
        .. " wetness_after=" .. tostring(summary.wetness_after)
        .. " wetness_readback_pass="
        .. boolText(summary.wetness_readback_pass)
        .. " exertion_route=" .. tostring(summary.exertion_route)
        .. " exertion_before=" .. tostring(summary.exertion_before)
        .. " exertion_after=" .. tostring(summary.exertion_after)
        .. " exertion_readback_pass="
        .. boolText(summary.exertion_readback_pass)
        .. " fatigue_before=" .. tostring(summary.fatigue_before)
        .. " fatigue_after=" .. tostring(summary.fatigue_after)
        .. " duplicate_fatigue_write=false"
        .. " visible_feedback_detected="
        .. boolText(summary.visible_feedback_detected)
        .. " changed_category_count="
        .. tostring(summary.changed_category_count)
        .. " safe_cap_hit=" .. boolText(summary.safe_cap_hit))
end

local function makeBlockedSummary(transactionInfo, reason)
    return {
        transaction_id = transactionInfo and transactionInfo.transactionId
            or "UNAVAILABLE",
        stack_before = 0,
        stack_after = 0,
        duration_seconds = 0,
        temperature_route = "FAIL_CLOSED_" .. tostring(reason),
        temperature_before = nil,
        temperature_after = nil,
        temperature_readback_pass = false,
        metabolic_before = nil,
        metabolic_after = nil,
        sweat_route = "FAIL_CLOSED_" .. tostring(reason),
        wetness_before = nil,
        wetness_after = nil,
        wetness_readback_pass = false,
        exertion_route = "FAIL_CLOSED_" .. tostring(reason),
        exertion_before = nil,
        exertion_after = nil,
        exertion_readback_pass = false,
        fatigue_before = transactionInfo and transactionInfo.fatigueBefore,
        fatigue_after = transactionInfo and transactionInfo.fatigueAfter,
        visible_feedback_detected = false,
        changed_category_count = 0,
        safe_cap_hit = false,
    }
end

function Load.Start(player, transactionInfo)
    transactionInfo = type(transactionInfo) == "table"
        and transactionInfo or {}
    local transactionId = tostring(
        transactionInfo.transactionId or "UNAVAILABLE")
    if isDead(player) then
        local summary = makeBlockedSummary(
            transactionInfo, "PLAYER_INVALID_AFTER_COMMIT")
        logSummary(summary)
        return false, "PLAYER_INVALID_AFTER_COMMIT", summary
    end
    if transactionInfo.costsReadbackPass ~= true then
        local summary = makeBlockedSummary(
            transactionInfo, "CRAFT_COST_READBACK_NOT_CONFIRMED")
        logSummary(summary)
        return false, "CRAFT_COST_READBACK_NOT_CONFIRMED", summary
    end
    local allowed, authorityReason = false, "AUTHORITY_API_UNAVAILABLE"
    if Core.Authority
        and type(Core.Authority.CanWriteNonFoodStats) == "function" then
        local authorityCallOk
        authorityCallOk, allowed, authorityReason = pcall(
            Core.Authority.CanWriteNonFoodStats,
            player, "RED_CRAFT_PHYSICAL_LOAD")
        if not authorityCallOk then
            allowed = false
            authorityReason = "AUTHORITY_API_EXCEPTION_FAIL_CLOSED"
        end
    end
    if allowed ~= true then
        local summary = makeBlockedSummary(
            transactionInfo, authorityReason)
        logSummary(summary)
        return false, authorityReason, summary
    end

    if Load.activePlayer and Load.activePlayer ~= player then
        Load.Cleanup("PLAYER_REPLACED", Load.activePlayer)
    end
    Load.activePlayer = player
    local state = stateFor(player)
    if state.seenTransactions[transactionId] == true then
        Load.duplicateTransactionCount = Load.duplicateTransactionCount + 1
        return false, "DUPLICATE_TRANSACTION"
    end
    state.seenTransactions[transactionId] = true

    local now = nowSeconds()
    pruneLayers(state, now)
    local stackBefore = #state.layers
    local duration = sandboxNumber(
        "RedCraftPhysicalLoadDurationSeconds", 20, 1, 120)
    local stackLimit = roundedOption(
        "RedCraftPhysicalLoadStackLimit", 3, 1, 3)
    local addedLayer = stackBefore < stackLimit
    if addedLayer then
        state.layers[#state.layers + 1] = {
            sourceTransaction = transactionId,
            expiresAt = now + duration,
        }
    else
        for index = 1, #state.layers do
            state.layers[index].expiresAt = now + duration
        end
    end
    local stackAfter = #state.layers

    logTemperatureCapability(player)
    local heat = applyHeat(player, stackAfter, now)
    local wetness = applyWetness(player, stackAfter, addedLayer)
    local exertion = applyExertion(player, stackAfter, addedLayer)
    state.nextHeatUpdate = now + UPDATE_INTERVAL_SECONDS
    state.heatPulse = heat.pulse

    print("[XNP RED TEMPERATURE ROUTE] route=" .. tostring(heat.route)
        .. " core_temperature_before=" .. tostring(heat.before)
        .. " core_temperature_t0=" .. tostring(heat.after)
        .. " metabolic_before=" .. tostring(heat.metabolicBefore)
        .. " metabolic_active=" .. tostring(heat.metabolicAfter)
        .. " temperature_effect_success=false")
    print("[XNP RED SWEAT READBACK] route=" .. tostring(wetness.route)
        .. " wetness_before=" .. tostring(wetness.before)
        .. " wetness_target=100 wetness_immediate=" .. tostring(wetness.after)
        .. " wetness_readback_pass=" .. boolText(wetness.readbackPass))
    print("[XNP RED EXERTION READBACK] route=" .. tostring(exertion.route)
        .. " endurance_before=" .. tostring(exertion.before)
        .. " endurance_target=0.1 endurance_after="
        .. tostring(exertion.after)
        .. " exertion_readback_pass=" .. boolText(exertion.readbackPass))

    local changedCategories = 0
    if heat.changed then changedCategories = changedCategories + 1 end
    if wetness.changed then changedCategories = changedCategories + 1 end
    if exertion.changed then changedCategories = changedCategories + 1 end
    local visible, wetMoodle, enduranceMoodle, heatMoodle =
        visibleFeedbackDetected(player, wetness.after, exertion.after)
    local summary = {
        transaction_id = transactionId,
        stack_before = stackBefore,
        stack_after = stackAfter,
        duration_seconds = duration,
        temperature_route = heat.route,
        temperature_before = heat.before,
        temperature_after = heat.after,
        temperature_readback_pass = heat.readbackPass,
        metabolic_before = heat.metabolicBefore,
        metabolic_after = heat.metabolicAfter,
        sweat_route = wetness.route,
        wetness_before = wetness.before,
        wetness_after = wetness.after,
        wetness_readback_pass = wetness.readbackPass,
        exertion_route = exertion.route,
        exertion_before = exertion.before,
        exertion_after = exertion.after,
        exertion_readback_pass = exertion.readbackPass,
        fatigue_before = transactionInfo.fatigueBefore,
        fatigue_after = transactionInfo.fatigueAfter,
        duplicate_fatigue_write = false,
        visible_feedback_detected = visible,
        wet_moodle_level = wetMoodle,
        endurance_moodle_level = enduranceMoodle,
        heat_moodle_level = heatMoodle,
        changed_category_count = changedCategories,
        safe_cap_hit = heat.safeCapHit or wetness.safeCapHit
            or exertion.safeCapHit or not addedLayer,
        authority = authorityReason,
    }
    state.lastSummary = summary
    logSummary(summary)
    return true, "PHYSICAL_LOAD_STARTED", summary
end

function Load.Update(player)
    if Load.activePlayer and Load.activePlayer ~= player then
        Load.Cleanup("PLAYER_REPLACED", Load.activePlayer)
    end
    local state = player and Load.states[player] or nil
    if not state then return false, "NO_ACTIVE_PULSE" end
    if isDead(player) then
        Load.Cleanup("PLAYER_DEATH", player)
        return false, "PLAYER_DEATH"
    end
    local now = nowSeconds()
    local stackCount = pruneLayers(state, now)
    if stackCount <= 0 then
        restoreHeatPulse(player, state, "PULSE_EXPIRED")
        Load.states[player] = nil
        if Load.activePlayer == player then Load.activePlayer = nil end
        return false, "PULSE_EXPIRED_NATURAL_THERMOREGULATION_RESUMED"
    end
    if state.heatPulse and now >= state.nextHeatUpdate then
        state.nextHeatUpdate = now + UPDATE_INTERVAL_SECONDS
        updateHeatPulse(player, state, now)
    end
    return true, "PULSE_ACTIVE", stackCount
end

function Load.Cleanup(reason, player)
    if player then
        local state = Load.states[player]
        if state then restoreHeatPulse(player, state, reason or "CLEANUP") end
        Load.states[player] = nil
    else
        for owner, state in pairs(Load.states) do
            restoreHeatPulse(owner, state, reason or "CLEANUP_ALL")
        end
        Load.states = setmetatable({}, { __mode = "k" })
    end
    if player == nil or Load.activePlayer == player then
        Load.activePlayer = nil
    end
    return true, tostring(reason or "CLEANUP")
end

function Load.GetState(player)
    return player and Load.states[player] or nil
end

function Load.GetAuditSnapshot()
    return {
        pulse_id = Load.PULSE_ID,
        summary_count = Load.summaryCount,
        duplicate_transaction_count = Load.duplicateTransactionCount,
        cancelled_physical_write_count = Load.cancelledWriteCount,
        failed_physical_write_count = Load.failedWriteCount,
        duplicate_fatigue_write_count = Load.duplicateFatigueWriteCount,
        dangerous_overheat_count = Load.dangerousOverheatCount,
        permanent_temperature_lock_count =
            Load.permanentTemperatureLockCount,
        stack_limit_maximum = 3,
        global_mod_data_transient_write_count = 0,
    }
end

Load.start = Load.Start
Core.RedPhysicalLoad = Load
return Load
