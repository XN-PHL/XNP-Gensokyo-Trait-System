require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTickBox"
require "ISUI/ISModalDialog"
require "XNP_PZ_DistanceRunner/XNP_DR_ConfigHealthCore"

local Core = XNP_PZ_DistanceRunner
local Health = Core.ConfigHealthCore

local UI = {
    panel = nil,
    scanCount = 0,
    closedScanCount = 0,
    minimumLiveRefreshMs = 2000,
}

local Filters = {
    "ALL", "DANGEROUS", "KNOWN_STALE", "USER_CUSTOM",
    "DEVELOPER_BYPASS", "PURPLE", "GREEN",
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return os.time() * 1000
end

local function text(key, fallback)
    if type(getText) == "function" then
        local ok, value = pcall(getText, key)
        if ok and value and value ~= key then return tostring(value) end
    end
    return fallback
end

local function valueText(value)
    if value == nil then return "<nil>" end
    return tostring(value)
end

local Panel = ISPanel:derive("XNPConfigHealthCenterPanel")

function Panel:new(x, y, width, height, player, readOnly)
    local object = ISPanel.new(self, x, y, width, height)
    object.player = player
    object.readOnly = readOnly == true
    object.filterIndex = 1
    object.report = nil
    object.lastRefreshMs = 0
    object.liveRefresh = false
    object.moveWithMouse = true
    object.backgroundColor = { r = 0.06, g = 0.07, b = 0.08, a = 0.96 }
    object.borderColor = { r = 0.45, g = 0.75, b = 0.95, a = 0.90 }
    return object
end

function Panel:initialise()
    ISPanel.initialise(self)
end

local function addButton(panel, x, y, width, label, callback)
    local button = ISButton:new(x, y, width, 24, label, panel, callback)
    button:initialise()
    panel:addChild(button)
    return button
end

function Panel:createChildren()
    ISPanel.createChildren(self)
    self.list = ISScrollingListBox:new(12, 186,
        self.width - 24, self.height - 294)
    self.list:initialise()
    self.list.itemheight = 40
    self.list.doDrawItem = function(list, y, item)
        local row = item.item
        local danger = row.dangerous == true
        local eligible = row.safe_repair_eligible == true
        local r, g, b = 0.88, 0.88, 0.88
        if danger then r, g, b = 1.0, 0.52, 0.42
        elseif eligible then r, g, b = 1.0, 0.82, 0.35 end
        list:drawText(row.key, 6, y + 2, r, g, b, 1,
            UIFont.Small)
        list:drawText(tostring(row.classification), 265, y + 2,
            0.72, 0.78, 0.84, 1, UIFont.Small)
        list:drawText(row.difference_type, 440, y + 2,
            0.65, 0.82, 1.0, 1, UIFont.Small)
        list:drawText("ui=" .. valueText(row.ui_value)
            .. " raw=" .. valueText(row.raw_value)
            .. " effective=" .. valueText(row.effective_value)
            .. " default=" .. valueText(row.canonical_default),
            12, y + 20,
            0.82, 0.82, 0.82, 1, UIFont.Small)
        list:drawText("source=" .. valueText(row.saved_source)
            .. " repair=" .. tostring(row.safe_repair_eligible)
            .. " reason=" .. valueText(row.reason),
            390, y + 20, 0.70, 0.76, 0.82, 1, UIFont.Small)
        return y + list.itemheight
    end
    self:addChild(self.list)

    local bottom = self.height - 98
    self.filterButton = addButton(self, 12, bottom, 130,
        "Filter: ALL", Panel.onCycleFilter)
    self.refreshButton = addButton(self, 148, bottom, 100,
        text("UI_XNPConfigHealthRefresh", "Refresh"), Panel.onRefresh)
    self.repairButton = addButton(self, 254, bottom, 155,
        text("UI_XNPConfigHealthSafeRepair", "Repair Known Stale"),
        Panel.onRepair)
    self.balanceButton = addButton(self, 415, bottom, 135,
        text("UI_XNPConfigHealthBalanced", "Formal Balance"),
        Panel.onBalanced)
    self.restoreButton = addButton(self, 556, bottom, 105,
        text("UI_XNPConfigHealthRestore", "Restore"), Panel.onRestore)
    self.exportButton = addButton(self, 667, bottom, 105,
        text("UI_XNPConfigHealthExport", "Export"), Panel.onExport)

    self.yellowChoice = ISTickBox:new(12, bottom + 31, 245, 20,
        text("UI_XNPConfigHealthYellowChoice",
            "Enable Yellow Alt breakout"), self)
    self.yellowChoice:initialise()
    self.yellowChoice:addOption(text("UI_XNPConfigHealthYellowChoice",
        "Yellow Alt"))
    self:addChild(self.yellowChoice)

    self.redChoice = ISTickBox:new(270, bottom + 31, 245, 20,
        text("UI_XNPConfigHealthRedChoice",
            "Enable Red body feedback"), self)
    self.redChoice:initialise()
    self.redChoice:addOption(text("UI_XNPConfigHealthRedChoice",
        "Red feedback"))
    self:addChild(self.redChoice)

    self.closeButton = addButton(self, self.width - 112,
        bottom + 31, 100, text("UI_Close", "Close"), Panel.onClose)

    if self.readOnly then
        self.repairButton.enable = false
        self.balanceButton.enable = false
        self.restoreButton.enable = false
        self.yellowChoice.enable = false
        self.redChoice.enable = false
    end
    self:refreshReport(true)
end

function Panel:refreshReport(force)
    local current = nowMs()
    if force ~= true
        and current - self.lastRefreshMs < UI.minimumLiveRefreshMs then
        return false, "REFRESH_THROTTLED"
    end
    self.lastRefreshMs = current
    self.report = Health.BuildReport()
    self.diagnostic = Core.B42_20RuntimeDiagnostic
        and Core.B42_20RuntimeDiagnostic.GetSnapshot
        and Core.B42_20RuntimeDiagnostic.GetSnapshot(self.player) or {}
    self.backupSummary = Health.GetBackupSummary()
    UI.scanCount = UI.scanCount + 1
    self.list:clear()
    local filter = Filters[self.filterIndex]
    local rows = Health.FilterRows(self.report, filter)
    for index = 1, #rows do self.list:addItem(rows[index].key, rows[index]) end
    self.filterButton:setTitle("Filter: " .. filter)
    return true, "REFRESHED"
end

function Panel:update()
    ISPanel.update(self)
    if self.liveRefresh == true then self:refreshReport(false) end
end

function Panel:render()
    ISPanel.render(self)
    local report = self.report or {}
    local diagnostic = self.diagnostic or {}
    local values = Core.SandboxTuning.GetSnapshot().values or {}
    local backup = self.backupSummary or {}
    self:drawText(text("UI_XNPConfigHealthTitle",
        "XNP Configuration Health Center"), 12, 10,
        0.85, 0.94, 1.0, 1, UIFont.Large)
    local mode = self.readOnly and "READ ONLY" or "HOST WRITE ENABLED"
    self:drawText("Game " .. tostring(diagnostic.ActualGameBuild)
        .. " | Version " .. tostring(Core.Constants.VERSION)
        .. " | Internal " .. tostring(Core.Constants.INTERNAL_VERSION)
        .. " | " .. mode, 12, 38, 0.75, 0.82, 0.88, 1, UIFont.Small)
    self:drawText("Build " .. tostring(Core.Constants.BUILD_ID)
        .. " | Channel " .. tostring(Core.Constants.RELEASE_CHANNEL),
        12, 54, 0.75, 0.82, 0.88, 1, UIFont.Small)
    self:drawText("Mod " .. tostring(Core.Constants.MOD_ID)
        .. " | Workshop " .. tostring(Core.Constants.TEST_WORKSHOP_ID)
        .. " | Active " .. tostring(diagnostic.ActiveXnpModIds),
        12, 70, 0.75, 0.82, 0.88, 1, UIFont.Small)
    self:drawText("Guard " .. tostring(diagnostic.ChannelGuardState)
        .. " | Preset " .. tostring(values.GeneralGameplayPreset)
        .. " | Migration " .. tostring(report.migration_marker_write_status)
        .. " | Backup " .. tostring(backup.last_backup_timestamp),
        12, 86, 0.75, 0.82, 0.88, 1, UIFont.Small)
    self:drawText("Compared " .. tostring(report.compared or 0)
        .. " | Different " .. tostring(report.different or 0)
        .. " | Raw only " .. tostring(report.raw_only or 0)
        .. " | Safe repair " .. tostring(report.safe_repair_count or 0),
        12, 102, 0.92, 0.92, 0.92, 1, UIFont.Small)
    self:drawText("Yellow enabled=" .. tostring(values.EnableYellowTraitSystem)
        .. " alt=" .. tostring(values.YellowAltCrowdBreakoutEnabled)
        .. " cooldown=" .. tostring(values.YellowAltCrowdBreakoutCooldownSeconds)
        .. " cost=" .. tostring(values.YellowAltCrowdBreakoutEnduranceCost)
        .. " last=" .. tostring(diagnostic.LastYellowAltResult),
        12, 118, 0.94, 0.86, 0.35, 1, UIFont.Small)
    self:drawText("Purple armed=" .. tostring(diagnostic.PhoenixArmedState)
        .. " cooldown=" .. tostring(values.PurpleCooldownRealSeconds)
        .. " invulnerability=" .. tostring(values.PurpleInvulnerabilitySeconds)
        .. " push=" .. tostring(values.PurpleLocalZombiePushEnabled)
        .. " last=" .. tostring(diagnostic.LastPhoenixResult),
        12, 134, 0.78, 0.58, 1.0, 1, UIFont.Small)
    self:drawText("Green runtime_test="
        .. tostring(values.GreenRuntimeTestModeEnabled)
        .. " cooldown=" .. tostring(values.GreenCooldownSeconds)
        .. " resource_gate=" .. tostring(values.ResourceGateEnabled)
        .. " active_casts=" .. tostring(diagnostic.GreenActiveCastCount
            or "N/A")
        .. " last=" .. tostring(diagnostic.LastGreenCastResult),
        12, 150, 0.45, 1.0, 0.55, 1, UIFont.Small)
    self:drawText("Red craft=" .. tostring(values.RedCraftEnabled)
        .. " sweat=" .. tostring(values.RedCraftSweatEnabled)
        .. " heat=" .. tostring(values.RedCraftBodyHeatEnabled)
        .. " exert=" .. tostring(values.RedCraftExertionFeedbackEnabled)
        .. " load=" .. tostring(values.RedCraftPhysicalLoadDurationSeconds)
        .. " rolling=" .. tostring(values.GreenContinuousRollingCastEnabled)
        .. " retain=" .. tostring(values.GreenRollingCastRetainedCount)
        .. " full_sweat=" .. tostring(values.RedCraftImmediateFullSweatEnabled)
        .. "s/" .. tostring(values.RedCraftPhysicalLoadStackLimit)
        .. " fatigue=" .. tostring(values.RedCraftFatigueCostPercent)
        .. "%",
        12, 166, 1.0, 0.45, 0.45, 1, UIFont.Small)
end

function Panel:onCycleFilter()
    self.filterIndex = self.filterIndex + 1
    if self.filterIndex > #Filters then self.filterIndex = 1 end
    self:refreshReport(true)
end

function Panel:onRefresh()
    self:refreshReport(true)
end

function Panel:confirm(message, callback)
    local modal = ISModalDialog:new(
        self.x + 90, self.y + 90, 460, 180,
        message, true, self, function(target, button)
            if button and button.internal == "YES" then callback(target) end
        end)
    modal:initialise()
    modal:addToUIManager()
    modal.alwaysOnTop = true
end

function Panel:onRepair()
    self:confirm(text("UI_XNPConfigHealthConfirmRepair",
        "Back up this world configuration and repair only proven old defaults?"),
        function(target)
            local ok, reason = Health.RepairKnownDefaults({
                player = target.player, confirmed = true,
            })
            print("[XNP CONFIG HEALTH] operation=SAFE_REPAIR success="
                .. tostring(ok) .. " result=" .. tostring(reason))
            target:refreshReport(true)
        end)
end

function Panel:onBalanced()
    self:confirm(text("UI_XNPConfigHealthConfirmBalanced",
        "Back up current values and apply the formal balance preset?"),
        function(target)
            local yellow = target.yellowChoice:isSelected(1)
            local red = target.redChoice:isSelected(1)
            local ok, reason = Health.ApplyBalancedPreset({
                player = target.player,
                confirmed = true,
                optional_features = {
                    YellowAltCrowdBreakoutEnabled = yellow,
                    RedCraftSweatEnabled = red,
                    RedCraftBodyHeatEnabled = red,
                    RedCraftExertionFeedbackEnabled = red,
                },
            })
            print("[XNP CONFIG HEALTH] operation=BALANCED_PRESET success="
                .. tostring(ok) .. " result=" .. tostring(reason))
            target:refreshReport(true)
        end)
end

function Panel:onRestore()
    self:confirm(text("UI_XNPConfigHealthConfirmRestore",
        "Back up current values and restore the latest configuration backup?"),
        function(target)
            local ok, reason = Health.RestoreLatest({
                player = target.player, confirmed = true,
            })
            print("[XNP CONFIG HEALTH] operation=RESTORE success="
                .. tostring(ok) .. " result=" .. tostring(reason))
            target:refreshReport(true)
        end)
end

function Panel:onExport()
    local ok, reason = Health.ExportSanitized({ report = self.report })
    print("[XNP CONFIG HEALTH] operation=EXPORT success="
        .. tostring(ok) .. " result=" .. tostring(reason))
end

function Panel:onClose()
    self:removeFromUIManager()
    if UI.panel == self then UI.panel = nil end
end

function UI.Show(player, readOnly)
    if UI.panel then UI.panel:onClose() end
    if not Health.IsTestChannel() then return false, "NOT_TEST_CHANNEL" end
    local writable = Health.HasWriteAuthority(player)
    readOnly = readOnly == true or writable ~= true
    local width, height = 790, 620
    local x, y = 30, 30
    if type(getCore) == "function" then
        local ok, gameCore = pcall(getCore)
        if ok and gameCore then
            width = math.min(width, gameCore:getScreenWidth() - 40)
            height = math.min(height, gameCore:getScreenHeight() - 40)
            x = math.max(20, (gameCore:getScreenWidth() - width) / 2)
            y = math.max(20, (gameCore:getScreenHeight() - height) / 2)
        end
    end
    local panel = Panel:new(x, y, width, height, player, readOnly)
    panel:initialise()
    panel:addToUIManager()
    panel.alwaysOnTop = true
    UI.panel = panel
    return true, readOnly and "READ_ONLY_SHOWN" or "WRITABLE_SHOWN"
end

function UI.GetAuditSnapshot()
    return {
        present = true,
        test_only = true,
        read_only_entry = true,
        write_entry_test_only = true,
        server_authority_gate = true,
        full_scan_per_frame = false,
        closed_scan_count_per_second = UI.closedScanCount,
        minimum_live_refresh_ms = UI.minimumLiveRefreshMs,
        scan_count = UI.scanCount,
    }
end

Core.ConfigHealthUI = UI
return UI
