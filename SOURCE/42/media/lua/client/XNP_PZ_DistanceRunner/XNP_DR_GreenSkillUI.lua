require "ISUI/ISPanel"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenDoubleClickGate"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWhiteAction"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_ToggleTransactions"

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
    inputRequestId = 0,
    lastInputTimestampMs = -1,
    sameFrameSequence = 0,
    duplicateFilteredCount = 0,
    requestActivateCallCount = 0,
    lastRejectReason = "NONE",
    inputByPlayer = setmetatable({}, { __mode = "k" }),
}

local POSITION_KEY = "XNP_UI_GREEN_ROUND_POS_0557"
local LEGACY_KEYS = { "XNP_UI_GREEN_ULTIMATE_POS", "XNP_UI_GREEN_SKILL_POS" }
local ICON_PATH = "media/ui/XNPMarkers/xnp_marker_green.png"
local DOUBLE_CLICK_MS = 500
local DRAG_THRESHOLD_PX = 5
local Panel = ISPanel:derive("XNPGreenUltimateRoundPanel0557")

local function tooltipText()
    local testMode = Core.GreenWorldOrb and Core.GreenWorldOrb.IsRuntimeTestModeEnabled
        and Core.GreenWorldOrb.IsRuntimeTestModeEnabled() == true
    local modeText = getText(testMode and "UI_XNPMarker_GreenDeveloperModeOn"
        or "UI_XNPMarker_GreenDeveloperModeOff")
    local meleeState = GreenUI.player and Core.GreenSkill
        and Core.GreenSkill.IsEnabled(GreenUI.player) == true
    local activeStatus = Core.GreenWorldOrb
        and type(Core.GreenWorldOrb.GetPlayerStatus) == "function"
        and Core.GreenWorldOrb.GetPlayerStatus(GreenUI.player) or {}
    return getText("UI_XNPMarker_GreenHelp")
        .. "<LINE>" .. modeText
        .. "<LINE>MELEE: " .. tostring(meleeState and "ON" or "OFF")
        .. "<LINE>ACTIVE: " .. tostring(activeStatus.ready and "READY"
            or activeStatus.reason or GreenUI.lastRejectReason)
        .. "<LINE>COOLDOWN: "
        .. string.format("%.1f", tonumber(activeStatus.cooldown_remaining_seconds) or 0)
end

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

local function pointerLog(route, snapshot, accepted, reason)
    snapshot = snapshot or {}
    print("[XNP GREEN POINTER INPUT]"
        .. " down_screen=" .. tostring(snapshot.down_screen_x) .. ","
        .. tostring(snapshot.down_screen_y)
        .. " down_local=" .. tostring(snapshot.down_local_x) .. ","
        .. tostring(snapshot.down_local_y)
        .. " up_screen=" .. tostring(snapshot.up_screen_x) .. ","
        .. tostring(snapshot.up_screen_y)
        .. " up_local=" .. tostring(snapshot.up_local_x) .. ","
        .. tostring(snapshot.up_local_y)
        .. " move_count=" .. tostring(snapshot.move_count or 0)
        .. " distance_same_space="
        .. string.format("%.2f", tonumber(snapshot.distance_same_space) or 0)
        .. " route=" .. tostring(route)
        .. " result=" .. tostring(accepted == true)
        .. " reason=" .. tostring(reason or "NONE"))
end

local function playerInputState(player)
    local state = GreenUI.inputByPlayer[player]
    if state then return state end
    state = {
        firstClickMs = 0,
        firstClickX = 0,
        firstClickY = 0,
        firstEdgeId = nil,
        lastEdgeId = nil,
        sequence = 0,
    }
    GreenUI.inputByPlayer[player] = state
    return state
end

local function resetPendingInput(player)
    local state = GreenUI.inputByPlayer[player]
    if state then
        state.firstClickMs = 0
        state.firstClickX = 0
        state.firstClickY = 0
        state.lastEdgeId = nil
        state.firstEdgeId = nil
    end
end

local function playerKeyHash(player)
    local index = -1
    if player and type(player.getPlayerNum) == "function" then
        local ok, value = pcall(player.getPlayerNum, player)
        if ok then index = tonumber(value) or -1 end
    end
    return "P" .. tostring(index)
end

local function inputLog(eventName, player, fields)
    if not Core.Constants or Core.Constants.RELEASE_CHANNEL ~= "B42_20_TEST_WORKSHOP" then return end
    fields = fields or {}
    print("[XNP GREEN " .. tostring(eventName) .. "]"
        .. " build_marker=" .. tostring(Core.Constants.BUILD_ID)
        .. " player_key_hash=" .. playerKeyHash(player)
        .. " edge_id=" .. tostring(fields.edge_id or "NONE")
        .. " input_sequence=" .. tostring(fields.input_sequence or 0)
        .. " input_time_ms=" .. tostring(fields.input_time_ms or 0)
        .. " request_source=" .. tostring(fields.request_source or "NONE")
        .. " result=" .. tostring(fields.result or "NONE")
        .. " reason=" .. tostring(fields.reason or "NONE"))
end

local function releaseEdgeId(inputTimestampMs, snapshot)
    snapshot = snapshot or {}
    return table.concat({
        tostring(inputTimestampMs),
        tostring(snapshot.down_screen_x or "nil"), tostring(snapshot.down_screen_y or "nil"),
        tostring(snapshot.up_screen_x or "nil"), tostring(snapshot.up_screen_y or "nil"),
        tostring(snapshot.move_count or 0),
    }, ":")
end

local function dispatchGreenInput(player, source, inputTimestampMs, snapshot, edgeId, ticket)
    local state = playerInputState(player)
    edgeId = edgeId or releaseEdgeId(inputTimestampMs, snapshot)
    if state.lastEdgeId == edgeId then
        GreenUI.duplicateFilteredCount = GreenUI.duplicateFilteredCount + 1
        inputLog("INPUT_DUPLICATE_SUPPRESSED", player, {
            edge_id = edgeId, input_sequence = state.sequence,
            input_time_ms = inputTimestampMs, request_source = source,
            result = "SUPPRESSED", reason = "DUPLICATE_EDGE",
        })
        return false, "INPUT_DUPLICATE_SUPPRESSED"
    end
    state.lastEdgeId = edgeId
    state.sequence = state.sequence + 1
    GreenUI.inputRequestId = GreenUI.inputRequestId + 1
    if inputTimestampMs == GreenUI.lastInputTimestampMs then
        GreenUI.sameFrameSequence = GreenUI.sameFrameSequence + 1
    else
        GreenUI.lastInputTimestampMs = inputTimestampMs
        GreenUI.sameFrameSequence = 1
    end
    inputLog("CAST_REQUEST", player, {
        edge_id = edgeId, input_sequence = state.sequence,
        input_time_ms = inputTimestampMs, request_source = source,
        result = "FORWARDED", reason = "NONE",
    })
    GreenUI.requestActivateCallCount = GreenUI.requestActivateCallCount + 1
    local debugInput = Core.SandboxTuning and type(Core.SandboxTuning.GetBoolean) == "function" and (
        Core.SandboxTuning.GetBoolean("EnableDebugSummary", false) == true
        or Core.SandboxTuning.GetBoolean("GreenPerformanceStatisticsEnabled", false) == true)
    if debugInput then
        local playerIndex = -1
        if player and type(player.getPlayerNum) == "function" then
            local ok, value = pcall(player.getPlayerNum, player)
            if ok then playerIndex = tonumber(value) or -1 end
        end
        print("[XNP GREEN INPUT] request_id=" .. tostring(GreenUI.inputRequestId)
            .. " player_index=" .. tostring(playerIndex)
            .. " input_timestamp_ms=" .. tostring(inputTimestampMs)
            .. " same_frame_sequence=" .. tostring(GreenUI.sameFrameSequence)
            .. " ui_duplicate_filtered=false request_activate_called=true")
    end
    local accepted, reason, castId = Core.GreenWorldOrb.RequestActivate(
        player, source, inputTimestampMs, GreenUI.inputRequestId, snapshot, ticket)
    GreenUI.lastRejectReason = accepted == true and "NONE" or tostring(reason)
    inputLog(accepted == true and "CAST_ACCEPTED" or "CAST_REJECTED", player, {
        edge_id = edgeId, input_sequence = state.sequence,
        input_time_ms = inputTimestampMs, request_source = source,
        result = accepted == true and "ACCEPTED" or "REJECTED", reason = reason,
    })
    pointerLog("GREEN_ACTIVE_CAST", snapshot, accepted, reason)
    return accepted, reason, castId
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
    GreenUI.dragMoved = false
    local started = Drag.Start(self, x, y, GreenUI.player, POSITION_KEY, GreenUI)
    inputLog("INPUT_EDGE", GreenUI.player, {
        input_time_ms = Frame.NowMs(), request_source = "GREEN_LEFT_POINTER",
        result = started == true and "TRACKING" or "IGNORED", reason = "NONE",
    })
    return started
end

function Panel:onMouseMove(dx, dy)
    if Drag.IsDragging(self) then
        local moved = Drag.Move(self)
        local snapshot = Drag.GetInputSnapshot(self, nil, nil)
        if snapshot and snapshot.is_drag == true then
            GreenUI.dragMoved = true
            resetPendingInput(GreenUI.player)
        end
        return moved
    end
    return Tooltip.Show(self, getText("UI_XNPMarker_GreenName"), tooltipText())
end

function Panel:onMouseUp(x, y)
    local released, snapshot, moved = Drag.Finish(self, x, y)
    local now = Frame.NowMs()
    local inputState = playerInputState(GreenUI.player)
    local edgeId = releaseEdgeId(now, snapshot)
    inputLog("INPUT_RELEASE", GreenUI.player, {
        edge_id = edgeId, input_sequence = inputState.sequence + 1,
        input_time_ms = now, request_source = "GREEN_LEFT_POINTER",
        result = released == true and "RELEASED" or "IGNORED", reason = moved and "DRAG" or "NONE",
    })
    if moved then
        pointerLog("DRAG", snapshot, released, "POSITION_ONLY")
        resetPendingInput(GreenUI.player)
        return released
    end
    if GreenUI.mapHidden or not GreenUI.desiredVisible then
        pointerLog("NONE", snapshot, false, "MAP_OR_ICON_HIDDEN")
        return released
    end
    local mx = snapshot and snapshot.up_screen_x or getMouseX()
    local my = snapshot and snapshot.up_screen_y or getMouseY()
    local close = distanceSquared(mx, my, inputState.firstClickX, inputState.firstClickY) <= DRAG_THRESHOLD_PX * DRAG_THRESHOLD_PX
    local activeDoubleClick = not Core.SandboxTuning
        or Core.SandboxTuning.GetBoolean("GreenActiveDoubleClickEnabled", true) == true
    if not activeDoubleClick then
        resetPendingInput(GreenUI.player)
        inputLog("DOUBLE_CLICK", GreenUI.player, { edge_id = edgeId, input_time_ms = now,
            request_source = "GREEN_LEFT_DOUBLE_CLICK", result = "ACTIVE_ENTRY_DISABLED_NO_SINGLE_CLICK_FALLBACK",
            reason = "SANDBOX_DISABLED" })
        GreenUI.nextUpdateMs = 0
        return true
    end
    if inputState.firstClickMs > 0 and now - inputState.firstClickMs <= DOUBLE_CLICK_MS and close then
        local ticket = Core.GreenDoubleClickGate.Create(GreenUI.player, inputState.firstEdgeId, edgeId, now)
        inputState.firstClickMs = 0
        inputState.firstEdgeId = nil
        dispatchGreenInput(GreenUI.player, "GREEN_LEFT_DOUBLE_CLICK", now, snapshot, edgeId, ticket)
        GreenUI.nextUpdateMs = 0
        return true
    end
    inputState.firstClickMs = now
    inputState.firstClickX = mx
    inputState.firstClickY = my
    inputState.firstEdgeId = edgeId
    inputLog("DOUBLE_CLICK", GreenUI.player, { edge_id = edgeId, input_time_ms = now,
        request_source = "GREEN_LEFT_DOUBLE_CLICK", result = "WAITING_FOR_SECOND_CLICK", reason = "NO_SIDE_EFFECTS" })
    return released
end

function Panel:onMouseMoveOutside(dx, dy)
    Tooltip.Hide("GREEN_MOUSE_OUT")
    local moved = Drag.Move(self)
    local snapshot = Drag.GetInputSnapshot(self, nil, nil)
    if snapshot and snapshot.is_drag == true then
        GreenUI.dragMoved = true
        resetPendingInput(GreenUI.player)
    end
    return moved
end

function Panel:onMouseUpOutside(x, y)
    resetPendingInput(GreenUI.player)
    local released, snapshot, moved = Drag.Finish(self, x, y)
    pointerLog(moved and "DRAG" or "NONE", snapshot, moved and released or false,
        moved and "POSITION_ONLY" or "RELEASE_OUTSIDE_NO_DRAG")
    return released
end

function Panel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        resetPendingInput(GreenUI.player)
        Core.GreenDoubleClickGate.Clear(GreenUI.player)
        return Drag.Cancel(self, "ESCAPE")
    end
    return false
end

function Panel:onRightMouseDown(x, y)
    Tooltip.Hide("GREEN_RIGHT_DOWN")
    resetPendingInput(GreenUI.player)
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
        return Core.ToggleTransactions.RequestGreen(
            GreenUI.player, "GREEN_ROUND_RIGHT_CLICK") == true
    end
    return armed
end

function GreenUI.CommitManualState(player, enabled)
    GreenUI.nextUpdateMs = 0
    local updated = GreenUI.Update(player, true)
    local colorMatch = (enabled == true and GreenUI.color ~= "WHITE")
        or (enabled ~= true and GreenUI.color == "WHITE")
    return updated == true and Core.GreenSkill.IsEnabled(player) == (enabled == true)
        and colorMatch, GreenUI.color
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
    Tooltip.Refresh(panel, getText("UI_XNPMarker_GreenName"), tooltipText())
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
        resetPendingInput(GreenUI.player)
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
    print("[XNP GREEN INPUT SUMMARY] requests=" .. tostring(GreenUI.inputRequestId)
        .. " duplicate_filtered=" .. tostring(GreenUI.duplicateFilteredCount)
        .. " request_activate_called=" .. tostring(GreenUI.requestActivateCallCount))
    GreenUI.inputRequestId = 0
    GreenUI.lastInputTimestampMs = -1
    GreenUI.sameFrameSequence = 0
    GreenUI.duplicateFilteredCount = 0
    GreenUI.requestActivateCallCount = 0
    GreenUI.lastRejectReason = "NONE"
    GreenUI.inputByPlayer = setmetatable({}, { __mode = "k" })
end

Core.GreenSkillUI = GreenUI
return GreenUI
