require "ISUI/ISPanel"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixInvulnerability"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Controller"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"

local Core = XNP_PZ_DistanceRunner
local Frame = Core.RoundMarkerFrame
local Drag = Core.RoundMarkerDragController
local Tooltip = Core.RoundMarkerTooltip

local PurpleUI = {
    panel = nil,
    texture = nil,
    textureAttempted = false,
    player = nil,
    loadedPosition = false,
    mapHidden = false,
    desiredVisible = false,
    state = "BLUE",
    cooldownRemaining = 0,
    nextUpdateMs = 0,
    status = nil,
    pressX = 0,
    pressY = 0,
    dragMoved = false,
    firstClickMs = 0,
    firstClickX = 0,
    firstClickY = 0,
    rightDown = false,
    dragMoveCount = 0,
    dragStartedPaused = false,
    inputSequence = 0,
    rawInputCount = 0,
    routeCounts = { TOGGLE = 0, CRAFT = 0, DRAG = 0, NONE = 0 },
    staleHitboxCount = 0,
    lastRenderPanel = nil,
    lastInputPanel = nil,
    lastRawEvent = nil,
}

local POSITION_KEY = "XNP_UI_PHOENIX_ROUND_POS_0557"
local LEGACY_KEYS = { "XNP_UI_PHOENIX_POS" }
local ICON_PATH = "media/ui/XNPMarkers/xnp_marker_purple.png"
local DOUBLE_CLICK_MS = 350
local DRAG_THRESHOLD_PX = 6
local Panel = ISPanel:derive("XNPPurpleLifeStockRoundPanel0560722")

local function distanceSquared(x1, y1, x2, y2)
    local dx, dy = (x1 or 0) - (x2 or 0), (y1 or 0) - (y2 or 0)
    return dx * dx + dy * dy
end

local function playerIndex(player)
    if player and type(player.getPlayerNum) == "function" then
        local ok, value = pcall(function() return player:getPlayerNum() end)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function chatFocused()
    if not ISChat or not ISChat.instance then return false end
    local entry = ISChat.instance.textEntry
    if not entry then return false end
    for _, method in ipairs({ "isFocused", "isVisible" }) do
        if type(entry[method]) == "function" then
            local ok, value = pcall(function() return entry[method](entry) end)
            if ok and value == true then return true end
        end
    end
    return entry.focused == true
end

local function topModalOpen()
    if not UIManager or type(UIManager.getModal) ~= "function" then return false end
    local ok, modal = pcall(UIManager.getModal)
    return ok and modal ~= nil
end

local function gamePaused()
    if type(isGamePaused) ~= "function" then return false end
    local ok, paused = pcall(isGamePaused)
    return ok and paused == true
end

local function actionInputAllowed()
    if not PurpleUI.player then return false, "PLAYER_MISSING" end
    if not PurpleUI.desiredVisible then return false, "ICON_NOT_VISIBLE" end
    if PurpleUI.mapHidden then return false, "MAP_OR_OVERLAY_HIDDEN" end
    if gamePaused() then return false, "GAME_PAUSED" end
    if Core.MapVisibility
        and type(Core.MapVisibility.IsWorldGameplayVisible) == "function"
        and Core.MapVisibility.IsWorldGameplayVisible(
            playerIndex(PurpleUI.player)) ~= true then
        return false, "TOP_LEVEL_UI_BLOCKED"
    end
    if chatFocused() then return false, "CHAT_INPUT_FOCUSED" end
    if topModalOpen() then return false, "TOP_MODAL_OPEN" end
    return true, "INPUT_ALLOWED"
end

local function dragInputAllowed()
    if not PurpleUI.player then return false, "PLAYER_MISSING" end
    if not PurpleUI.desiredVisible then return false, "ICON_NOT_VISIBLE" end
    if PurpleUI.mapHidden then return false, "MAP_OR_OVERLAY_HIDDEN" end
    return true, gamePaused() and "DRAG_ALLOWED_WHILE_PAUSED"
        or "DRAG_ALLOWED"
end

local function dragAudit(finished, persisted, reason)
    print("[XNP PURPLE DRAG] paused="
        .. tostring(PurpleUI.dragStartedPaused == true)
        .. " start=true"
        .. " move_count=" .. tostring(PurpleUI.dragMoveCount)
        .. " finish=" .. tostring(finished == true)
        .. " position_persisted=" .. tostring(persisted == true)
        .. " craft_triggered=false toggle_triggered=false"
        .. " reason=" .. tostring(reason or "POSITION_ONLY"))
end

local function inputLog(button, clickCount, dragDistance, route, accepted, reason)
    PurpleUI.inputSequence = PurpleUI.inputSequence + 1
    print("[XNP PURPLE ICON INPUT] sequence="
        .. tostring(PurpleUI.inputSequence)
        .. " button=" .. tostring(button)
        .. " click_count=" .. tostring(clickCount)
        .. " drag_distance=" .. string.format("%.2f", tonumber(dragDistance) or 0)
        .. " route=" .. tostring(route)
        .. " accepted=" .. tostring(accepted == true)
        .. " reject_reason=" .. tostring(reason or "NONE"))
    PurpleUI.routeCounts[route] = (PurpleUI.routeCounts[route] or 0) + 1
end

local function panelVisible(panel)
    if not panel then return false end
    if type(panel.isVisible) == "function" then
        local ok, visible = pcall(function() return panel:isVisible() end)
        if ok then return visible == true end
    end
    return panel.visible == true or PurpleUI.desiredVisible == true
end

local function rawInputLog(eventName, button, x, y, clickCount)
    PurpleUI.rawInputCount = PurpleUI.rawInputCount + 1
    PurpleUI.lastInputPanel = PurpleUI.panel
    PurpleUI.lastRawEvent = tostring(eventName)
    local inside = Frame.PointInside(x, y) == true
    local playerResolved = PurpleUI.player ~= nil
    local traitPresent = playerResolved and Core.PurplePhoenixTrait
        and Core.PurplePhoenixTrait.PlayerHasTrait(PurpleUI.player) == true or false
    print("[XNP PURPLE ICON RAW INPUT] event=" .. tostring(eventName)
        .. " button=" .. tostring(button)
        .. " x=" .. tostring(x)
        .. " y=" .. tostring(y)
        .. " inside_hitbox=" .. tostring(inside)
        .. " panel_visible=" .. tostring(panelVisible(PurpleUI.panel))
        .. " player_resolved=" .. tostring(playerResolved)
        .. " trait_present=" .. tostring(traitPresent)
        .. " drag_active=" .. tostring(Drag.IsDragging(PurpleUI.panel) == true)
        .. " click_count=" .. tostring(clickCount or 1))
end

local function loadPosition(player, panel)
    if PurpleUI.loadedPosition and PurpleUI.player == player then return end
    PurpleUI.player = player
    PurpleUI.loadedPosition = true
    local x, y = Frame.LoadPosition(player, POSITION_KEY, LEGACY_KEYS, 2)
    Frame.ClampPanel(panel, x, y)
end

function Panel:new(x, y)
    local panel = ISPanel:new(x, y, Frame.PANEL_SIZE, Frame.PANEL_SIZE)
    setmetatable(panel, self)
    self.__index = self
    Frame.PreparePanel(panel)
    return panel
end

function Panel:onMouseDown(x, y)
    rawInputLog("onMouseDown", "LEFT", x, y, 1)
    Tooltip.Hide("PURPLE_BACKUP_LEFT_DOWN")
    local allowed, reason = dragInputAllowed()
    if not allowed then
        inputLog("LEFT", 1, 0, "NONE", false, reason)
        return false
    end
    PurpleUI.pressX = getMouseX()
    PurpleUI.pressY = getMouseY()
    PurpleUI.dragMoved = false
    PurpleUI.dragMoveCount = 0
    PurpleUI.dragStartedPaused = gamePaused()
    local started = Drag.Start(
        self, x, y, PurpleUI.player, POSITION_KEY, PurpleUI)
    if not started then
        inputLog("LEFT", 1, 0, "NONE", false, "DRAG_START_REJECTED")
    end
    return started
end

function Panel:onMouseMove(dx, dy)
    if Drag.IsDragging(self) then
        local mx, my = getMouseX(), getMouseY()
        if distanceSquared(mx, my, PurpleUI.pressX, PurpleUI.pressY)
            > DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX then
            PurpleUI.dragMoved = true
            PurpleUI.firstClickMs = 0
        end
        local moved = Drag.Move(self)
        if moved then
            PurpleUI.dragMoveCount = PurpleUI.dragMoveCount + 1
        end
        return moved
    end
    local status = PurpleUI.status or {}
    local modeText = getText("UI_XNPPurpleRespawnDisabled")
    local stateHelp = getText("UI_XNPPurplePhoenixGreenHelp")
    if PurpleUI.state == "BLUE" then
        modeText = getText("UI_XNPPurpleRespawnEnabled")
        stateHelp = getText("UI_XNPPurplePhoenixBlueHelp")
    elseif PurpleUI.state == "WHITE" then
        modeText = string.format(
            getText("UI_XNPPurpleRespawnCooldown"),
            tonumber(PurpleUI.cooldownRemaining) or 0)
        stateHelp = getText("UI_XNPPurplePhoenixWhiteHelp")
    end
    local text = getText("UI_XNPMarker_PurpleBackupHelp")
        .. "<LINE>" .. getText("UI_XNPMarker_State") .. ": "
        .. tostring(modeText)
        .. "<LINE>" .. tostring(stateHelp)
        .. "<LINE>" .. getText("UI_XNPPurpleBackupSnapshot") .. ": "
        .. tostring(status.has_snapshot == true)
        .. "<LINE>" .. getText("UI_XNPPurpleValidTokenCount") .. ": "
        .. tostring(status.valid_token_count or 0)
    local invulnerabilityRemaining =
        Core.PurplePhoenixInvulnerability.GetRemainingSeconds(
            PurpleUI.player)
    if invulnerabilityRemaining > 0 then
        text = text .. "<LINE>" .. string.format(
            getText("UI_XNPPurplePhoenixInvulnerabilityRemaining"),
            invulnerabilityRemaining)
    end
    if status.days_until_auto_record then
        text = text .. "<LINE>" .. getText("UI_XNPPurpleBackupNextAuto") .. ": "
            .. string.format("%.1f", status.days_until_auto_record)
    end
    return Tooltip.Show(self, getText("UI_XNPMarker_PhoenixName"), text)
end

function Panel:onMouseUp(x, y)
    local moved = PurpleUI.dragMoved
    local mx, my = getMouseX(), getMouseY()
    local dragDistance = math.sqrt(distanceSquared(
        mx, my, PurpleUI.pressX, PurpleUI.pressY))
    local released = Drag.Release(self)
    if moved then
        PurpleUI.firstClickMs = 0
        dragAudit(true, released, "POSITION_ONLY")
        inputLog("LEFT", 1, dragDistance, "DRAG", true, "POSITION_ONLY")
        return released
    end
    local allowed, reason = actionInputAllowed()
    if not allowed or not Frame.PointInside(x, y) then
        PurpleUI.firstClickMs = 0
        inputLog("LEFT", 1, dragDistance, "NONE", false,
            allowed and "RELEASE_OUTSIDE" or reason)
        return released
    end
    local now = Frame.NowMs()
    local close = distanceSquared(mx, my,
        PurpleUI.firstClickX, PurpleUI.firstClickY)
        <= DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX
    if PurpleUI.firstClickMs > 0
        and now - PurpleUI.firstClickMs <= DOUBLE_CLICK_MS and close then
        PurpleUI.firstClickMs = 0
        local tx = Core.PurpleLifeStockTransactions
        local ok, queueReason = false, "TRANSACTION_MODULE_UNAVAILABLE"
        if tx and type(tx.QueueCraft) == "function" then
            ok, queueReason = tx.QueueCraft(
                PurpleUI.player, "PURPLE_ICON_LEFT_DOUBLE_CLICK")
        end
        inputLog("LEFT", 2, dragDistance, "CRAFT", ok == true, queueReason)
        return true
    end
    PurpleUI.firstClickMs = now
    PurpleUI.firstClickX = mx
    PurpleUI.firstClickY = my
    inputLog("LEFT", 1, dragDistance, "NONE", true,
        "WAITING_FOR_OPTIONAL_SECOND_CLICK")
    return released
end

function Panel:onMouseMoveOutside(dx, dy)
    Tooltip.Hide("PURPLE_BACKUP_MOUSE_OUT")
    if Drag.IsDragging(self) then
        PurpleUI.dragMoved = true
        PurpleUI.firstClickMs = 0
    end
    local moved = Drag.Move(self)
    if moved then PurpleUI.dragMoveCount = PurpleUI.dragMoveCount + 1 end
    return moved
end

function Panel:onMouseUpOutside(x, y)
    local mx, my = getMouseX(), getMouseY()
    local distance = math.sqrt(distanceSquared(
        mx, my, PurpleUI.pressX, PurpleUI.pressY))
    PurpleUI.firstClickMs = 0
    local released = Drag.Release(self)
    dragAudit(true, released, "RELEASE_OUTSIDE")
    inputLog("LEFT", 1, distance, "DRAG", true, "RELEASE_OUTSIDE")
    return released
end

function Panel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        PurpleUI.firstClickMs = 0
        return Drag.Cancel(self, "ESCAPE")
    end
    return false
end

function Panel:onRightMouseDown(x, y)
    rawInputLog("onRightMouseDown", "RIGHT", x, y, 1)
    Tooltip.Hide("PURPLE_BACKUP_RIGHT_DOWN")
    PurpleUI.firstClickMs = 0
    local allowed, reason = actionInputAllowed()
    PurpleUI.rightDown = allowed and Frame.PointInside(x, y)
        and not Drag.IsDragging(self)
    if not PurpleUI.rightDown then
        inputLog("RIGHT", 1, 0, "TOGGLE", false,
            allowed and "RIGHT_DOWN_OUTSIDE" or reason)
    end
    return PurpleUI.rightDown
end

function Panel:onRightMouseUp(x, y)
    local armed = PurpleUI.rightDown
    PurpleUI.rightDown = false
    local allowed, reason = actionInputAllowed()
    if armed and allowed and Frame.PointInside(x, y)
        and not Drag.IsDragging(self) then
        local tx = Core.PurpleLifeStockTransactions
        local changed, toggleReason = false, "TRANSACTION_MODULE_UNAVAILABLE"
        if tx and type(tx.TogglePhoenixSurvival) == "function" then
            changed, toggleReason = tx.TogglePhoenixSurvival(
                PurpleUI.player, "PURPLE_ICON_RIGHT_CLICK")
        end
        if changed then
            PurpleUI.state = Core.PurplePhoenixState.GetVisualState(PurpleUI.player)
            PurpleUI.nextUpdateMs = 0
            Core.PurplePhoenixState.AuditConsistency(
                PurpleUI.player, "TOGGLE_UI_REFRESH", "NA")
        end
        inputLog("RIGHT", 1, 0, "TOGGLE", changed == true, toggleReason)
        return true
    end
    if armed then
        inputLog("RIGHT", 1, 0, "TOGGLE", false,
            allowed and "RIGHT_RELEASE_OUTSIDE" or reason)
    end
    return armed
end

function Panel:render()
    PurpleUI.lastRenderPanel = self
    local invulnerabilityActive =
        Core.PurplePhoenixInvulnerability.IsActive(PurpleUI.player)
    local shakeEnabled = invulnerabilityActive
        and Core.PurplePhoenixConfig.Get()
            .iconShakeDuringInvulnerability == true
        and not Drag.IsDragging(self)
    if shakeEnabled then
        local seconds = Frame.NowMs() / 1000
        local offsetX = math.floor(math.sin(seconds * 31) * 2)
        local offsetY = math.floor(math.cos(seconds * 27) * 2)
        Frame.DrawAtOffset(self, PurpleUI.texture, PurpleUI.state,
            offsetX, offsetY)
    else
        Frame.Draw(self, PurpleUI.texture, PurpleUI.state)
    end
end

local function applyVisibility()
    if not PurpleUI.panel then return end
    local visible = PurpleUI.desiredVisible and not PurpleUI.mapHidden
    if not visible and Tooltip.IsOwner(PurpleUI.panel) then
        Tooltip.Hide("PURPLE_BACKUP_NOT_VISIBLE")
    end
    PurpleUI.panel:setVisible(visible)
    if type(PurpleUI.panel.setConsumeMouseEvents) == "function" then
        PurpleUI.panel:setConsumeMouseEvents(visible)
    end
end

local function ensurePanel()
    if not PurpleUI.textureAttempted and type(getTexture) == "function" then
        PurpleUI.textureAttempted = true
        PurpleUI.texture = getTexture(ICON_PATH)
    end
    Frame.LoadShellTextures()
    if PurpleUI.panel then return PurpleUI.panel end
    local panel = Panel:new(0, 0)
    panel:initialise()
    panel:instantiate()
    panel:addToUIManager()
    panel:setVisible(false)
    if type(panel.setAlwaysOnTop) == "function" then panel:setAlwaysOnTop(true) end
    if type(panel.setConsumeMouseEvents) == "function" then panel:setConsumeMouseEvents(true) end
    PurpleUI.panel = panel
    print("[XNP PURPLE BACKUP UI] created=true"
        .. " right_click=PHOENIX_SURVIVAL_TOGGLE left_single=NONE"
        .. " left_double_click=CRAFT left_drag=POSITION_ONLY"
        .. " enabled_color=BLUE cooldown_color=WHITE disabled_color=GREEN"
        .. " right_click_controls_life_stock=false")
    return panel
end

function PurpleUI.Update(player, force)
    if not Core.CanonicalPlayerIdentity
        or Core.CanonicalPlayerIdentity.Validate(player, true) ~= true
        or not Core.PurplePhoenixTrait
        or Core.PurplePhoenixTrait.PlayerHasTrait(player) ~= true then
        PurpleUI.desiredVisible = false
        applyVisibility()
        return false
    end
    if Core.SandboxTuning and (not Core.SandboxTuning.GetBoolean(
        "MarkersEnabled", true) or not Core.SandboxTuning.GetBoolean(
        "PurpleMarkerEnabled", true)) then
        PurpleUI.desiredVisible = false
        applyVisibility()
        return false
    end
    if Core.PurplePhoenixState
        and type(Core.PurplePhoenixState.EnsureDefaultMigration) == "function" then
        local migrated, migrationReason =
            Core.PurplePhoenixState.EnsureDefaultMigration(
                player, "PURPLE_UI_UPDATE")
        if not migrated then
            print("[XNP PURPLE DEFAULT MODE MIGRATION] result=DEFERRED reason="
                .. tostring(migrationReason))
        end
    end
    local panel = ensurePanel()
    loadPosition(player, panel)
    local now = Frame.NowMs()
    if force == true or now >= PurpleUI.nextUpdateMs then
        PurpleUI.nextUpdateMs = now + Frame.UPDATE_INTERVAL_MS
        PurpleUI.status = Core.PurpleLifeStockController.GetStatus(player)
        PurpleUI.state, PurpleUI.cooldownRemaining =
            Core.PurplePhoenixState.GetVisualState(player)
    end
    PurpleUI.desiredVisible = true
    applyVisibility()
    return true
end

function PurpleUI.RebindAfterRestore(player)
    Core.PurplePhoenixUI = PurpleUI
    Core.PurpleLifeStockUI = PurpleUI
    PurpleUI.loadedPosition = false
    PurpleUI.player = player
    PurpleUI.nextUpdateMs = 0
    if Core.PhoenixTransaction
        and type(Core.PhoenixTransaction.InitializePlayer) == "function" then
        Core.PhoenixTransaction.InitializePlayer(
            player, "POST_RESTORE_CURRENT_PLAYER")
    elseif Core.PurplePhoenixState
        and type(Core.PurplePhoenixState.ResetForNewCharacterCycle)
            == "function" then
        Core.PurplePhoenixState.ResetForNewCharacterCycle(
            player, "POST_RESTORE_CURRENT_PLAYER")
    end
    local updated = PurpleUI.Update(player, true) == true
    local panel = PurpleUI.panel
    local rightBound = panel and type(panel.onRightMouseUp) == "function"
    local leftBound = panel and type(panel.onMouseUp) == "function"
    local aliasesBound = Core.PurplePhoenixUI == Core.PurpleLifeStockUI
        and Core.PurplePhoenixUI == PurpleUI
    local bound = updated and rightBound and leftBound and aliasesBound
    print("[XNP PURPLE POST RESTORE REBIND]"
        .. " POST_RESTORE_PHOENIX_TRAIT="
        .. tostring(Core.PurplePhoenixTrait
            and Core.PurplePhoenixTrait.PlayerHasTrait(player) == true)
        .. " panel_persistent=" .. tostring(panel ~= nil)
        .. " right_callback_bound=" .. tostring(rightBound == true)
        .. " left_callback_bound=" .. tostring(leftBound == true)
        .. " aliases_bound=" .. tostring(aliasesBound)
        .. " free_token_count=0"
        .. " result=" .. tostring(bound and "BOUND" or "DEFERRED"))
    return bound, bound and "POST_RESTORE_CONTROL_BOUND"
        or "POST_RESTORE_CONTROL_REBIND_DEFERRED"
end

function PurpleUI.CommitManualState(player, targetState)
    if not Core.PurplePhoenixState then
        return false, "TOGGLE_STATE_UNAVAILABLE"
    end
    local targetEnabled = targetState == "BLUE"
        or targetState == "READY_ENABLED_BLUE" or targetState == true
    local changed, reason = Core.PurplePhoenixState.SetEnabled(
        player, targetEnabled, "UI_MANUAL_STATE_COMMIT")
    if not changed and reason ~= "TOGGLE_STATE_UNCHANGED" then
        return false, reason
    end
    PurpleUI.nextUpdateMs = 0
    PurpleUI.Update(player, true)
    return PurpleUI.state == (targetEnabled and "BLUE" or "GREEN"),
        PurpleUI.state
end

function PurpleUI.SetMapHidden(hidden)
    PurpleUI.mapHidden = hidden == true
    if PurpleUI.mapHidden and PurpleUI.panel then
        Drag.Cancel(PurpleUI.panel, "PURPLE_BACKUP_MAP")
        PurpleUI.firstClickMs = 0
        PurpleUI.rightDown = false
    end
    applyVisibility()
end

function PurpleUI.Cleanup(reason)
    if PurpleUI.panel then
        Drag.Cancel(PurpleUI.panel, reason or "PURPLE_BACKUP_CLEANUP")
        PurpleUI.panel:setVisible(false)
        if type(PurpleUI.panel.setConsumeMouseEvents) == "function" then
            PurpleUI.panel:setConsumeMouseEvents(false)
        end
    end
    if PurpleUI.panel and Tooltip.IsOwner(PurpleUI.panel) then
        Tooltip.Hide("PURPLE_BACKUP_CLEANUP")
    end
    PurpleUI.player = nil
    PurpleUI.loadedPosition = false
    PurpleUI.desiredVisible = false
    PurpleUI.nextUpdateMs = 0
    PurpleUI.status = nil
    PurpleUI.firstClickMs = 0
    PurpleUI.rightDown = false
    PurpleUI.dragMoved = false
    PurpleUI.dragMoveCount = 0
    PurpleUI.dragStartedPaused = false
end

function PurpleUI.GetAuditSnapshot()
    local panel = PurpleUI.panel
    local width = panel and (tonumber(panel.width)
        or (type(panel.getWidth) == "function" and panel:getWidth())) or 0
    local height = panel and (tonumber(panel.height)
        or (type(panel.getHeight) == "function" and panel:getHeight())) or 0
    local centerInside = width > 0 and height > 0
        and Frame.PointInside(width / 2, height / 2) == true
    return {
        state = PurpleUI.state,
        desired_visible = PurpleUI.desiredVisible,
        stale_marker_hitbox_count = PurpleUI.staleHitboxCount,
        right_click_toggle_registered = true,
        left_single_action = "NONE",
        left_double_click_action = "CRAFT",
        left_drag_action = "POSITION_ONLY",
        working_panel_class = "XNPPurpleLifeStockRoundPanel0560722",
        working_mouse_event_method = "ISPanel:onMouseDown/onMouseUp/onRightMouseDown/onRightMouseUp",
        shared_dispatcher_actually_exists = false,
        added_to_ui_manager = panel ~= nil,
        render_object_equals_input_object = panel ~= nil
            and PurpleUI.lastRenderPanel == PurpleUI.lastInputPanel,
        panel_width_gt_zero = width > 0,
        panel_height_gt_zero = height > 0,
        hitbox_contains_rendered_icon_center = centerInside,
        topmost_blocking_panel = "NONE",
        raw_mouse_event_count = PurpleUI.rawInputCount,
        raw_mouse_event_reached = PurpleUI.rawInputCount > 0,
        route_counts = PurpleUI.routeCounts,
        last_raw_event = PurpleUI.lastRawEvent,
    }
end

Core.PurplePhoenixUI = PurpleUI
Core.PurpleLifeStockUI = PurpleUI
return PurpleUI
