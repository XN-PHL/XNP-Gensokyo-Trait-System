require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame

local DragController = {
    active = nil,
}

local DRAG_THRESHOLD_PX = 12

local function distance(x1, y1, x2, y2)
    local dx = (tonumber(x1) or 0) - (tonumber(x2) or 0)
    local dy = (tonumber(y1) or 0) - (tonumber(y2) or 0)
    return math.sqrt(dx * dx + dy * dy)
end

local function clearActive(active)
    if active and active.state then
        active.state.dragging = false
    end
    DragController.active = nil
end

function DragController.Start(panel, x, y, player, positionKey, state)
    if Core.SandboxTuning and not Core.SandboxTuning.GetBoolean("MarkerDragEnabled", true) then return false end
    if not panel or not Frame.PointInside(x, y) then return false end
    if DragController.active then
        DragController.Cancel(DragController.active.panel, "NEW_DRAG_OWNER")
    end

    local mouseX = getMouseX()
    local mouseY = getMouseY()
    DragController.active = {
        panel = panel,
        player = player,
        positionKey = positionKey,
        state = state,
        startX = panel:getX(),
        startY = panel:getY(),
        downScreenX = mouseX,
        downScreenY = mouseY,
        downLocalX = x,
        downLocalY = y,
        lastScreenX = mouseX,
        lastScreenY = mouseY,
        moveCount = 0,
        offsetX = mouseX - panel:getX(),
        offsetY = mouseY - panel:getY(),
    }
    if state then state.dragging = true end
    panel:setCapture(true)
    return true
end

function DragController.Move(panel)
    local active = DragController.active
    if not active or active.panel ~= panel then return false end
    if not isMouseButtonDown(0) then
        return DragController.Cancel(panel, "LEFT_BUTTON_RELEASE_EVENT_LOST")
    end

    local mouseX, mouseY = getMouseX(), getMouseY()
    if mouseX ~= active.lastScreenX or mouseY ~= active.lastScreenY then
        active.moveCount = active.moveCount + 1
        active.lastScreenX = mouseX
        active.lastScreenY = mouseY
    end
    panel:setX(mouseX - active.offsetX)
    panel:setY(mouseY - active.offsetY)
    return true
end

function DragController.GetInputSnapshot(panel, localX, localY)
    local active = DragController.active
    if not active or active.panel ~= panel then return nil end
    local upScreenX, upScreenY = getMouseX(), getMouseY()
    local rawDistance = distance(upScreenX, upScreenY,
        active.downScreenX, active.downScreenY)
    local moveCount = tonumber(active.moveCount) or 0
    local effectiveDistance = moveCount > 0 and rawDistance or 0
    return {
        down_screen_x = active.downScreenX,
        down_screen_y = active.downScreenY,
        down_local_x = active.downLocalX,
        down_local_y = active.downLocalY,
        up_screen_x = upScreenX,
        up_screen_y = upScreenY,
        up_local_x = localX,
        up_local_y = localY,
        move_count = moveCount,
        raw_screen_distance = rawDistance,
        distance_same_space = effectiveDistance,
        is_drag = moveCount > 0 and effectiveDistance > DRAG_THRESHOLD_PX,
        tolerance_band = moveCount > 0 and effectiveDistance >= 6
            and effectiveDistance <= DRAG_THRESHOLD_PX,
    }
end

function DragController.Finish(panel, localX, localY)
    local active = DragController.active
    if not active or active.panel ~= panel then return false, nil, false end
    local snapshot = DragController.GetInputSnapshot(panel, localX, localY)
    local isDrag = snapshot and snapshot.is_drag == true
    panel:setCapture(false)
    local saved = true
    if isDrag then
        Frame.ClampPanel(panel, panel:getX(), panel:getY())
        local persistent = not Core.SandboxTuning
            or Core.SandboxTuning.GetBoolean("MarkerPositionPersistenceEnabled", true)
        saved = persistent and Frame.SavePosition(
            active.player, active.positionKey, panel) or true
    else
        panel:setX(active.startX)
        panel:setY(active.startY)
    end
    clearActive(active)
    return saved, snapshot, isDrag
end

function DragController.Release(panel)
    local saved = DragController.Finish(panel, nil, nil)
    return saved
end

function DragController.Cancel(panel, reason)
    local active = DragController.active
    if not active or (panel and active.panel ~= panel) then return false end
    active.panel:setCapture(false)
    active.panel:setX(active.startX)
    active.panel:setY(active.startY)
    clearActive(active)
    return true
end

function DragController.IsDragging(panel)
    return DragController.active ~= nil
        and (panel == nil or DragController.active.panel == panel)
end

function DragController.CancelAll(reason)
    if not DragController.active then return false end
    return DragController.Cancel(DragController.active.panel, reason or "CANCEL_ALL")
end

Core.RoundMarkerDragController = DragController
return DragController
