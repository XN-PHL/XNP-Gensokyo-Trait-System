require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_StableInputSelfCheck"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_VFXManager"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Log"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_SubsystemGuard"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Controller"
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
require "XNP_PZ_DistanceRunner/XNP_DR_YellowAltCrowdBreakout"
require "XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_MapVisibility"
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
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixRevive"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_UI"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_TraitStateCache"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkillUI"
require "XNP_PZ_DistanceRunner/XNP_DR_RedMagicUI"
require "XNP_PZ_DistanceRunner/XNP_DR_RedPhysicalLoad"
require "XNP_PZ_DistanceRunner/XNP_DR_RedCraftFeedback"
require "XNP_PZ_DistanceRunner/XNP_DR_TestBuildNotice"
require "XNP_PZ_DistanceRunner/XNP_DR_B42_20_RuntimeDiagnostic"
require "XNP_PZ_DistanceRunner/XNP_DR_ConfigHealthUI"
require "XNP_PZ_DistanceRunner/XNP_DR_DeveloperTestTools"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Runtime = {
    lastActiveLogged = nil,
    lastPhoenixActiveLogged = nil,
    lastGreenActiveLogged = nil,
    runtimeSnapshot = {
        enableMod = true,
        yellow = true,
        purple = true,
        green = true,
        red = true,
        hash = "BOOT_DEFAULTS",
    },
    runtimeSnapshotLoaded = false,
    identityShutdownDone = false,
}

function Runtime.InvalidateTraitState(reason)
    if Core.TraitStateCache then
        return Core.TraitStateCache.Invalidate(reason or "RUNTIME_INVALIDATION")
    end
    return false
end

function Runtime.RebuildTraitUI(player, reason, state)
    local cleanupReason = reason or "TRAIT_UI_REBUILD"
    if Core.StatusIconUI then Core.StatusIconUI.Cleanup(cleanupReason) end
    if Core.PurplePhoenixUI then Core.PurplePhoenixUI.Cleanup(cleanupReason) end
    if Core.GreenSkillUI then Core.GreenSkillUI.Cleanup(cleanupReason) end
    if Core.RedMagicUI then Core.RedMagicUI.Cleanup(cleanupReason) end
    for _, module in ipairs({
        Core.StatusIconUI, Core.PurplePhoenixUI,
        Core.GreenSkillUI, Core.RedMagicUI,
    }) do
        if module and module.panel
            and type(module.panel.setConsumeMouseEvents) == "function" then
            module.panel:setConsumeMouseEvents(false)
        end
    end

    state = state or (Core.TraitStateCache
        and select(1, Core.TraitStateCache.Get(
            player, Runtime.runtimeSnapshot.hash))) or {
        yellow = false, purple = false, green = false, red = false,
        count = 0,
    }
    local count = 0
    local flags = Runtime.runtimeSnapshot
    local modEnabled = flags.enableMod == true
    if player and modEnabled and flags.yellow == true and state.yellow
        and Core.StatusIconUI and Core.StatusIconUI.Update(player) == true then
        count = count + 1
    end
    if player and modEnabled and flags.purple == true and state.purple
        and Core.PurplePhoenixUI
        and Core.PurplePhoenixUI.Update(player, true) == true then
        count = count + 1
    end
    if player and modEnabled and flags.green == true and state.green
        and Core.GreenSkillUI and Core.GreenSkillUI.Update(player) == true then
        count = count + 1
    end
    if player and flags.red == true and state.red
        and Core.RedMagicUI and Core.RedMagicUI.Update(player, true) == true then
        count = count + 1
    end
    if Core.TraitStateCache then
        Core.TraitStateCache.MarkUiRebuild({ count = count }, cleanupReason)
    end
    return count
end

function Runtime.RefreshTraitState(player, reason, rebuild)
    if reason and Core.PurpleLifeStockSnapshot
        and type(Core.PurpleLifeStockSnapshot.RepairTraitMultiplicity) == "function" then
        local repairOk, repaired, repairReason = pcall(
            Core.PurpleLifeStockSnapshot.RepairTraitMultiplicity, player, reason)
        if not repairOk or repaired ~= true then
            print("[XNP TRAIT MULTIPLICITY REPAIR] result=FAILED reason="
                .. tostring(repairOk and repairReason or repaired))
        end
    end
    if reason then Runtime.InvalidateTraitState(reason) end
    if not Core.TraitStateCache then
        return nil, false, false
    end
    local state, changed, scanned = Core.TraitStateCache.Get(
        player, Runtime.runtimeSnapshot.hash)
    if rebuild ~= false and (rebuild == true or changed == true) then
        Runtime.RebuildTraitUI(player, reason or "TRAIT_STATE_CHANGED", state)
    end
    return state, changed, scanned
end

function Runtime.GetTraitScanAudit()
    return Core.TraitStateCache and Core.TraitStateCache.GetAuditSnapshot() or nil
end

local function subsystemForLabel(label)
    label = tostring(label or "")
    if string.find(label, "^PURPLE") or string.find(label, "^PHOENIX")
        or string.find(label, "^LIFE_STOCK") then
        return "PURPLE"
    end
    if string.find(label, "^GREEN") then return "GREEN" end
    if string.find(label, "^RED") then return "RED" end
    if label == "PERFORMANCE_BUDGET" or label == "NEARBY_ZOMBIE_CACHE"
        or label == "CENTRAL_GAME_HOUR_TASKS" or label == "SANDBOX_TUNING"
        or label == "ROUND_MARKER_MAP_VISIBILITY" then
        return "CORE"
    end
    return "YELLOW"
end

local function getLocalPlayer()
    return Core.CanonicalPlayerIdentity.GetPlayer(false)
end

-- Keep protected calls at transaction and high-risk world/API boundaries.
-- The OnPlayerUpdate adapter already protects the whole frame, so wrapping
-- every pure internal dispatch here would add dozens of pcalls per frame.
local HIGH_RISK_BOUNDARY = {
    PURPLE_BACKUP_CONTROLLER = true,
    SPRINT_VEHICLE_IMPACT = true,
    PREBITE_JOG_RESCUE = true,
    DRAGDOWN_DANGER_BREAKOUT = true,
    EMERGENCY_BREAKOUT = true,
    BREAKOUT_PUSH = true,
    RED_GUARDIAN_STARTER_GRANT = true,
    RED_MAGIC_UI_LOW_FREQUENCY = true,
    RED_PHYSICAL_LOAD = true,
    GREEN_WORLD_ORB = true,
    GREEN_STRUCTURE_DAMAGE = true,
}

local function runPart(label, fn)
    if HIGH_RISK_BOUNDARY[label] then
        local ok = Core.SubsystemGuard.Execute(subsystemForLabel(label), label, fn)
        return ok == true
    end
    fn()
    return true
end

function Runtime.RefreshRuntimeSnapshot()
    local oldHash = Runtime.runtimeSnapshot and Runtime.runtimeSnapshot.hash or nil
    local snapshot = Core.SandboxTuning and Core.SandboxTuning.GetSnapshot
        and Core.SandboxTuning.GetSnapshot() or nil
    local values = snapshot and snapshot.values or {}
    Runtime.runtimeSnapshot = {
        enableMod = values.EnableMod ~= false,
        yellow = values.EnableYellowTraitSystem ~= false,
        purple = values.EnablePurplePhoenixSystem ~= false,
        green = values.EnableGreenTraitSystem ~= false,
        red = values.EnableRedTraitSystem ~= false,
        hash = snapshot and snapshot.hash or "NO_SANDBOX_SNAPSHOT",
    }
    if Runtime.runtimeSnapshotLoaded == true and oldHash
        and oldHash ~= Runtime.runtimeSnapshot.hash then
        Runtime.InvalidateTraitState("SANDBOX_HASH_CHANGED")
    end
    Runtime.runtimeSnapshotLoaded = true
    return Runtime.runtimeSnapshot
end

function Runtime.ActivateForPlayer(player)
    local valid = Core.CanonicalPlayerIdentity.Validate(player, true) == true
    if not valid then return false end
    Runtime.identityShutdownDone = false
    local flags = Runtime.runtimeSnapshot
    if flags.enableMod ~= true then return false end
    if not Config.ENABLE_MOD or not player or not Core.Trait
        or not Core.Trait.IsRuntimeEnabled() then
        return false
    end
    local state = Runtime.RefreshTraitState(player, nil, false)
    return state and state.yellow == true or false
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
    if Core.YellowAltCrowdBreakout then
        runPart("YELLOW_ALT_CROWD_BREAKOUT", function()
            Core.YellowAltCrowdBreakout.Update(player)
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

function Runtime.Update(eventPlayer)
    if Runtime.runtimeSnapshotLoaded ~= true then Runtime.RefreshRuntimeSnapshot() end
    if eventPlayer and Core.CanonicalPlayerIdentity and Core.CanonicalPlayerIdentity.ObserveSuccessor then
        local confirmed = Core.CanonicalPlayerIdentity.ObserveSuccessor(
            eventPlayer, "POST_DEATH_NEW_CHARACTER") == true
        if confirmed and Core.Bootstrap and Core.Bootstrap.OnSuccessorConfirmed then
            Core.Bootstrap.OnSuccessorConfirmed(eventPlayer)
        end
    end
    local player, identityReason = Core.CanonicalPlayerIdentity.GetPlayer(true)
    if player and Core.TestBuildNotice then
        runPart("TEST_BUILD_NOTICE", function()
            Core.TestBuildNotice.Update(player)
        end)
    end
    if eventPlayer and player and eventPlayer ~= player then return false end
    if not player then
        local snapshot = Core.CanonicalPlayerIdentity.GetAuditSnapshot()
        local candidate = eventPlayer or snapshot.player_ref
        local deathReason = invalidPlayerReason(candidate)
        if deathReason and snapshot.player_ref == candidate
            and Runtime.identityShutdownDone ~= true then
            Runtime.identityShutdownDone = true
            if Core.PhoenixTransaction then
                Core.PhoenixTransaction.OnDeath(
                    candidate, "UPDATE:" .. deathReason)
            end
            if Core.PurpleLifeStockController then
                Core.PurpleLifeStockController.OnPlayerDeath(candidate)
            end
            Core.CanonicalPlayerIdentity.MarkDead(candidate, "UPDATE:" .. deathReason)
            Runtime.Cleanup("player_death", candidate)
        end
        return false, identityReason
    end
    Core.CanonicalPlayerIdentity.UpdateDiagnostic(player)
    if Core.PerformanceScheduler and Core.PerformanceScheduler.AdvanceActiveSecondTasks then
        Core.PerformanceScheduler.AdvanceActiveSecondTasks(player)
    end

    if Core.MasterEffectState then
        Core.MasterEffectState.Load(player)
    end

    -- Central scheduled tasks and map presentation remain independent of traits.
    if Core.PerformanceScheduler then
        runPart("CENTRAL_GAME_HOUR_TASKS", function()
            Core.PerformanceScheduler.DispatchGameHourTasks(player)
        end)
    end
    if Core.RoundMarkerMapVisibility then
        runPart("ROUND_MARKER_MAP_VISIBILITY", function()
            Core.RoundMarkerMapVisibility.Update(false)
        end)
    end

    local flags = Runtime.runtimeSnapshot
    local traitState, traitChanged = Runtime.RefreshTraitState(player, nil, false)
    traitState = traitState or {
        yellow = false, purple = false, green = false, red = false,
        count = 0, any = false,
    }
    if traitChanged == true then
        Runtime.RebuildTraitUI(player, "TRAIT_STATE_EDGE", traitState)
    end

    local modEnabled = flags.enableMod == true
    local yellowSystemEnabled = modEnabled and flags.yellow == true
    local purpleSystemEnabled = modEnabled and flags.purple == true
    local greenSystemEnabled = modEnabled and flags.green == true
    local redSystemEnabled = flags.red == true
    local active = yellowSystemEnabled and traitState.yellow == true
    local phoenixActive = purpleSystemEnabled and traitState.purple == true
    local greenActive = greenSystemEnabled and traitState.green == true
    local redActive = redSystemEnabled and traitState.red == true

    if Core.RedPhysicalLoad then
        runPart("RED_PHYSICAL_LOAD", function()
            Core.RedPhysicalLoad.Update(player)
        end)
    end

    if phoenixActive and Core.PurplePhoenixRevive then
        runPart("PHOENIX_SURVIVAL", function()
            Core.PurplePhoenixRevive.PreUpdate(player)
        end)
    end

    if Core.PurpleLifeStockController then
        runPart("PURPLE_BACKUP_CONTROLLER", function()
            Core.PurpleLifeStockController.Update(player)
        end)
    end
    if Core.RedGuardianMark and redActive then
        runPart("RED_GUARDIAN_STARTER_GRANT", function()
            Core.RedGuardianMark.UpdateStarterGrant(player)
        end)
    end
    if Core.RedMagicUI and redActive then
        runPart("RED_MAGIC_UI_LOW_FREQUENCY", function()
            Core.RedMagicUI.Update(player, false)
        end)
    end

    if Runtime.lastActiveLogged ~= active then
        Runtime.lastActiveLogged = active
        print("[XNP RUNTIME] player_trait_active=" .. tostring(active)
            .. (active and "" or " reason=PLAYER_DOES_NOT_HAVE_TRAIT"))
    end
    if Runtime.lastPhoenixActiveLogged ~= phoenixActive then
        Runtime.lastPhoenixActiveLogged = phoenixActive
        print("[XNP PHOENIX] player_trait_active=" .. tostring(phoenixActive))
    end
    if Runtime.lastGreenActiveLogged ~= greenActive then
        Runtime.lastGreenActiveLogged = greenActive
        print("[XNP GREEN ULTIMATE] player_trait_active=" .. tostring(greenActive))
    end

    if greenActive then
        if Core.GreenWorldOrb then
            runPart("GREEN_WORLD_ORB", function() Core.GreenWorldOrb.Update(player) end)
        end
        if Core.GreenStructureDamage then
            runPart("GREEN_STRUCTURE_DAMAGE", function()
                Core.GreenStructureDamage.Update(player)
            end)
        end
    elseif traitChanged == true then
        if Core.GreenWorldOrb and Core.GreenWorldOrb.Shutdown then
            Core.GreenWorldOrb.Shutdown("GREEN_TRAIT_EDGE_MISSING")
        end
        if Core.GreenStructureDamage and Core.GreenStructureDamage.Cleanup then
            Core.GreenStructureDamage.Cleanup("GREEN_TRAIT_EDGE_MISSING")
        end
    end

    if not active and not phoenixActive and not greenActive and not redActive then
        if Core.Adrenaline then Core.Adrenaline.Clear("trait_missing") end
        return false
    end

    local invalid_reason = invalidPlayerReason(player)
    if invalid_reason then
        if Core.Adrenaline then Core.Adrenaline.Clear(invalid_reason) end
        if Core.PurplePhoenixUI then Core.PurplePhoenixUI.Cleanup(invalid_reason) end
        return false
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
            Runtime.RefreshRuntimeSnapshot()
        end)
    end
    if schedule.ui then
        if active and Core.StatusIconUI then
            runPart("STATUS_ICON_MINIMAL", function()
                Core.StatusIconUI.Update(player)
            end)
        end
        if phoenixActive and Core.PurplePhoenixUI then
            runPart("PURPLE_PHOENIX_UI", function()
                Core.PurplePhoenixUI.Update(player)
            end)
        end
        if greenActive and Core.GreenSkillUI then
            runPart("GREEN_SKILL_UI", function()
                Core.GreenSkillUI.Update(player)
            end)
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
    local deathShutdown = reason == "player_death" or reason == "dead_character"
        or reason == "death_done" or reason == "DEATH_ALREADY_COMMITTED"
    local sessionReset = deathShutdown or reason == "main_menu"
        or reason == "game_exit"
    if Core.TraitStateCache then
        if sessionReset then
            Core.TraitStateCache.ResetSession(reason or "SESSION_RESET")
        else
            Core.TraitStateCache.Invalidate(reason or "RUNTIME_CLEANUP")
        end
    end
    if deathShutdown then
        Runtime.identityShutdownDone = true
        if Core.CentralWorldQuery then Core.CentralWorldQuery.Clear() end
        if Core.Adrenaline then Core.Adrenaline.Clear(reason or "player_death") end
        if Core.FoodReserveConversion then Core.FoodReserveConversion.Cleanup(reason or "player_death") end
        if Core.TieredFoodRecovery then Core.TieredFoodRecovery.Cleanup(reason or "player_death") end
        if Core.PreBiteJogRescue then Core.PreBiteJogRescue.Cleanup(reason or "player_death") end
        if Core.NearbyZombieCache then Core.NearbyZombieCache.Cleanup(reason or "player_death") end
        if Core.BreakoutPush then Core.BreakoutPush.Cleanup(reason or "player_death") end
        if Core.NativeTripWindow then Core.NativeTripWindow.Cleanup(reason or "player_death") end
        if Core.SprintTripImmunity then Core.SprintTripImmunity.Cleanup(reason or "player_death") end
        if Core.DragdownDangerBreakout then Core.DragdownDangerBreakout.Cleanup(reason or "player_death") end
        if Core.DragdownDangerClassifier then Core.DragdownDangerClassifier.Cleanup(reason or "player_death") end
        if Core.BreakoutActionBus then Core.BreakoutActionBus.Cleanup(reason or "player_death") end
        if Core.YellowAltCrowdBreakout then
            Core.YellowAltCrowdBreakout.Cleanup(reason or "player_death")
        end
        if Core.GreenWorldOrb then Core.GreenWorldOrb.Shutdown(reason or "player_death") end
        if Core.VFXManager then Core.VFXManager.Cleanup(nil, reason or "player_death") end
        if Core.StatusIconUI then Core.StatusIconUI.Cleanup(reason or "player_death") end
        if Core.PurplePhoenixUI then Core.PurplePhoenixUI.Cleanup(reason or "player_death") end
        if Core.GreenSkillUI then Core.GreenSkillUI.Cleanup(reason or "player_death") end
        if Core.RedMagicUI then Core.RedMagicUI.Cleanup(reason or "player_death") end
        if Core.RedPhysicalLoad then
            Core.RedPhysicalLoad.Cleanup(reason or "player_death", player)
        end
        if Core.RoundMarkerTooltip then Core.RoundMarkerTooltip.Cleanup(reason or "player_death") end
        if Core.RoundMarkerMapVisibility then Core.RoundMarkerMapVisibility.Cleanup(reason or "player_death") end
        if Core.PurpleLifeStockController then
            Core.PurpleLifeStockController.Cleanup(reason or "player_death")
        end
        if Core.PhoenixTransaction then
            Core.PhoenixTransaction.Cleanup(
                player, reason or "player_death")
        end
        if Core.PerformanceScheduler and Core.PerformanceScheduler.ClearActiveSecondTasks then
            Core.PerformanceScheduler.ClearActiveSecondTasks(reason or "player_death")
        end
        return true
    end
    if Core.PerformanceScheduler and Core.PerformanceScheduler.ReleasePlayer then
        Core.PerformanceScheduler.ReleasePlayer(player)
    end
    if Core.CentralWorldQuery then Core.CentralWorldQuery.Clear() end
    if Core.PhoenixTransaction then
        Core.PhoenixTransaction.Cleanup(player, reason or "cleanup")
    end
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
    if Core.YellowAltCrowdBreakout then
        Core.YellowAltCrowdBreakout.Cleanup(reason or "cleanup")
    end
    if Core.StatusIconUI then
        Core.StatusIconUI.Cleanup(reason or "cleanup")
    end
    if Core.YellowRedSignals then
        Core.YellowRedSignals.Cleanup(reason or "cleanup")
    end
    if Core.PurpleLifeStockController then
        Core.PurpleLifeStockController.Cleanup(reason or "cleanup")
    end
    if Core.GreenWorldOrb then
        Core.GreenWorldOrb.Shutdown(reason or "cleanup")
    end
    if Core.VFXManager then
        Core.VFXManager.Cleanup(nil, reason or "cleanup")
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
    if Core.RedPhysicalLoad then
        Core.RedPhysicalLoad.Cleanup(reason or "cleanup", player)
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

if not Core.runtime_v2_220_startup_logged then
    Core.runtime_v2_220_startup_logged = true
    print("[XNP RUNTIME] VERSION=" .. tostring(Constants.VERSION)
        .. " BUILD_MARKER=" .. tostring(Constants.BUILD_ID)
        .. " channel=" .. tostring(Constants.RELEASE_CHANNEL)
        .. " runtime_entry_loaded=true"
        .. " purple_shared_input=true trait_object_restore=true"
        .. " right_click_toggle=true left_double_click_craft=true"
        .. " paused_drag=true post_restore_rebind=true"
        .. " purple_authoritative_mode=true auto_rearm=false"
        .. " red_mood_direction=DECREASE red_halo_created=false"
        .. " red_physical_load=POST_COMMIT_BOUNDED_NATIVE_PULSE"
        .. " predeath_intercept=true false_success_guard=true"
        .. " invulnerability=CANONICAL_0_TO_30_DEFAULT_10")
end

if not Core.red_physical_load_self_check_logged then
    Core.red_physical_load_self_check_logged = true
    local load = Core.RedPhysicalLoad
    local feedback = Core.RedCraftFeedback
    local moduleOk = type(load) == "table"
    local startOk = moduleOk and type(load.start) == "function"
    local bindingOk = type(feedback) == "table"
        and type(feedback.GetPhysicalLoadModuleForAudit) == "function"
        and feedback.GetPhysicalLoadModuleForAudit() == load
    print("[XNP RED PHYSICAL LOAD SELF CHECK]"
        .. " parse_ok=" .. tostring(moduleOk)
        .. " module_ok=" .. tostring(moduleOk)
        .. " start_function_ok=" .. tostring(startOk)
        .. " craft_feedback_binding_ok=" .. tostring(bindingOk))
end

Core.Runtime = Runtime
return Runtime
