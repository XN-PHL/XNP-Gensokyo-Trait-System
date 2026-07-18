require "XNP_PZ_DistanceRunner/XNP_DR_GreenSmoothVisual"

local Core = XNP_PZ_DistanceRunner

local Proxy = {
    ROUTE = "PER_PLAYER_ZOOM_VIEWPORT_PROJECTED_DRAW_PROOF",
    TRACKING_VISUAL_GRANULARITY = "SUB_TILE_EVERY_RENDER_FRAME",
    WORLD_COORDINATE_ANCHORED = true,
    SCREEN_FIXED_UI = false,
    CAMERA_DRIFT = false,
    PREVIOUS_FRAME_TRAIL_CLEARED = true,
    SAVE_PERSISTENCE = false,
    MODEL_SCRIPT_LOOKUP = false,
    FBX_MODEL = false,
    preflight = nil,
}

local EXPLOSION = {
    path = "media/textures/Item_XNPGreenOrbWorldExplosion.png",
    expectedWidth = 144,
    expectedHeight = 144,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function basename(path)
    local value = string.gsub(tostring(path or ""), "\\", "/")
    return string.match(value, "([^/]+)$") or value
end

local function explosionContract()
    if type(getTexture) ~= "function" then return nil, "GET_TEXTURE_UNAVAILABLE" end
    local ok, texture = pcall(getTexture, EXPLOSION.path)
    if not ok or not texture then return nil, "TEXTURE_LOAD_FAILED" end
    local nameOk, name = invoke(texture, "getName")
    local widthOk, width = invoke(texture, "getWidth")
    local heightOk, height = invoke(texture, "getHeight")
    width = widthOk and tonumber(width) or nil
    height = heightOk and tonumber(height) or nil
    if not nameOk or type(name) ~= "string" or name == "" then return nil, "TEXTURE_NAME_UNAVAILABLE" end
    if width ~= EXPLOSION.expectedWidth or height ~= EXPLOSION.expectedHeight then
        return nil, "TEXTURE_SIZE_MISMATCH"
    end
    return { name = name, basename = basename(name), width = width, height = height }, "READY"
end

function Proxy.Preflight()
    if Proxy.preflight then return Proxy.preflight end
    local smooth = Core.GreenSmoothVisual.Preflight()
    local explosion, explosionReason = explosionContract()
    Proxy.preflight = {
        smoothReady = smooth.ready == true,
        smoothReason = smooth.reason,
        explosion = explosion,
        explosionReady = explosion ~= nil,
        ready = smooth.ready == true and explosion ~= nil,
    }
    print("[XNP GREEN ASSET] explosion_loaded=" .. tostring(explosion ~= nil)
        .. " texture_basename=" .. tostring(explosion and explosion.basename or "none")
        .. " reason=" .. tostring(explosionReason))
    return Proxy.preflight
end

function Proxy.ResetPreflight()
    Proxy.preflight = nil
    if Core.GreenSmoothVisual then Core.GreenSmoothVisual.ResetPreflight() end
end

local function removeMarkers(proxy)
    if not proxy or type(proxy.markers) ~= "table" then return 0 end
    local removed = 0
    for _, marker in ipairs(proxy.markers) do
        local ok = invoke(marker, "remove")
        if ok then removed = removed + 1 end
    end
    proxy.markers = {}
    return removed
end

local function squareAt(state)
    if type(getCell) ~= "function" then return nil, "CELL_API_UNAVAILABLE" end
    local ok, cell = pcall(getCell)
    if not ok or not cell or type(cell.getGridSquare) ~= "function" then return nil, "CELL_UNAVAILABLE" end
    local x = math.floor(tonumber(state.world_x) or 0)
    local y = math.floor(tonumber(state.world_y) or 0)
    local z = math.floor(tonumber(state.world_z) or 0)
    local squareOk, square = pcall(function() return cell:getGridSquare(x, y, z) end)
    if not squareOk or not square then return nil, "GRID_SQUARE_UNAVAILABLE" end
    return square
end

function Proxy.Create(state)
    if not state then return false, "STATE_MISSING" end
    local preflight = Proxy.Preflight()
    if preflight.ready ~= true then return false, preflight.smoothReason or "PREFLIGHT_FAILED" end
    local active, method = Core.GreenSmoothVisual.Activate(state)
    if not active then return false, method end
    state.visibleProxy = { kind = "TRACK", markers = {}, drawProofPending = true }
    print("[XNP GREEN VISUAL] created=true draw_proof_pending=true route=" .. Proxy.ROUTE
        .. " layers=LOCK_AREA_GROUND_RING>SMALL_GLOW>ROUND_ORB_CENTER"
        .. " shared_center=true aspect_ratio=1.0 rotation_degrees=0")
    return true, method
end

function Proxy.Update(state)
    if not state or not state.visibleProxy or state.visibleProxy.kind ~= "TRACK" then
        return false, "VISIBLE_PROXY_NOT_CONFIRMED"
    end
    if Core.GreenSmoothVisual.IsActive(state) ~= true then return false, "SMOOTH_VISUAL_NOT_ACTIVE" end
    return true, "SUB_TILE_WORLD_POSITION_AVAILABLE_DRAW_PROOF_PENDING"
end

function Proxy.ShowImpact(state)
    if not state or not state.visibleProxy or Core.GreenSmoothVisual.IsActive(state) ~= true then
        return false, "TRACK_SMOOTH_VISUAL_NOT_CONFIRMED"
    end
    local requiredFrames = state.options and state.options.minimumInflightRenderFrames or 2
    local proof = Core.GreenSmoothVisual.GetProof(state, requiredFrames)
    if proof.ready ~= true then return false, "INFLIGHT_DRAW_NOT_PROVEN" end
    Core.GreenSmoothVisual.Deactivate(state)
    local preflight = Proxy.Preflight()
    if not preflight.explosionReady then return false, "EXPLOSION_TEXTURE_NOT_READY" end
    if type(getIsoMarkers) ~= "function" then return false, "ISO_MARKER_API_UNAVAILABLE" end
    local managerOk, manager = pcall(getIsoMarkers)
    local square, squareReason = squareAt(state)
    if not managerOk or not manager then return false, "ISO_MARKER_MANAGER_UNAVAILABLE" end
    if not square then return false, squareReason end
    local ok, marker = pcall(function()
        return manager:addIsoMarker(preflight.explosion.name, square, 0.15, 1.0, 0.26, 1.0)
    end)
    if not ok or not marker then return false, "IMPACT_MARKER_CREATE_FAILED" end
    state.visibleProxy.kind = "IMPACT"
    state.visibleProxy.markers = { marker }
    state.visibleProxy.explosionMarker = marker
    state.visibleProxy.confirmed = true
    print("[XNP GREEN IMPACT] visible=true explosion=true ground_lock_ring_removed=true")
    return true, "NATIVE_ISO_MARKER_IMPACT_ONLY"
end

function Proxy.ConfirmImpact(state)
    local proxy = state and state.visibleProxy or nil
    if not proxy or proxy.kind ~= "IMPACT" or proxy.confirmed ~= true or not proxy.explosionMarker then return false end
    local removedOk, removed = invoke(proxy.explosionMarker, "isRemoved")
    return not removedOk or removed ~= true
end

function Proxy.Cleanup(state)
    if not state then return end
    local requiredFrames = state.options and state.options.minimumInflightRenderFrames or 2
    if Core.GreenSmoothVisual and Core.GreenSmoothVisual.LogSummary then
        Core.GreenSmoothVisual.LogSummary(state, requiredFrames)
    end
    Core.GreenSmoothVisual.Deactivate(state)
    local proxy = state.visibleProxy
    local removed = removeMarkers(proxy)
    state.visibleProxy = nil
    print("[XNP GREEN TRACK] smooth_render_frames=" .. tostring(state.smoothVisualFrames or 0)
        .. " visual_granularity=" .. Proxy.TRACKING_VISUAL_GRANULARITY)
    print("[XNP GREEN VISUAL] removed=true impact_marker_count=" .. tostring(removed)
        .. " no_trail=true")
end

Core.GreenVisibleProxy = Proxy
return Proxy
