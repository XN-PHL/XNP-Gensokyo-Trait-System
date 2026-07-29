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

function Proxy.Preflight()
    if Proxy.preflight then return Proxy.preflight end
    local smooth = Core.GreenSmoothVisual.Preflight()
    Proxy.preflight = {
        smoothReady = smooth.ready == true,
        smoothReason = smooth.reason,
        ready = smooth.ready == true,
    }
    return Proxy.preflight
end

function Proxy.ResetPreflight()
    Proxy.preflight = nil
    if Core.GreenSmoothVisual then Core.GreenSmoothVisual.ResetPreflight() end
end

function Proxy.Create(state)
    if not state then return false, "STATE_MISSING" end
    local preflight = Proxy.Preflight()
    if preflight.ready ~= true then return false, preflight.smoothReason or "PREFLIGHT_FAILED" end
    local active, method = Core.GreenSmoothVisual.Activate(state)
    if not active then return false, method end
    state.visibleProxy = { kind = "FLIGHT", drawProofPending = true }
    print("[XNP GREEN VISUAL] created=true draw_proof_pending=true route=" .. Proxy.ROUTE
        .. " layers=PULSING_GLOW>ROTATING_ENERGY_CORE>ROUND_ORB_CENTER"
        .. " outer_ground_ring=false trail=false max_draw_calls_per_orb=4")
    return true, method
end

function Proxy.Update(state)
    if not state or not state.visibleProxy or state.visibleProxy.kind ~= "FLIGHT" then
        return false, "VISIBLE_PROXY_NOT_CONFIRMED"
    end
    if Core.GreenSmoothVisual.IsActive(state) ~= true then return false, "SMOOTH_VISUAL_NOT_ACTIVE" end
    return true, "SUB_TILE_WORLD_POSITION_AVAILABLE_DRAW_PROOF_PENDING"
end

function Proxy.ShowImpact(state)
    if not state or not state.visibleProxy or Core.GreenSmoothVisual.IsActive(state) ~= true then
        return false, "TRACK_SMOOTH_VISUAL_NOT_CONFIRMED"
    end
    local requiredFrames = state.options and state.options.projectileArmRenderFrames or 1
    local proof = Core.GreenSmoothVisual.GetProof(state, requiredFrames)
    if proof.ready ~= true then
        print("[XNP GREEN INFLIGHT] draw_proof_ready=false diagnostic_only=true reason="
            .. tostring(proof.reason or "INFLIGHT_DRAW_NOT_PROVEN"))
    end
    local visible, method, impactId = Core.GreenSmoothVisual.ShowImpact(state)
    if not visible then return false, method end
    state.visibleProxy.kind = "IMPACT"
    state.visibleProxy.impactId = impactId
    state.visibleProxy.confirmed = true
    print("[XNP GREEN IMPACT] visible=true projected_explosion=true"
        .. " ground_lock_ring_removed=true lifetime_ms="
        .. tostring(state.options and state.options.impactVisualLifetimeMs or 140))
    return true, method
end

function Proxy.ConfirmImpact(state)
    local proxy = state and state.visibleProxy or nil
    return proxy ~= nil and proxy.kind == "IMPACT" and proxy.confirmed == true
        and Core.GreenSmoothVisual.ConfirmImpact(state) == true
end

function Proxy.Cleanup(state)
    if not state then return true, "STATE_MISSING" end
    local requiredFrames = state.options and state.options.projectileArmRenderFrames or 1
    if Core.GreenSmoothVisual and Core.GreenSmoothVisual.LogSummary then
        Core.GreenSmoothVisual.LogSummary(state, requiredFrames)
    end
    Core.GreenSmoothVisual.Deactivate(state)
    local preserveTimedImpact = state.visibleProxy and state.visibleProxy.kind == "IMPACT"
    if preserveTimedImpact then
        Core.GreenSmoothVisual.DetachImpact(state)
    else
        Core.GreenSmoothVisual.RemoveImpact(state)
    end
    state.visibleProxy = nil
    print("[XNP GREEN TRACK] smooth_render_frames=" .. tostring(state.smoothVisualFrames or 0)
        .. " visual_granularity=" .. Proxy.TRACKING_VISUAL_GRANULARITY)
    print("[XNP GREEN VISUAL] projectile_removed=true timed_impact_preserved="
        .. tostring(preserveTimedImpact) .. " no_trail=true")
    return true, "CAST_VISUAL_CLEANED"
end

function Proxy.SetMapHidden(hidden)
    if Core.GreenSmoothVisual and Core.GreenSmoothVisual.SetMapHidden then
        Core.GreenSmoothVisual.SetMapHidden(hidden)
    end
end

Core.GreenVisibleProxy = Proxy
return Proxy
