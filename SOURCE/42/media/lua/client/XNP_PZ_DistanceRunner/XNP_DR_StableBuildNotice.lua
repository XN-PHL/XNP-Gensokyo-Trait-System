local Core = XNP_PZ_DistanceRunner
local Notice = { shown = false }

function Notice.Update(player)
    if Notice.shown or not player then return false end
    local text = "XNP B42.20 stable build loaded."
    if type(getText) == "function" then
        local ok, value = pcall(getText, "UI_XNPStableBuildNotice")
        if ok and value and value ~= "UI_XNPStableBuildNotice" then
            text = tostring(value)
        end
    end
    if type(player.setHaloNote) == "function" then
        local ok = pcall(function()
            player:setHaloNote(text, 255, 210, 80, 240)
        end)
        if not ok then return false end
    end
    Notice.shown = true
    print("[XNP STABLE BUILD] one_time_notice=true"
        .. " BUILD_MARKER=XNP_V2_230_TEST1_MULTI_RECORD_INHERITANCE_A")
    return true
end

Core.StableBuildNotice = Notice
return Notice
