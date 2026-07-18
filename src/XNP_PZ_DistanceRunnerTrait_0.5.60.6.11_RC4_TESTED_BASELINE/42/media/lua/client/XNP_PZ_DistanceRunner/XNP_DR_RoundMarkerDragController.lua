require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame

local DragController = {
    active = nil,
}

local function clearActive(active)
    if active and active.state then
        active.state.dragging = false
    end
    DragController.active = nil
end

function DragController.Start(panel, x, y, player, positionKey, state)
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

    panel:setX(getMouseX() - active.offsetX)
    panel:setY(getMouseY() - active.offsetY)
    return true
end

function DragController.Release(panel)
    local active = DragController.active
    if not active or active.panel ~= panel then return false end
    panel:setCapture(false)
    Frame.ClampPanel(panel, panel:getX(), panel:getY())
    local saved = Frame.SavePosition(active.player, active.positionKey, panel)
    clearActive(active)
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
