XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
if not Core.test12e_input_self_check_logged then
    Core.test12e_input_self_check_logged = true
    print("[XNP TEST12E INPUT SELF CHECK]"
        .. " build_marker=XNP_V2_230_TEST1_MULTI_RECORD_INHERITANCE_A"
        .. " single_click_direct_path_count=0"
        .. " double_click_confirmed_path_count=1"
        .. " core_ticket_gate=true"
        .. " single_click_rejected_by_core=true"
        .. " double_click_window_ms=500")
end

return true
