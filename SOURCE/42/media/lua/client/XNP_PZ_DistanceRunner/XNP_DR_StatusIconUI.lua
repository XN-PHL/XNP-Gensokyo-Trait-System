require "ISUI/ISPanel"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_YellowToggle"
require "XNP_PZ_DistanceRunner/XNP_DR_YellowRoundState"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_ToggleTransactions"

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame
local Drag = Core.RoundMarkerDragController
local Tooltip = Core.RoundMarkerTooltip

local StatusIconUI = {
    panel = nil,
    texture = nil,
    textureAttempted = false,
    player = nil,
    loadedPosition = false,
    dragging = false,
    rightDown = false,
    color = "GREEN",
    reason = "INITIAL",
    lastLogKey = nil,
    nextUpdateMs = 0,
    desiredVisible = false,
    mapHidden = false,
}

local POSITION_KEY = "XNP_UI_YELLOW_ROUND_POS_0557"
local LEGACY_KEYS = { "XNP_UI_YELLOW_POS" }
local ICON_PATH = "media/ui/XNPMarkers/xnp_marker_yellow.png"
local Panel = ISPanel:derive("XNPDistanceRunnerYellowRoundPanel0557")
local SHAKE_PROFILES = {
    BLUE = { ampX = 1.0, ampY = 0.6, speed = 0.12 },
    YELLOW = { ampX = 1.8, ampY = 1.2, speed = 0.18 },
    RED = { ampX = 2.8, ampY = 2.0, speed = 0.26 },
}

local function inputLog(snapshot, route, result)
    snapshot = snapshot or {}
    print("[XNP YELLOW POINTER INPUT]"
        .. " down_screen=" .. tostring(snapshot.down_screen_x) .. "," .. tostring(snapshot.down_screen_y)
        .. " up_screen=" .. tostring(snapshot.up_screen_x) .. "," .. tostring(snapshot.up_screen_y)
        .. " down_local=" .. tostring(snapshot.down_local_x) .. "," .. tostring(snapshot.down_local_y)
        .. " up_local=" .. tostring(snapshot.up_local_x) .. "," .. tostring(snapshot.up_local_y)
        .. " move_count=" .. tostring(snapshot.move_count or 0)
        .. " distance_same_space=" .. tostring(snapshot.distance_same_space or 0)
        .. " route=" .. tostring(route)
        .. " result=" .. tostring(result))
end

local function loadPosition(player, panel)
    if StatusIconUI.loadedPosition and StatusIconUI.player == player then return end
    StatusIconUI.player = player
    StatusIconUI.loadedPosition = true
    local x, y, source = Frame.LoadPosition(player, POSITION_KEY, LEGACY_KEYS, 3)
    Frame.ClampPanel(panel, x, y)
    print("[XNP YELLOW ROUND] position_source=" .. tostring(source))
end

function Panel:new(x, y)
    local panel = ISPanel:new(x, y, Frame.PANEL_SIZE, Frame.PANEL_SIZE)
    setmetatable(panel, self)
    self.__index = self
    Frame.PreparePanel(panel)
    return panel
end

function Panel:onMouseDown(x, y)
    Tooltip.Hide("YELLOW_MOUSE_DOWN")
    return Drag.Start(self, x, y, StatusIconUI.player, POSITION_KEY, StatusIconUI)
end

function Panel:onMouseMove(dx, dy)
    if Drag.IsDragging(self) then return Drag.Move(self) end
    return Tooltip.Show(self, getText("UI_XNPMarker_YellowName"), getText("UI_XNPMarker_YellowHelp") .. "<LINE>" .. getText("UI_XNPMarker_State") .. ": " .. tostring(StatusIconUI.color) .. " / " .. tostring(StatusIconUI.reason))
end

function Panel:onMouseUp(x, y)
    local released, snapshot, moved = Drag.Finish(self, x, y)
    inputLog(snapshot, "LEFT_RELEASE", moved and "DRAG" or "CLICK")
    return released
end

function Panel:onMouseMoveOutside(dx, dy)
    Tooltip.Hide("YELLOW_MOUSE_OUT")
    return Drag.Move(self)
end

function Panel:onMouseUpOutside(x, y)
    local released, snapshot, moved = Drag.Finish(self, x, y)
    inputLog(snapshot, "LEFT_RELEASE_OUTSIDE", moved and "DRAG" or "RELEASE_OUTSIDE_NO_DRAG")
    return released
end

function Panel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        return Drag.Cancel(self, "ESCAPE")
    end
    return false
end

function Panel:onRightMouseDown(x, y)
    Tooltip.Hide("YELLOW_RIGHT_DOWN")
    StatusIconUI.rightDown = Frame.PointInside(x, y)
    return StatusIconUI.rightDown
end

local function applyVisibility()
    if not StatusIconUI.panel then return end
    local visible = StatusIconUI.desiredVisible and not StatusIconUI.mapHidden
    if not visible and Tooltip.IsOwner(StatusIconUI.panel) then Tooltip.Hide("YELLOW_NOT_VISIBLE") end
    StatusIconUI.panel:setVisible(visible)
    if type(StatusIconUI.panel.setConsumeMouseEvents) == "function" then StatusIconUI.panel:setConsumeMouseEvents(visible) end
end

function Panel:onRightMouseUp(x, y)
    local armed = StatusIconUI.rightDown
    StatusIconUI.rightDown = false
    if armed and Frame.PointInside(x, y) and Core.ToggleTransactions then
        local committed = Core.ToggleTransactions.RequestYellow(
            StatusIconUI.player, "YELLOW_ROUND_RIGHT_CLICK") == true
        return committed
    end
    return armed
end

function StatusIconUI.CommitManualState(player, enabled)
    StatusIconUI.nextUpdateMs = 0
    local updated = StatusIconUI.Update(player, true)
    local expected = (enabled == true and StatusIconUI.reason ~= "MANUAL_OFF")
        or (enabled ~= true and StatusIconUI.color == "WHITE"
            and StatusIconUI.reason == "MANUAL_OFF")
    return updated == true and expected == true, StatusIconUI.color
end

function Panel:render()
    local tuning = Core.SandboxTuning
    local shakeEnabled = not tuning or not tuning.GetBoolean
        or (tuning.GetBoolean("EnableStatusShake", true)
            and tuning.GetBoolean("YellowMarkerShakeEnabled", true)
            and not tuning.GetBoolean("LowPerformanceUIMode", false))
    local intensity = tuning and tuning.GetNumber
        and tuning.GetNumber("YellowMarkerShakeIntensity", 1.0, 0.0, 3.0) or 1.0
    local shake = shakeEnabled and not Drag.IsDragging(self) and SHAKE_PROFILES[StatusIconUI.color] or nil
    local offsetX, offsetY = 0, 0
    if shake then
        local t = Frame.NowMs() / 1000
        offsetX = math.floor(math.sin(t * shake.speed * 60.0) * shake.ampX * intensity)
        offsetY = math.floor(math.cos(t * shake.speed * 52.0) * shake.ampY * intensity)
    end
    Frame.DrawAtOffset(self, StatusIconUI.texture, StatusIconUI.color, offsetX, offsetY)
end

local function ensurePanel()
    if not StatusIconUI.textureAttempted and type(getTexture) == "function" then
        StatusIconUI.textureAttempted = true
        StatusIconUI.texture = getTexture(ICON_PATH)
        print("[XNP YELLOW ROUND] center_locked=true path=" .. ICON_PATH .. " loaded=" .. tostring(StatusIconUI.texture ~= nil))
    end
    Frame.LoadShellTextures()
    if StatusIconUI.panel then return StatusIconUI.panel end
    local panel = Panel:new(0, 0)
    panel:initialise()
    panel:instantiate()
    panel:addToUIManager()
    panel:setVisible(false)
    if type(panel.setAlwaysOnTop) == "function" then panel:setAlwaysOnTop(true) end
    if type(panel.setConsumeMouseEvents) == "function" then panel:setConsumeMouseEvents(true) end
    StatusIconUI.panel = panel
    print("[XNP ROUND UI] panel=YELLOW created=true texture=" .. tostring(StatusIconUI.texture ~= nil))
    return panel
end

function StatusIconUI.Update(player, force)
    if Core.SandboxTuning and (not Core.SandboxTuning.GetBoolean("MarkersEnabled", true)
        or not Core.SandboxTuning.GetBoolean("YellowMarkerEnabled", true)) then
        StatusIconUI.desiredVisible = false
        applyVisibility()
        return false
    end
    if not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        StatusIconUI.desiredVisible = false
        applyVisibility()
        return false
    end
    local panel = ensurePanel()
    loadPosition(player, panel)
    local now = Frame.NowMs()
    if force == true or now >= StatusIconUI.nextUpdateMs then
        StatusIconUI.nextUpdateMs = now + Frame.UPDATE_INTERVAL_MS
        StatusIconUI.color, StatusIconUI.reason = Core.YellowRoundState.Resolve(player)
        local key = StatusIconUI.color .. "|" .. StatusIconUI.reason
        if key ~= StatusIconUI.lastLogKey then
            StatusIconUI.lastLogKey = key
            print("[XNP YELLOW ROUND] color=" .. StatusIconUI.color .. " reason=" .. StatusIconUI.reason)
        end
    end
    StatusIconUI.desiredVisible = true
    applyVisibility()
    Tooltip.Refresh(panel, getText("UI_XNPMarker_YellowName"), getText("UI_XNPMarker_YellowHelp") .. "<LINE>" .. getText("UI_XNPMarker_State") .. ": " .. tostring(StatusIconUI.color) .. " / " .. tostring(StatusIconUI.reason))
    return true
end

function StatusIconUI.SetMapHidden(hidden)
    StatusIconUI.mapHidden = hidden == true
    if StatusIconUI.mapHidden then
        if StatusIconUI.panel then Drag.Cancel(StatusIconUI.panel, "YELLOW_MAP") end
        Tooltip.Hide("YELLOW_MAP")
    end
    applyVisibility()
end

function StatusIconUI.NotifySkillTriggered(reason)
    StatusIconUI.nextUpdateMs = 0
    return true
end

function StatusIconUI.Cleanup(reason)
    if StatusIconUI.panel then Drag.Cancel(StatusIconUI.panel, reason or "YELLOW_CLEANUP") end
    if StatusIconUI.panel then StatusIconUI.panel:setVisible(false) end
    if StatusIconUI.panel and Tooltip.IsOwner(StatusIconUI.panel) then Tooltip.Hide("YELLOW_CLEANUP") end
    StatusIconUI.player = nil
    StatusIconUI.loadedPosition = false
    StatusIconUI.dragging = false
    StatusIconUI.rightDown = false
    StatusIconUI.nextUpdateMs = 0
    StatusIconUI.desiredVisible = false
end

Core.StatusIconUI = StatusIconUI
return StatusIconUI
