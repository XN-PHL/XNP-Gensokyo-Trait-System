XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local Audio = {
    sounds = {
        PHOENIX_REVIVE = "XNPPhoenixRevive",
        RED_USE_OR_PHOENIX_READY = "XNPRedUseOrPhoenixReady",
        MARKER_TOGGLE = "XNPMarkerToggle",
        GREEN_BOMB_SKILL = "XNPGreenBombSkill",
        GREEN_PROJECTILE_CAST = "XNPGreenProjectileCast",
    },
    consumedTokens = {},
    consumedOrder = {},
    maxTokens = 64,
}

local function remember(token)
    if Audio.consumedTokens[token] then return false end
    Audio.consumedTokens[token] = true
    Audio.consumedOrder[#Audio.consumedOrder + 1] = token
    if #Audio.consumedOrder > Audio.maxTokens then
        local oldest = table.remove(Audio.consumedOrder, 1)
        Audio.consumedTokens[oldest] = nil
    end
    return true
end

function Audio.PlayOnce(player, soundKey, eventToken)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean
        and Core.SandboxTuning.GetBoolean("EnableSounds", true) ~= true then
        return false, "SOUNDS_DISABLED_BY_SANDBOX"
    end
    local soundName = Audio.sounds[soundKey]
    if not player or not soundName or type(player.playSound) ~= "function" then
        return false, "SOUND_API_UNAVAILABLE"
    end
    local token = tostring(soundKey) .. ":" .. tostring(eventToken or "MISSING_EVENT_TOKEN")
    if not remember(token) then return false, "EVENT_ALREADY_PLAYED" end
    local ok, handle = pcall(function() return player:playSound(soundName) end)
    if not ok then
        Audio.consumedTokens[token] = nil
        print("[XNP AUDIO] play_failed sound=" .. soundName .. " error=" .. tostring(handle))
        return false, "PLAY_FAILED"
    end
    print("[XNP AUDIO] one_shot=true sound=" .. soundName .. " event=" .. tostring(eventToken))
    return true, handle
end

function Audio.ReleasePrefix(prefix)
    prefix = tostring(prefix or "")
    if prefix == "" then return 0 end
    local released = 0
    for index = #Audio.consumedOrder, 1, -1 do
        local token = Audio.consumedOrder[index]
        if string.sub(token, 1, #prefix) == prefix then
            Audio.consumedTokens[token] = nil
            table.remove(Audio.consumedOrder, index)
            released = released + 1
        end
    end
    return released
end

Core.Audio = Audio
return Audio
