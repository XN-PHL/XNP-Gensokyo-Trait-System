local Core = XNP_PZ_DistanceRunner

local Visual = {
    ROUTE = "ON_POST_UI_DRAW_SCREEN_PROJECTION",
    PROJECTILE_FORM = "WORLD_COORDINATE_VIRTUAL_PROJECTILE_WITH_NATIVE_WORLD_LIGHT",
    DRAW_ENTRY = "UIManager.DrawTexture_TEXTURE_X_Y_WIDTH_HEIGHT_ALPHA",
    AUTHORITATIVE_WORLD_POSITION = true,
    SCREEN_FIXED_UI = false,
    PLAYER_FIXED_UI = false,
    CAMERA_REPROJECT_EVERY_FRAME = true,
    SUB_TILE_INTERPOLATION = true,
    INTERPOLATION_ROUTE = "ONE_FIXED_STEP_DELAY_PREVIOUS_TO_CURRENT",
    CORE_ALPHA_MINIMUM = 0.65,
    JAVA_WORLD_ENTITY_COUNT = 0,
    MAX_DRAW_CALLS_PER_ORB = 2,
    DEFAULT_MAXIMUM_FPS = 60,
    activeByCastId = {},
    impactsById = {},
    activeCount = 0,
    peakActiveCount = 0,
    impactSerial = 0,
    impactPeakCount = 0,
    maximumImpactRecords = 64,
    staleCastPurges = 0,
    staleImpactPurges = 0,
    preflight = nil,
    registered = false,
    renderedFrames = 0,
    lastFailure = nil,
    runtimeOptions = nil,
    nextVisualUpdateMs = 0,
    projectionEpoch = 0,
    projectionComputations = 0,
    projectionCacheHits = 0,
    duplicateProjectionCount = 0,
    visualTicks = 0,
    visualBudgetSkips = 0,
    mapHiddenTicks = 0,
    offscreenDrawCalls = 0,
    mapOpenDrawCalls = 0,
    mapHidden = false,
    sharedDrawCallbackCalls = 0,
    perCastDrawEventCount = 0,
    frameParityHidingCount = 0,
    drawListGapFrames = 0,
    interpolatedPositionCount = 0,
    castDrawIsolationFailures = 0,
    impactDrawIsolationFailures = 0,
    terminalDrawNotProvenCount = 0,
}

local ASSETS = {
    CENTER = { path = "media/textures/Item_XNPGreenOrbWorldCenter.png", width = 68, height = 64 },
    GLOW = { path = "media/textures/Item_XNPGreenOrbWorldGlow.png", width = 88, height = 94 },
    IMPACT = { path = "media/textures/Item_XNPGreenOrbWorldExplosion.png", width = 144, height = 144 },
}

local SPIN_FRAMES = {}
for index = 1, 16 do
    SPIN_FRAMES[index] = {
        path = string.format("media/textures/Item_XNPGreenOrbSpin%02d.png", index),
        width = 64,
        height = 64,
    }
end

local DEFAULT_VISUAL_OPTIONS = {
    centerDiameter = 36,
    glowDiameter = 48,
    spinEnabled = true,
    spinDegreesPerSecond = 220,
    spinFrameCount = 16,
    glowPulseEnabled = true,
    glowPulseHz = 3.0,
    glowJitterEnabled = true,
    glowJitterPixels = 1.5,
    glowOrbitPixels = 1.0,
    glowMinAlpha = 0.42,
    glowMaxAlpha = 0.90,
    coreAlpha = 0.98,
    impactVisualLifetimeMs = 140,
    impactVisualScale = 1.0,
    diagnosticBorder = false,
    visualMaximumFps = 60,
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

local function basename(path)
    local value = string.gsub(tostring(path or ""), "\\", "/")
    return string.match(value, "([^/]+)$") or value
end

local function copyVisualOptions(source)
    source = source or {}
    local copy = {}
    for key, fallback in pairs(DEFAULT_VISUAL_OPTIONS) do
        local value = source[key]
        if value == nil then value = fallback end
        copy[key] = value
    end
    copy.spinFrameCount = math.max(1, math.min(16,
        math.floor(tonumber(copy.spinFrameCount) or 16)))
    copy.glowMinAlpha = math.max(0, math.min(tonumber(copy.glowMinAlpha) or 0.42, 1))
    copy.glowMaxAlpha = math.max(copy.glowMinAlpha,
        math.min(tonumber(copy.glowMaxAlpha) or 0.90, 1))
    copy.coreAlpha = math.max(Visual.CORE_ALPHA_MINIMUM,
        math.min(tonumber(copy.coreAlpha) or 0.98, 1))
    copy.visualMaximumFps = math.max(15, math.min(tonumber(copy.visualMaximumFps) or 60, 60))
    return copy
end

function Visual.SetRuntimeOptions(options)
    Visual.runtimeOptions = copyVisualOptions(options)
    return Visual.runtimeOptions
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
    return IsoUtils ~= nil and IsoUtils.XToScreen ~= nil and IsoUtils.YToScreen ~= nil
        and IsoCamera ~= nil and IsoCamera.getOffX ~= nil and IsoCamera.getOffY ~= nil
        and type(getCore) == "function" and type(getPlayerScreenLeft) == "function"
        and type(getPlayerScreenTop) == "function" and type(getPlayerScreenWidth) == "function"
        and type(getPlayerScreenHeight) == "function" and UIManager ~= nil
        and UIManager.DrawTexture ~= nil
end

function Visual.Preflight()
    if Visual.preflight then return Visual.preflight end
    local contracts = { SPIN = {} }
    local ready = staticApiReady()
    local reason = ready and "READY" or "PROJECTION_VIEWPORT_OR_DRAW_API_UNAVAILABLE"
    for _, name in ipairs({ "CENTER", "GLOW", "IMPACT" }) do
        local contract, itemReason = textureContract(ASSETS[name])
        contracts[name] = contract
        if not contract then ready = false; reason = name .. ":" .. tostring(itemReason) end
        print("[XNP GREEN SMOOTH ASSET] asset=" .. string.lower(name)
            .. " loaded=" .. tostring(contract ~= nil)
            .. " texture_basename=" .. tostring(contract and contract.basename or "none")
            .. " reason=" .. tostring(itemReason))
    end
    for index, asset in ipairs(SPIN_FRAMES) do
        local contract, itemReason = textureContract(asset)
        contracts.SPIN[index] = contract
        if not contract then ready = false; reason = "SPIN_" .. tostring(index) .. ":" .. tostring(itemReason) end
    end
    Visual.preflight = { ready = ready, reason = reason, contracts = contracts }
    print("[XNP GREEN SMOOTH] preflight_ready=" .. tostring(ready)
        .. " spin_frames_loaded=" .. tostring(#contracts.SPIN)
        .. " textures_preloaded_once=true per_frame_texture_load_count=0"
        .. " route=" .. Visual.ROUTE .. " draw_entry=" .. Visual.DRAW_ENTRY
        .. " max_draw_calls_per_orb=2")
    return Visual.preflight
end

local function playerNumberFromPlayer(player)
    local ok, number = invoke(player, "getPlayerNum")
    number = ok and tonumber(number) or 0
    return math.max(0, math.floor(number or 0))
end

local function projectionContext(playerNum)
    local coreOk, core = pcall(getCore)
    if not coreOk or not core then return nil, "CORE_UNAVAILABLE" end
    local zoomOk, zoom = invoke(core, "getZoom", playerNum)
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
        or width <= 0 or height <= 0 or not offX or not offY then
        return nil, "PROJECTION_CONTEXT_INVALID"
    end
    return {
        zoom = zoom, left = left, top = top, width = width, height = height,
        offX = offX, offY = offY,
        viewport = table.concat({ left, top, width, height }, ":"),
    }, "READY"
end

local function changed(a, b, epsilon)
    if a == nil or b == nil then return true end
    return math.abs(a - b) > (epsilon or 0.0001)
end

local function project(holder, x, y, z, playerNum, context, epoch, visualTick)
    if not context then return nil, "PROJECTION_CONTEXT_MISSING" end
    local needsProjection = holder.last_screen_x == nil or holder.last_screen_y == nil
        or changed(holder.last_projectile_world_x, x, 0.02)
        or changed(holder.last_projectile_world_y, y, 0.02)
        or changed(holder.last_projectile_world_z, z, 0.02)
        or changed(holder.last_camera_offset_x, context.offX)
        or changed(holder.last_camera_offset_y, context.offY)
        or changed(holder.last_zoom, context.zoom)
        or holder.last_viewport ~= context.viewport
        or holder.last_projection_epoch ~= epoch
    if holder.last_projection_visual_tick == visualTick and needsProjection then
        Visual.duplicateProjectionCount = Visual.duplicateProjectionCount + 1
    end
    if not needsProjection then
        Visual.projectionCacheHits = Visual.projectionCacheHits + 1
        return holder.last_projected, "CACHE_HIT"
    end
    local okX, rawX = pcall(function() return IsoUtils.XToScreen(x, y, z, 0) end)
    local okY, rawY = pcall(function() return IsoUtils.YToScreen(x, y, z, 0) end)
    rawX = okX and tonumber(rawX) or nil
    rawY = okY and tonumber(rawY) or nil
    if not rawX or not rawY then return nil, "WORLD_TO_SCREEN_FAILED" end
    local screenX = context.left + (rawX - context.offX) / context.zoom
    local screenY = context.top + (rawY - context.offY) / context.zoom
    local margin = 96
    local inside = screenX >= context.left - margin
        and screenX < context.left + context.width + margin
        and screenY >= context.top - margin
        and screenY < context.top + context.height + margin
    local projected = {
        rawX = rawX, rawY = rawY, cameraOffX = context.offX, cameraOffY = context.offY,
        zoom = context.zoom, viewportLeft = context.left, viewportTop = context.top,
        viewportWidth = context.width, viewportHeight = context.height,
        screenX = screenX, screenY = screenY, inside = inside,
    }
    holder.last_projectile_world_x = x
    holder.last_projectile_world_y = y
    holder.last_projectile_world_z = z
    holder.last_camera_offset_x = context.offX
    holder.last_camera_offset_y = context.offY
    holder.last_zoom = context.zoom
    holder.last_viewport = context.viewport
    holder.last_screen_x = screenX
    holder.last_screen_y = screenY
    holder.last_projection_epoch = epoch
    holder.last_projection_visual_tick = visualTick
    holder.last_projected = projected
    Visual.projectionComputations = Visual.projectionComputations + 1
    return projected, "REPROJECTED"
end

local function draw(texture, centerX, centerY, width, height, alpha)
    return pcall(function()
        UIManager.DrawTexture(texture, centerX - width * 0.5, centerY - height * 0.5,
            width, height, alpha)
    end)
end

local function newCounters()
    return {
        render_callback_frames = 0,
        projection_success_frames = 0,
        inside_viewport_frames = 0,
        draw_attempt_frames = 0,
        draw_call_no_exception_frames = 0,
        glow_draw_attempts = 0,
        glow_draw_call_no_exception_frames = 0,
        core_draw_attempts = 0,
        core_draw_call_no_exception_frames = 0,
        draw_exception_count = 0,
        projection_exception_count = 0,
        offscreen_frame_count = 0,
        interpolated_position_frames = 0,
        first_frame_logged = false,
    }
end

local function isFlightPhase(phase)
    return phase == "CRUISE_SEARCHING" or phase == "LOCKED_HOMING"
        or phase == "TRACKING" or phase == "TARGET_LOST_DECELERATING"
end

local function interpolatedWorldPosition(state, currentMs)
    local previousX = tonumber(state.previous_simulation_x)
    local previousY = tonumber(state.previous_simulation_y)
    local previousZ = tonumber(state.previous_simulation_z)
    local currentX = tonumber(state.current_simulation_x)
    local currentY = tonumber(state.current_simulation_y)
    local currentZ = tonumber(state.current_simulation_z)
    local previousMs = tonumber(state.previous_simulation_ms)
    local simulationMs = tonumber(state.current_simulation_ms)
    if not previousX or not previousY or not previousZ or not currentX or not currentY
        or not currentZ or not previousMs or not simulationMs or simulationMs <= previousMs then
        return tonumber(state.world_x) or 0, tonumber(state.world_y) or 0,
            tonumber(state.world_z) or 0, 1, false
    end
    local spanMs = simulationMs - previousMs
    local renderTimeMs = currentMs - spanMs
    local alpha = math.max(0, math.min((renderTimeMs - previousMs) / spanMs, 1))
    return previousX + (currentX - previousX) * alpha,
        previousY + (currentY - previousY) * alpha,
        previousZ + (currentZ - previousZ) * alpha,
        alpha, true
end

local function renderCast(state, currentMs, preflight, contexts, epoch, visualTick)
    if not state or state.finished == true or not isFlightPhase(state.phase) then return end
    state.inflightDraw = state.inflightDraw or newCounters()
    local counters = state.inflightDraw
    counters.render_callback_frames = counters.render_callback_frames + 1
    state.smoothVisualFrames = counters.render_callback_frames
    if state.mapHidden == true then return end
    local playerNum = state.playerNum or playerNumberFromPlayer(state.player)
    if contexts[playerNum] == nil then contexts[playerNum] = projectionContext(playerNum) end
    local renderX, renderY, renderZ, interpolationAlpha, interpolated =
        interpolatedWorldPosition(state, currentMs)
    if interpolated then
        counters.interpolated_position_frames = counters.interpolated_position_frames + 1
        Visual.interpolatedPositionCount = Visual.interpolatedPositionCount + 1
        state.lastInterpolationAlpha = interpolationAlpha
    end
    local projected, projectionReason = project(state, renderX, renderY,
        renderZ + 0.18, playerNum, contexts[playerNum], epoch, visualTick)
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
    local options = state.visualOptions or Visual.runtimeOptions or DEFAULT_VISUAL_OPTIONS
    local seconds = math.max(0, currentMs - (state.startedMs or currentMs)) / 1000
    local phase = (tonumber(state.id) or 0) * 0.73
    local pulse = options.glowPulseEnabled and (0.5 + 0.5 * math.sin(
        seconds * math.pi * 2 * options.glowPulseHz + phase)) or 0.5
    local alpha = options.glowMinAlpha
        + (options.glowMaxAlpha - options.glowMinAlpha) * pulse
    local jitterX, jitterY = 0, 0
    if options.glowJitterEnabled then
        jitterX = math.sin(seconds * math.pi * 2 * options.glowPulseHz * 0.79 + phase)
            * options.glowJitterPixels
        jitterY = math.cos(seconds * math.pi * 2 * options.glowPulseHz * 0.67 + phase)
            * options.glowJitterPixels
    end
    counters.draw_attempt_frames = counters.draw_attempt_frames + 1
    counters.glow_draw_attempts = counters.glow_draw_attempts + 1
    local glowOk = draw(preflight.contracts.GLOW.texture,
        projected.screenX + jitterX, projected.screenY + jitterY,
        options.glowDiameter, options.glowDiameter, alpha * 0.76)
    if glowOk then
        counters.glow_draw_call_no_exception_frames =
            counters.glow_draw_call_no_exception_frames + 1
    end
    local spinCount = options.spinEnabled and options.spinFrameCount or 1
    local rotationCycles = seconds * options.spinDegreesPerSecond / 360
    local spinIndex = math.floor(rotationCycles * spinCount) % spinCount + 1
    local spinContract = preflight.contracts.SPIN[spinIndex] or preflight.contracts.SPIN[1]
    counters.core_draw_attempts = counters.core_draw_attempts + 1
    local coreAlpha = math.max(Visual.CORE_ALPHA_MINIMUM,
        math.min(tonumber(options.coreAlpha) or 0.98, 1))
    local coreOk = spinContract and draw(spinContract.texture, projected.screenX, projected.screenY,
        options.centerDiameter, options.centerDiameter, coreAlpha)
    if coreOk then
        counters.core_draw_call_no_exception_frames =
            counters.core_draw_call_no_exception_frames + 1
    end
    if glowOk and coreOk then
        counters.draw_call_no_exception_frames = counters.draw_call_no_exception_frames + 1
        Visual.renderedFrames = Visual.renderedFrames + 1
        state.lastSmoothVisualAtMs = currentMs
    else
        counters.draw_exception_count = counters.draw_exception_count + 1
    end
end

local function renderImpact(record, currentMs, preflight, contexts, epoch, visualTick)
    if not record or record.mapHidden == true then return end
    if contexts[record.playerNum] == nil then
        contexts[record.playerNum] = projectionContext(record.playerNum)
    end
    local projected = project(record, record.world_x, record.world_y, record.world_z + 0.08,
        record.playerNum, contexts[record.playerNum], epoch, visualTick)
    if not projected or projected.inside ~= true then return end
    local lifetime = math.max(1, record.expiresAtMs - record.startedMs)
    local progress = math.max(0, math.min((currentMs - record.startedMs) / lifetime, 1))
    local size = (52 + 92 * progress) * record.scale
    draw(preflight.contracts.IMPACT.texture, projected.screenX, projected.screenY,
        size, size, 1.0 - progress * 0.82)
end

local function purgeExpiredImpacts(currentMs)
    local removed = 0
    for id, record in pairs(Visual.impactsById) do
        if not record or currentMs >= (record.expiresAtMs or 0) then
            Visual.impactsById[id] = nil
            removed = removed + 1
        end
    end
    Visual.staleImpactPurges = Visual.staleImpactPurges + removed
end

local function purgeFinishedCasts()
    local removed = 0
    for id, state in pairs(Visual.activeByCastId) do
        if not state or state.finished == true or state.cleanupComplete == true then
            Visual.activeByCastId[id] = nil
            Visual.activeCount = math.max(0, Visual.activeCount - 1)
            removed = removed + 1
        end
    end
    Visual.staleCastPurges = Visual.staleCastPurges + removed
end

local function renderActive()
    Visual.sharedDrawCallbackCalls = Visual.sharedDrawCallbackCalls + 1
    local currentMs = nowMs()
    purgeExpiredImpacts(currentMs)
    purgeFinishedCasts()
    if Core.MapVisibility and type(Core.MapVisibility.Update) == "function" then
        Core.MapVisibility.Update(false, 0)
    end
    local gameplayVisible = not Core.MapVisibility
        or Core.MapVisibility.IsWorldGameplayVisible(0) == true
    if not gameplayVisible then
        Visual.mapHiddenTicks = Visual.mapHiddenTicks + 1
        Visual.SetMapHidden(true)
        return
    end
    if Visual.mapHidden then Visual.SetMapHidden(false) end
    local options = Visual.runtimeOptions or DEFAULT_VISUAL_OPTIONS
    local maximumFps = math.max(15, math.min(tonumber(options.visualMaximumFps) or 60, 60))
    if currentMs < Visual.nextVisualUpdateMs then
        Visual.visualBudgetSkips = Visual.visualBudgetSkips + 1
        return
    end
    Visual.nextVisualUpdateMs = currentMs + (1000 / maximumFps)
    Visual.visualTicks = Visual.visualTicks + 1
    local preflight = Visual.Preflight()
    if preflight.ready ~= true then return end
    local epoch = Core.MapVisibility and Core.MapVisibility.GetProjectionEpoch()
        or Visual.projectionEpoch
    local contexts = {}
    local casts = {}
    for _, state in pairs(Visual.activeByCastId) do casts[#casts + 1] = state end
    table.sort(casts, function(a, b) return tostring(a and a.id) < tostring(b and b.id) end)
    if #casts ~= Visual.activeCount then
        Visual.drawListGapFrames = Visual.drawListGapFrames + 1
    end
    for _, state in ipairs(casts) do
        local ok, reason = pcall(renderCast, state, currentMs, preflight,
            contexts, epoch, Visual.visualTicks)
        if not ok then
            Visual.castDrawIsolationFailures = Visual.castDrawIsolationFailures + 1
            Visual.lastFailure = "CAST_DRAW_ISOLATED:" .. tostring(reason)
        end
    end
    local impacts = {}
    for _, record in pairs(Visual.impactsById) do impacts[#impacts + 1] = record end
    for _, record in ipairs(impacts) do
        local ok, reason = pcall(renderImpact, record, currentMs, preflight,
            contexts, epoch, Visual.visualTicks)
        if not ok then
            Visual.impactDrawIsolationFailures = Visual.impactDrawIsolationFailures + 1
            Visual.lastFailure = "IMPACT_DRAW_ISOLATED:" .. tostring(reason)
        end
    end
end

function Visual.GetProof(state, requiredFrames)
    local counters = state and state.inflightDraw or nil
    local required = math.max(1, math.floor(tonumber(requiredFrames) or 1))
    if state and state.mapHidden == true and Visual.IsActive(state) then
        return {
            ready = true,
            requiredFrames = required,
            reason = "MAP_HIDDEN_VISUAL_PROOF_BYPASS_PRESERVES_PHYSICS",
            counters = counters or newCounters(),
        }
    end
    if not counters then
        return { ready = false, requiredFrames = required, reason = "NO_RENDER_CALLBACK_COUNTERS" }
    end
    local ready = counters.projection_success_frames >= required
        and counters.inside_viewport_frames >= required
        and counters.glow_draw_call_no_exception_frames >= required
        and counters.core_draw_call_no_exception_frames >= required
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
    if proof.ready ~= true and not (state and state.mapHidden == true) then
        Visual.terminalDrawNotProvenCount = Visual.terminalDrawNotProvenCount + 1
    end
    print("[XNP GREEN FLIGHT DRAW SUMMARY] render_callback_frames=" .. tostring(c.render_callback_frames)
        .. " projection_success_frames=" .. tostring(c.projection_success_frames)
        .. " inside_viewport_frames=" .. tostring(c.inside_viewport_frames)
        .. " draw_call_no_exception_frames=" .. tostring(c.draw_call_no_exception_frames)
        .. " draw_exception_count=" .. tostring(c.draw_exception_count)
        .. " projection_exception_count=" .. tostring(c.projection_exception_count)
        .. " offscreen_frame_count=" .. tostring(c.offscreen_frame_count)
        .. " minimum_required_frames=" .. tostring(proof.requiredFrames)
        .. " inflight_draw_proven=" .. tostring(proof.ready))
    return proof
end

local function onPostUIDrawAdapter()
    return renderActive()
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
    Events.OnPostUIDraw.Add(onPostUIDrawAdapter)
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
    if state.id == nil then return false, "CAST_ID_MISSING" end
    state.visualOptions = copyVisualOptions(state.options or Visual.runtimeOptions)
    if Visual.activeByCastId[state.id] ~= state then
        if Visual.activeByCastId[state.id] == nil then
            Visual.activeCount = Visual.activeCount + 1
            Visual.peakActiveCount = math.max(Visual.peakActiveCount, Visual.activeCount)
        end
        Visual.activeByCastId[state.id] = state
    end
    state.inflightDraw = newCounters()
    state.smoothVisualFrames = 0
    state.lastSmoothVisualAtMs = nil
    state.visualIdentity = "GREEN_ORB_STABLE_GLOW_AND_CORE"
    return true, Visual.ROUTE
end

function Visual.IsActive(state)
    return state ~= nil and state.id ~= nil and Visual.activeByCastId[state.id] == state
        and Visual.preflight and Visual.preflight.ready == true
end

function Visual.Deactivate(state)
    if not state or state.id == nil then return false, "STATE_OR_CAST_ID_MISSING" end
    if Visual.activeByCastId[state.id] == state then
        Visual.activeByCastId[state.id] = nil
        Visual.activeCount = math.max(0, Visual.activeCount - 1)
    end
    return true, "CAST_VISUAL_REMOVED"
end

function Visual.ShowImpact(state)
    if not state then return false, "STATE_MISSING" end
    local preflight = Visual.Preflight()
    if preflight.ready ~= true then return false, preflight.reason end
    Visual.Deactivate(state)
    local currentMs = nowMs()
    purgeExpiredImpacts(currentMs)
    local count, oldestId, oldestStarted = 0, nil, math.huge
    for id, existing in pairs(Visual.impactsById) do
        count = count + 1
        if (existing.startedMs or 0) < oldestStarted then
            oldestId, oldestStarted = id, existing.startedMs or 0
        end
    end
    if count >= Visual.maximumImpactRecords and oldestId ~= nil then
        Visual.impactsById[oldestId] = nil
        Visual.staleImpactPurges = Visual.staleImpactPurges + 1
        count = count - 1
    end
    Visual.impactSerial = Visual.impactSerial + 1
    local options = state.visualOptions or Visual.runtimeOptions or DEFAULT_VISUAL_OPTIONS
    local record = {
        id = Visual.impactSerial,
        castId = state.id,
        playerNum = state.playerNum or playerNumberFromPlayer(state.player),
        world_x = state.world_x,
        world_y = state.world_y,
        world_z = state.world_z,
        mapHidden = state.mapHidden == true or Visual.mapHidden == true,
        startedMs = currentMs,
        expiresAtMs = currentMs + math.max(1, options.impactVisualLifetimeMs),
        scale = options.impactVisualScale,
    }
    Visual.impactsById[record.id] = record
    Visual.impactPeakCount = math.max(Visual.impactPeakCount, count + 1)
    state.impactVisualId = record.id
    return true, "PROJECTED_SHORT_LIVED_IMPACT", record.id
end

function Visual.ConfirmImpact(state)
    local id = state and state.impactVisualId or nil
    return id ~= nil and Visual.impactsById[id] ~= nil
end

function Visual.DetachImpact(state)
    if state then state.impactVisualId = nil end
end

function Visual.RemoveImpact(state)
    local id = state and state.impactVisualId or nil
    if id ~= nil then Visual.impactsById[id] = nil end
    if state then state.impactVisualId = nil end
end

function Visual.SetMapHidden(hidden)
    hidden = hidden == true
    if Visual.mapHidden and not hidden then
        Visual.projectionEpoch = Visual.projectionEpoch + 1
        Visual.nextVisualUpdateMs = 0
    end
    Visual.mapHidden = hidden
    for _, state in pairs(Visual.activeByCastId) do state.mapHidden = hidden end
    for _, record in pairs(Visual.impactsById) do record.mapHidden = hidden end
end

function Visual.GetMetrics()
    local impactCount = 0
    for _ in pairs(Visual.impactsById) do impactCount = impactCount + 1 end
    return {
        activeCount = Visual.activeCount,
        peakActiveCount = Visual.peakActiveCount,
        renderCallbackCountOwned = Visual.registered and 1 or 0,
        renderedFrames = Visual.renderedFrames,
        impactPeakCount = Visual.impactPeakCount,
        impactCount = impactCount,
        maximumImpactRecords = Visual.maximumImpactRecords,
        staleCastPurges = Visual.staleCastPurges,
        staleImpactPurges = Visual.staleImpactPurges,
        perFrameTextureLoadCount = 0,
        maximumDrawCallsPerOrb = 2,
        projectionComputations = Visual.projectionComputations,
        projectionCacheHits = Visual.projectionCacheHits,
        duplicateProjectionCount = Visual.duplicateProjectionCount,
        visualTicks = Visual.visualTicks,
        visualBudgetSkips = Visual.visualBudgetSkips,
        mapHiddenTicks = Visual.mapHiddenTicks,
        mapOpenDrawCalls = Visual.mapOpenDrawCalls,
        offscreenDrawCalls = Visual.offscreenDrawCalls,
        sharedDrawCallbackCalls = Visual.sharedDrawCallbackCalls,
        perCastDrawEventCount = Visual.perCastDrawEventCount,
        frameParityHidingCount = Visual.frameParityHidingCount,
        drawListGapFrames = Visual.drawListGapFrames,
        interpolatedPositionCount = Visual.interpolatedPositionCount,
        castDrawIsolationFailures = Visual.castDrawIsolationFailures,
        impactDrawIsolationFailures = Visual.impactDrawIsolationFailures,
        terminalDrawNotProvenCount = Visual.terminalDrawNotProvenCount,
        coreAlphaMinimum = Visual.CORE_ALPHA_MINIMUM,
    }
end

function Visual.ResetPreflight()
    Visual.preflight = nil
end

function Visual.Shutdown()
    print("[XNP GREEN RENDER CLEANUP] stale_casts_before_shutdown=" .. tostring(Visual.activeCount)
        .. " stale_impacts_before_shutdown=" .. tostring(Visual.GetMetrics().impactCount)
        .. " stale_casts_after_shutdown=0 stale_impacts_after_shutdown=0"
        .. " per_frame_texture_load_count=0")
    Visual.activeByCastId = {}
    Visual.impactsById = {}
    Visual.activeCount = 0
    Visual.peakActiveCount = 0
    Visual.impactPeakCount = 0
    Visual.staleCastPurges = 0
    Visual.staleImpactPurges = 0
    Visual.lastFailure = nil
    Visual.preflight = nil
    Visual.runtimeOptions = nil
    Visual.nextVisualUpdateMs = 0
    Visual.projectionComputations = 0
    Visual.projectionCacheHits = 0
    Visual.duplicateProjectionCount = 0
    Visual.visualTicks = 0
    Visual.visualBudgetSkips = 0
    Visual.mapHiddenTicks = 0
    Visual.mapHidden = false
    Visual.sharedDrawCallbackCalls = 0
    Visual.drawListGapFrames = 0
    Visual.interpolatedPositionCount = 0
    Visual.castDrawIsolationFailures = 0
    Visual.impactDrawIsolationFailures = 0
    Visual.terminalDrawNotProvenCount = 0
end

Core.GreenSmoothVisual = Visual
return Visual
