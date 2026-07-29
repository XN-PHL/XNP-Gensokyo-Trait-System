-- 0.5.60.7.20 compatibility entry: one purple panel owns both rendering and input.
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_UI"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner
local PurpleUI = Core.PurpleLifeStockUI

Core.PurplePhoenixUI = PurpleUI
Core.PurpleLifeStockUI = PurpleUI

print("[XNP PURPLE UI COMPAT] duplicate_panel_removed=true alias_same_object="
    .. tostring(Core.PurplePhoenixUI == Core.PurpleLifeStockUI))
return PurpleUI
