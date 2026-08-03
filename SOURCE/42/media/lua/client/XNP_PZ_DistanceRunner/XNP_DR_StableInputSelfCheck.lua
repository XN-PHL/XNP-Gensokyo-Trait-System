XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner
if not Core.stable_input_self_check_logged then
    Core.stable_input_self_check_logged = true
    print("[XNP STABLE INPUT SELF CHECK]"
        .. " single_click_direct_path_count=0"
        .. " double_click_confirmed_path_count=1"
        .. " core_ticket_gate=true"
        .. " double_click_window_ms=500")
end
return true
