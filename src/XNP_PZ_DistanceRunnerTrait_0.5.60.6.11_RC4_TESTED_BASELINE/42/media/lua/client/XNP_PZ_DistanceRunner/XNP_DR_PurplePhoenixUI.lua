require "ISUI/ISPanel"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixRevive"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame
local Drag = Core.RoundMarkerDragController
local Tooltip = Core.RoundMarkerTooltip

local PhoenixUI = {
    panel = nil,
    texture = nil,
    textureAttempted = false,
    player = nil,
    loadedPosition = false,
    dragging = false,
    rightDown = false,
    state = "OFF",
    color = "WHITE",
    visible = true,
    lastLogKey = nil,
    nextUpdateMs = 0,
    desiredVisible = false,
    mapHidden = false,
    remainingSeconds = 0,
}

local POSITION_KEY = "XNP_UI_PHOENIX_ROUND_POS_0557"
local LEGACY_KEYS = { "XNP_UI_PHOENIX_POS" }
local ICON_PATH = "media/ui/XNPMarkers/xnp_marker_purple.png"
local Panel = ISPanel:derive("XNPPurplePhoenixRoundPanel0557")

local function loadPosition(player, panel)
    if PhoenixUI.loadedPosition and PhoenixUI.player == player then return end
    PhoenixUI.player = player
    PhoenixUI.loadedPosition = true
    local x, y, source = Frame.LoadPosition(player, POSITION_KEY, LEGACY_KEYS, 2)
    Frame.ClampPanel(panel, x, y)
    print("[XNP PHOENIX ROUND] position_source=" .. tostring(source))
end

function Panel:new(x, y)
    local panel = ISPanel:new(x, y, Frame.PANEL_SIZE, Frame.PANEL_SIZE)
    setmetatable(panel, self)
    self.__index = self
    Frame.PreparePanel(panel)
    return panel
end


function Panel:onMouseDown(x, y)
    Tooltip.Hide("PHOENIX_MOUSE_DOWN")
    return Drag.Start(self, x, y, PhoenixUI.player, POSITION_KEY, PhoenixUI)
end

function Panel:onMouseMove(dx, dy)
    if Drag.IsDragging(self) then return Drag.Move(self) end
    local text = getText("UI_XNPMarker_PhoenixHelp") .. "<LINE>" .. getText("UI_XNPMarker_State") .. ": " .. tostring(PhoenixUI.state)
    if PhoenixUI.state == "WHITE" then text = text .. "<LINE>" .. string.format(getText("UI_XNPMarker_PhoenixCooldown"), PhoenixUI.remainingSeconds) end
    return Tooltip.Show(self, getText("UI_XNPMarker_PhoenixName"), text)
end

function Panel:onMouseUp(x, y)
    return Drag.Release(self)
end

function Panel:onMouseMoveOutside(dx, dy)
    Tooltip.Hide("PHOENIX_MOUSE_OUT")
    return Drag.Move(self)
end

function Panel:onMouseUpOutside(x, y)
    return Drag.Release(self)
end

function Panel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        return Drag.Cancel(self, "ESCAPE")
    end
    return false
end

function Panel:onRightMouseDown(x, y)
    Tooltip.Hide("PHOENIX_RIGHT_DOWN")
    PhoenixUI.rightDown = Frame.PointInside(x, y)
    return PhoenixUI.rightDown
end

local function tooltipText()
    local text = getText("UI_XNPMarker_PhoenixHelp") .. "<LINE>" .. getText("UI_XNPMarker_State") .. ": " .. tostring(PhoenixUI.state)
    if PhoenixUI.state == "WHITE" then text = text .. "<LINE>" .. string.format(getText("UI_XNPMarker_PhoenixCooldown"), PhoenixUI.remainingSeconds) end
    return text
end

local function applyVisibility()
    if not PhoenixUI.panel then return end
    local visible = PhoenixUI.desiredVisible and not PhoenixUI.mapHidden
    if not visible and Tooltip.IsOwner(PhoenixUI.panel) then Tooltip.Hide("PHOENIX_NOT_VISIBLE") end
    PhoenixUI.panel:setVisible(visible)
    if type(PhoenixUI.panel.setConsumeMouseEvents) == "function" then PhoenixUI.panel:setConsumeMouseEvents(visible) end
end

function Panel:onRightMouseUp(x, y)
    local armed = PhoenixUI.rightDown
    PhoenixUI.rightDown = false
    if armed and Frame.PointInside(x, y) and Core.PurplePhoenixState and Core.PurplePhoenixState.Toggle then
        Core.PurplePhoenixState.Toggle(PhoenixUI.player)
        PhoenixUI.nextUpdateMs = 0
        return true
    end
    return armed
end

function Panel:render()
    Frame.Draw(self, PhoenixUI.texture, PhoenixUI.color)
end

local function ensurePanel()
    if not PhoenixUI.textureAttempted and type(getTexture) == "function" then
        PhoenixUI.textureAttempted = true
        PhoenixUI.texture = getTexture(ICON_PATH)
        print("[XNP PHOENIX ROUND] center_locked=true path=" .. ICON_PATH .. " loaded=" .. tostring(PhoenixUI.texture ~= nil))
    end
    Frame.LoadShellTextures()
    if PhoenixUI.panel then return PhoenixUI.panel end
    local panel = Panel:new(0, 0)
    panel:initialise()
    panel:instantiate()
    panel:addToUIManager()
    panel:setVisible(false)
    if type(panel.setAlwaysOnTop) == "function" then panel:setAlwaysOnTop(true) end
    if type(panel.setConsumeMouseEvents) == "function" then panel:setConsumeMouseEvents(true) end
    PhoenixUI.panel = panel
    print("[XNP ROUND UI] panel=PURPLE created=true texture=" .. tostring(PhoenixUI.texture ~= nil))
    return panel
end

function PhoenixUI.Update(player, force)
    if not Core.PurplePhoenixTrait or not Core.PurplePhoenixTrait.PlayerHasTrait(player) then
        PhoenixUI.desiredVisible = false
        applyVisibility()
        return false
    end
    local panel = ensurePanel()
    loadPosition(player, panel)
    local now = Frame.NowMs()
    if force == true or now >= PhoenixUI.nextUpdateMs then
        PhoenixUI.nextUpdateMs = now + Frame.UPDATE_INTERVAL_MS
        PhoenixUI.state, PhoenixUI.remainingSeconds = Core.PurplePhoenixState.GetVisualState(player)
        PhoenixUI.color = PhoenixUI.state
        PhoenixUI.visible = true
        local key = PhoenixUI.state
        if key ~= PhoenixUI.lastLogKey then
            PhoenixUI.lastLogKey = key
            print("[XNP PHOENIX ROUND] state=" .. PhoenixUI.state .. " visible=" .. tostring(PhoenixUI.visible))
        end
    end
    PhoenixUI.desiredVisible = true
    applyVisibility()
    Tooltip.Refresh(panel, getText("UI_XNPMarker_PhoenixName"), tooltipText())
    return true
end

function PhoenixUI.SetMapHidden(hidden)
    PhoenixUI.mapHidden = hidden == true
    if PhoenixUI.mapHidden then
        if PhoenixUI.panel then Drag.Cancel(PhoenixUI.panel, "PHOENIX_MAP") end
        Tooltip.Hide("PHOENIX_MAP")
    end
    applyVisibility()
end

function PhoenixUI.Cleanup(reason)
    if PhoenixUI.panel then Drag.Cancel(PhoenixUI.panel, reason or "PURPLE_CLEANUP") end
    if PhoenixUI.panel then PhoenixUI.panel:setVisible(false) end
    if PhoenixUI.panel and Tooltip.IsOwner(PhoenixUI.panel) then Tooltip.Hide("PHOENIX_CLEANUP") end
    PhoenixUI.player = nil
    PhoenixUI.loadedPosition = false
    PhoenixUI.dragging = false
    PhoenixUI.rightDown = false
    PhoenixUI.nextUpdateMs = 0
    PhoenixUI.desiredVisible = false
end

Core.PurplePhoenixUI = PhoenixUI
return PhoenixUI
