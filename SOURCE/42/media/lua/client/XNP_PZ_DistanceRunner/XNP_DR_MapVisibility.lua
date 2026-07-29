XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local Visibility = {
    gameplayVisible = false,
    initialized = false,
    hideWithMap = true,
    closeHoldUntilMs = 0,
    transitionHoldMs = 50,
    projectionEpoch = 0,
    lastReason = "NOT_INITIALIZED",
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function invokeBoolean(object, method)
    if not object or type(object[method]) ~= "function" then return nil end
    local ok, value = pcall(function() return object[method](object) end)
    if not ok then return nil end
    return value == true
end

local function visible(object)
    local result = invokeBoolean(object, "isVisible")
    if result ~= nil then return result end
    return object and object.visible == true or false
end

local function worldMapVisible()
    return visible(ISWorldMap_instance)
end

local function minimapCandidate(playerIndex)
    if not ISMiniMap then return nil end
    if ISMiniMap.instances then
        return ISMiniMap.instances[(tonumber(playerIndex) or 0) + 1]
            or ISMiniMap.instances[tonumber(playerIndex) or 0]
    end
    return ISMiniMap.instance
end

local function minimapExpanded(playerIndex)
    local minimap = minimapCandidate(playerIndex)
    if not minimap or visible(minimap) ~= true then return false end
    for _, method in ipairs({ "isExpanded", "getIsExpanded", "isMaximized", "getIsMaximized" }) do
        local value = invokeBoolean(minimap, method)
        if value ~= nil then return value end
    end
    return minimap.expanded == true or minimap.maximized == true
        or minimap.isExpanded == true or minimap.isMaximized == true
end

local function gamePaused()
    if type(isGamePaused) ~= "function" then return false end
    local ok, result = pcall(isGamePaused)
    return ok and result == true
end

local function playerAvailable(playerIndex)
    if type(getSpecificPlayer) == "function" then
        local ok, player = pcall(getSpecificPlayer, tonumber(playerIndex) or 0)
        if ok then return player ~= nil end
    end
    if type(getPlayer) == "function" then
        local ok, player = pcall(getPlayer)
        if ok then return player ~= nil end
    end
    return false
end

local function rawBlocked(playerIndex)
    if not playerAvailable(playerIndex) then return true, "MAIN_MENU_OR_PLAYER_UNAVAILABLE" end
    if worldMapVisible() then return true, "WORLD_MAP_VISIBLE" end
    if minimapExpanded(playerIndex) then return true, "MINIMAP_EXPANDED" end
    if gamePaused() then return true, "PAUSE_OR_TOP_LEVEL_OVERLAY" end
    return false, "WORLD_GAMEPLAY_VISIBLE"
end

local function publish(hidden)
    for _, moduleName in ipairs({
        "StatusIconUI", "PurplePhoenixUI", "GreenSkillUI", "RedMagicUI", "GreenWorldOrb"
    }) do
        local module = Core[moduleName]
        if module and type(module.SetMapHidden) == "function" then
            pcall(module.SetMapHidden, hidden)
        end
    end
    if hidden and Core.RoundMarkerTooltip then
        pcall(Core.RoundMarkerTooltip.Hide, "WORLD_GAMEPLAY_OCCLUDED")
    end
end

local function refreshOption()
    if Core.SandboxTuning and type(Core.SandboxTuning.GetBoolean) == "function" then
        Visibility.hideWithMap = Core.SandboxTuning.GetBoolean("HideMarkersWithMap", true)
    else
        Visibility.hideWithMap = true
    end
end

function Visibility.Update(force, playerIndex)
    playerIndex = math.max(0, math.floor(tonumber(playerIndex) or 0))
    if force == true or Visibility.initialized ~= true then refreshOption() end
    local currentMs = nowMs()
    local blocked, reason = rawBlocked(playerIndex)
    local mapOverlay = reason == "WORLD_MAP_VISIBLE" or reason == "MINIMAP_EXPANDED"
    if mapOverlay then blocked = Visibility.hideWithMap == true end
    if blocked then
        Visibility.closeHoldUntilMs = currentMs + Visibility.transitionHoldMs
    elseif currentMs < Visibility.closeHoldUntilMs then
        blocked, reason = true, "MAP_CLOSE_TRANSITION_HOLD"
    end
    local gameplayVisible = not blocked
    if Visibility.initialized ~= true or gameplayVisible ~= Visibility.gameplayVisible then
        local wasVisible = Visibility.gameplayVisible
        Visibility.initialized = true
        Visibility.gameplayVisible = gameplayVisible
        Visibility.lastReason = reason
        if gameplayVisible and not wasVisible then
            Visibility.projectionEpoch = Visibility.projectionEpoch + 1
        end
        publish(not gameplayVisible)
        print("[XNP MAP VISIBILITY] gameplay_visible=" .. tostring(gameplayVisible)
            .. " reason=" .. tostring(reason)
            .. " projection_epoch=" .. tostring(Visibility.projectionEpoch)
            .. " casts_deleted=0 lifetime_reset=0")
    else
        Visibility.lastReason = reason
    end
    return gameplayVisible
end

function Visibility.IsWorldGameplayVisible(playerIndex)
    if Visibility.initialized ~= true then Visibility.Update(true, playerIndex) end
    return Visibility.gameplayVisible == true
end

function Visibility.IsMapHidden(playerIndex)
    return not Visibility.IsWorldGameplayVisible(playerIndex)
end

function Visibility.GetProjectionEpoch()
    return Visibility.projectionEpoch
end

function Visibility.GetReason()
    return Visibility.lastReason
end

function Visibility.Cleanup(reason)
    Visibility.gameplayVisible = false
    Visibility.initialized = false
    Visibility.closeHoldUntilMs = 0
    Visibility.lastReason = reason or "CLEANUP"
    publish(true)
end

Core.MapVisibility = Visibility
return Visibility
