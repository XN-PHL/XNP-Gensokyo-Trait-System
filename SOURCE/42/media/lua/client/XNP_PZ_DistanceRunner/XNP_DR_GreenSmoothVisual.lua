local XNPChannelGuard = require "XNP_PZ_DistanceRunner/XNP_DR_ChannelGuard"
if type(XNPChannelGuard) == "table"
    and type(XNPChannelGuard.allowRuntime) == "function"
    and not XNPChannelGuard.allowRuntime() then
    return
end

require "XNP_PZ_DistanceRunner/XNP_DR_VFXManager"

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
    CORE_ALPHA_MINIMUM = 0.90,
    DEFAULT_VISUAL_STYLE = 6,
    VISUAL_STYLE_NAMES = {
        [1] = "STABLE_CORE",
        [2] = "ENERGY_EFFECT",
        [3] = "LOW_COST",
        [4] = "BLOOM_ROTATING_CORE",
        [5] = "EMERALD_ARC_ORB",
        [6] = "CORE_ONLY_PROJECTILE",
    },
    PROJECTION_HOLD_MS = 100,
    JAVA_WORLD_ENTITY_COUNT = 0,
    MAX_DRAW_CALLS_PER_ORB = 1,
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
    activeRenderFrames = 0,
    centerSubmitFrames = 0,
    centerDrawSuccessFrames = 0,
    glowSubmitFrames = 0,
    projectionFailFrames = 0,
    heldProjectionFrames = 0,
    centerMissingFrames = 0,
    maximumConsecutiveCenterMissingFrames = 0,
    renderSnapshotAllocations = 0,
    renderSnapshotReuses = 0,
    renderSnapshotPool = {},
    renderIntervalSamples = {},
    lastRenderCallbackMs = nil,
    qualityTier = 1,
    qualityTierPending = nil,
    qualityTierPendingSinceMs = 0,
    qualityTierChanges = 0,
    bloomFrames = 0,
    rotationFrames = 0,
    trailDrawCalls = 0,
    reducedFlashingFrames = 0,
    textureFallbackCount = 0,
}

local ASSETS = {
    CENTER = { path = "media/textures/Item_XNPGreenOrbWorldCenter.png", width = 68, height = 64 },
    GLOW = { path = "media/textures/Item_XNPGreenOrbWorldGlow.png", width = 88, height = 94 },
    IMPACT = { path = "media/textures/Item_XNPGreenOrbWorldExplosion.png", width = 144, height = 144 },
    BLOOM_CORE = { path = "media/textures/Item_XNPGreenOrbBloomCore.png", width = 64, height = 64 },
    BLOOM_RING = { path = "media/textures/Item_XNPGreenOrbBloomRing.png", width = 96, height = 96 },
    BLOOM_GLOW = { path = "media/textures/Item_XNPGreenOrbBloomGlow.png", width = 128, height = 128 },
    BLOOM_TRAIL = { path = "media/textures/Item_XNPGreenOrbTrail.png", width = 96, height = 48 },
    BLOOM_IMPACT = { path = "media/textures/Item_XNPGreenOrbImpactRing.png", width = 128, height = 128 },
    ARC_CORE = { path = "media/textures/Item_XNPGreenOrbArcCore.png", width = 64, height = 64 },
    ARC_BAND = { path = "media/textures/Item_XNPGreenOrbArcBand.png", width = 96, height = 96 },
    ARC_GLOW = { path = "media/textures/Item_XNPGreenOrbArcGlow.png", width = 128, height = 128 },
    ARC_TRAIL = { path = "media/textures/Item_XNPGreenOrbArcTrail.png", width = 96, height = 48 },
    ARC_IMPACT = { path = "media/textures/Item_XNPGreenOrbArcImpact.png", width = 128, height = 128 },
    CORE_ONLY = { path = "media/textures/Item_XNPGreenOrbArcCore.png", width = 64, height = 64 },
}

local SPIN_FRAMES = {}
for index = 1, 16 do
    SPIN_FRAMES[index] = {
        path = string.format("media/textures/Item_XNPGreenOrbSpin%02d.png", index),
        width = 64,
        height = 64,
    }
end

local BLOOM_SPIN_FRAMES = {}
for index = 1, 16 do
    BLOOM_SPIN_FRAMES[index] = {
        path = string.format("media/textures/Item_XNPGreenOrbBloomRingSpin%02d.png", index),
        width = 96,
        height = 96,
    }
end

local ARC_SPIN_FRAMES = {}
for index = 1, 24 do
    ARC_SPIN_FRAMES[index] = {
        path = string.format("media/textures/Item_XNPGreenOrbArcBandSpin%02d.png", index),
        width = 96,
        height = 96,
    }
end

local DEFAULT_VISUAL_OPTIONS = {
    visualStyle = 6,
    centerDiameter = 36,
    glowDiameter = 48,
    spinEnabled = false,
    spinDegreesPerSecond = 220,
    spinFrameCount = 16,
    glowPulseEnabled = true,
    glowPulseHz = 1.25,
    glowJitterEnabled = false,
    glowJitterPixels = 0,
    glowOrbitPixels = 0,
    glowMinAlpha = 0.42,
    glowMaxAlpha = 0.75,
    coreAlpha = 1.0,
    impactVisualLifetimeMs = 140,
    impactVisualScale = 1.0,
    diagnosticBorder = false,
    visualMaximumFps = 60,
    bloomCoreDiameter = 32,
    bloomRingDiameter = 48,
    bloomGlowDiameter = 72,
    bloomScalePercent = 100,
    bloomPulseHz = 0.85,
    bloomGlowMinAlpha = 0.22,
    bloomGlowMaxAlpha = 0.42,
    bloomTrailEnabled = true,
    bloomTrailSegments = 2,
    bloomReducedFlashing = false,
    visualQualityPreset = 2,
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
    copy.visualStyle = math.max(1, math.min(6,
        math.floor(tonumber(copy.visualStyle) or Visual.DEFAULT_VISUAL_STYLE)))
    copy.glowMinAlpha = math.max(0, math.min(tonumber(copy.glowMinAlpha) or 0.42, 1))
    copy.glowMaxAlpha = math.max(copy.glowMinAlpha,
        math.min(tonumber(copy.glowMaxAlpha) or 0.90, 1))
    copy.coreAlpha = math.max(Visual.CORE_ALPHA_MINIMUM,
        math.min(tonumber(copy.coreAlpha) or 1.0, 1))
    copy.bloomTrailSegments = math.max(0, math.min(3,
        math.floor(tonumber(copy.bloomTrailSegments) or 2)))
    copy.bloomScalePercent = math.max(50,
        math.min(tonumber(copy.bloomScalePercent) or 100, 200))
    copy.visualQualityPreset = math.max(1, math.min(4,
        math.floor(tonumber(copy.visualQualityPreset) or 2)))
    if copy.visualStyle == 1 then
        copy.spinEnabled = false
        copy.glowPulseHz = math.min(tonumber(copy.glowPulseHz) or 1.25, 1.5)
        copy.glowJitterEnabled = false
        copy.glowJitterPixels = 0
        copy.glowOrbitPixels = 0
        copy.glowMinAlpha = math.max(0.35, math.min(copy.glowMinAlpha, 0.75))
        copy.glowMaxAlpha = math.max(copy.glowMinAlpha,
            math.min(copy.glowMaxAlpha, 0.75))
        copy.coreAlpha = 1.0
    elseif copy.visualStyle == 2 then
        copy.coreAlpha = math.max(0.90, copy.coreAlpha)
    elseif copy.visualStyle == 3 then
        copy.spinEnabled = false
        copy.glowPulseEnabled = false
        copy.glowJitterEnabled = false
        copy.coreAlpha = 1.0
    elseif copy.visualStyle == 4 then
        copy.spinEnabled = true
        copy.spinFrameCount = 16
        copy.spinDegreesPerSecond = math.max(30,
            math.min(tonumber(copy.spinDegreesPerSecond) or 180, 720))
        copy.glowPulseEnabled = true
        copy.glowJitterEnabled = false
        copy.glowJitterPixels = 0
        copy.glowOrbitPixels = 0
        copy.coreAlpha = 1.0
        copy.bloomPulseHz = math.max(0.20,
            math.min(tonumber(copy.bloomPulseHz) or 0.85, 2.0))
        copy.bloomGlowMinAlpha = math.max(0.10,
            math.min(tonumber(copy.bloomGlowMinAlpha) or 0.22, 0.60))
        copy.bloomGlowMaxAlpha = math.max(copy.bloomGlowMinAlpha,
            math.min(tonumber(copy.bloomGlowMaxAlpha) or 0.42, 0.75))
        if copy.bloomReducedFlashing == true or copy.visualQualityPreset == 4 then
            copy.bloomReducedFlashing = true
            copy.bloomPulseHz = math.min(copy.bloomPulseHz, 0.55)
            copy.bloomGlowMinAlpha = math.max(copy.bloomGlowMinAlpha, 0.24)
            copy.bloomGlowMaxAlpha = math.min(copy.bloomGlowMaxAlpha, 0.34)
        end
    elseif copy.visualStyle == 5 then
        copy.spinEnabled = true
        copy.spinFrameCount = 24
        copy.spinDegreesPerSecond = math.max(30,
            math.min(tonumber(copy.spinDegreesPerSecond) or 180, 720))
        copy.glowPulseEnabled = true
        copy.glowJitterEnabled = false
        copy.glowJitterPixels = 0
        copy.glowOrbitPixels = 0
        copy.coreAlpha = 1.0
        copy.bloomPulseHz = math.max(0.70,
            math.min(tonumber(copy.bloomPulseHz) or 0.80, 0.90))
        copy.bloomGlowMinAlpha = math.max(0.18,
            math.min(tonumber(copy.bloomGlowMinAlpha) or 0.18, 0.38))
        copy.bloomGlowMaxAlpha = math.max(copy.bloomGlowMinAlpha,
            math.min(tonumber(copy.bloomGlowMaxAlpha) or 0.38, 0.38))
        copy.bloomTrailSegments = math.max(1, math.min(2,
            math.floor(tonumber(copy.bloomTrailSegments) or 2)))
    else
        copy.spinEnabled = false
        copy.glowPulseEnabled = false
        copy.glowJitterEnabled = false
        copy.glowJitterPixels = 0
        copy.glowOrbitPixels = 0
        copy.bloomTrailEnabled = false
        copy.bloomTrailSegments = 0
        copy.diagnosticBorder = false
        copy.coreAlpha = 1.0
        copy.bloomCoreDiameter = math.max(20, math.min(
            tonumber(copy.bloomCoreDiameter) or 32, 42))
    end
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
    local requestedStyle = math.max(1, math.min(6, math.floor(tonumber(
        Visual.runtimeOptions and Visual.runtimeOptions.visualStyle)
        or Visual.DEFAULT_VISUAL_STYLE)))
    if Visual.preflight and Visual.preflight.style == requestedStyle then
        return Visual.preflight
    end
    Visual.preflight = nil
    local contracts = { SPIN = {}, BLOOM_SPIN = {}, ARC_SPIN = {} }
    local ready = staticApiReady()
    local reason = ready and "READY" or "PROJECTION_VIEWPORT_OR_DRAW_API_UNAVAILABLE"
    local style = requestedStyle
    if style == 6 then
        local primary, primaryReason = textureContract(ASSETS.CORE_ONLY)
        local stableFallback, stableReason = nil, "NOT_NEEDED"
        local fallback = "NONE"
        if not primary then
            stableFallback, stableReason = textureContract(ASSETS.CENTER)
            fallback = stableFallback and "TEST5_CORE" or "PROCEDURAL_DOT"
        end
        local impact, impactReason = textureContract(ASSETS.IMPACT)
        contracts.CORE_ONLY = primary or stableFallback
        contracts.CENTER = stableFallback
        contracts.IMPACT = impact
        if not contracts.CORE_ONLY then
            ready = false
            reason = "CORE_ONLY_AND_TEST5_CORE_UNAVAILABLE:"
                .. tostring(primaryReason) .. ":" .. tostring(stableReason)
        elseif not impact then
            ready = false
            reason = "IMPACT:" .. tostring(impactReason)
        end
        Visual.preflight = {
            ready = ready,
            reason = reason,
            contracts = contracts,
            style = style,
            core_fallback = fallback,
            spin_group_ready = false,
            bloom_spin_group_ready = false,
            arc_spin_group_ready = false,
            legacy_flight_assets_preloaded = false,
        }
        print("[XNP GREEN CORE PREFLIGHT] style=CORE_ONLY_PROJECTILE"
            .. " core_loaded=" .. tostring(contracts.CORE_ONLY ~= nil)
            .. " fallback=" .. tostring(fallback)
            .. " old_spin_loaded=0 bloom_spin_loaded=0 arc_spin_loaded=0"
            .. " outer_ring_loaded=false arc_band_loaded=false glow_loaded=false"
            .. " trail_loaded=false per_frame_texture_load_count=0"
            .. " max_draw_calls_per_orb=1")
        return Visual.preflight
    end
    for _, name in ipairs({
        "CENTER", "GLOW", "IMPACT", "BLOOM_CORE", "BLOOM_RING",
        "BLOOM_GLOW", "BLOOM_TRAIL", "BLOOM_IMPACT",
        "ARC_CORE", "ARC_BAND", "ARC_GLOW", "ARC_TRAIL", "ARC_IMPACT",
    }) do
        local contract, itemReason = textureContract(ASSETS[name])
        contracts[name] = contract
        if not contract then ready = false; reason = name .. ":" .. tostring(itemReason) end
        print("[XNP GREEN SMOOTH ASSET] asset=" .. string.lower(name)
            .. " loaded=" .. tostring(contract ~= nil)
            .. " texture_basename=" .. tostring(contract and contract.basename or "none")
            .. " reason=" .. tostring(itemReason))
    end
    local spinMissing = 0
    for index, asset in ipairs(SPIN_FRAMES) do
        local contract, itemReason = textureContract(asset)
        contracts.SPIN[index] = contract
        if not contract then spinMissing = spinMissing + 1 end
    end
    local bloomSpinMissing = 0
    for index, asset in ipairs(BLOOM_SPIN_FRAMES) do
        local contract, itemReason = textureContract(asset)
        contracts.BLOOM_SPIN[index] = contract
        if not contract then bloomSpinMissing = bloomSpinMissing + 1 end
    end
    local arcSpinMissing = 0
    for index, asset in ipairs(ARC_SPIN_FRAMES) do
        local contract = textureContract(asset)
        contracts.ARC_SPIN[index] = contract
        if not contract then arcSpinMissing = arcSpinMissing + 1 end
    end
    if spinMissing > 0 then
        for index = 1, #SPIN_FRAMES do
            contracts.SPIN[index] = contracts.GLOW
        end
        Visual.textureFallbackCount = Visual.textureFallbackCount + spinMissing
        print("[XNP GREEN SMOOTH] spin_group_fallback=STATIC_GLOW missing_frames="
            .. tostring(spinMissing))
    end
    if bloomSpinMissing > 0 then
        for index = 1, #BLOOM_SPIN_FRAMES do
            contracts.BLOOM_SPIN[index] = contracts.BLOOM_RING
        end
        Visual.textureFallbackCount = Visual.textureFallbackCount
            + bloomSpinMissing
        print("[XNP GREEN SMOOTH] bloom_spin_group_fallback=STATIC_RING missing_frames="
            .. tostring(bloomSpinMissing))
    end
    if arcSpinMissing > 0 then
        for index = 1, #ARC_SPIN_FRAMES do
            contracts.ARC_SPIN[index] = contracts.ARC_BAND
        end
        Visual.textureFallbackCount = Visual.textureFallbackCount + arcSpinMissing
        print("[XNP GREEN SMOOTH] arc_spin_group_fallback=STATIC_ARC missing_frames="
            .. tostring(arcSpinMissing))
    end
    Visual.preflight = {
        ready = ready,
        reason = reason,
        contracts = contracts,
        style = style,
        core_fallback = "LEGACY_STYLE",
        spin_group_ready = spinMissing == 0,
        bloom_spin_group_ready = bloomSpinMissing == 0,
        arc_spin_group_ready = arcSpinMissing == 0,
    }
    print("[XNP GREEN SMOOTH] preflight_ready=" .. tostring(ready)
        .. " spin_frames_loaded=" .. tostring(#contracts.SPIN)
        .. " bloom_spin_frames_loaded=" .. tostring(#contracts.BLOOM_SPIN)
        .. " arc_spin_frames_loaded=" .. tostring(#contracts.ARC_SPIN)
        .. " textures_preloaded_once=true per_frame_texture_load_count=0"
        .. " route=" .. Visual.ROUTE .. " draw_entry=" .. Visual.DRAW_ENTRY
        .. " max_draw_calls_per_orb=5")
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

local function project(holder, x, y, z, playerNum, context, epoch, visualTick)
    if not context then return nil, "PROJECTION_CONTEXT_MISSING" end
    if holder.last_projection_visual_tick == visualTick then
        Visual.duplicateProjectionCount = Visual.duplicateProjectionCount + 1
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
        active_render_frames = 0,
        projection_success_frames = 0,
        projection_fail_frames = 0,
        held_projection_frames = 0,
        inside_viewport_frames = 0,
        draw_attempt_frames = 0,
        draw_call_no_exception_frames = 0,
        center_submit_frames = 0,
        center_draw_success_frames = 0,
        center_missing_frames = 0,
        consecutive_center_missing_frames = 0,
        maximum_consecutive_center_missing_frames = 0,
        glow_draw_attempts = 0,
        glow_submit_frames = 0,
        glow_draw_call_no_exception_frames = 0,
        core_draw_attempts = 0,
        core_draw_call_no_exception_frames = 0,
        bloom_ring_draw_attempts = 0,
        bloom_ring_draw_success_frames = 0,
        bloom_glow_draw_attempts = 0,
        bloom_glow_draw_success_frames = 0,
        trail_draw_attempts = 0,
        trail_draw_success_count = 0,
        empty_rotation_frame_count = 0,
        full_projectile_blink_frames = 0,
        draw_exception_count = 0,
        projection_exception_count = 0,
        offscreen_frame_count = 0,
        interpolated_position_frames = 0,
        render_interval_samples = {},
        render_interval_p50_ms = 0,
        render_interval_p95_ms = 0,
        render_interval_max_ms = 0,
        last_active_render_ms = nil,
        first_frame_logged = false,
    }
end

local function desiredQualityTier(activeCount, preset)
    if preset == 3 then
        return 4
    elseif preset == 4 then
        if activeCount <= 8 then return 3 end
        return 4
    end
    if activeCount <= 4 then return 1 end
    if activeCount <= 8 then return 2 end
    if activeCount <= 12 then return 3 end
    return 4
end

local function resolveQualityTier(activeCount, preset, currentMs)
    local desired = desiredQualityTier(activeCount, preset)
    if desired == Visual.qualityTier then
        Visual.qualityTierPending = nil
        Visual.qualityTierPendingSinceMs = 0
        return Visual.qualityTier
    end
    if desired > Visual.qualityTier then
        Visual.qualityTier = desired
        Visual.qualityTierPending = nil
        Visual.qualityTierPendingSinceMs = 0
        Visual.qualityTierChanges = Visual.qualityTierChanges + 1
        return Visual.qualityTier
    end
    if Visual.qualityTierPending ~= desired then
        Visual.qualityTierPending = desired
        Visual.qualityTierPendingSinceMs = currentMs
    elseif currentMs - Visual.qualityTierPendingSinceMs >= 500 then
        Visual.qualityTier = desired
        Visual.qualityTierPending = nil
        Visual.qualityTierPendingSinceMs = 0
        Visual.qualityTierChanges = Visual.qualityTierChanges + 1
    end
    return Visual.qualityTier
end

local function recordBoundedSample(samples, value)
    if value == nil or value < 0 then return end
    samples[#samples + 1] = value
    if #samples > 240 then table.remove(samples, 1) end
end

local function percentile(samples, ratio)
    if #samples == 0 then return 0 end
    local copy = {}
    for index = 1, #samples do copy[index] = samples[index] end
    table.sort(copy)
    local selected = math.max(1, math.min(#copy,
        math.floor((#copy - 1) * ratio + 1.5)))
    return copy[selected] or 0
end

local function updateIntervalSummary(counters, currentMs)
    if counters.last_active_render_ms then
        recordBoundedSample(counters.render_interval_samples,
            currentMs - counters.last_active_render_ms)
    end
    counters.last_active_render_ms = currentMs
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

local function renderSnapshot(state)
    if not state then return nil end
    local snapshot = table.remove(Visual.renderSnapshotPool)
    if snapshot then
        Visual.renderSnapshotReuses = Visual.renderSnapshotReuses + 1
    else
        snapshot = {}
        Visual.renderSnapshotAllocations = Visual.renderSnapshotAllocations + 1
    end
    snapshot.owner = state
    snapshot.id = state.id
    snapshot.player = state.player
    snapshot.playerNum = state.playerNum
    snapshot.phase = state.phase
    snapshot.mapHidden = state.mapHidden
    snapshot.startedMs = state.startedMs
    snapshot.visualOptions = state.visualOptions
    snapshot.world_x = state.world_x
    snapshot.world_y = state.world_y
    snapshot.world_z = state.world_z
    snapshot.previous_simulation_x = state.previous_simulation_x
    snapshot.previous_simulation_y = state.previous_simulation_y
    snapshot.previous_simulation_z = state.previous_simulation_z
    snapshot.previous_simulation_ms = state.previous_simulation_ms
    snapshot.current_simulation_x = state.current_simulation_x
    snapshot.current_simulation_y = state.current_simulation_y
    snapshot.current_simulation_z = state.current_simulation_z
    snapshot.current_simulation_ms = state.current_simulation_ms
    return snapshot
end

local function releaseRenderSnapshot(snapshot)
    if not snapshot or #Visual.renderSnapshotPool >= 24 then return end
    snapshot.owner = nil
    snapshot.player = nil
    snapshot.visualOptions = nil
    Visual.renderSnapshotPool[#Visual.renderSnapshotPool + 1] = snapshot
end

local function projectedOrHeld(owner, snapshot, renderX, renderY, renderZ,
        playerNum, context, epoch, visualTick, currentMs)
    local projected, reason = project(owner, renderX, renderY, renderZ,
        playerNum, context, epoch, visualTick)
    if projected then
        if projected.inside == true then
            owner.last_valid_projected = projected
            owner.last_valid_projection_ms = currentMs
            owner.last_valid_projection_viewport = context and context.viewport or nil
        end
        return projected, reason, false
    end
    local held = owner.last_valid_projected
    local heldAt = tonumber(owner.last_valid_projection_ms)
    if held and held.inside == true and heldAt
        and currentMs - heldAt <= Visual.PROJECTION_HOLD_MS
        and context and owner.last_valid_projection_viewport == context.viewport then
        return held, "HELD_LAST_VALID_PROJECTION", true
    end
    return nil, reason, false
end

local function renderCast(snapshot, currentMs, preflight, contexts, epoch, visualTick)
    if not snapshot or not isFlightPhase(snapshot.phase) then return end
    local state = snapshot.owner
    state.inflightDraw = state.inflightDraw or newCounters()
    local counters = state.inflightDraw
    counters.render_callback_frames = counters.render_callback_frames + 1
    state.smoothVisualFrames = counters.render_callback_frames
    if snapshot.mapHidden == true then return end
    local playerNum = snapshot.playerNum or playerNumberFromPlayer(snapshot.player)
    if contexts[playerNum] == nil then contexts[playerNum] = projectionContext(playerNum) end
    local renderX, renderY, renderZ, interpolationAlpha, interpolated =
        interpolatedWorldPosition(snapshot, currentMs)
    if interpolated then
        counters.interpolated_position_frames = counters.interpolated_position_frames + 1
        Visual.interpolatedPositionCount = Visual.interpolatedPositionCount + 1
        state.lastInterpolationAlpha = interpolationAlpha
    end
    local priorScreenX = tonumber(state.last_screen_x)
    local priorScreenY = tonumber(state.last_screen_y)
    local projected, projectionReason, held = projectedOrHeld(state, snapshot,
        renderX, renderY, renderZ + 0.18, playerNum, contexts[playerNum],
        epoch, visualTick, currentMs)
    if not projected then
        counters.projection_exception_count = counters.projection_exception_count + 1
        counters.projection_fail_frames = counters.projection_fail_frames + 1
        Visual.projectionFailFrames = Visual.projectionFailFrames + 1
        Visual.lastFailure = projectionReason or "WORLD_TO_SCREEN_PROJECTION_FAILED"
        return
    end
    if held then
        counters.held_projection_frames = counters.held_projection_frames + 1
        Visual.heldProjectionFrames = Visual.heldProjectionFrames + 1
    end
    counters.projection_success_frames = counters.projection_success_frames + 1
    if projected.inside ~= true then
        counters.offscreen_frame_count = counters.offscreen_frame_count + 1
        return
    end
    counters.inside_viewport_frames = counters.inside_viewport_frames + 1
    counters.active_render_frames = counters.active_render_frames + 1
    Visual.activeRenderFrames = Visual.activeRenderFrames + 1
    updateIntervalSummary(counters, currentMs)
    local options = snapshot.visualOptions or Visual.runtimeOptions or DEFAULT_VISUAL_OPTIONS
    local seconds = math.max(0, currentMs - (snapshot.startedMs or currentMs)) / 1000
    local phase = (tonumber(snapshot.id) or 0) * 0.73
    local style = math.max(1, math.min(6, math.floor(
        tonumber(options.visualStyle) or Visual.DEFAULT_VISUAL_STYLE)))
    local activeCount = math.max(1, Visual.activeCount)
    local qualityTier = resolveQualityTier(activeCount,
        tonumber(options.visualQualityPreset) or 2, currentMs)
    state.visualQualityTier = qualityTier
    local richBudget = activeCount <= 5
    local simpleBudget = activeCount <= 12
    local effectAllowed = style ~= 3 and style ~= 6 and simpleBudget
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
    counters.core_draw_attempts = counters.core_draw_attempts + 1
    counters.center_submit_frames = counters.center_submit_frames + 1
    Visual.centerSubmitFrames = Visual.centerSubmitFrames + 1
    local arcScale = style == 5 and (0.98 + 0.10 * (0.5 + 0.5 * math.sin(
        seconds * math.pi * 2 * options.bloomPulseHz + phase))) or 1
    local scale = (style == 4 or style == 5)
        and (math.max(50, math.min(tonumber(options.bloomScalePercent) or 100, 200)) / 100)
        or 1
    scale = scale * arcScale
    local coreAlpha = (style == 4 or style == 5) and 1.0 or math.max(Visual.CORE_ALPHA_MINIMUM,
        math.min(tonumber(options.coreAlpha) or 1.0, 1))
    local centerContract = style == 6 and preflight.contracts.CORE_ONLY
        or (style == 5 and preflight.contracts.ARC_CORE
        or (style == 4 and preflight.contracts.BLOOM_CORE
            or preflight.contracts.CENTER))
    local centerSize = style == 6 and math.max(20, math.min(
        tonumber(options.bloomCoreDiameter) or 32, 42))
        or ((style == 4 or style == 5)
        and (tonumber(options.bloomCoreDiameter) or 32) * scale
        or options.centerDiameter)
    local coreOk = centerContract and draw(centerContract.texture,
        projected.screenX, projected.screenY, centerSize, centerSize, coreAlpha)
    if coreOk then
        counters.core_draw_call_no_exception_frames =
            counters.core_draw_call_no_exception_frames + 1
        counters.center_draw_success_frames = counters.center_draw_success_frames + 1
        counters.consecutive_center_missing_frames = 0
        Visual.centerDrawSuccessFrames = Visual.centerDrawSuccessFrames + 1
    else
        counters.center_missing_frames = counters.center_missing_frames + 1
        counters.consecutive_center_missing_frames =
            counters.consecutive_center_missing_frames + 1
        counters.maximum_consecutive_center_missing_frames = math.max(
            counters.maximum_consecutive_center_missing_frames,
            counters.consecutive_center_missing_frames)
        Visual.centerMissingFrames = Visual.centerMissingFrames + 1
        Visual.maximumConsecutiveCenterMissingFrames = math.max(
            Visual.maximumConsecutiveCenterMissingFrames,
            counters.consecutive_center_missing_frames)
    end
    local effectOk = true
    if style == 4 or style == 5 then
        Visual.bloomFrames = Visual.bloomFrames + 1
        if options.bloomReducedFlashing == true then
            Visual.reducedFlashingFrames = Visual.reducedFlashingFrames + 1
        end
        local bloomPulse = 0.5 + 0.5 * math.sin(
            seconds * math.pi * 2 * options.bloomPulseHz + phase)
        local bloomAlpha = options.bloomGlowMinAlpha
            + (options.bloomGlowMaxAlpha - options.bloomGlowMinAlpha) * bloomPulse
        local spinCount = style == 5 and 24 or 16
        local rotationCycles = seconds * options.spinDegreesPerSecond / 360
        local spinIndex = math.floor(rotationCycles * spinCount) % spinCount + 1
        local ringContract
        if style == 5 then
            ringContract = qualityTier <= 3
                and preflight.contracts.ARC_SPIN[spinIndex]
                or preflight.contracts.ARC_BAND
        else
            ringContract = qualityTier <= 3
                and preflight.contracts.BLOOM_SPIN[spinIndex]
                or preflight.contracts.BLOOM_RING
        end
        counters.bloom_ring_draw_attempts = counters.bloom_ring_draw_attempts + 1
        if qualityTier <= 3 then Visual.rotationFrames = Visual.rotationFrames + 1 end
        local ringOk = ringContract and draw(ringContract.texture,
            projected.screenX, projected.screenY,
            (tonumber(options.bloomRingDiameter) or 48) * scale,
            (tonumber(options.bloomRingDiameter) or 48) * scale,
            style == 5 and 0.90
                or (options.bloomReducedFlashing == true and 0.72 or 0.88))
        if ringOk then
            counters.bloom_ring_draw_success_frames =
                counters.bloom_ring_draw_success_frames + 1
        else
            counters.empty_rotation_frame_count =
                counters.empty_rotation_frame_count + 1
        end
        effectOk = ringOk == true

        if qualityTier <= 3 then
            counters.bloom_glow_draw_attempts = counters.bloom_glow_draw_attempts + 1
            counters.glow_submit_frames = counters.glow_submit_frames + 1
            Visual.glowSubmitFrames = Visual.glowSubmitFrames + 1
            local glowContract = style == 5 and preflight.contracts.ARC_GLOW
                or preflight.contracts.BLOOM_GLOW
            local glowOk = glowContract and draw(
                glowContract.texture,
                projected.screenX, projected.screenY,
                (tonumber(options.bloomGlowDiameter) or 72) * scale,
                (tonumber(options.bloomGlowDiameter) or 72) * scale,
                bloomAlpha)
            if glowOk then
                counters.bloom_glow_draw_success_frames =
                    counters.bloom_glow_draw_success_frames + 1
            end
            effectOk = effectOk and glowOk == true
        end

        local trailSegments = 0
        if options.bloomTrailEnabled == true and qualityTier <= 2 then
            trailSegments = qualityTier == 1
                and options.bloomTrailSegments or math.min(1, options.bloomTrailSegments)
        end
        if trailSegments > 0 and priorScreenX and priorScreenY then
            local dx = projected.screenX - priorScreenX
            local dy = projected.screenY - priorScreenY
            local length = math.sqrt(dx * dx + dy * dy)
            if length > 0.05 then
                local nx, ny = dx / length, dy / length
                for index = 1, trailSegments do
                    counters.trail_draw_attempts = counters.trail_draw_attempts + 1
                    local offset = math.min(centerSize * 0.35,
                        centerSize * (0.13 + index * 0.10))
                    local trailContract = style == 5 and preflight.contracts.ARC_TRAIL
                        or preflight.contracts.BLOOM_TRAIL
                    local trailOk = trailContract and draw(
                        trailContract.texture,
                        projected.screenX - nx * offset,
                        projected.screenY - ny * offset,
                        centerSize * (1.10 + index * 0.10),
                        centerSize * (0.42 + index * 0.04),
                        0.24 / index)
                    if trailOk then
                        counters.trail_draw_success_count =
                            counters.trail_draw_success_count + 1
                        Visual.trailDrawCalls = Visual.trailDrawCalls + 1
                    end
                end
            end
        end
    elseif effectAllowed then
        counters.glow_draw_attempts = counters.glow_draw_attempts + 1
        local effectContract = preflight.contracts.GLOW
        local effectAlpha = alpha
        if style == 2 and richBudget and options.spinEnabled == true then
            local spinCount = options.spinFrameCount
            local rotationCycles = seconds * options.spinDegreesPerSecond / 360
            local spinIndex = math.floor(rotationCycles * spinCount) % spinCount + 1
            effectContract = preflight.contracts.SPIN[spinIndex]
                or preflight.contracts.SPIN[1]
            effectAlpha = math.max(0.35, math.min(alpha, 0.75))
        else
            counters.glow_submit_frames = counters.glow_submit_frames + 1
            Visual.glowSubmitFrames = Visual.glowSubmitFrames + 1
        end
        effectOk = effectContract and draw(effectContract.texture,
            projected.screenX + jitterX, projected.screenY + jitterY,
            options.glowDiameter, options.glowDiameter, effectAlpha)
        if effectOk then
            counters.glow_draw_call_no_exception_frames =
                counters.glow_draw_call_no_exception_frames + 1
        end
    end
    if coreOk and effectOk then
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
    local impactContract = record.visualStyle == 6 and preflight.contracts.IMPACT
        or (record.visualStyle == 5 and preflight.contracts.ARC_IMPACT
        or (record.visualStyle == 4 and preflight.contracts.BLOOM_IMPACT
            or preflight.contracts.IMPACT))
    draw(impactContract.texture, projected.screenX, projected.screenY,
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
    if Visual.lastRenderCallbackMs then
        recordBoundedSample(Visual.renderIntervalSamples,
            currentMs - Visual.lastRenderCallbackMs)
    end
    Visual.lastRenderCallbackMs = currentMs
    local preflight = Visual.Preflight()
    if preflight.ready ~= true then return end
    local epoch = Core.MapVisibility and Core.MapVisibility.GetProjectionEpoch()
        or Visual.projectionEpoch
    local contexts = {}
    local casts = {}
    for _, state in pairs(Visual.activeByCastId) do
        if state and state.finished ~= true and state.cleanupComplete ~= true then
            casts[#casts + 1] = renderSnapshot(state)
        end
    end
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
        releaseRenderSnapshot(state)
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
        and counters.center_draw_success_frames >= required
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
    c.render_interval_p50_ms = percentile(c.render_interval_samples, 0.50)
    c.render_interval_p95_ms = percentile(c.render_interval_samples, 0.95)
    c.render_interval_max_ms = percentile(c.render_interval_samples, 1.00)
    if proof.ready ~= true and not (state and state.mapHidden == true) then
        Visual.terminalDrawNotProvenCount = Visual.terminalDrawNotProvenCount + 1
    end
    print("[XNP GREEN FLIGHT DRAW SUMMARY] render_callback_frames=" .. tostring(c.render_callback_frames)
        .. " projection_success_frames=" .. tostring(c.projection_success_frames)
        .. " projection_fail_frames=" .. tostring(c.projection_fail_frames)
        .. " held_projection_frames=" .. tostring(c.held_projection_frames)
        .. " inside_viewport_frames=" .. tostring(c.inside_viewport_frames)
        .. " active_render_frames=" .. tostring(c.active_render_frames)
        .. " center_submit_frames=" .. tostring(c.center_submit_frames)
        .. " center_draw_success_frames=" .. tostring(c.center_draw_success_frames)
        .. " glow_submit_frames=" .. tostring(c.glow_submit_frames)
        .. " center_missing_frames=" .. tostring(c.center_missing_frames)
        .. " maximum_consecutive_center_missing_frames="
        .. tostring(c.maximum_consecutive_center_missing_frames)
        .. " render_interval_p50_ms=" .. tostring(c.render_interval_p50_ms)
        .. " render_interval_p95_ms=" .. tostring(c.render_interval_p95_ms)
        .. " render_interval_max_ms=" .. tostring(c.render_interval_max_ms)
        .. " draw_call_no_exception_frames=" .. tostring(c.draw_call_no_exception_frames)
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
    if not Core.VFXManager
        or type(Core.VFXManager.RegisterRenderer) ~= "function" then
        Visual.lastFailure = "VFX_MANAGER_UNAVAILABLE"
        return false
    end
    local registered, reason = Core.VFXManager.RegisterRenderer(
        "GREEN_PROJECTILE_RENDERER", renderActive)
    if registered ~= true then
        Visual.lastFailure = tostring(reason or "VFX_MANAGER_REGISTRATION_FAILED")
        return false
    end
    Core.green_smooth_visual_render_registered = true
    Visual.registered = true
    print("[XNP GREEN SMOOTH] renderer_registered=true callback_owner=XNP_DR_VFX_MANAGER callback_count_owned=0")
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
    state.visualIdentity = "GREEN_ORB_PERSISTENT_CENTER_"
        .. tostring(Visual.VISUAL_STYLE_NAMES[state.visualOptions.visualStyle]
            or "STABLE_CORE")
    if state.visualOptions.visualStyle == 5 then
        print("[XNP GREEN STYLE5] cast_id=" .. tostring(state.id)
            .. " style=EMERALD_ARC_ORB core=true arc_band_count=2"
            .. " crosshair=false cardinal_spokes=false target_reticle=false"
            .. " debug_border=false trail_count="
            .. tostring(state.visualOptions.bloomTrailSegments)
            .. " glow_hz=" .. tostring(state.visualOptions.bloomPulseHz)
            .. " glow_alpha_min=" .. tostring(state.visualOptions.bloomGlowMinAlpha)
            .. " glow_alpha_max=" .. tostring(state.visualOptions.bloomGlowMaxAlpha))
    elseif state.visualOptions.visualStyle == 6 then
        print("[XNP GREEN CORE ONLY] cast_id=" .. tostring(state.id)
            .. " style=CORE_ONLY_PROJECTILE core=true outer_ring=false"
            .. " rotating_layer=false arc_band_count=0 glow_layer=false"
            .. " trail_count=0 crosshair=false cardinal_spokes=false"
            .. " target_reticle=false target_outline=false debug_border=false"
            .. " draw_calls_per_orb=1 fallback="
            .. tostring(preflight.core_fallback or "NONE"))
    end
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
        visualStyle = options.visualStyle,
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
        renderCallbackCountOwned = 0,
        renderedFrames = Visual.renderedFrames,
        impactPeakCount = Visual.impactPeakCount,
        impactCount = impactCount,
        maximumImpactRecords = Visual.maximumImpactRecords,
        staleCastPurges = Visual.staleCastPurges,
        staleImpactPurges = Visual.staleImpactPurges,
        perFrameTextureLoadCount = 0,
        maximumDrawCallsPerOrb = Visual.MAX_DRAW_CALLS_PER_ORB,
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
        defaultVisualStyle = Visual.VISUAL_STYLE_NAMES[Visual.DEFAULT_VISUAL_STYLE],
        activeRenderFrames = Visual.activeRenderFrames,
        centerSubmitFrames = Visual.centerSubmitFrames,
        centerDrawSuccessFrames = Visual.centerDrawSuccessFrames,
        glowSubmitFrames = Visual.glowSubmitFrames,
        projectionFailFrames = Visual.projectionFailFrames,
        heldProjectionFrames = Visual.heldProjectionFrames,
        centerMissingFrames = Visual.centerMissingFrames,
        maximumConsecutiveCenterMissingFrames =
            Visual.maximumConsecutiveCenterMissingFrames,
        renderIntervalP50Ms = percentile(Visual.renderIntervalSamples, 0.50),
        renderIntervalP95Ms = percentile(Visual.renderIntervalSamples, 0.95),
        renderIntervalMaxMs = percentile(Visual.renderIntervalSamples, 1.00),
        renderAllocationEstimate = Visual.renderSnapshotAllocations,
        renderSnapshotReuseCount = Visual.renderSnapshotReuses,
        renderSnapshotPoolSize = #Visual.renderSnapshotPool,
        immutableRenderSnapshots = true,
        projectionHoldMaximumMs = Visual.PROJECTION_HOLD_MS,
        qualityTier = Visual.qualityTier,
        qualityTierChanges = Visual.qualityTierChanges,
        qualityTierHysteresisMs = 500,
        bloomFrames = Visual.bloomFrames,
        rotationFrames = Visual.rotationFrames,
        trailDrawCalls = Visual.trailDrawCalls,
        reducedFlashingFrames = Visual.reducedFlashingFrames,
        textureFallbackCount = Visual.textureFallbackCount,
    }
end

function Visual.ResetPreflight()
    Visual.preflight = nil
end

function Visual.Shutdown()
    local metrics = Visual.GetMetrics()
    print("[XNP GREEN RENDER CONTINUITY] active_render_frames="
        .. tostring(metrics.activeRenderFrames)
        .. " center_submit_frames=" .. tostring(metrics.centerSubmitFrames)
        .. " center_draw_success_frames=" .. tostring(metrics.centerDrawSuccessFrames)
        .. " glow_submit_frames=" .. tostring(metrics.glowSubmitFrames)
        .. " projection_fail_frames=" .. tostring(metrics.projectionFailFrames)
        .. " held_projection_frames=" .. tostring(metrics.heldProjectionFrames)
        .. " center_missing_frames=" .. tostring(metrics.centerMissingFrames)
        .. " maximum_consecutive_center_missing_frames="
        .. tostring(metrics.maximumConsecutiveCenterMissingFrames)
        .. " render_interval_p50_ms=" .. tostring(metrics.renderIntervalP50Ms)
        .. " render_interval_p95_ms=" .. tostring(metrics.renderIntervalP95Ms)
        .. " render_interval_max_ms=" .. tostring(metrics.renderIntervalMaxMs)
        .. " allocation_estimate=" .. tostring(metrics.renderAllocationEstimate))
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
    Visual.activeRenderFrames = 0
    Visual.centerSubmitFrames = 0
    Visual.centerDrawSuccessFrames = 0
    Visual.glowSubmitFrames = 0
    Visual.projectionFailFrames = 0
    Visual.heldProjectionFrames = 0
    Visual.centerMissingFrames = 0
    Visual.maximumConsecutiveCenterMissingFrames = 0
    Visual.renderSnapshotAllocations = 0
    Visual.renderSnapshotReuses = 0
    Visual.renderSnapshotPool = {}
    Visual.renderIntervalSamples = {}
    Visual.lastRenderCallbackMs = nil
    Visual.qualityTier = 1
    Visual.qualityTierPending = nil
    Visual.qualityTierPendingSinceMs = 0
    Visual.qualityTierChanges = 0
    Visual.bloomFrames = 0
    Visual.rotationFrames = 0
    Visual.trailDrawCalls = 0
    Visual.reducedFlashingFrames = 0
    Visual.textureFallbackCount = 0
end

Core.GreenSmoothVisual = Visual
return Visual
