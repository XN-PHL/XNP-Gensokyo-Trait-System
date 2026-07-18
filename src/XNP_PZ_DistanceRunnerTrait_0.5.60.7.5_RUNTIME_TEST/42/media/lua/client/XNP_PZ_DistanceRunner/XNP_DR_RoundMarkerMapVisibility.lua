XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local Visibility = {
    hidden = false,
    initialized = false,
    nextQueryMs = 0,
    queryIntervalMs = 250,
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function readWorldMapVisible()
    if not ISWorldMap_instance or type(ISWorldMap_instance.isVisible) ~= "function" then return false end
    local ok, visible = pcall(function() return ISWorldMap_instance:isVisible() end)
    return ok and visible == true
end

local function publish(hidden)
    for _, moduleName in ipairs({ "StatusIconUI", "PurplePhoenixUI", "GreenSkillUI", "RedMagicUI" }) do
        local module = Core[moduleName]
        if module and type(module.SetMapHidden) == "function" then module.SetMapHidden(hidden) end
    end
    if hidden and Core.RoundMarkerTooltip then Core.RoundMarkerTooltip.Hide("WORLD_MAP_VISIBLE") end
end

function Visibility.Update(force)
    local now = nowMs()
    if Core.SandboxTuning then
        Visibility.queryIntervalMs = Core.SandboxTuning.GetNumber("MarkerUpdateIntervalFrames", 15, 1, 120) * (1000 / 60)
    end
    if force ~= true and now < Visibility.nextQueryMs then return false end
    Visibility.nextQueryMs = now + Visibility.queryIntervalMs
    local hidden = (not Core.SandboxTuning or Core.SandboxTuning.GetBoolean("HideMarkersWithMap", true))
        and readWorldMapVisible()
    if not Visibility.initialized or hidden ~= Visibility.hidden then
        Visibility.initialized = true
        Visibility.hidden = hidden
        publish(hidden)
        print("[XNP ROUND MAP VISIBILITY] map_visible=" .. tostring(hidden) .. " markers_hidden=" .. tostring(hidden))
    end
    return true
end

function Visibility.IsMapHidden()
    return Visibility.hidden == true
end

function Visibility.Cleanup(reason)
    Visibility.hidden = false
    Visibility.initialized = false
    Visibility.nextQueryMs = 0
    publish(false)
end

Core.RoundMarkerMapVisibility = Visibility
return Visibility
