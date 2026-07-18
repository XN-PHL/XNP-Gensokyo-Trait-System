require "ISUI/ISToolTip"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local Tooltip = {
    instance = nil,
    owner = nil,
    name = nil,
    description = nil,
}

local function ensureTooltip()
    if Tooltip.instance then return Tooltip.instance end
    local tip = ISToolTip:new()
    tip:initialise()
    tip:addToUIManager()
    tip:setVisible(false)
    if type(tip.setAlwaysOnTop) == "function" then tip:setAlwaysOnTop(true) end
    if type(tip.setConsumeMouseEvents) == "function" then tip:setConsumeMouseEvents(false) end
    Tooltip.instance = tip
    print("[XNP ROUND TOOLTIP] shared_instance_created=true")
    return tip
end

function Tooltip.Show(owner, name, description)
    if not owner or (Core.RoundMarkerMapVisibility and Core.RoundMarkerMapVisibility.IsMapHidden()) then
        return Tooltip.Hide("MAP_OR_OWNER")
    end
    local tip = ensureTooltip()
    Tooltip.owner = owner
    Tooltip.name = tostring(name or "")
    Tooltip.description = tostring(description or "")
    if type(tip.setOwner) == "function" then tip:setOwner(owner) end
    if type(tip.setName) == "function" then tip:setName(Tooltip.name) else tip.name = Tooltip.name end
    tip.description = Tooltip.description
    tip:setX(owner:getAbsoluteX() + owner:getWidth() + 8)
    tip:setY(owner:getAbsoluteY())
    tip:setVisible(true)
    return true
end

function Tooltip.Refresh(owner, name, description)
    if Tooltip.owner ~= owner then return false end
    return Tooltip.Show(owner, name, description)
end

function Tooltip.IsOwner(owner)
    return Tooltip.owner == owner
end

function Tooltip.Hide(reason)
    if Tooltip.instance then Tooltip.instance:setVisible(false) end
    Tooltip.owner = nil
    Tooltip.name = nil
    Tooltip.description = nil
    return true
end

function Tooltip.Cleanup(reason)
    Tooltip.Hide(reason)
    if Tooltip.instance then
        Tooltip.instance:removeFromUIManager()
        Tooltip.instance = nil
    end
end

Core.RoundMarkerTooltip = Tooltip
return Tooltip
