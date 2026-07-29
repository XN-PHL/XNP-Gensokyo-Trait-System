require "ISUI/ISPanel"
require "ISUI/ISContextMenu"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_ToggleTransactions"

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame
local Drag = Core.RoundMarkerDragController
local Tooltip = Core.RoundMarkerTooltip

local RedUI = {
    panel = nil,
    texture = nil,
    textureAttempted = false,
    player = nil,
    loadedPosition = false,
    dragging = false,
    rightDown = false,
    count = 0,
    color = "GREEN",
    mode = "GREEN_STAMINA",
    hasTrait = false,
    crafting = false,
    lastColor = nil,
    dirty = true,
    nextInventoryRefreshMs = 0,
    desiredVisible = false,
    mapHidden = false,
    pressX = 0,
    pressY = 0,
    dragMoved = false,
    firstClickMs = 0,
    firstClickX = 0,
    firstClickY = 0,
}

local POSITION_KEY = "XNP_UI_RED_ROUND_POS_0557"
local LEGACY_KEYS = { "XNP_UI_RED_MAGIC_POS", "XNP_UI_RED_MARK_POS", "XNP_UI_RED_GUARDIAN_POS" }
local ICON_PATH = "media/ui/XNPMarkers/xnp_marker_red.png"
local INVENTORY_REFRESH_MS = 500
local DOUBLE_CLICK_MS = 350
local DRAG_THRESHOLD_PX = 5
local Panel = ISPanel:derive("XNPRedMagicRoundPanel0557")

local function distanceSquared(x1, y1, x2, y2)
    local dx, dy = x1 - x2, y1 - y2
    return dx * dx + dy * dy
end

local function loadPosition(player, panel)
    if RedUI.loadedPosition and RedUI.player == player then return end
    RedUI.player = player
    RedUI.loadedPosition = true
    local x, y, source = Frame.LoadPosition(player, POSITION_KEY, LEGACY_KEYS, 0)
    Frame.ClampPanel(panel, x, y)
    print("[XNP RED ROUND] position_source=" .. tostring(source))
end

local function refreshCount(player, force)
    local now = Frame.NowMs()
    if force ~= true and not RedUI.dirty and now < RedUI.nextInventoryRefreshMs then return false end
    RedUI.nextInventoryRefreshMs = now + INVENTORY_REFRESH_MS
    RedUI.dirty = false
    local snapshot = Core.RedGuardianMark and Core.RedGuardianMark.GetInventorySnapshot
        and Core.RedGuardianMark.GetInventorySnapshot(player) or nil
    RedUI.hasTrait = Core.RedGuardianMark.PlayerHasTrait(player) == true
    RedUI.count = snapshot and tonumber(snapshot.count) or 0
    RedUI.mode = Core.RedGuardianMark.GetMode(player)
    RedUI.color = RedUI.crafting and "BLUE" or (RedUI.mode == Core.RedGuardianMark.MODE_TREATMENT and "WHITE" or "GREEN")
    if RedUI.color ~= RedUI.lastColor then
        RedUI.lastColor = RedUI.color
        print("[XNP RED ROUND] color=" .. RedUI.color .. " mode=" .. RedUI.mode .. " whole_item_count=" .. tostring(RedUI.count))
    end
    return true
end

local function craftRawStatText()
    local tuning = Core.SandboxTuning
    local unhappiness = tuning and tuning.GetNumber
        and tuning.GetNumber("RedCraftUnhappinessCost", 10, 0, 100) or 10
    local boredom = tuning and tuning.GetNumber
        and tuning.GetNumber("RedPCraftBoredomReduction", 30, 0, 100) or 30
    return string.format(getText("UI_XNPMarker_RedCraftRawStats"),
        tostring(unhappiness), tostring(boredom))
end

function Panel:new(x, y)
    local panel = ISPanel:new(x, y, Frame.PANEL_SIZE, Frame.PANEL_SIZE)
    setmetatable(panel, self)
    self.__index = self
    Frame.PreparePanel(panel)
    return panel
end


function Panel:onMouseDown(x, y)
    Tooltip.Hide("RED_MOUSE_DOWN")
    RedUI.pressX = getMouseX()
    RedUI.pressY = getMouseY()
    RedUI.dragMoved = false
    return Drag.Start(self, x, y, RedUI.player, POSITION_KEY, RedUI)
end

function Panel:onMouseMove(dx, dy)
    if Drag.IsDragging(self) then
        local mx, my = getMouseX(), getMouseY()
        if distanceSquared(mx, my, RedUI.pressX, RedUI.pressY) > DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX then
            RedUI.dragMoved = true
            RedUI.firstClickMs = 0
        end
        return Drag.Move(self)
    end
    local detail
    if not RedUI.hasTrait then
        detail = getText("UI_XNPMarker_RedLocked")
    else
        detail = getText("UI_XNPMarker_RedHelp")
            .. "<LINE>" .. craftRawStatText()
            .. "<LINE>" .. getText("UI_XNPMarker_RedMode") .. ": " .. tostring(RedUI.mode)
            .. "<LINE>" .. getText("UI_XNPMarker_RedCount") .. ": " .. tostring(RedUI.count)
    end
    return Tooltip.Show(self, getText("UI_XNPMarker_RedName"), detail)
end

function Panel:onMouseUp(x, y)
    local moved = RedUI.dragMoved
    local mx, my = getMouseX(), getMouseY()
    local released = Drag.Release(self)
    if moved then return released end
    local now = Frame.NowMs()
    local close = distanceSquared(mx, my, RedUI.firstClickX, RedUI.firstClickY) <= DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX
    if RedUI.hasTrait and RedUI.firstClickMs > 0 and now - RedUI.firstClickMs <= DOUBLE_CLICK_MS and close then
        RedUI.firstClickMs = 0
        local queued = Core.RedGuardianMark.QueueCraftOne(RedUI.player, "RED_ROUND_DOUBLE_CLICK")
        if queued then RedUI.MarkDirty() end
        return true
    end
    RedUI.firstClickMs = now
    RedUI.firstClickX = mx
    RedUI.firstClickY = my
    return released
end

function Panel:onMouseMoveOutside(dx, dy)
    Tooltip.Hide("RED_MOUSE_OUT")
    if Drag.IsDragging(self) then RedUI.dragMoved = true; RedUI.firstClickMs = 0 end
    return Drag.Move(self)
end

function Panel:onMouseUpOutside(x, y)
    RedUI.firstClickMs = 0
    return Drag.Release(self)
end

function Panel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        return Drag.Cancel(self, "ESCAPE")
    end
    return false
end

function Panel:onRightMouseDown(x, y)
    Tooltip.Hide("RED_RIGHT_DOWN")
    RedUI.firstClickMs = 0
    RedUI.rightDown = Frame.PointInside(x, y) and RedUI.desiredVisible
        and not RedUI.mapHidden and not Drag.IsDragging(self)
    return RedUI.rightDown
end

local function applyVisibility()
    if not RedUI.panel then return end
    local visible = RedUI.desiredVisible and not RedUI.mapHidden
    if not visible and Tooltip.IsOwner(RedUI.panel) then Tooltip.Hide("RED_NOT_VISIBLE") end
    RedUI.panel:setVisible(visible)
    if type(RedUI.panel.setConsumeMouseEvents) == "function" then RedUI.panel:setConsumeMouseEvents(visible) end
end

local function tooltipText()
    if not RedUI.hasTrait then return getText("UI_XNPMarker_RedLocked") end
    return getText("UI_XNPMarker_RedHelp")
        .. "<LINE>" .. craftRawStatText()
        .. "<LINE>" .. getText("UI_XNPMarker_RedMode") .. ": " .. tostring(RedUI.mode)
        .. "<LINE>" .. getText("UI_XNPMarker_RedCount") .. ": " .. tostring(RedUI.count)
end

function Panel:onRightMouseUp(x, y)
    local armed = RedUI.rightDown
    RedUI.rightDown = false
    local dead = RedUI.player and type(RedUI.player.isDead) == "function" and RedUI.player:isDead() == true
    if armed and RedUI.desiredVisible and not RedUI.mapHidden and not Drag.IsDragging(self)
        and not dead and RedUI.hasTrait and Frame.PointInside(x, y) and Core.RedGuardianMark then
        return Core.ToggleTransactions.RequestRed(
            RedUI.player, "RED_ROUND_RIGHT_CLICK") == true
    end
    return armed
end

function RedUI.CommitMode(player, mode)
    RedUI.MarkDirty()
    local updated = RedUI.Update(player, true)
    local expectedColor = mode == Core.RedGuardianMark.MODE_TREATMENT and "WHITE" or "GREEN"
    return updated == true and RedUI.mode == mode and RedUI.color == expectedColor, RedUI.color
end

function Panel:render()
    Frame.Draw(self, RedUI.texture, RedUI.color)
    local alpha = RedUI.hasTrait and 1.0 or 0.20
    self:drawTextCentre(tostring(RedUI.count), Frame.PANEL_SIZE - 9, Frame.PANEL_SIZE - 17, 1.0, 1.0, 1.0, alpha, UIFont.Small)
end

local function ensurePanel()
    if not RedUI.textureAttempted and type(getTexture) == "function" then
        RedUI.textureAttempted = true
        RedUI.texture = getTexture(ICON_PATH)
        print("[XNP RED ROUND] center_locked=true path=" .. ICON_PATH .. " loaded=" .. tostring(RedUI.texture ~= nil))
    end
    Frame.LoadShellTextures()
    if RedUI.panel then return RedUI.panel end
    local panel = Panel:new(0, 0)
    panel:initialise()
    panel:instantiate()
    panel:addToUIManager()
    panel:setVisible(false)
    if type(panel.setAlwaysOnTop) == "function" then panel:setAlwaysOnTop(true) end
    if type(panel.setConsumeMouseEvents) == "function" then panel:setConsumeMouseEvents(true) end
    RedUI.panel = panel
    print("[XNP ROUND UI] panel=RED created=true texture=" .. tostring(RedUI.texture ~= nil))
    return panel
end

function RedUI.MarkDirty()
    RedUI.dirty = true
    RedUI.nextInventoryRefreshMs = 0
end

function RedUI.SetCrafting(crafting)
    RedUI.crafting = crafting == true
    RedUI.MarkDirty()
end

function RedUI.Update(player, force)
    if Core.SandboxTuning and (not Core.SandboxTuning.GetBoolean("MarkersEnabled", true)
        or not Core.SandboxTuning.GetBoolean("RedMarkerEnabled", true)) then
        RedUI.desiredVisible = false
        applyVisibility()
        return false
    end
    if not player then
        RedUI.desiredVisible = false
        applyVisibility()
        return false
    end
    local panel = ensurePanel()
    loadPosition(player, panel)
    local refreshed = refreshCount(player, force == true)
    RedUI.desiredVisible = true
    applyVisibility()
    if refreshed then Tooltip.Refresh(panel, getText("UI_XNPMarker_RedName"), tooltipText()) end
    return true
end

function RedUI.SetMapHidden(hidden)
    RedUI.mapHidden = hidden == true
    if RedUI.mapHidden then
        if RedUI.panel then Drag.Cancel(RedUI.panel, "RED_MAP") end
        RedUI.firstClickMs = 0
        Tooltip.Hide("RED_MAP")
    end
    applyVisibility()
end

function RedUI.Cleanup(reason)
    if RedUI.panel then Drag.Cancel(RedUI.panel, reason or "RED_CLEANUP") end
    if RedUI.panel then RedUI.panel:setVisible(false) end
    if RedUI.panel and Tooltip.IsOwner(RedUI.panel) then Tooltip.Hide("RED_CLEANUP") end
    RedUI.player = nil
    RedUI.loadedPosition = false
    RedUI.dragging = false
    RedUI.rightDown = false
    RedUI.count = 0
    RedUI.color = "GREEN"
    RedUI.mode = "GREEN_STAMINA"
    RedUI.hasTrait = false
    RedUI.crafting = false
    RedUI.dirty = true
    RedUI.nextInventoryRefreshMs = 0
    RedUI.desiredVisible = false
    RedUI.firstClickMs = 0
end

Core.RedMagicUI = RedUI
return RedUI
