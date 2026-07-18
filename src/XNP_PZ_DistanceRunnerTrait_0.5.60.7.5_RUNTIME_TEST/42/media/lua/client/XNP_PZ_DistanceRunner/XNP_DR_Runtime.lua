require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Log"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixState"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixLifeGate"
require "XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState"
require "XNP_PZ_DistanceRunner/XNP_DR_Adrenaline"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaDrain"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_SprintTripImmunity"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost"
require "XNP_PZ_DistanceRunner/XNP_DR_ActivationDiagnostic"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"
require "XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerClassifier"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput"
require "XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerMapVisibility"
require "XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput"
require "XNP_PZ_DistanceRunner/XNP_DR_MinorScrapeCost"
require "XNP_PZ_DistanceRunner/XNP_DR_JogFallShockwave"
require "XNP_PZ_DistanceRunner/XNP_DR_JogBumpLaunch"
require "XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact"
require "XNP_PZ_DistanceRunner/XNP_DR_SprintTripConsequence"
require "XNP_PZ_DistanceRunner/XNP_DR_NativeTripWindow"
require "XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush"
require "XNP_PZ_DistanceRunner/XNP_DR_PreBiteJogRescue"
require "XNP_PZ_DistanceRunner/XNP_DR_PerformanceBudget"
require "XNP_PZ_DistanceRunner/XNP_DR_NearbyZombieCache"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaTrendMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaColorSafeRGBA"
require "XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState"
require "XNP_PZ_DistanceRunner/XNP_DR_EnduranceCapabilityState"
require "XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist"
require "XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery"
require "XNP_PZ_DistanceRunner/XNP_DR_PlayerSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_PerformanceScheduler"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenStructureDamage"
require "XNP_PZ_DistanceRunner/XNP_DR_TieredFoodRecovery"
require "XNP_PZ_DistanceRunner/XNP_DR_FoodReserveConversion"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixTransaction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixRevive"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixUI"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkillUI"
require "XNP_PZ_DistanceRunner/XNP_DR_RedMagicUI"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Runtime = {
    fatal = {},
    lastActiveLogged = nil,
    lastPhoenixActiveLogged = nil,
    lastGreenActiveLogged = nil,
}

local function getLocalPlayer()
    if type(getSpecificPlayer) == "function" then
        return getSpecificPlayer(0)
    end
    if type(getPlayer) == "function" then
        return getPlayer()
    end
    return nil
end

local function runPart(label, fn)
    local ok, err = pcall(fn)
    if not ok and not Runtime.fatal[label] then
        Runtime.fatal[label] = true
        Constants.Log(label .. " fatal error=" .. tostring(err))
    end
    return ok
end

function Runtime.ActivateForPlayer(player)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean and Core.SandboxTuning.GetBoolean("EnableMod", true) ~= true then
        return false
    end
    if not Config.ENABLE_MOD or not player or not Core.Trait or not Core.Trait.IsRuntimeEnabled() then
        return false
    end
    return Core.Trait.PlayerHasTrait(player)
end

local function invalidPlayerReason(player)
    if not player then
        return "invalid_player"
    end
    if type(player.isOnDeathDone) == "function" and player:isOnDeathDone() == true then return "death_done" end
    if type(player.isDead) == "function" and player:isDead() == true then return "dead_character" end
    return nil
end

local function updateLight(player)
    if Core.PerformanceBudget then
        runPart("PERFORMANCE_BUDGET", function()
            Core.PerformanceBudget.Update()
        end)
    end
    if Core.ActivationDiagnostic then
        runPart("ACTIVATION", function()
            Core.ActivationDiagnostic.Update(player, true)
        end)
    end
    if Core.Adrenaline then
        runPart("ADRENALINE", function()
            Core.Adrenaline.Update(player)
        end)
    end
    if Core.StaminaDrain then
        runPart("STAMINA", function()
            Core.StaminaDrain.Update(player)
        end)
    end
    if Core.LongMigrationStaminaAssist then
        runPart("LONG_MIGRATION_STAMINA", function()
            Core.LongMigrationStaminaAssist.Tick(player)
        end)
    end
    if Core.EnduranceBandState then
        runPart("ENDURANCE_BAND_STATE", function()
            Core.EnduranceBandState.GetStableState(player)
        end)
    end
end

local function updateThreat(player)
    if Core.NearbyZombieCache then
        runPart("NEARBY_ZOMBIE_CACHE", function()
            Core.NearbyZombieCache.Update(player)
        end)
    end
end

local function updateCritical(player)
    local vehicleApplied = false
    if Core.PerformanceScheduler and Core.VehicleVerifiedEvaluator then
        runPart("SPRINT_VEHICLE_IMPACT", function()
            vehicleApplied = Core.PerformanceScheduler.RunVehicleEvaluator(player) == true
            Core.PerformanceScheduler.VehicleSummaryTick()
        end)
    end
    if Core.NativeTripWindow then
        runPart("NATIVE_TRIP_WINDOW", function()
            Core.NativeTripWindow.Update(player)
        end)
    end
    if Core.SprintTripImmunity and not vehicleApplied then
        runPart("SPRINT_IMMUNITY", function()
            Core.SprintTripImmunity.Update(player)
        end)
    end
    local danger = nil
    if Core.DragdownDangerClassifier then
        runPart("DANGER_CLASSIFIER", function()
            danger = Core.DragdownDangerClassifier.Update(player)
        end)
    end
    if Core.PreBiteJogRescue then
        runPart("PREBITE_JOG_RESCUE", function()
            Core.PreBiteJogRescue.Update(player, danger)
        end)
    end
    if Core.BreakoutActionBus then
        runPart("ACTION_BUS", function()
            Core.BreakoutActionBus.Update(danger)
        end)
    end
    if Core.MovementIntentGate then
        runPart("MOVEMENT_INTENT_GATE", function()
            Core.MovementIntentGate.SummaryTick()
        end)
    end
    if Core.DragdownDangerBreakout then
        runPart("DRAGDOWN_DANGER_BREAKOUT", function()
            Core.DragdownDangerBreakout.Update(player)
        end)
    end
    if Core.EmergencyBreakout then
        runPart("EMERGENCY_BREAKOUT", function()
            Core.EmergencyBreakout.Update(player)
        end)
    end
    if Core.FallRecoveryInput then
        runPart("FALL_RECOVERY_INPUT", function()
            Core.FallRecoveryInput.Update(player)
        end)
    end
    if Core.JogBumpLaunch then
        runPart("JOG_BUMP_LAUNCH", function()
            Core.JogBumpLaunch.Update(player)
            Core.JogBumpLaunch.SummaryTick()
        end)
    end
    if Core.ImpactQuotaMeter then
        runPart("IMPACT_QUOTA", function()
            Core.ImpactQuotaMeter.SummaryTick()
        end)
    end
    if Core.BreakoutPush then
        runPart("BREAKOUT_PUSH", function()
            Core.BreakoutPush.Update(player)
        end)
    end
end

function Runtime.Update()
    local player = getLocalPlayer()
    -- A nil player cannot own a trait. Phoenix never receives a post-death
    -- threshold opportunity; projectile interception happens at the event edge.
    if not player then return false end
    if Core.PerformanceScheduler and Core.PerformanceScheduler.AdvanceActiveSecondTasks then
        Core.PerformanceScheduler.AdvanceActiveSecondTasks(player)
    end

    if Core.MasterEffectState then
        Core.MasterEffectState.Load(player)
    end

    -- Red Guardian is trait-independent. Its single registered game-hour task
    -- is dispatched here through the existing central scheduler/event route.
    if Core.PerformanceScheduler then
        runPart("CENTRAL_GAME_HOUR_TASKS", function()
            Core.PerformanceScheduler.DispatchGameHourTasks(player)
        end)
    end

    -- The world-map visibility query is internally capped at 4 Hz. Panels are
    -- retained in place and only their visibility/mouse consumption changes.
    if Core.RoundMarkerMapVisibility then
        runPart("ROUND_MARKER_MAP_VISIBILITY", function()
            Core.RoundMarkerMapVisibility.Update(false)
        end)
    end

    -- Red Guardian grant recovery retries after the native trait and inventory
    -- collections finish initialization. The transaction is version-gated.
    local redSystemEnabled = not Core.SandboxTuning or Core.SandboxTuning.GetBoolean("EnableRedTraitSystem", true) == true
    if Core.RedGuardianMark and redSystemEnabled then
        runPart("RED_GUARDIAN_STARTER_GRANT", function()
            Core.RedGuardianMark.UpdateStarterGrant(player)
        end)
    end
    -- Red Magic UI performs inventory work at no more than 2 Hz and keeps one
    -- persistent panel between refreshes.
    if Core.RedMagicUI and redSystemEnabled then
        runPart("RED_MAGIC_UI_LOW_FREQUENCY", function()
            Core.RedMagicUI.Update(player, false)
        end)
    elseif Core.RedMagicUI then
        Core.RedMagicUI.Cleanup("RED_SYSTEM_DISABLED")
    end

    -- Evaluate the three native trait objects independently. The compatibility
    -- trait keeps its historical full ID and owns the original green ultimate UI.
    local active = Runtime.ActivateForPlayer(player)
    local modEnabled = Core.SandboxTuning == nil or Core.SandboxTuning.GetBoolean == nil or Core.SandboxTuning.GetBoolean("EnableMod", true) == true
    local yellowSystemEnabled = modEnabled and (not Core.SandboxTuning or Core.SandboxTuning.GetBoolean("EnableYellowTraitSystem", true) == true)
    local purpleSystemEnabled = modEnabled and (not Core.SandboxTuning or Core.SandboxTuning.GetBoolean("EnablePurplePhoenixSystem", true) == true)
    local greenSystemEnabled = modEnabled and (not Core.SandboxTuning or Core.SandboxTuning.GetBoolean("EnableGreenTraitSystem", true) == true)
    local phoenixActive = purpleSystemEnabled and Core.PurplePhoenixTrait and Core.PurplePhoenixTrait.PlayerHasTrait(player) == true
    local greenActive = greenSystemEnabled and Core.ExtraTraits and Core.ExtraTraits.PlayerHas(player, "GREEN") == true
    active = yellowSystemEnabled and active
    if Runtime.lastActiveLogged ~= active then
        Runtime.lastActiveLogged = active
        print("[XNP RUNTIME] player_trait_active=" .. tostring(active) .. (active and "" or " reason=PLAYER_DOES_NOT_HAVE_TRAIT"))
    end
    if Runtime.lastPhoenixActiveLogged ~= phoenixActive then
        Runtime.lastPhoenixActiveLogged = phoenixActive
        print("[XNP PHOENIX] player_trait_active=" .. tostring(phoenixActive))
    end
    if Runtime.lastGreenActiveLogged ~= greenActive then
        Runtime.lastGreenActiveLogged = greenActive
        print("[XNP GREEN ULTIMATE] player_trait_active=" .. tostring(greenActive))
    end

    if Core.GreenWorldOrb then
        runPart("GREEN_WORLD_ORB", function() Core.GreenWorldOrb.Update(player) end)
    end
    if Core.GreenStructureDamage then
        runPart("GREEN_STRUCTURE_DAMAGE", function() Core.GreenStructureDamage.Update(player) end)
    end

    if not active and not phoenixActive and not greenActive then
        if Core.Adrenaline then
            Core.Adrenaline.Clear("trait_missing")
        end
        return false
    end

    local invalid_reason = invalidPlayerReason(player)
    if invalid_reason then
        if Core.Adrenaline then Core.Adrenaline.Clear(invalid_reason) end
        if Core.PhoenixLifeGate then Core.PhoenixLifeGate.MarkDead(player, invalid_reason) end
        if Core.PurplePhoenixDamageGuard then Core.PurplePhoenixDamageGuard.CancelForDeath(player, invalid_reason) end
        if Core.PurplePhoenixRevive then Core.PurplePhoenixRevive.CancelPendingForDeath(player, invalid_reason) end
        if Core.PurplePhoenixUI then Core.PurplePhoenixUI.Cleanup(invalid_reason) end
        return false
    end

    local phoenixLiving = false
    if phoenixActive and Core.PhoenixLifeGate then
        phoenixLiving = Core.PhoenixLifeGate.IsLivingPlayer(player) == true
        if not phoenixLiving then
            Core.PurplePhoenixRevive.Cleanup(player, "LIVING_GATE_REJECTED")
            if Core.PurplePhoenixUI then Core.PurplePhoenixUI.Cleanup("LIVING_GATE_REJECTED") end
        end
    end

    -- Fall landing is evaluated every player update inside the one existing
    -- handler. This pre-landing edge performs no world scan.
    if phoenixActive and phoenixLiving and Core.PhoenixTransaction then
        runPart("PHOENIX_FALL_PREDEATH_EDGE", function()
            Core.PhoenixTransaction.UpdateFallPredeathEdge(player)
        end)
    end

    -- One scheduler instance preserves the established yellow/Phoenix budget.
    -- Green active/structure lanes run above; Red Guardian uses inventory and
    -- one central game-hour task.
    local schedule = Core.PerformanceScheduler and Core.PerformanceScheduler.Begin(player) or {
        light = true,
        threat = true,
        critical = true,
        food = true,
        ui = true,
        sandbox = true,
    }

    if schedule.sandbox and Core.SandboxTuning then
        runPart("SANDBOX_TUNING", function()
            Core.SandboxTuning.Tick()
        end)
    end
    if schedule.sandbox and Core.PurplePhoenixConfig then
        runPart("PURPLE_PHOENIX_CONFIG", function()
            Core.PurplePhoenixConfig.Refresh()
        end)
    end
    if phoenixActive and phoenixLiving and Core.PurplePhoenixRevive then
        if schedule.light or schedule.critical then
            runPart("PURPLE_PHOENIX_TRIGGER", function()
                Core.PurplePhoenixRevive.PreUpdate(player)
                Core.PurplePhoenixState.UpdateRecovery(player, false)
            end)
        end
    end
    if schedule.ui then
        if active and Core.StatusIconUI then
            runPart("STATUS_ICON_MINIMAL", function() Core.StatusIconUI.Update(player) end)
        elseif Core.StatusIconUI then
            Core.StatusIconUI.Cleanup("yellow_trait_missing")
        end
        if phoenixActive and phoenixLiving and Core.PurplePhoenixUI then
            runPart("PURPLE_PHOENIX_UI", function() Core.PurplePhoenixUI.Update(player) end)
        elseif Core.PurplePhoenixUI then
            Core.PurplePhoenixUI.Cleanup("PHOENIX_NOT_LIVING_OR_TRAIT_MISSING")
        end
        if Core.GreenSkillUI then
            runPart("GREEN_SKILL_UI", function() Core.GreenSkillUI.Update(player) end)
        end
    end
    -- A non-yellow character stops after its independent Phoenix/green lanes.
    -- No Distance Runner stamina, impact, food, or melee route executes.
    if not active then
        if Core.LogThrottle then Core.LogThrottle.SummaryTick() end
        if Core.PerformanceScheduler then Core.PerformanceScheduler.SummaryTick() end
        return true
    end

    -- This compatibility gate now controls yellow Distance Runner only. It is
    -- deliberately placed after every Phoenix route.
    if Core.MasterEffectState and Core.MasterEffectState.IsEnabled(player) ~= true then
        Core.MasterEffectState.EnsureDisabledCleanup(player)
        return false
    end

    if Core.ActivationDiagnostic and schedule.light then
        runPart("ACTIVATION_STATUS", function()
            Core.ActivationDiagnostic.Update(player, active)
        end)
    end

    if schedule.light then
        updateLight(player)
    end
    if schedule.threat then
        updateThreat(player)
    end
    if schedule.critical or schedule.impact then
        updateCritical(player)
    end
    if schedule.food and Core.TieredFoodRecovery then
        runPart("TIERED_FOOD_RECOVERY", function()
            Core.TieredFoodRecovery.Tick(player, schedule.snapshot)
        end)
    end
    -- StatusIconUI is updated before the master gate so right-click OFF remains visible.
    if Core.LogThrottle then
        Core.LogThrottle.SummaryTick()
    end
    if Core.PerformanceScheduler then
        Core.PerformanceScheduler.SummaryTick()
    end
    return true
end

function Runtime.Cleanup(reason, explicitPlayer)
    local player = explicitPlayer or getLocalPlayer()
    if Core.PerformanceScheduler and Core.PerformanceScheduler.ReleasePlayer then
        Core.PerformanceScheduler.ReleasePlayer(player)
    end
    if Core.CentralWorldQuery then Core.CentralWorldQuery.Clear() end
    if Core.Adrenaline then
        Core.Adrenaline.Clear(reason or "cleanup")
    end
    if Core.StaminaDrain then
        Core.StaminaDrain.Cleanup(player, reason or "cleanup")
    end
    if Core.LongMigrationStaminaAssist then
        Core.LongMigrationStaminaAssist.Cleanup(reason or "cleanup")
    end
    if Core.FoodReserveConversion then
        Core.FoodReserveConversion.Cleanup(reason or "cleanup")
    end
    if Core.TieredFoodRecovery then
        Core.TieredFoodRecovery.Cleanup(reason or "cleanup")
    end
    if Core.PreBiteJogRescue then
        Core.PreBiteJogRescue.Cleanup(reason or "cleanup")
    end
    if Core.StaminaTrendMeter then
        Core.StaminaTrendMeter.Cleanup()
    end
    if Core.EnduranceBandState then
        Core.EnduranceBandState.Reset(player)
    elseif Core.EnduranceCapabilityState then
        Core.EnduranceCapabilityState.Reset(player)
    end
    if Core.NearbyZombieCache then
        Core.NearbyZombieCache.Cleanup(reason or "cleanup")
    end
    if Core.BreakoutPush then
        Core.BreakoutPush.Cleanup(reason or "cleanup")
    end
    if Core.NativeTripWindow then
        Core.NativeTripWindow.Cleanup(reason or "cleanup")
    end
    if Core.SprintTripImmunity then
        Core.SprintTripImmunity.Cleanup(reason or "cleanup")
    end
    if Core.DragdownDangerBreakout then
        Core.DragdownDangerBreakout.Cleanup(reason or "cleanup")
    end
    if Core.DragdownDangerClassifier then
        Core.DragdownDangerClassifier.Cleanup(reason or "cleanup")
    end
    if Core.BreakoutActionBus then
        Core.BreakoutActionBus.Cleanup(reason or "cleanup")
    end
    if Core.StatusIconUI then
        Core.StatusIconUI.Cleanup(reason or "cleanup")
    end
    if Core.YellowRedSignals then
        Core.YellowRedSignals.Cleanup(reason or "cleanup")
    end
    if Core.PurplePhoenixRevive then
        Core.PurplePhoenixRevive.Cleanup(player, reason or "cleanup")
    end
    if Core.GreenWorldOrb then
        Core.GreenWorldOrb.Shutdown(reason or "cleanup")
    end
    if Core.GreenWhiteAction then
        Core.GreenWhiteAction.Cleanup(player)
    end
    if Core.GreenStructureDamage then
        Core.GreenStructureDamage.Cleanup(reason or "cleanup")
    end
    if Core.PurplePhoenixUI then
        Core.PurplePhoenixUI.Cleanup(reason or "cleanup")
    end
    if Core.GreenSkillUI then
        Core.GreenSkillUI.Cleanup(reason or "cleanup")
    end
    if Core.RedMagicUI then
        Core.RedMagicUI.Cleanup(reason or "cleanup")
    end
    if Core.RedGuardianMark then
        Core.RedGuardianMark.Cleanup(reason or "cleanup")
    end
    if Core.RoundMarkerTooltip then
        Core.RoundMarkerTooltip.Cleanup(reason or "cleanup")
    end
    if Core.RoundMarkerMapVisibility then
        Core.RoundMarkerMapVisibility.Cleanup(reason or "cleanup")
    end
    if Core.PerformanceScheduler and Core.PerformanceScheduler.ClearActiveSecondTasks then
        Core.PerformanceScheduler.ClearActiveSecondTasks(reason or "cleanup")
    end
end

if not Core.runtime_056075_startup_logged then
    Core.runtime_056075_startup_logged = true
    print("[XNP 0.5.60.7.5 STARTUP] runtime_entry_loaded=true")
end

Core.Runtime = Runtime
return Runtime
