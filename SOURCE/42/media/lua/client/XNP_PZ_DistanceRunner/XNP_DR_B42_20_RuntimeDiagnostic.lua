require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_ConfigHealthCore"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local Diagnostic = {
    startupChecked = false,
    modal = nil,
}

local FIELD_ORDER = {
    "ActualGameBuild",
    "ModVersion",
    "BuildMarker",
    "Channel",
    "ModID",
    "YellowInit",
    "PurpleInit",
    "GreenInit",
    "RedInit",
    "LifeStockInit",
    "PhoenixGuardInit",
    "ChannelGuardState",
    "SandboxRawEffectiveDiff",
    "RegisteredEventCount",
    "Bandits2BridgeAvailable",
    "LastPhoenixResult",
    "LastYellowAltResult",
    "LastGreenCastResult",
    "LastRedCraftResult",
    "LastFootwearRepairResult",
    "ActiveXnpModIds",
    "PhoenixArmedState",
    "GreenActiveCastCount",
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function actualGameBuild()
    if type(getCore) ~= "function" then
        return "UNAVAILABLE_STATIC_HARNESS"
    end
    local okCore, core = pcall(getCore)
    if not okCore or not core then return "CORE_UNAVAILABLE" end
    local okVersion, version = invoke(core, "getVersionNumber")
    if okVersion and version then return tostring(version) end
    local okGameVersion, gameVersion = invoke(core, "getGameVersion")
    if okGameVersion and gameVersion then return tostring(gameVersion) end
    return "VERSION_API_UNAVAILABLE"
end

local function collectionSize(collection)
    local ok, size = invoke(collection, "size")
    return ok and tonumber(size) or 0
end

local function activeModIdCount()
    if type(getActivatedMods) ~= "function" then return -1 end
    local ok, mods = pcall(getActivatedMods)
    if not ok or not mods then return -1 end
    local count = 0
    for index = 0, collectionSize(mods) - 1 do
        local itemOk, modId = invoke(mods, "get", index)
        if itemOk and tostring(modId) == Constants.MOD_ID then
            count = count + 1
        end
    end
    return count
end

local function activeXnpModIds()
    if type(getActivatedMods) ~= "function" then
        return "ACTIVE_MOD_API_UNAVAILABLE"
    end
    local ok, mods = pcall(getActivatedMods)
    if not ok or not mods then return "ACTIVE_MOD_API_UNAVAILABLE" end
    local ids = {}
    for index = 0, collectionSize(mods) - 1 do
        local itemOk, modId = invoke(mods, "get", index)
        local value = itemOk and tostring(modId) or ""
        if value == Constants.MOD_ID
            or value == Constants.STABLE_MOD_ID
            or value == Constants.TEST_MOD_ID then
            ids[#ids + 1] = value
        end
    end
    table.sort(ids)
    return #ids > 0 and table.concat(ids, ",") or "NONE"
end

local function phoenixArmedState(player)
    if not Core.PhoenixTransaction
        or type(Core.PhoenixTransaction.GetAuditSnapshot)
            ~= "function" then return "UNAVAILABLE" end
    local ok, audit = pcall(
        Core.PhoenixTransaction.GetAuditSnapshot, player)
    return ok and type(audit) == "table"
        and tostring(audit.state or "UNKNOWN") or "READ_FAILED"
end

local function greenActiveCastCount()
    if not Core.GreenWorldOrb
        or type(Core.GreenWorldOrb.GetDiagnostics) ~= "function" then
        return "UNAVAILABLE"
    end
    local ok, audit = pcall(Core.GreenWorldOrb.GetDiagnostics)
    return ok and type(audit) == "table"
        and tonumber(audit.activeCastCount) or "READ_FAILED"
end

local function channelGuardState()
    local guard = Core.ChannelGuard or {}
    local activeCount = activeModIdCount()
    if guard.conflict == true then
        return tostring(guard.state)
    end
    if activeCount == 0 then
        return "ACTIVE_MOD_ID_NOT_VISIBLE"
    end
    if activeCount > 1 then
        return "DUPLICATE_ACTIVE_MOD_ID"
    end
    if activeCount < 0 then
        return "ACTIVE_MOD_API_UNAVAILABLE"
    end
    return "STABLE_CHANNEL_IDENTITY_OK"
end

local function sandboxDiff()
    if Core.ConfigHealthCore and Core.ConfigHealthCore.BuildReport then
        local report = Core.ConfigHealthCore.BuildReport()
        return "compared=" .. tostring(report.compared)
            .. " different=" .. tostring(report.different)
            .. " raw_only=" .. tostring(report.raw_only)
    end
    local snapshot = Core.SandboxTuning
        and Core.SandboxTuning.GetSnapshot
        and Core.SandboxTuning.GetSnapshot() or nil
    local effective = snapshot and snapshot.values or {}
    local raw = type(SandboxVars) == "table"
        and SandboxVars.XNPDistanceRunner or nil
    if type(raw) ~= "table" then
        return "raw_unavailable effective_keys="
            .. tostring(type(effective) == "table" and "present" or "missing")
    end
    local compared = 0
    local different = 0
    local rawOnly = 0
    for key, value in pairs(raw) do
        if effective[key] ~= nil then
            compared = compared + 1
            if tostring(value) ~= tostring(effective[key]) then
                different = different + 1
            end
        else
            rawOnly = rawOnly + 1
        end
    end
    return "compared=" .. tostring(compared)
        .. " different=" .. tostring(different)
        .. " raw_only=" .. tostring(rawOnly)
end

local function candidateEventCount(candidateEvents)
    if not candidateEvents or candidateEvents == "" then return 0 end
    local count = 1
    for _ in string.gmatch(tostring(candidateEvents), ",") do
        count = count + 1
    end
    return count
end

local function registeredEventCount()
    local count = Core.events_registered == true and 5 or 0
    if Core.DeveloperTestTools
        and Core.DeveloperTestTools.registered == true then
        count = count + 1
    end
    if Core.RedGuardianMark
        and Core.RedGuardianMark.contextRegistered == true then
        count = count + 1
    end
    if Core.PurplePhoenixDamageGuard
        and Core.PurplePhoenixDamageGuard.GetAuditSnapshot then
        local ok, audit = pcall(
            Core.PurplePhoenixDamageGuard.GetAuditSnapshot)
        if ok and type(audit) == "table" and audit.registered == true then
            count = count + candidateEventCount(audit.candidate_events)
        end
    end
    return count
end

local function traitState(player)
    if not player or not Core.TraitStateCache
        or type(Core.TraitStateCache.Get) ~= "function" then
        return {}
    end
    local ok, state = pcall(Core.TraitStateCache.Get, player,
        Core.Runtime and Core.Runtime.runtimeSnapshot
            and Core.Runtime.runtimeSnapshot.hash or "DIAGNOSTIC")
    return ok and type(state) == "table" and state or {}
end

local function moduleState(loaded, owned)
    return (loaded and "LOADED" or "MISSING")
        .. " trait=" .. tostring(owned == true)
end

local function phoenixResult(player)
    if not Core.PhoenixTransaction
        or type(Core.PhoenixTransaction.GetAuditSnapshot) ~= "function" then
        return "UNAVAILABLE"
    end
    local ok, audit = pcall(
        Core.PhoenixTransaction.GetAuditSnapshot, player)
    if not ok or type(audit) ~= "table" then return "READ_FAILED" end
    return tostring(audit.state or "UNKNOWN")
        .. " last_transaction=" .. tostring(
            audit.last_transaction_id or "NONE")
end

local function yellowResult()
    if not Core.YellowAltCrowdBreakout
        or type(Core.YellowAltCrowdBreakout.GetAuditSnapshot)
            ~= "function" then
        return "UNAVAILABLE"
    end
    local ok, audit = pcall(
        Core.YellowAltCrowdBreakout.GetAuditSnapshot)
    return ok and type(audit) == "table"
        and tostring(audit.last_result or "UNKNOWN") or "READ_FAILED"
end

local function greenResult()
    if not Core.GreenWorldOrb
        or type(Core.GreenWorldOrb.GetDiagnostics) ~= "function" then
        return "UNAVAILABLE"
    end
    local ok, audit = pcall(Core.GreenWorldOrb.GetDiagnostics)
    return ok and type(audit) == "table"
        and tostring(audit.lastRequestResult or "NOT_RUN")
        or "READ_FAILED"
end

local function redResult()
    if not Core.RedGuardianMark
        or type(Core.RedGuardianMark.GetAuditSnapshot) ~= "function" then
        return "UNAVAILABLE"
    end
    local ok, audit = pcall(Core.RedGuardianMark.GetAuditSnapshot)
    return ok and type(audit) == "table"
        and tostring(audit.last_craft_result or "NOT_RUN")
        or "READ_FAILED"
end

local function footwearResult()
    if not Core.PurpleLifeStockRepair
        or type(Core.PurpleLifeStockRepair.GetAuditSnapshot)
            ~= "function" then
        return "UNAVAILABLE"
    end
    local ok, audit = pcall(
        Core.PurpleLifeStockRepair.GetAuditSnapshot)
    return ok and type(audit) == "table"
        and tostring(audit.last_result or "NOT_RUN")
        or "READ_FAILED"
end

local function phoenixGuardAudit()
    if not Core.PurplePhoenixDamageGuard
        or type(Core.PurplePhoenixDamageGuard.GetAuditSnapshot)
            ~= "function" then
        return nil
    end
    local ok, audit = pcall(
        Core.PurplePhoenixDamageGuard.GetAuditSnapshot)
    return ok and type(audit) == "table" and audit or nil
end

function Diagnostic.IsTestChannel()
    return Constants.VERSION == "2.3.0-test.1"
        and Constants.BUILD_ID == "XNP_V2_230_TEST1_MULTI_RECORD_INHERITANCE_A"
        and Constants.RELEASE_CHANNEL == "B42_20_TEST_WORKSHOP"
end

function Diagnostic.IsEnabled()
    return Diagnostic.IsTestChannel()
        and Core.SandboxTuning
        and Core.SandboxTuning.GetBoolean
        and Core.SandboxTuning.GetBoolean(
            "DeveloperTestToolsEnabled", false) == true
end

function Diagnostic.GetSnapshot(player)
    local state = traitState(player)
    local guardAudit = phoenixGuardAudit()
    local channelState = channelGuardState()
    local activeCount = activeModIdCount()
    return {
        ActualGameBuild = actualGameBuild(),
        ModVersion = Constants.VERSION,
        BuildMarker = Constants.BUILD_ID,
        Channel = Constants.RELEASE_CHANNEL,
        ModID = Constants.MOD_ID,
        YellowInit = moduleState(
            Core.TraitRegistration ~= nil
                and Core.BreakoutPush ~= nil, state.yellow),
        PurpleInit = moduleState(
            Core.PurplePhoenixTraitRegistration ~= nil
                and Core.PhoenixTransaction ~= nil, state.purple),
        GreenInit = moduleState(
            Core.GreenWorldOrb ~= nil
                and Core.GreenSkillUI ~= nil, state.green),
        RedInit = moduleState(
            Core.RedGuardianMark ~= nil
                and Core.RedMagicUI ~= nil, state.red),
        LifeStockInit = moduleState(
            Core.PurpleLifeStockController ~= nil, state.purple),
        PhoenixGuardInit = guardAudit and guardAudit.registered == true
            and "REGISTERED" or "NOT_REGISTERED",
        ChannelGuardState = channelState
            .. " active_mod_id_count=" .. tostring(activeCount),
        SandboxRawEffectiveDiff = sandboxDiff(),
        RegisteredEventCount = registeredEventCount(),
        Bandits2BridgeAvailable = guardAudit
            and tostring(guardAudit.bandits_bridge_installed == true)
            or "false",
        LastPhoenixResult = phoenixResult(player),
        LastYellowAltResult = yellowResult(),
        LastGreenCastResult = greenResult(),
        LastRedCraftResult = redResult(),
        LastFootwearRepairResult = footwearResult(),
        ActiveXnpModIds = activeXnpModIds(),
        PhoenixArmedState = phoenixArmedState(player),
        GreenActiveCastCount = greenActiveCastCount(),
    }
end

local function printSnapshot(snapshot)
    for _, field in ipairs(FIELD_ORDER) do
        print("[XNP B42.20 DIAGNOSTIC] " .. field
            .. "=" .. tostring(snapshot[field]))
    end
end

local function richText(snapshot)
    local parts = {
        "<H1>XNP B42.20 Test Build Diagnostic</H1>",
    }
    for _, field in ipairs(FIELD_ORDER) do
        parts[#parts + 1] = "<LINE><RGB:0.85,0.85,0.85>"
            .. field .. ": <RGB:1,1,1>"
            .. tostring(snapshot[field])
    end
    return table.concat(parts, "")
end

function Diagnostic.Show(player)
    if not Diagnostic.IsEnabled() then
        print("[XNP B42.20 DIAGNOSTIC] blocked=true"
            .. " reason=DEVELOPER_TEST_TOOLS_DISABLED_OR_NOT_TEST_CHANNEL")
        return false, "DIAGNOSTIC_DISABLED"
    end
    local snapshot = Diagnostic.GetSnapshot(player)
    printSnapshot(snapshot)
    local requireOk = pcall(require, "ISUI/ISModalRichText")
    if not requireOk or not ISModalRichText then
        return false, "DIAGNOSTIC_UI_UNAVAILABLE"
    end
    local ok, modal = pcall(function()
        local core = getCore()
        local width = math.min(780, core:getScreenWidth() - 40)
        local height = math.min(660, core:getScreenHeight() - 40)
        local x = math.max(20, (core:getScreenWidth() - width) / 2)
        local y = math.max(20, (core:getScreenHeight() - height) / 2)
        local window = ISModalRichText:new(
            x, y, width, height, richText(snapshot), false)
        window:initialise()
        window:addToUIManager()
        window.alwaysOnTop = true
        return window
    end)
    if not ok or not modal then
        return false, "DIAGNOSTIC_UI_CREATE_FAILED"
    end
    Diagnostic.modal = modal
    return true, "DIAGNOSTIC_SHOWN"
end

function Diagnostic.StartupSelfCheck(player)
    if Diagnostic.startupChecked then return false, "ALREADY_CHECKED" end
    Diagnostic.startupChecked = true
    local snapshot = Diagnostic.GetSnapshot(player)
    print("[XNP B42.20 SELF CHECK]"
        .. " game_build=" .. tostring(snapshot.ActualGameBuild)
        .. " mod_version=" .. tostring(snapshot.ModVersion)
        .. " build_marker=" .. tostring(snapshot.BuildMarker)
        .. " channel=" .. tostring(snapshot.Channel)
        .. " channel_guard=" .. tostring(snapshot.ChannelGuardState)
        .. " sandbox=" .. tostring(snapshot.SandboxRawEffectiveDiff)
        .. " modules=" .. tostring(snapshot.YellowInit)
        .. "/" .. tostring(snapshot.PurpleInit)
        .. "/" .. tostring(snapshot.GreenInit)
        .. "/" .. tostring(snapshot.RedInit))
    return true, snapshot
end

function Diagnostic.GetAuditSnapshot(player)
    return {
        reachable = true,
        test_only = true,
        enabled_by_default = false,
        requires_developer_test_tools = true,
        mutates_save = false,
        auto_spawns_items = false,
        auto_triggers_skills = false,
        writes_private_paths = false,
        snapshot = Diagnostic.GetSnapshot(player),
    }
end

Core.B42_20RuntimeDiagnostic = Diagnostic
return Diagnostic
