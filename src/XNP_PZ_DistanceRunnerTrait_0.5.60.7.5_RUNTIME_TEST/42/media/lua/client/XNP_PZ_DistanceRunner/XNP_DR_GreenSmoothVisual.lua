local Core = XNP_PZ_DistanceRunner

local Visual = {
    ROUTE = "PER_PLAYER_ZOOM_VIEWPORT_PROJECTED_DRAW_PROOF",
    DRAW_ENTRY = "UIManager.DrawTexture_TEXTURE_X_Y_WIDTH_HEIGHT_ALPHA",
    AUTHORITATIVE_WORLD_POSITION = true,
    SCREEN_FIXED_UI = false,
    PLAYER_FIXED_UI = false,
    CAMERA_REPROJECT_EVERY_FRAME = true,
    SUB_TILE_INTERPOLATION = true,
    VISUAL_UPDATE_EVERY_RENDER_FRAME = true,
    CAMERA_OFFSET_DEDUCTED_ONCE = true,
    ZOOM_DIVISION_REQUIRED = true,
    VIEWPORT_ORIGIN_ADDED_FOR_GLOBAL_UI_PASS = true,
    OLD_FRAME_TRAIL = false,
    SAVE_PERSISTENCE = false,
    JAVA_WORLD_ENTITY_COUNT = 0,
    active = nil,
    preflight = nil,
    registered = false,
    renderedFrames = 0,
    lastFailure = nil,
}

local ASSETS = {
    CENTER = { path = "media/textures/Item_XNPGreenOrbWorldCenter.png", width = 68, height = 64 },
    GLOW = { path = "media/textures/Item_XNPGreenOrbWorldGlow.png", width = 88, height = 94 },
    RING = { path = "media/textures/Item_XNPGreenOrbWorldRing.png", width = 112, height = 112 },
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function basename(path)
    local value = tostring(path or "")
    value = string.gsub(value, "\\", "/")
    return string.match(value, "([^/]+)$") or value
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

local function textureContract(asset)
    if type(getTexture) ~= "function" then return nil, "GET_TEXTURE_UNAVAILABLE" end
    local ok, texture = pcall(getTexture, asset.path)
    if not ok or not texture then return nil, "TEXTURE_LOAD_FAILED" end
    local nameOk, name = invoke(texture, "getName")
    local widthOk, width = invoke(texture, "getWidth")
    local heightOk, height = invoke(texture, "getHeight")
    width = widthOk and tonumber(width) or nil
    height = heightOk and tonumber(height) or nil
    if not nameOk or type(name) ~= "string" or name == "" then
        return nil, "TEXTURE_NAME_UNAVAILABLE"
    end
    if width ~= asset.width or height ~= asset.height then
        return nil, "TEXTURE_SIZE_MISMATCH"
    end
    return { texture = texture, basename = basename(name), width = width, height = height }, "READY"
end

local function staticApiReady()
    return IsoUtils ~= nil
        and IsoUtils.XToScreen ~= nil
        and IsoUtils.YToScreen ~= nil
        and IsoCamera ~= nil
        and IsoCamera.getOffX ~= nil
        and IsoCamera.getOffY ~= nil
        and type(getCore) == "function"
        and type(getPlayerScreenLeft) == "function"
        and type(getPlayerScreenTop) == "function"
        and type(getPlayerScreenWidth) == "function"
        and type(getPlayerScreenHeight) == "function"
        and UIManager ~= nil
        and UIManager.DrawTexture ~= nil
end

function Visual.Preflight()
    if Visual.preflight then return Visual.preflight end
    local contracts = {}
    local ready = staticApiReady()
    local reason = ready and "READY" or "PROJECTION_VIEWPORT_OR_DRAW_API_UNAVAILABLE"
    for _, name in ipairs({ "CENTER", "GLOW", "RING" }) do
        local contract, itemReason = textureContract(ASSETS[name])
        contracts[name] = contract
        if not contract then ready = false; reason = name .. ":" .. tostring(itemReason) end
        print("[XNP GREEN SMOOTH ASSET] asset=" .. string.lower(name)
            .. " loaded=" .. tostring(contract ~= nil)
            .. " texture_basename=" .. tostring(contract and contract.basename or "none")
            .. " reason=" .. tostring(itemReason))
    end
    Visual.preflight = { ready = ready, reason = reason, contracts = contracts }
    print("[XNP GREEN SMOOTH] preflight_ready=" .. tostring(ready)
        .. " route=" .. Visual.ROUTE
        .. " draw_entry=" .. Visual.DRAW_ENTRY
        .. " camera_offset_deducted_once=true zoom_division=true viewport_origin=true")
    return Visual.preflight
end

local function playerNumber(state)
    local ok, number = invoke(state and state.player, "getPlayerNum")
    number = ok and tonumber(number) or 0
    return math.max(0, math.floor(number or 0))
end

local function viewportContract(playerNum)
    local coreOk, core = pcall(getCore)
    if not coreOk or not core then return nil, "CORE_UNAVAILABLE" end
    local zoomOk, zoom = invoke(core, "getZoom", playerNum)
    local leftOk, left = pcall(getPlayerScreenLeft, playerNum)
    local topOk, top = pcall(getPlayerScreenTop, playerNum)
    local widthOk, width = pcall(getPlayerScreenWidth, playerNum)
    local heightOk, height = pcall(getPlayerScreenHeight, playerNum)
    zoom = zoomOk and tonumber(zoom) or nil
    left = leftOk and tonumber(left) or nil
    top = topOk and tonumber(top) or nil
    width = widthOk and tonumber(width) or nil
    height = heightOk and tonumber(height) or nil
    if not zoom or zoom <= 0 or not left or not top or not width or not height
        or width <= 0 or height <= 0 then
        return nil, "ZOOM_OR_VIEWPORT_INVALID"
    end
    return { zoom = zoom, left = left, top = top, width = width, height = height }, "READY"
end

local function project(x, y, z, playerNum)
    local viewport, viewportReason = viewportContract(playerNum)
    if not viewport then return nil, viewportReason end
    local okX, rawX = pcall(function() return IsoUtils.XToScreen(x, y, z, 0) end)
    local okY, rawY = pcall(function() return IsoUtils.YToScreen(x, y, z, 0) end)
    local okOffX, offX = pcall(function() return IsoCamera.getOffX(playerNum) end)
    local okOffY, offY = pcall(function() return IsoCamera.getOffY(playerNum) end)
    rawX = okX and tonumber(rawX) or nil
    rawY = okY and tonumber(rawY) or nil
    offX = okOffX and tonumber(offX) or nil
    offY = okOffY and tonumber(offY) or nil
    if not rawX or not rawY or not offX or not offY then
        return nil, "WORLD_TO_SCREEN_OR_CAMERA_OFFSET_FAILED"
    end
    local localX = (rawX - offX) / viewport.zoom
    local localY = (rawY - offY) / viewport.zoom
    local screenX = viewport.left + localX
    local screenY = viewport.top + localY
    local inside = screenX >= viewport.left and screenX < viewport.left + viewport.width
        and screenY >= viewport.top and screenY < viewport.top + viewport.height
    return {
        rawX = rawX,
        rawY = rawY,
        cameraOffX = offX,
        cameraOffY = offY,
        zoom = viewport.zoom,
        viewportLeft = viewport.left,
        viewportTop = viewport.top,
        viewportWidth = viewport.width,
        viewportHeight = viewport.height,
        screenX = screenX,
        screenY = screenY,
        inside = inside,
    }, "READY"
end

local function draw(texture, centerX, centerY, width, height, alpha)
    return pcall(function()
        UIManager.DrawTexture(texture, centerX - width * 0.5, centerY - height * 0.5,
            width, height, alpha)
    end)
end

local function groundRingSize(state, playerNum, radius)
    local x, y, z = state.world_x, state.world_y, state.world_z
    local left = project(x - radius, y + radius, z, playerNum)
    local right = project(x + radius, y - radius, z, playerNum)
    local top = project(x - radius, y - radius, z, playerNum)
    local bottom = project(x + radius, y + radius, z, playerNum)
    if not left or not right or not top or not bottom then return nil, nil end
    return math.max(8, math.abs(right.screenX - left.screenX)),
        math.max(4, math.abs(bottom.screenY - top.screenY))
end

local function newCounters()
    return {
        render_callback_frames = 0,
        projection_success_frames = 0,
        inside_viewport_frames = 0,
        draw_attempt_frames = 0,
        draw_call_no_exception_frames = 0,
        center_draw_attempts = 0,
        center_draw_call_no_exception_frames = 0,
        glow_draw_attempts = 0,
        glow_draw_call_no_exception_frames = 0,
        diagnostic_border_draw_attempts = 0,
        diagnostic_border_draw_call_no_exception_frames = 0,
        draw_exception_count = 0,
        projection_exception_count = 0,
        offscreen_frame_count = 0,
        first_frame_logged = false,
    }
end

local function numberText(value)
    local number = tonumber(value)
    if not number then return "nil" end
    return string.format("%.3f", number)
end

local function logProjectionFirstFrame(state, playerNum, projected, reason)
    local counters = state.inflightDraw
    if counters.first_frame_logged then return end
    counters.first_frame_logged = true
    print("[XNP GREEN FLIGHT PROJECTION] player_index=" .. tostring(playerNum)
        .. " world_x=" .. numberText(state.world_x)
        .. " world_y=" .. numberText(state.world_y)
        .. " world_z=" .. numberText(state.world_z)
        .. " projected_raw_x=" .. numberText(projected and projected.rawX)
        .. " projected_raw_y=" .. numberText(projected and projected.rawY)
        .. " camera_off_x=" .. numberText(projected and projected.cameraOffX)
        .. " camera_off_y=" .. numberText(projected and projected.cameraOffY)
        .. " zoom=" .. numberText(projected and projected.zoom)
        .. " viewport_left=" .. numberText(projected and projected.viewportLeft)
        .. " viewport_top=" .. numberText(projected and projected.viewportTop)
        .. " viewport_width=" .. numberText(projected and projected.viewportWidth)
        .. " viewport_height=" .. numberText(projected and projected.viewportHeight)
        .. " final_screen_x=" .. numberText(projected and projected.screenX)
        .. " final_screen_y=" .. numberText(projected and projected.screenY)
        .. " inside_viewport=" .. tostring(projected and projected.inside == true)
        .. " reason=" .. tostring(reason))
end

local function renderActive()
    local state = Visual.active
    if not state or state.finished == true or state.phase ~= "TRACKING" then return end
    state.inflightDraw = state.inflightDraw or newCounters()
    local counters = state.inflightDraw
    counters.render_callback_frames = counters.render_callback_frames + 1
    state.smoothVisualFrames = counters.render_callback_frames
    if state.mapHidden == true then
        counters.offscreen_frame_count = counters.offscreen_frame_count + 1
        logProjectionFirstFrame(state, playerNumber(state), nil, "MAP_HIDDEN")
        return
    end
    local preflight = Visual.Preflight()
    if preflight.ready ~= true then
        counters.projection_exception_count = counters.projection_exception_count + 1
        logProjectionFirstFrame(state, playerNumber(state), nil, preflight.reason)
        return
    end
    local playerNum = playerNumber(state)
    local projected, projectionReason = project(state.world_x, state.world_y,
        state.world_z + 0.18, playerNum)
    logProjectionFirstFrame(state, playerNum, projected, projectionReason)
    if not projected then
        counters.projection_exception_count = counters.projection_exception_count + 1
        Visual.lastFailure = projectionReason or "WORLD_TO_SCREEN_PROJECTION_FAILED"
        return
    end
    counters.projection_success_frames = counters.projection_success_frames + 1
    if projected.inside ~= true then
        counters.offscreen_frame_count = counters.offscreen_frame_count + 1
        return
    end
    counters.inside_viewport_frames = counters.inside_viewport_frames + 1

    local lockRadius = state.options and state.options.lockAreaRadius or 4.0
    if state.options and state.options.lockAreaEnabled == true then
        local ringWidth, ringHeight = groundRingSize(state, playerNum, lockRadius)
        local ground = project(state.world_x, state.world_y, state.world_z, playerNum)
        if ringWidth and ringHeight and ground and ground.inside then
            draw(preflight.contracts.RING.texture, ground.screenX, ground.screenY,
                ringWidth, ringHeight, 0.62)
        end
    end

    local centerDiameter = tuningNumber("GreenOrbScreenDiameterPx", 36, 12, 128)
    local glowDiameter = tuningNumber("GreenOrbGlowDiameterPx", 48, 16, 160)
    counters.draw_attempt_frames = counters.draw_attempt_frames + 1
    counters.glow_draw_attempts = counters.glow_draw_attempts + 1
    local glowOk = draw(preflight.contracts.GLOW.texture, projected.screenX, projected.screenY,
        glowDiameter, glowDiameter, 0.62)
    if glowOk then
        counters.glow_draw_call_no_exception_frames = counters.glow_draw_call_no_exception_frames + 1
    else
        counters.draw_exception_count = counters.draw_exception_count + 1
    end

    if tuningBoolean("GreenInflightDiagnosticBorderEnabled", true) then
        counters.diagnostic_border_draw_attempts = counters.diagnostic_border_draw_attempts + 1
        local borderOk = draw(preflight.contracts.RING.texture, projected.screenX, projected.screenY,
            centerDiameter + 8, centerDiameter + 8, 0.95)
        if borderOk then
            counters.diagnostic_border_draw_call_no_exception_frames =
                counters.diagnostic_border_draw_call_no_exception_frames + 1
        else
            counters.draw_exception_count = counters.draw_exception_count + 1
        end
    end

    counters.center_draw_attempts = counters.center_draw_attempts + 1
    local centerOk = draw(preflight.contracts.CENTER.texture, projected.screenX, projected.screenY,
        centerDiameter, centerDiameter, 1.0)
    if centerOk then
        counters.center_draw_call_no_exception_frames =
            counters.center_draw_call_no_exception_frames + 1
    else
        counters.draw_exception_count = counters.draw_exception_count + 1
    end
    if glowOk and centerOk then
        counters.draw_call_no_exception_frames = counters.draw_call_no_exception_frames + 1
        Visual.renderedFrames = Visual.renderedFrames + 1
        state.lastSmoothVisualAtMs = type(getTimestampMs) == "function" and getTimestampMs() or nil
    end
end

function Visual.GetProof(state, requiredFrames)
    local counters = state and state.inflightDraw or nil
    local required = math.max(2, math.floor(tonumber(requiredFrames) or 2))
    if not counters then
        return { ready = false, requiredFrames = required, reason = "NO_RENDER_CALLBACK_COUNTERS" }
    end
    local ready = counters.projection_success_frames >= required
        and counters.inside_viewport_frames >= required
        and counters.center_draw_call_no_exception_frames >= required
        and counters.glow_draw_call_no_exception_frames >= required
    return {
        ready = ready,
        requiredFrames = required,
        reason = ready and "INFLIGHT_DRAW_PROOF_READY" or "INFLIGHT_DRAW_NOT_PROVEN",
        counters = counters,
    }
end

function Visual.LogSummary(state, requiredFrames)
    local proof = Visual.GetProof(state, requiredFrames)
    local c = proof.counters or newCounters()
    print("[XNP GREEN FLIGHT DRAW SUMMARY] render_callback_frames=" .. tostring(c.render_callback_frames)
        .. " projection_success_frames=" .. tostring(c.projection_success_frames)
        .. " inside_viewport_frames=" .. tostring(c.inside_viewport_frames)
        .. " draw_attempt_frames=" .. tostring(c.draw_attempt_frames)
        .. " draw_call_no_exception_frames=" .. tostring(c.draw_call_no_exception_frames)
        .. " center_draw_attempts=" .. tostring(c.center_draw_attempts)
        .. " center_draw_call_no_exception_frames=" .. tostring(c.center_draw_call_no_exception_frames)
        .. " glow_draw_attempts=" .. tostring(c.glow_draw_attempts)
        .. " glow_draw_call_no_exception_frames=" .. tostring(c.glow_draw_call_no_exception_frames)
        .. " draw_exception_count=" .. tostring(c.draw_exception_count)
        .. " projection_exception_count=" .. tostring(c.projection_exception_count)
        .. " offscreen_frame_count=" .. tostring(c.offscreen_frame_count)
        .. " minimum_required_frames=" .. tostring(proof.requiredFrames)
        .. " inflight_draw_proven=" .. tostring(proof.ready))
    return proof
end

function Visual.Register()
    if Visual.registered then return true end
    if Core.green_smooth_visual_render_registered == true then
        Visual.registered = true
        return true
    end
    if not Events or not Events.OnPostUIDraw or type(Events.OnPostUIDraw.Add) ~= "function" then
        Visual.lastFailure = "ON_POST_UI_DRAW_UNAVAILABLE"
        return false
    end
    Events.OnPostUIDraw.Add(renderActive)
    Core.green_smooth_visual_render_registered = true
    Visual.registered = true
    print("[XNP GREEN SMOOTH] render_callback_registered=true event=OnPostUIDraw callback_count_owned=1")
    return true
end

function Visual.Activate(state)
    if not state then return false, "STATE_MISSING" end
    if Visual.Register() ~= true then return false, Visual.lastFailure or "RENDER_CALLBACK_UNAVAILABLE" end
    local preflight = Visual.Preflight()
    if preflight.ready ~= true then return false, preflight.reason end
    Visual.active = state
    state.inflightDraw = newCounters()
    state.smoothVisualFrames = 0
    state.lastSmoothVisualAtMs = nil
    return true, Visual.ROUTE
end

function Visual.IsActive(state)
    return state ~= nil and Visual.active == state and Visual.preflight and Visual.preflight.ready == true
end

function Visual.Deactivate(state)
    if state == nil or Visual.active == state then Visual.active = nil end
end

function Visual.ResetPreflight()
    Visual.preflight = nil
end

function Visual.Shutdown()
    Visual.active = nil
    Visual.lastFailure = nil
    Visual.preflight = nil
end

Core.GreenSmoothVisual = Visual
return Visual
