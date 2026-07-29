require "XNP_PZ_DistanceRunner/XNP_DR_Audio"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local Sound = {
    EVENT_KEY = "RED_USE_OR_PHOENIX_READY",
    EVENT_NAME = "XNPRedUseOrPhoenixReady",
    successRouteCount = 0,
    failureNoticeCount = 0,
}

local function safeText(key, fallback)
    if type(getText) == "function" then
        local ok, value = pcall(getText, key)
        if ok and value and value ~= key then return tostring(value) end
    end
    return fallback
end

local function emit(stage, success, handle, reason)
    print("[XNP PURPLE SOUND] stage=" .. tostring(stage)
        .. " event_name=" .. Sound.EVENT_NAME
        .. " route=Core.Audio.PlayOnce"
        .. " emitter_precondition=NOT_REQUIRED"
        .. " play_call_success=" .. tostring(success == true)
        .. " returned_handle=" .. tostring(handle == nil and "NONE" or handle)
        .. " reason=" .. tostring(reason or "NONE")
        .. " audibility_claim=NOT_YET_USER_VERIFIED")
end

function Sound.LogDeferred(stage, reason)
    emit(stage, false, nil, reason or "DEFERRED_UNTIL_COMMIT")
end

function Sound.PlaySuccess(player, stage, token)
    if not Core.Audio or type(Core.Audio.PlayOnce) ~= "function" then
        emit(stage, false, nil, "AUDIO_HELPER_UNAVAILABLE")
        return false, "AUDIO_HELPER_UNAVAILABLE"
    end
    local eventId = tostring(token or stage)
    local ok, played, handle = pcall(Core.Audio.PlayOnce, player,
        Sound.EVENT_KEY, eventId)
    if not ok then
        emit(stage, false, nil, "PLAY_EXCEPTION:" .. tostring(played))
        return false, "PLAY_EXCEPTION"
    end
    if played == true then Sound.successRouteCount = Sound.successRouteCount + 1 end
    emit(stage, played == true, played == true and handle or nil,
        played == true and "NONE" or handle)
    return played == true, handle
end

function Sound.NotifyFailure(player, key, fallback, detail)
    local text = safeText(key, fallback)
    if detail and detail ~= "" then text = text .. " (" .. tostring(detail) .. ")" end
    if player and type(player.setHaloNote) == "function" then
        pcall(function() player:setHaloNote(text, 255, 190, 210, 240) end)
    end
    Sound.failureNoticeCount = Sound.failureNoticeCount + 1
    emit("FAIL", false, nil, detail or key)
    return text
end

function Sound.GetAuditSnapshot()
    return {
        route = "Core.Audio.PlayOnce",
        emitter_precondition = false,
        success_route_count = Sound.successRouteCount,
        failure_notice_count = Sound.failureNoticeCount,
        audibility_claim = "NOT_YET_USER_VERIFIED",
    }
end

Core.PurpleLifeStockSound = Sound
return Sound
