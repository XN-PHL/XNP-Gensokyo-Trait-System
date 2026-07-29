require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_SubsystemGuard"
require "XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState"
require "XNP_PZ_DistanceRunner/XNP_DR_YellowToggle"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"

local Core = XNP_PZ_DistanceRunner

local Transactions = {
    serial = 0,
    lastRequestMs = { YELLOW = 0, GREEN = 0, RED = 0 },
    debounceMs = 250,
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function transactionId(system, now)
    Transactions.serial = Transactions.serial + 1
    return string.lower(system) .. "-toggle-" .. tostring(now) .. "-" .. tostring(Transactions.serial)
end

local function begin(system)
    local now = nowMs()
    if now - (Transactions.lastRequestMs[system] or 0) < Transactions.debounceMs then
        return nil, nil, "DUPLICATE_MOUSE_EVENT_FILTERED"
    end
    Transactions.lastRequestMs[system] = now
    return now, transactionId(system, now), nil
end

local function resolve(candidate)
    return Core.CanonicalPlayerIdentity.ResolveCurrentControlledPlayer(0, candidate, true)
end

local function play(player, system, id)
    if not Core.Audio then return false end
    return Core.Audio.PlayOnce(player, "MARKER_TOGGLE", string.lower(system) .. "-toggle:" .. tostring(id)) == true
end

local function commitUi(owner, method, ...)
    if not owner or type(owner[method]) ~= "function" then return false, "UNAVAILABLE" end
    local ok, matched, color = pcall(owner[method], ...)
    if not ok then return false, "UI_COMMIT_EXCEPTION" end
    return matched == true, color
end

function Transactions.RequestYellow(candidate, source)
    local now, id, blocked = begin("YELLOW")
    if blocked then return false, blocked end
    local guarded, committed, reason, summary = Core.SubsystemGuard.Execute("YELLOW", id, function()
        local player, identityReason = resolve(candidate)
        if not player then return false, "IDENTITY_MISMATCH:" .. tostring(identityReason) end
        if not Core.Trait or Core.Trait.PlayerHasTrait(player) ~= true then return false, "TRAIT_MISSING" end
        local fromEnabled = Core.YellowToggle.IsEnabled(player)
        local targetEnabled = not fromEnabled
        local changed, stateReason = Core.YellowToggle.SetEnabled(player, targetEnabled, source or "YELLOW_ICON_RIGHT_CLICK")
        if not changed then return false, stateReason end
        local stateMatch = Core.YellowToggle.IsEnabled(player) == targetEnabled
        local gateMatch = Core.MasterEffectState.IsEnabled(player) == targetEnabled
        local uiMatch, uiColor = false, "UNAVAILABLE"
        uiMatch, uiColor = commitUi(Core.StatusIconUI, "CommitManualState", player, targetEnabled)
        local fullCommit = stateMatch and gateMatch and uiMatch
        local rolledBack = false
        if not fullCommit then
            local rollbackState = Core.YellowToggle.SetEnabled(
                player, fromEnabled, "YELLOW_TOGGLE_TRANSACTION_ROLLBACK") == true
            local rollbackUi = commitUi(Core.StatusIconUI, "CommitManualState", player, fromEnabled)
            rolledBack = rollbackState and rollbackUi
        end
        local sound = fullCommit and play(player, "YELLOW", id) or false
        local result = {
            transaction_id = id, from_enabled = fromEnabled, to_enabled = targetEnabled,
            identity_match = true, state_commit = stateMatch, gameplay_gate_commit = gateMatch,
            ui_commit = uiMatch, ui_color = uiColor, readback_match = fullCommit,
            rolled_back = rolledBack, sound_after_full_commit = sound,
        }
        print("[XNP YELLOW TOGGLE TRANSACTION] transaction_id=" .. id
            .. " identity_match=true from_enabled=" .. tostring(fromEnabled)
            .. " to_enabled=" .. tostring(targetEnabled)
            .. " state_commit=" .. tostring(stateMatch)
            .. " gameplay_gate_commit=" .. tostring(gateMatch)
            .. " ui_commit=" .. tostring(uiMatch)
            .. " ui_color=" .. tostring(uiColor)
            .. " readback_match=" .. tostring(fullCommit)
            .. " rolled_back=" .. tostring(rolledBack)
            .. " sound_after_full_commit=" .. tostring(sound)
            .. " result=" .. tostring(fullCommit and "COMMITTED" or "READBACK_MISMATCH"))
        return fullCommit, fullCommit and "TOGGLE_COMMITTED" or "FULL_COMMIT_READBACK_MISMATCH", result
    end)
    if not guarded then return false, committed end
    return committed == true, reason, summary
end

function Transactions.RequestGreen(candidate, source)
    local now, id, blocked = begin("GREEN")
    if blocked then return false, blocked end
    local guarded, committed, reason, summary = Core.SubsystemGuard.Execute("GREEN", id, function()
        local player, identityReason = resolve(candidate)
        if not player then return false, "IDENTITY_MISMATCH:" .. tostring(identityReason) end
        if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then
            return false, "GREEN_TRAIT_MISSING"
        end
        if Core.SandboxTuning.GetBoolean("GreenMeleeRightClickToggleAllowed", true) ~= true then
            return false, "GREEN_MELEE_TOGGLE_DISABLED"
        end
        Core.GreenSkill.EnsureMigrated(player)
        local fromEnabled = Core.GreenSkill.IsEnabled(player)
        local targetEnabled = not fromEnabled
        local changed, stateValue = Core.GreenSkill.SetEnabled(player, targetEnabled)
        if not changed then return false, tostring(stateValue) end
        local stateMatch = Core.GreenSkill.IsEnabled(player) == targetEnabled
        local gateMatch = stateMatch
        local uiMatch, uiColor = false, "UNAVAILABLE"
        uiMatch, uiColor = commitUi(Core.GreenSkillUI, "CommitManualState", player, targetEnabled)
        local fullCommit = stateMatch and gateMatch and uiMatch
        local rolledBack = false
        if not fullCommit then
            local rollbackState = Core.GreenSkill.SetEnabled(player, fromEnabled) == true
            local rollbackUi = commitUi(Core.GreenSkillUI, "CommitManualState", player, fromEnabled)
            rolledBack = rollbackState and rollbackUi
        end
        local sound = fullCommit and play(player, "GREEN", id) or false
        local result = {
            transaction_id = id, from_enabled = fromEnabled, to_enabled = targetEnabled,
            identity_match = true, state_commit = stateMatch, gameplay_gate_commit = gateMatch,
            ui_commit = uiMatch, ui_color = uiColor, readback_match = fullCommit,
            rolled_back = rolledBack, sound_after_full_commit = sound,
        }
        print("[XNP GREEN MELEE TOGGLE TRANSACTION] transaction_id=" .. id
            .. " identity_match=true from_enabled=" .. tostring(fromEnabled)
            .. " to_enabled=" .. tostring(targetEnabled)
            .. " state_commit=" .. tostring(stateMatch)
            .. " gameplay_gate_commit=" .. tostring(gateMatch)
            .. " ui_commit=" .. tostring(uiMatch)
            .. " ui_color=" .. tostring(uiColor)
            .. " readback_match=" .. tostring(fullCommit)
            .. " rolled_back=" .. tostring(rolledBack)
            .. " sound_after_full_commit=" .. tostring(sound)
            .. " result=" .. tostring(fullCommit and "COMMITTED" or "READBACK_MISMATCH"))
        return fullCommit, fullCommit and "TOGGLE_COMMITTED" or "FULL_COMMIT_READBACK_MISMATCH", result
    end)
    if not guarded then return false, committed end
    return committed == true, reason, summary
end

function Transactions.RequestRed(candidate, source)
    local now, id, blocked = begin("RED")
    if blocked then return false, blocked end
    local guarded, committed, reason, summary = Core.SubsystemGuard.Execute("RED", id, function()
        local player, identityReason = resolve(candidate)
        if not player then return false, "IDENTITY_MISMATCH:" .. tostring(identityReason) end
        if Core.RedGuardianMark.PlayerHasTrait(player) ~= true then return false, "RED_TRAIT_MISSING" end
        local fromMode = Core.RedGuardianMark.GetMode(player)
        local targetMode = fromMode == Core.RedGuardianMark.MODE_STAMINA
            and Core.RedGuardianMark.MODE_TREATMENT or Core.RedGuardianMark.MODE_STAMINA
        local changed, stateReason = Core.RedGuardianMark.SetMode(player, targetMode)
        if not changed then return false, tostring(stateReason) end
        local stateMatch = Core.RedGuardianMark.GetMode(player) == targetMode
        local gameplayMatch = stateMatch
        local uiMatch, uiColor = false, "UNAVAILABLE"
        uiMatch, uiColor = commitUi(Core.RedMagicUI, "CommitMode", player, targetMode)
        local fullCommit = stateMatch and gameplayMatch and uiMatch
        local rolledBack = false
        if not fullCommit then
            local rollbackState = Core.RedGuardianMark.SetMode(player, fromMode) == true
            local rollbackUi = commitUi(Core.RedMagicUI, "CommitMode", player, fromMode)
            rolledBack = rollbackState and rollbackUi
        end
        local sound = fullCommit and play(player, "RED", id) or false
        local result = {
            transaction_id = id, from_mode = fromMode, to_mode = targetMode,
            identity_match = true, state_commit = stateMatch, gameplay_gate_commit = gameplayMatch,
            ui_commit = uiMatch, ui_color = uiColor, readback_match = fullCommit,
            rolled_back = rolledBack, sound_after_full_commit = sound,
        }
        print("[XNP RED TOGGLE TRANSACTION] transaction_id=" .. id
            .. " identity_match=true from_mode=" .. tostring(fromMode)
            .. " to_mode=" .. tostring(targetMode)
            .. " state_commit=" .. tostring(stateMatch)
            .. " gameplay_gate_commit=" .. tostring(gameplayMatch)
            .. " ui_commit=" .. tostring(uiMatch)
            .. " ui_color=" .. tostring(uiColor)
            .. " readback_match=" .. tostring(fullCommit)
            .. " rolled_back=" .. tostring(rolledBack)
            .. " sound_after_full_commit=" .. tostring(sound)
            .. " result=" .. tostring(fullCommit and "COMMITTED" or "READBACK_MISMATCH"))
        return fullCommit, fullCommit and "TOGGLE_COMMITTED" or "FULL_COMMIT_READBACK_MISMATCH", result
    end)
    if not guarded then return false, committed end
    return committed == true, reason, summary
end

Core.ToggleTransactions = Transactions
return Transactions
