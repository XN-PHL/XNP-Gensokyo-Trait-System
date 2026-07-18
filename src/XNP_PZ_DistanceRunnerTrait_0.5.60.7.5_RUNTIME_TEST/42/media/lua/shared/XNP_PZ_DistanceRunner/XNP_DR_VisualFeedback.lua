require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local VisualFeedback = {
    logged = false,
}

local function logDisabledOnce()
    if not VisualFeedback.logged then
        VisualFeedback.logged = true
        print("[XNP FEEDBACK] method=" .. Constants.VISUAL_FEEDBACK_METHOD)
    end
end

function VisualFeedback.ShowOnce(player, key, text)
    logDisabledOnce()
end

logDisabledOnce()

Core.VisualFeedback = VisualFeedback
return VisualFeedback
