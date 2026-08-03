local XNPChannelGuard = require "XNP_PZ_DistanceRunner/XNP_DR_ChannelGuard"
if type(XNPChannelGuard) == "table"
    and type(XNPChannelGuard.allowRuntime) == "function"
    and not XNPChannelGuard.allowRuntime() then
    return
end

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner

local Manager = {
    CALLBACK_OWNER = "XNP_DR_VFX_MANAGER",
    MULTIPLAYER_VISUAL_SCOPE = "PARTIAL_MULTIPLAYER_VISUAL_ONLY",
    renderers = {},
    rendererOrder = {},
    pulses = {},
    pulsePool = {},
    textures = {},
    registered = false,
    preloaded = false,
    mapHidden = false,
    serial = 0,
    callbackFrames = 0,
    rendererExceptions = 0,
    pulseExceptions = 0,
    pulseSpawnCount = 0,
    pulseCleanupCount = 0,
    pulsePoolReuseCount = 0,
    perFrameTextureLoads = 0,
    lastFailure = nil,
}

local ASSETS = {
    GREEN_IMPACT = {
        path = "media/textures/Item_XNPGreenOrbImpactRing.png",
        width = 128,
        height = 128,
    },
    YELLOW_CONTACT = {
        path = "media/textures/Item_XNPVFXYellowContactRing.png",
        width = 128,
        height = 128,
    },
    PURPLE_PHOENIX = {
        path = "media/textures/Item_XNPVFXPurplePhoenixBloom.png",
        width = 128,
        height = 128,
    },
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function playerNumber(player)
    local ok, value = invoke(player, "getPlayerNum")
    return math.max(0, math.floor(ok and tonumber(value) or 0))
end

local function loadTexture(name, spec)
    if type(getTexture) ~= "function" then return nil, "GET_TEXTURE_UNAVAILABLE" end
    local ok, texture = pcall(getTexture, spec.path)
    if not ok or not texture then return nil, "TEXTURE_LOAD_FAILED" end
    local widthOk, width = invoke(texture, "getWidth")
    local heightOk, height = invoke(texture, "getHeight")
    if not widthOk or not heightOk
        or tonumber(width) ~= spec.width or tonumber(height) ~= spec.height then
        return nil, "TEXTURE_SIZE_MISMATCH"
    end
    Manager.textures[name] = texture
    return texture, "READY"
end

function Manager.Preload()
    if Manager.preloaded then return true end
    local ready = true
    for name, spec in pairs(ASSETS) do
        local texture, reason = loadTexture(name, spec)
        if not texture then ready = false; Manager.lastFailure = name .. ":" .. reason end
        print("[XNP VFX ASSET] name=" .. tostring(name)
            .. " loaded=" .. tostring(texture ~= nil)
            .. " reason=" .. tostring(reason))
    end
    Manager.preloaded = ready
    return ready
end

local function projectionContext(playerNum)
    if type(getCore) ~= "function" or not IsoCamera or not IsoUtils
        or type(getPlayerScreenLeft) ~= "function"
        or type(getPlayerScreenTop) ~= "function"
        or type(getPlayerScreenWidth) ~= "function"
        or type(getPlayerScreenHeight) ~= "function" then
        return nil
    end
    local coreOk, gameCore = pcall(getCore)
    if not coreOk or not gameCore then return nil end
    local zoomOk, zoom = invoke(gameCore, "getZoom", playerNum)
    local leftOk, left = pcall(getPlayerScreenLeft, playerNum)
    local topOk, top = pcall(getPlayerScreenTop, playerNum)
    local widthOk, width = pcall(getPlayerScreenWidth, playerNum)
    local heightOk, height = pcall(getPlayerScreenHeight, playerNum)
    local offXOk, offX = pcall(function() return IsoCamera.getOffX(playerNum) end)
    local offYOk, offY = pcall(function() return IsoCamera.getOffY(playerNum) end)
    zoom = zoomOk and tonumber(zoom) or nil
    left = leftOk and tonumber(left) or nil
    top = topOk and tonumber(top) or nil
    width = widthOk and tonumber(width) or nil
    height = heightOk and tonumber(height) or nil
    offX = offXOk and tonumber(offX) or nil
    offY = offYOk and tonumber(offY) or nil
    if not zoom or zoom <= 0 or not left or not top or not width or not height
        or width <= 0 or height <= 0 or not offX or not offY then return nil end
    return {
        zoom = zoom, left = left, top = top, width = width, height = height,
        offX = offX, offY = offY,
    }
end

local function project(x, y, z, context)
    if not context or not IsoUtils.XToScreen or not IsoUtils.YToScreen then return nil end
    local okX, rawX = pcall(function() return IsoUtils.XToScreen(x, y, z, 0) end)
    local okY, rawY = pcall(function() return IsoUtils.YToScreen(x, y, z, 0) end)
    rawX = okX and tonumber(rawX) or nil
    rawY = okY and tonumber(rawY) or nil
    if not rawX or not rawY then return nil end
    local screenX = context.left + (rawX - context.offX) / context.zoom
    local screenY = context.top + (rawY - context.offY) / context.zoom
    local margin = 160
    return {
        x = screenX,
        y = screenY,
        inside = screenX >= context.left - margin
            and screenX <= context.left + context.width + margin
            and screenY >= context.top - margin
            and screenY <= context.top + context.height + margin,
    }
end

local function draw(texture, x, y, size, alpha)
    if not texture or not UIManager or not UIManager.DrawTexture then return false end
    return pcall(function()
        UIManager.DrawTexture(texture, x - size * 0.5, y - size * 0.5,
            size, size, alpha)
    end)
end

local function releasePulse(record)
    if not record then return end
    for key in pairs(record) do record[key] = nil end
    if #Manager.pulsePool < 32 then
        Manager.pulsePool[#Manager.pulsePool + 1] = record
    end
    Manager.pulseCleanupCount = Manager.pulseCleanupCount + 1
end

local function renderPulses(currentMs)
    if Manager.mapHidden then return end
    local contexts = {}
    local keep = {}
    for index = 1, #Manager.pulses do
        local pulse = Manager.pulses[index]
        if currentMs < (pulse.startedAtMs or 0) then
            keep[#keep + 1] = pulse
        elseif currentMs < (pulse.expiresAtMs or 0) then
            local context = contexts[pulse.playerNum]
            if context == nil then
                context = projectionContext(pulse.playerNum)
                contexts[pulse.playerNum] = context or false
            end
            if context then
                local projected = project(pulse.x, pulse.y, pulse.z, context)
                if projected and projected.inside then
                    local duration = math.max(1, pulse.expiresAtMs - pulse.startedAtMs)
                    local progress = math.max(0,
                        math.min((currentMs - pulse.startedAtMs) / duration, 1))
                    local eased = 1 - (1 - progress) * (1 - progress)
                    local size = pulse.startSize
                        + (pulse.endSize - pulse.startSize) * eased
                    local alpha = pulse.maxAlpha * (1 - progress)
                    local ok = draw(Manager.textures[pulse.asset],
                        projected.x, projected.y, size, alpha)
                    if not ok then Manager.pulseExceptions = Manager.pulseExceptions + 1 end
                end
            end
            keep[#keep + 1] = pulse
        else
            releasePulse(pulse)
        end
    end
    Manager.pulses = keep
end

local function onPostUIDraw()
    Manager.callbackFrames = Manager.callbackFrames + 1
    local visible = not Core.MapVisibility
        or type(Core.MapVisibility.IsWorldGameplayVisible) ~= "function"
        or Core.MapVisibility.IsWorldGameplayVisible(0) == true
    Manager.mapHidden = visible ~= true
    for index = 1, #Manager.rendererOrder do
        local name = Manager.rendererOrder[index]
        local renderer = Manager.renderers[name]
        if renderer then
            local ok, reason = pcall(renderer)
            if not ok then
                Manager.rendererExceptions = Manager.rendererExceptions + 1
                Manager.lastFailure = tostring(name) .. ":" .. tostring(reason)
            end
        end
    end
    local ok, reason = pcall(renderPulses, nowMs())
    if not ok then
        Manager.pulseExceptions = Manager.pulseExceptions + 1
        Manager.lastFailure = "WORLD_PULSE:" .. tostring(reason)
    end
end

function Manager.Register()
    if Manager.registered then return true end
    if not Events or not Events.OnPostUIDraw
        or type(Events.OnPostUIDraw.Add) ~= "function" then
        Manager.lastFailure = "ON_POST_UI_DRAW_UNAVAILABLE"
        return false
    end
    Events.OnPostUIDraw.Add(onPostUIDraw)
    Manager.registered = true
    Manager.Preload()
    print("[XNP VFX MANAGER] callback_registered=true event=OnPostUIDraw callback_owner_count=1")
    return true
end

function Manager.RegisterRenderer(name, callback)
    if type(name) ~= "string" or name == "" or type(callback) ~= "function" then
        return false, "INVALID_RENDERER"
    end
    if Manager.renderers[name] == nil then
        Manager.rendererOrder[#Manager.rendererOrder + 1] = name
    end
    Manager.renderers[name] = callback
    local registered = Manager.Register()
    return registered, registered and "REGISTERED"
        or (Manager.lastFailure or "REGISTER_FAILED")
end

function Manager.SpawnWorldPulse(asset, player, x, y, z, options)
    if not ASSETS[asset] then return false, "UNKNOWN_ASSET" end
    if Manager.Register() ~= true or Manager.Preload() ~= true then
        return false, Manager.lastFailure or "VFX_MANAGER_UNAVAILABLE"
    end
    options = type(options) == "table" and options or {}
    local record = table.remove(Manager.pulsePool)
    if record then
        Manager.pulsePoolReuseCount = Manager.pulsePoolReuseCount + 1
    else
        record = {}
    end
    Manager.serial = Manager.serial + 1
    local current = nowMs()
    local delay = math.max(0, tonumber(options.delayMs) or 0)
    local duration = math.max(40, math.min(tonumber(options.durationMs) or 160, 600))
    record.id = Manager.serial
    record.owner = options.owner
    record.asset = asset
    record.playerNum = playerNumber(player)
    record.x = tonumber(x) or 0
    record.y = tonumber(y) or 0
    record.z = tonumber(z) or 0
    record.startedAtMs = current + delay
    record.expiresAtMs = current + delay + duration
    record.startSize = math.max(8, tonumber(options.startSize) or 24)
    record.endSize = math.max(record.startSize, tonumber(options.endSize) or 96)
    record.maxAlpha = math.max(0.05, math.min(tonumber(options.maxAlpha) or 0.82, 1))
    Manager.pulses[#Manager.pulses + 1] = record
    Manager.pulseSpawnCount = Manager.pulseSpawnCount + 1
    return true, "WORLD_PULSE_QUEUED", record.id
end

function Manager.SpawnPlayerPulse(asset, player, options)
    local xOk, x = invoke(player, "getX")
    local yOk, y = invoke(player, "getY")
    local zOk, z = invoke(player, "getZ")
    if not xOk or not yOk or not zOk then return false, "PLAYER_POSITION_UNAVAILABLE" end
    return Manager.SpawnWorldPulse(asset, player, x, y, z, options)
end

function Manager.Cleanup(owner, reason)
    local kept = {}
    for index = 1, #Manager.pulses do
        local pulse = Manager.pulses[index]
        if owner == nil or pulse.owner == owner then
            releasePulse(pulse)
        else
            kept[#kept + 1] = pulse
        end
    end
    Manager.pulses = kept
    print("[XNP VFX CLEANUP] owner=" .. tostring(owner or "ALL")
        .. " reason=" .. tostring(reason or "CLEANUP")
        .. " remaining=" .. tostring(#Manager.pulses))
    return true
end

function Manager.GetMetrics()
    return {
        callback_owner_count = Manager.registered and 1 or 0,
        callback_frames = Manager.callbackFrames,
        renderer_count = #Manager.rendererOrder,
        renderer_exceptions = Manager.rendererExceptions,
        pulse_exceptions = Manager.pulseExceptions,
        pulse_spawn_count = Manager.pulseSpawnCount,
        pulse_cleanup_count = Manager.pulseCleanupCount,
        active_pulse_count = #Manager.pulses,
        pulse_pool_size = #Manager.pulsePool,
        pulse_pool_reuse_count = Manager.pulsePoolReuseCount,
        per_frame_texture_loads = Manager.perFrameTextureLoads,
        multiplayer_visual_scope = Manager.MULTIPLAYER_VISUAL_SCOPE,
        last_failure = Manager.lastFailure,
    }
end

Core.VFXManager = Manager
return Manager
