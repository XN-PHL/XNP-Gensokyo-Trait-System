require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"

local Core = XNP_PZ_DistanceRunner
local P = Core.PurplePhoenixConstants
local State = { lastToggleMs = 0, toggleDebounceMs = 250 }
local productionRecharge

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

local function dataFor(player)
    local ok, data = invoke(player, "getModData")
    return ok and type(data) == "table" and data or nil
end

local function worldHours()
    if type(getGameTime) ~= "function" then return nil end
    local ok, gameTime = pcall(getGameTime)
    if not ok or not gameTime then return nil end
    local got, value = invoke(gameTime, "getWorldAgeHours")
    return got and type(value) == "number" and value or nil
end

local function healthFraction(player)
    local ok, body = invoke(player, "getBodyDamage")
    if ok and body then
        local got, value = invoke(body, "getOverallBodyHealth")
        if got and type(value) == "number" then return value > 1 and value / 100 or value, body end
    end
    local got, value = invoke(player, "getHealth")
    if got and type(value) == "number" then return value > 1 and value / 100 or value, body end
    return nil, body
end

-- B42 hunger uses 0 as full and larger values as hungrier. The positive-credit
-- gate therefore accepts only the low-hunger band and never reverses the scale.
local function isWellFed(player)
    local ok, stats = invoke(player, "getStats")
    if not ok or not stats then return false end
    if CharacterStat and CharacterStat.HUNGER and type(stats.get) == "function" then
        local got, value = pcall(function() return stats:get(CharacterStat.HUNGER) end)
        if got and type(value) == "number" then return value <= 0.15 end
    end
    local got, value = invoke(stats, "getHunger")
    return got and type(value) == "number" and value <= 0.15
end

local function hasSevereWound(body)
    local ok, parts = invoke(body, "getBodyParts")
    if not ok or not parts then return true end
    local sizeOk, size = invoke(parts, "size")
    if not sizeOk or type(size) ~= "number" then return true end
    for index = 0, size - 1 do
        local partOk, part = invoke(parts, "get", index)
        if partOk and part then
            for _, method in ipairs({ "bitten", "IsInfected", "isDeepWounded", "isFracture" }) do
                local readOk, value = invoke(part, method)
                if readOk and value == true then return true end
            end
        end
    end
    return false
end

local function migrateTestState(player, data)
    if not P.TEST_COOLDOWN_MODE or data[P.TEST_MIGRATION_MODDATA_KEY] == true then return end
    local legacyDeadline = tonumber(data[P.LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY])
    if legacyDeadline and legacyDeadline > nowMs() then
        data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] = legacyDeadline
    end
    data[P.LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY] = nil
    data[P.LEGACY_TEST_MIGRATION_MODDATA_KEY] = nil
    local oldState = productionRecharge and productionRecharge(player) or "READY"
    if oldState == "COOLDOWN" or oldState == "WAITING_FOR_CALM" then
        data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] = nowMs() + P.TEST_COOLDOWN_MS
        data[P.ENABLED_MODDATA_KEY] = true
    elseif data[P.ENABLED_MODDATA_KEY] == nil then
        data[P.ENABLED_MODDATA_KEY] = true
    end
    data[P.TEST_MIGRATION_MODDATA_KEY] = true
    print("[XNP PHOENIX TEST STATE] migrated=true old_state=" .. tostring(oldState))
end

function State.CancelPendingForDeath(player)
    local data = dataFor(player)
    if not data then return false, "NO_MODDATA" end
    data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] = nil
    data[P.LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY] = nil
    data[P.ENABLED_MODDATA_KEY] = false
    return true, "DEATH_TRANSIENTS_CLEARED"
end

local function settleTestState(player, data)
    if not P.TEST_COOLDOWN_MODE then return end
    migrateTestState(player, data)
    local deadline = tonumber(data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY])
    if deadline and nowMs() >= deadline then
        data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] = nil
        data[P.ENABLED_MODDATA_KEY] = false
        if Core.PhoenixTransaction then Core.PhoenixTransaction.OnCooldownFinished(player) end
        print("[XNP PHOENIX TEST STATE] cooldown_complete=true next_state=GREEN")
        if Core.Audio then
            Core.Audio.PlayOnce(player, "RED_USE_OR_PHOENIX_READY", "phoenix-ready:" .. tostring(deadline))
        end
    end
end

function State.IsEnabled(player)
    local data = dataFor(player)
    if not data then return true end
    settleTestState(player, data)
    if data[P.ENABLED_MODDATA_KEY] == nil then data[P.ENABLED_MODDATA_KEY] = true end
    return data[P.ENABLED_MODDATA_KEY] ~= false
end

function State.SetEnabled(player, enabled)
    if not player or not Core.PurplePhoenixTrait.PlayerHasTrait(player) then return false, "TRAIT_MISSING" end
    local data = dataFor(player)
    if not data then return false, "NO_MODDATA" end
    settleTestState(player, data)
    if P.TEST_COOLDOWN_MODE and tonumber(data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY]) then
        return false, "COOLDOWN_LOCKED"
    end
    enabled = enabled == true
    if State.IsEnabled(player) == enabled then return false, "UNCHANGED" end
    data[P.ENABLED_MODDATA_KEY] = enabled
    if Core.PhoenixTransaction then
        if enabled then Core.PhoenixTransaction.OnManualReenabled(player)
        else Core.PhoenixTransaction.OnManualDisabled(player) end
    end
    if not enabled then
        if Core.PurplePhoenixInvulnerability then Core.PurplePhoenixInvulnerability.Cleanup(player, "PHOENIX_TOGGLE_OFF") end
        if Core.PurplePhoenixProtect then Core.PurplePhoenixProtect.Cleanup(player, "PHOENIX_TOGGLE_OFF") end
    end
    print("[XNP PHOENIX TOGGLE] enabled=" .. tostring(enabled))
    return true, "OK"
end

function State.Toggle(player)
    local now = nowMs()
    if now - State.lastToggleMs < State.toggleDebounceMs then return false, "DEBOUNCE" end
    State.lastToggleMs = now
    local changed, reason = State.SetEnabled(player, not State.IsEnabled(player))
    if changed and Core.Audio then
        Core.Audio.PlayOnce(player, "MARKER_TOGGLE", "phoenix-toggle:" .. tostring(now))
    end
    return changed, reason
end

function State.ValidateBeginRecovery(player)
    local data = dataFor(player)
    if not data then return false, "MODDATA_UNAVAILABLE" end
    if not P.TEST_COOLDOWN_MODE and not worldHours() then return false, "TIME_UNAVAILABLE" end
    return true, "STATE_CONTRACT_READY"
end

-- Starts a fresh recovery contract. Calm observed and both credit counters are
-- reset only on a successful Phoenix trigger, never by either icon toggle.
function State.BeginRecovery(player)
    local data = dataFor(player)
    local now = worldHours()
    if not data then return false, "MODDATA_UNAVAILABLE" end
    if P.TEST_COOLDOWN_MODE then
        data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] = nowMs() + P.TEST_COOLDOWN_MS
        data[P.TEST_MIGRATION_MODDATA_KEY] = true
        data[P.ENABLED_MODDATA_KEY] = true
    end
    if not now then
        if P.TEST_COOLDOWN_MODE then return true, data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] end
        return false, "TIME_UNAVAILABLE"
    end
    data[P.COOLDOWN_START_MODDATA_KEY] = now
    data[P.LAST_TRIGGER_MODDATA_KEY] = now
    data[P.CALM_OBSERVED_MODDATA_KEY] = false
    data[P.LAST_CREDIT_HOUR_MODDATA_KEY] = now
    data[P.WELL_FED_HOURS_MODDATA_KEY] = 0
    data[P.HEALTHY_HOURS_MODDATA_KEY] = 0
    return true, now
end

local function readPanic(player)
    local ok, stats = invoke(player, "getStats")
    if not ok or not stats then return nil end
    if CharacterStat and CharacterStat.PANIC and type(stats.get) == "function" then
        local got, value = pcall(function() return stats:get(CharacterStat.PANIC) end)
        if got and type(value) == "number" then return value end
    end
    local got, value = invoke(stats, "getPanic")
    return got and type(value) == "number" and value or nil
end

-- Accumulates at most the actual elapsed world hours. Reloads, time acceleration,
-- and duplicate updates cannot count the same interval twice.
function State.UpdateRecovery(player, invulnerabilityActive)
    if not Core.PhoenixLifeGate or Core.PhoenixLifeGate.IsLivingPlayer(player) ~= true then return false end
    local data = dataFor(player)
    local now = worldHours()
    local config = Core.PurplePhoenixConfig.Get()
    if not data or not now or not data[P.COOLDOWN_START_MODDATA_KEY] then return false end

    if data[P.CALM_OBSERVED_MODDATA_KEY] ~= true and now > tonumber(data[P.LAST_TRIGGER_MODDATA_KEY] or now) then
        local panic = readPanic(player)
        if panic and panic <= config.panicZeroThreshold then
            data[P.CALM_OBSERVED_MODDATA_KEY] = true
            print("[XNP PHOENIX RECHARGE] calm_reset_observed=true")
        end
    end

    local previous = tonumber(data[P.LAST_CREDIT_HOUR_MODDATA_KEY]) or now
    local elapsed = math.max(0, math.min(now - previous, 6))
    data[P.LAST_CREDIT_HOUR_MODDATA_KEY] = now
    if elapsed <= 0 or invulnerabilityActive or not config.earlyRechargeEnabled then return true end

    local health, body = healthFraction(player)
    if isWellFed(player) then
        data[P.WELL_FED_HOURS_MODDATA_KEY] = math.max(0, tonumber(data[P.WELL_FED_HOURS_MODDATA_KEY]) or 0) + elapsed
    end
    if health and health >= config.healthyMinHealth and body and not hasSevereWound(body) then
        data[P.HEALTHY_HOURS_MODDATA_KEY] = math.max(0, tonumber(data[P.HEALTHY_HOURS_MODDATA_KEY]) or 0) + elapsed
    end
    return true
end

productionRecharge = function(player)
    local data = dataFor(player)
    local now = worldHours()
    local config = Core.PurplePhoenixConfig.Get()
    if not data or not now then return "BLOCKED", math.huge, 0 end
    local start = tonumber(data[P.COOLDOWN_START_MODDATA_KEY])
    if not start then return "READY", 0, 0 end

    local wellHours = tonumber(data[P.WELL_FED_HOURS_MODDATA_KEY]) or 0
    local healthyHours = tonumber(data[P.HEALTHY_HOURS_MODDATA_KEY]) or 0
    local wellDays = math.min(config.wellFedCreditMaxDays, wellHours / config.wellFedRequiredGameHours * config.wellFedCreditMaxDays)
    local healthyDays = math.min(config.healthyCreditMaxDays, healthyHours / config.healthyRequiredGameHours * config.healthyCreditMaxDays)
    local credit = config.earlyRechargeEnabled and math.min(config.earlyRechargeMaxDays, wellDays + healthyDays) or 0
    local requiredDays = math.max(config.minimumCooldownDays, config.baseCooldownDays - credit)
    local remaining = math.max(0, start + requiredDays * 24 - now)
    if remaining > 0 then return "COOLDOWN", remaining, credit end
    if config.requirePanicZero and data[P.CALM_OBSERVED_MODDATA_KEY] ~= true then return "WAITING_FOR_CALM", 0, credit end
    return "READY", 0, credit
end

function State.GetRecharge(player)
    if not P.TEST_COOLDOWN_MODE then return productionRecharge(player) end
    local data = dataFor(player)
    if not data then return "BLOCKED", math.huge, 0 end
    settleTestState(player, data)
    local deadline = tonumber(data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY])
    if deadline then return "COOLDOWN", math.max(0, deadline - nowMs()) / 1000, 0 end
    if data[P.ENABLED_MODDATA_KEY] == false then return "READY_DISABLED", 0, 0 end
    return "READY", 0, 0
end

function State.GetVisualState(player)
    local recharge, remaining = State.GetRecharge(player)
    if recharge == "COOLDOWN" then return "WHITE", remaining end
    if recharge == "READY" and State.IsEnabled(player) then return "BLUE", 0 end
    return "GREEN", 0
end

Core.PurplePhoenixState = State
return State
