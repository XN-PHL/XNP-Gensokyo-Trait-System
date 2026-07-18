require "ISUI/ISPanel"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWhiteAction"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame
local Drag = Core.RoundMarkerDragController
local Tooltip = Core.RoundMarkerTooltip

local GreenUI = {
    panel = nil,
    texture = nil,
    textureAttempted = false,
    player = nil,
    loadedPosition = false,
    dragging = false,
    color = "GREEN",
    lastColor = nil,
    nextUpdateMs = 0,
    desiredVisible = false,
    mapHidden = false,
    hasTrait = false,
    locked = true,
    pressX = 0,
    pressY = 0,
    dragMoved = false,
    rightDown = false,
    feedbackUntilMs = 0,
    firstClickMs = 0,
    firstClickX = 0,
    firstClickY = 0,
}

local POSITION_KEY = "XNP_UI_GREEN_ROUND_POS_0557"
local LEGACY_KEYS = { "XNP_UI_GREEN_ULTIMATE_POS", "XNP_UI_GREEN_SKILL_POS" }
local ICON_PATH = "media/ui/XNPMarkers/xnp_marker_green.png"
local DOUBLE_CLICK_MS = 350
local DRAG_THRESHOLD_PX = 5
local Panel = ISPanel:derive("XNPGreenUltimateRoundPanel0557")

local function distanceSquared(x1, y1, x2, y2)
    local dx, dy = x1 - x2, y1 - y2
    return dx * dx + dy * dy
end

local function loadPosition(player, panel)
    if GreenUI.loadedPosition and GreenUI.player == player then return end
    GreenUI.player = player
    GreenUI.loadedPosition = true
    local x, y, source = Frame.LoadPosition(player, POSITION_KEY, LEGACY_KEYS, 1)
    Frame.ClampPanel(panel, x, y)
    print("[XNP GREEN ROUND] position_source=" .. tostring(source))
end

function Panel:new(x, y)
    local panel = ISPanel:new(x, y, Frame.PANEL_SIZE, Frame.PANEL_SIZE)
    setmetatable(panel, self)
    self.__index = self
    Frame.PreparePanel(panel)
    return panel
end

function Panel:onMouseDown(x, y)
    Tooltip.Hide("GREEN_MOUSE_DOWN")
    GreenUI.pressX = getMouseX()
    GreenUI.pressY = getMouseY()
    GreenUI.dragMoved = false
    return Drag.Start(self, x, y, GreenUI.player, POSITION_KEY, GreenUI)
end

function Panel:onMouseMove(dx, dy)
    if Drag.IsDragging(self) then
        local mx, my = getMouseX(), getMouseY()
        if distanceSquared(mx, my, GreenUI.pressX, GreenUI.pressY) > DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX then
            GreenUI.dragMoved = true
            GreenUI.firstClickMs = 0
        end
        return Drag.Move(self)
    end
    return Tooltip.Show(self, getText("UI_XNPMarker_GreenName"), getText("UI_XNPMarker_GreenHelp"))
end

function Panel:onMouseUp(x, y)
    local moved = GreenUI.dragMoved
    local mx, my = getMouseX(), getMouseY()
    local released = Drag.Release(self)
    if moved or GreenUI.mapHidden or not GreenUI.desiredVisible then return released end
    local now = Frame.NowMs()
    local close = distanceSquared(mx, my, GreenUI.firstClickX, GreenUI.firstClickY) <= DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX
    local activeDoubleClick = not Core.SandboxTuning
        or Core.SandboxTuning.GetBoolean("GreenActiveDoubleClickEnabled", true) == true
    if activeDoubleClick and GreenUI.firstClickMs > 0 and now - GreenUI.firstClickMs <= DOUBLE_CLICK_MS and close then
        GreenUI.firstClickMs = 0
        if Core.GreenSkill.IsEnabled(GreenUI.player) then
            Core.GreenWorldOrb.RequestActivate(GreenUI.player, "GREEN_LEFT_DOUBLE_CLICK")
        else
            Core.GreenWhiteAction.Request(GreenUI.player, "WHITE_LEFT_DOUBLE_CLICK")
        end
        GreenUI.nextUpdateMs = 0
        return true
    end
    GreenUI.firstClickMs = now
    GreenUI.firstClickX = mx
    GreenUI.firstClickY = my
    return released
end

function Panel:onMouseMoveOutside(dx, dy)
    Tooltip.Hide("GREEN_MOUSE_OUT")
    if Drag.IsDragging(self) then GreenUI.dragMoved = true; GreenUI.firstClickMs = 0 end
    return Drag.Move(self)
end

function Panel:onMouseUpOutside(x, y)
    GreenUI.firstClickMs = 0
    return Drag.Release(self)
end

function Panel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        return Drag.Cancel(self, "ESCAPE")
    end
    return false
end

function Panel:onRightMouseDown(x, y)
    Tooltip.Hide("GREEN_RIGHT_DOWN")
    GreenUI.firstClickMs = 0
    GreenUI.rightDown = Frame.PointInside(x, y) and GreenUI.desiredVisible
        and not GreenUI.mapHidden and not Drag.IsDragging(self)
    return GreenUI.rightDown
end

local function applyVisibility()
    if not GreenUI.panel then return end
    local visible = GreenUI.desiredVisible and not GreenUI.mapHidden
    if not visible and Tooltip.IsOwner(GreenUI.panel) then Tooltip.Hide("GREEN_NOT_VISIBLE") end
    GreenUI.panel:setVisible(visible)
    if type(GreenUI.panel.setConsumeMouseEvents) == "function" then GreenUI.panel:setConsumeMouseEvents(visible) end
end

function Panel:onRightMouseUp(x, y)
    local armed = GreenUI.rightDown
    GreenUI.rightDown = false
    local dead = GreenUI.player and type(GreenUI.player.isDead) == "function" and GreenUI.player:isDead() == true
    if armed and GreenUI.hasTrait and GreenUI.desiredVisible and not GreenUI.mapHidden and not Drag.IsDragging(self)
        and not dead and Frame.PointInside(x, y) then
        local changed, enabled = Core.GreenSkill.ToggleEnabled(GreenUI.player, "GREEN_ROUND_RIGHT_CLICK")
        if changed then
            Core.Audio.PlayOnce(GreenUI.player, "MARKER_TOGGLE", "green-melee-toggle:" .. tostring(Frame.NowMs()))
            GreenUI.nextUpdateMs = 0
        end
        return changed == true, enabled
    end
    return armed
end

function Panel:render()
    Frame.Draw(self, GreenUI.texture, GreenUI.color)
end

local function ensurePanel()
    if not GreenUI.textureAttempted and type(getTexture) == "function" then
        GreenUI.textureAttempted = true
        GreenUI.texture = getTexture(ICON_PATH)
        print("[XNP GREEN ROUND] center_locked=true path=" .. ICON_PATH .. " loaded=" .. tostring(GreenUI.texture ~= nil))
    end
    Frame.LoadShellTextures()
    if GreenUI.panel then return GreenUI.panel end
    local panel = Panel:new(0, 0)
    panel:initialise()
    panel:instantiate()
    panel:addToUIManager()
    panel:setVisible(false)
    if type(panel.setAlwaysOnTop) == "function" then panel:setAlwaysOnTop(true) end
    if type(panel.setConsumeMouseEvents) == "function" then panel:setConsumeMouseEvents(true) end
    GreenUI.panel = panel
    print("[XNP ROUND UI] panel=GREEN created=true texture=" .. tostring(GreenUI.texture ~= nil))
    return panel
end

function GreenUI.Update(player, force)
    if Core.SandboxTuning and (not Core.SandboxTuning.GetBoolean("MarkersEnabled", true)
        or not Core.SandboxTuning.GetBoolean("GreenMarkerEnabled", true)) then
        GreenUI.desiredVisible = false
        applyVisibility()
        return false
    end
    local panel = ensurePanel()
    loadPosition(player, panel)
    GreenUI.hasTrait = Core.ExtraTraits and Core.ExtraTraits.PlayerHas(player, "GREEN") == true
    GreenUI.locked = not GreenUI.hasTrait
    local feedbackActive = Frame.NowMs() < GreenUI.feedbackUntilMs
    local panelAlpha = GreenUI.locked and 0.28 or (feedbackActive and 0.58 or 1.0)
    if type(panel.setAlpha) == "function" then
        panel:setAlpha(panelAlpha)
    else
        panel.alpha = panelAlpha
    end
    local now = Frame.NowMs()
    if force == true or now >= GreenUI.nextUpdateMs then
        GreenUI.nextUpdateMs = now + Frame.UPDATE_INTERVAL_MS
        GreenUI.color = GreenUI.hasTrait and Core.GreenSkill.GetVisualState(player) or "WHITE"
        if GreenUI.color ~= GreenUI.lastColor then
            GreenUI.lastColor = GreenUI.color
            print("[XNP GREEN ROUND] color=" .. GreenUI.color
                .. " melee_tier_dynamic=true active_cooldown_changes_color=false locked=" .. tostring(GreenUI.locked))
        end
    end
    GreenUI.desiredVisible = true
    applyVisibility()
    Tooltip.Refresh(panel, getText("UI_XNPMarker_GreenName"), getText("UI_XNPMarker_GreenHelp"))
    return GreenUI.hasTrait
end

function GreenUI.NotifyVirtualCast(kind)
    GreenUI.feedbackUntilMs = Frame.NowMs() + 280
    GreenUI.nextUpdateMs = 0
    print("[XNP GREEN ROUND] safe_flash=true feedback=" .. tostring(kind or "CAST")
        .. " world_render_callback=false")
end

function GreenUI.SetMapHidden(hidden)
    GreenUI.mapHidden = hidden == true
    if GreenUI.mapHidden then
        if GreenUI.panel then Drag.Cancel(GreenUI.panel, "GREEN_MAP") end
        GreenUI.firstClickMs = 0
        Tooltip.Hide("GREEN_MAP")
    end
    applyVisibility()
    if Core.GreenWorldOrb then Core.GreenWorldOrb.SetMapHidden(GreenUI.mapHidden) end
end

function GreenUI.Cleanup(reason)
    if GreenUI.panel then Drag.Cancel(GreenUI.panel, reason or "GREEN_CLEANUP") end
    if GreenUI.panel then GreenUI.panel:setVisible(false) end
    if GreenUI.panel and Tooltip.IsOwner(GreenUI.panel) then Tooltip.Hide("GREEN_CLEANUP") end
    GreenUI.player = nil
    GreenUI.loadedPosition = false
    GreenUI.dragging = false
    GreenUI.nextUpdateMs = 0
    GreenUI.desiredVisible = false
    GreenUI.firstClickMs = 0
    GreenUI.rightDown = false
    GreenUI.hasTrait = false
    GreenUI.locked = true
    GreenUI.feedbackUntilMs = 0
end

Core.GreenSkillUI = GreenUI
return GreenUI
