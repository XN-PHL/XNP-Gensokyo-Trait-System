require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local MoodleStatus = {
    logged = false,
}

function MoodleStatus.Register()
    if MoodleStatus.logged then
        return
    end
    MoodleStatus.logged = true
    print("[XNP MOODLE] status=" .. Constants.RIGHT_TOP_ICON_STATUS)
end

MoodleStatus.Register()

Core.MoodleStatus = MoodleStatus
return MoodleStatus
