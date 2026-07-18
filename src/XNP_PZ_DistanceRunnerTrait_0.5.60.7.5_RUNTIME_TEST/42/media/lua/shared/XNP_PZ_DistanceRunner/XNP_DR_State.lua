require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local State = {
    by_player = {},
}

local function playerKey(player)
    if player and type(player.getOnlineID) == "function" then
        local ok, id = pcall(function()
            return player:getOnlineID()
        end)
        if ok and id ~= nil then
            return "online:" .. tostring(id)
        end
    end
    return tostring(player)
end

function State.IsValidPlayer(player)
    return player ~= nil and (type(player) == "userdata" or type(player) == "table")
end

function State.Get(player)
    if not State.IsValidPlayer(player) then
        return nil, Constants.ERROR.INVALID_PLAYER
    end
    local key = playerKey(player)
    local state = State.by_player[key]
    if not state then
        state = {
            key = key,
            trait_active = false,
            runtime_active = false,
            valid_run_seconds = 0,
            stop_seconds = 0,
            last_x = nil,
            last_y = nil,
            total_session_distance = 0,
            continuous_run_seconds = 0,
            normal_drain_distance = 0,
            speed_applied = false,
            last_applied_factor = nil,
            last_known_factor = 1.0,
            modules = {
                movement = "READY",
                metabolism = "READY",
                xp = "DISABLED",
                recovery_load = "READY",
                hud = "READY",
            },
            training_load = 0,
            recovery_load_pending = false,
            recovery_load_active = false,
            hud_text = "",
            x3_status = "READY",
            movement_apply_logged = false,
            movement_reset_logged = false,
            logs = {},
        }
        State.by_player[key] = state
    end
    return state, Constants.ERROR.OK
end

function State.ResetTransient(state)
    if not state then
        return false, Constants.ERROR.INVALID_PLAYER
    end
    state.valid_run_seconds = 0
    state.stop_seconds = 0
    state.last_x = nil
    state.last_y = nil
    state.total_session_distance = 0
    state.continuous_run_seconds = 0
    state.normal_drain_distance = 0
    state.speed_applied = false
    state.last_applied_factor = nil
    state.last_known_factor = 1.0
    state.runtime_active = false
    return true, Constants.ERROR.OK
end

function State.Cleanup(reason)
    State.by_player = {}
    Constants.Log("runtime state cleared reason=" .. tostring(reason))
end

Core.State = State
return State
