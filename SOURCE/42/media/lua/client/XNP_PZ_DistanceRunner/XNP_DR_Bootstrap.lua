local XNPChannelGuard = require "XNP_PZ_DistanceRunner/XNP_DR_ChannelGuard"
if type(XNPChannelGuard) == "table"
    and type(XNPChannelGuard.allowRuntime) == "function"
    and not XNPChannelGuard.allowRuntime() then
    return
end

require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedImpactPath"
require "XNP_PZ_DistanceRunner/XNP_DR_MeleeMultiplayerGuard"
require "XNP_PZ_DistanceRunner/XNP_DR_Log"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTraitRegistration"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Codec"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"
require "XNP_PZ_DistanceRunner/XNP_DR_SubsystemGuard"
require "XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState"
require "XNP_PZ_DistanceRunner/XNP_DR_TraitRegistration"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_VisualFeedback"
require "XNP_PZ_DistanceRunner/XNP_DR_MoodleStatus"
require "XNP_PZ_DistanceRunner/XNP_DR_Adrenaline"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaDrain"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame"
require "XNP_PZ_DistanceRunner/XNP_DR_VFXManager"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerTooltip"
require "XNP_PZ_DistanceRunner/XNP_DR_MapVisibility"
require "XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerMapVisibility"
require "XNP_PZ_DistanceRunner/XNP_DR_YellowRedSignals"
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
require "XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput"
require "XNP_PZ_DistanceRunner/XNP_DR_MinorScrapeCost"
require "XNP_PZ_DistanceRunner/XNP_DR_JogFallShockwave"
require "XNP_PZ_DistanceRunner/XNP_DR_JogBumpLaunch"
require "XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact"
require "XNP_PZ_DistanceRunner/XNP_DR_SprintTripConsequence"
require "XNP_PZ_DistanceRunner/XNP_DR_NativeTripWindow"
require "XNP_PZ_DistanceRunner/XNP_DR_VehicleVerifiedEvaluator"
require "XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush"
require "XNP_PZ_DistanceRunner/XNP_DR_PreBiteJogRescue"
require "XNP_PZ_DistanceRunner/XNP_DR_PerformanceBudget"
require "XNP_PZ_DistanceRunner/XNP_DR_NearbyZombieCache"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaTrendMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaColorSafeRGBA"
require "XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState"
require "XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist"
require "XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery"
require "XNP_PZ_DistanceRunner/XNP_DR_PlayerSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactCandidateSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_PerformanceScheduler"
require "XNP_PZ_DistanceRunner/XNP_DR_TieredFoodRecovery"
require "XNP_PZ_DistanceRunner/XNP_DR_FoodReserveConversion"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixLifeGate"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixProtect"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixInvulnerability"
require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixTransaction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixDamageGuard"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixRevive"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Snapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Items"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Transactions"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Controller"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_UI"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWhiteAction"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkillUI"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianConsumeAction"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianCraftAction"
require "XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark"
require "XNP_PZ_DistanceRunner/XNP_DR_RedMagicUI"
require "XNP_PZ_DistanceRunner/XNP_DR_ReleaseMigration"
require "XNP_PZ_DistanceRunner/XNP_DR_Runtime"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Bootstrap = {}

local function logModuleStartup()
    if not Config.RUNTIME_MODULE_STARTUP_LOGS then
        return
    end
    print("[XNP RUNTIME] module=StatusIconUI loaded=" .. tostring(Core.StatusIconUI ~= nil))
    print("[XNP RUNTIME] module=MasterEffectState loaded=" .. tostring(Core.MasterEffectState ~= nil))
    print("[XNP RUNTIME] module=VFXManager loaded=" .. tostring(Core.VFXManager ~= nil))
    print("[XNP RUNTIME] module=ImpactQuotaMeter loaded=" .. tostring(Core.ImpactQuotaMeter ~= nil))
    print("[XNP RUNTIME] module=JogBumpLaunch loaded=" .. tostring(Core.JogBumpLaunch ~= nil))
    print("[XNP RUNTIME] module=SprintVehicleImpact loaded=" .. tostring(Core.SprintVehicleImpact ~= nil))
    print("[XNP RUNTIME] module=NativeTripWindow loaded=" .. tostring(Core.NativeTripWindow ~= nil))
    print("[XNP RUNTIME] module=SprintTripConsequence loaded=" .. tostring(Core.SprintTripConsequence ~= nil))
    print("[XNP RUNTIME] module=FallRecoveryInput loaded=" .. tostring(Core.FallRecoveryInput ~= nil))
    print("[XNP RUNTIME] module=EmergencyInput loaded=" .. tostring(Core.EmergencyInput ~= nil))
    print("[XNP RUNTIME] module=EmergencyBreakout loaded=" .. tostring(Core.EmergencyBreakout ~= nil))
    print("[XNP RUNTIME] module=DragdownDangerBreakout loaded=" .. tostring(Core.DragdownDangerBreakout ~= nil))
    print("[XNP RUNTIME] module=DragdownDangerClassifier loaded=" .. tostring(Core.DragdownDangerClassifier ~= nil))
    print("[XNP RUNTIME] module=BreakoutActionBus loaded=" .. tostring(Core.BreakoutActionBus ~= nil))
    print("[XNP RUNTIME] module=MovementIntentGate loaded=" .. tostring(Core.MovementIntentGate ~= nil))
    print("[XNP RUNTIME] module=BreakoutPush loaded=" .. tostring(Core.BreakoutPush ~= nil))
    print("[XNP RUNTIME] module=PreBiteJogRescue loaded=" .. tostring(Core.PreBiteJogRescue ~= nil))
    print("[XNP RUNTIME] module=SprintTripImmunity loaded=" .. tostring(Core.SprintTripImmunity ~= nil))
    print("[XNP RUNTIME] module=ActivationDiagnostic loaded=" .. tostring(Core.ActivationDiagnostic ~= nil))
    print("[XNP RUNTIME] module=PerformanceBudget loaded=" .. tostring(Core.PerformanceBudget ~= nil))
    print("[XNP RUNTIME] module=NearbyZombieCache loaded=" .. tostring(Core.NearbyZombieCache ~= nil))
    print("[XNP RUNTIME] module=StaminaTrendMeter loaded=" .. tostring(Core.StaminaTrendMeter ~= nil))
    print("[XNP RUNTIME] module=StaminaColorSafeRGBA loaded=" .. tostring(Core.StaminaColorSafeRGBA ~= nil))
    print("[XNP RUNTIME] module=EnduranceBandState loaded=" .. tostring(Core.EnduranceBandState ~= nil))
    print("[XNP RUNTIME] module=LongMigrationStaminaAssist loaded=" .. tostring(Core.LongMigrationStaminaAssist ~= nil))
    print("[XNP RUNTIME] module=CentralWorldQuery loaded=" .. tostring(Core.CentralWorldQuery ~= nil))
    print("[XNP RUNTIME] module=PlayerSnapshot loaded=" .. tostring(Core.PlayerSnapshot ~= nil))
    print("[XNP RUNTIME] module=PerformanceScheduler loaded=" .. tostring(Core.PerformanceScheduler ~= nil))
    print("[XNP RUNTIME] module=TieredFoodRecovery loaded=" .. tostring(Core.TieredFoodRecovery ~= nil))
    print("[XNP RUNTIME] module=FoodReserveConversion loaded=" .. tostring(Core.FoodReserveConversion ~= nil))
    print("[XNP RUNTIME] module=PurplePhoenixTrait loaded=" .. tostring(Core.PurplePhoenixTrait ~= nil))
    print("[XNP RUNTIME] module=PurpleLifeStockRegistry loaded=" .. tostring(Core.PurpleLifeStockRegistry ~= nil))
    print("[XNP RUNTIME] module=PurpleLifeStockTransactions loaded=" .. tostring(Core.PurpleLifeStockTransactions ~= nil))
    print("[XNP RUNTIME] module=PurpleLifeStockController loaded=" .. tostring(Core.PurpleLifeStockController ~= nil))
    print("[XNP RUNTIME] purple_predeath_intercept_reachable=1"
        .. " false_success_guard=true"
        .. " purple_invulnerability_runtime_reachable="
        .. tostring(Core.PurplePhoenixConfig.Get()
            .invulnerabilitySeconds > 0 and 1 or 0))
    print("[XNP RUNTIME] module=PurplePhoenixUI loaded=" .. tostring(Core.PurplePhoenixUI ~= nil))
    print("[XNP RUNTIME] module=GreenSkillUI loaded=" .. tostring(Core.GreenSkillUI ~= nil))
    print("[XNP RUNTIME] module=GreenWhiteAction loaded=" .. tostring(Core.GreenWhiteAction ~= nil))
    print("[XNP RUNTIME] module=GreenWorldOrb loaded=" .. tostring(Core.GreenWorldOrb ~= nil))
    print("[XNP RUNTIME] green_entity_render_module_loaded=false forced_render_safe=true")
    print("[XNP RUNTIME] module=GreenStructureDamage loaded=" .. tostring(Core.GreenStructureDamage ~= nil))
    print("[XNP RUNTIME] module=RedGuardianMark loaded=" .. tostring(Core.RedGuardianMark ~= nil))
    print("[XNP RUNTIME] module=RedGuardianCraftAction loaded=" .. tostring(XNPRedGuardianCraftAction ~= nil))
    print("[XNP RUNTIME] module=RedMagicUI loaded=" .. tostring(Core.RedMagicUI ~= nil))
    print("[XNP RUNTIME] module=RoundMarkerMapVisibility loaded=" .. tostring(Core.RoundMarkerMapVisibility ~= nil))
    print("[XNP RUNTIME] module=RoundMarkerTooltip loaded=" .. tostring(Core.RoundMarkerTooltip ~= nil))
end

local function playerAt(index)
    if type(getSpecificPlayer) == "function" then
        return getSpecificPlayer(index or 0)
    end
    if type(getPlayer) == "function" then
        return getPlayer()
    end
    return nil
end

function Bootstrap.OnGameStart()
    if Core.CanonicalPlayerIdentity then
        Core.CanonicalPlayerIdentity.BeginWorld("GAME_START")
    end
    if Core.SandboxTuning then Core.SandboxTuning.Refresh(true) end
    if Core.Runtime and Core.Runtime.RefreshRuntimeSnapshot then Core.Runtime.RefreshRuntimeSnapshot() end
    local player = playerAt(0)
    local bound = Core.CanonicalPlayerIdentity
        and Core.CanonicalPlayerIdentity.Bind(player, 0, "GAME_START") == true
    if not bound then
        print("[XNP PLAYER IDENTITY] startup_blocked=true reason=CANONICAL_BIND_FAILED")
        return false
    end
    if Core.ReleaseMigration then Core.ReleaseMigration.ApplyPlayer(player, "GAME_START") end
    if Core.GreenWorldOrb then Core.GreenWorldOrb.InitializePlayer(player, "GAME_START") end
    if Core.RoundMarkerMapVisibility then Core.RoundMarkerMapVisibility.Update(true) end
    local traitState = nil
    if Core.Runtime then
        Core.Runtime.InvalidateTraitState("GAME_START")
        traitState = Core.Runtime.RefreshTraitState(player, nil, false)
    end
    if Core.PurpleLifeStockController then
        Core.PurpleLifeStockController.InitializePlayer(player, "GAME_START")
    end
    if traitState and traitState.purple == true
        and Core.PhoenixTransaction then
        Core.PhoenixTransaction.InitializePlayer(player, "GAME_START")
    end
    if Core.RedGuardianMark and traitState and traitState.red == true then
        Core.RedGuardianMark.GrantStarter(player)
    end
    if Core.Runtime then
        Core.Runtime.RebuildTraitUI(player, "GAME_START", traitState)
    end
    if Core.B42_20RuntimeDiagnostic then
        Core.B42_20RuntimeDiagnostic.StartupSelfCheck(player)
    end
    return true
end

local function initializeBoundPlayer(player, source)
    local lifecycleSource = source or "CREATE_PLAYER"
    if Core.SandboxTuning then Core.SandboxTuning.Refresh(true) end
    if Core.Runtime and Core.Runtime.RefreshRuntimeSnapshot then Core.Runtime.RefreshRuntimeSnapshot() end
    if Core.ReleaseMigration then Core.ReleaseMigration.ApplyPlayer(player, lifecycleSource) end
    if Core.GreenWorldOrb then
        Core.GreenWorldOrb.Shutdown("PLAYER_REPLACED")
        Core.GreenWorldOrb.InitializePlayer(player, lifecycleSource)
    end
    if Core.RedGuardianMark then Core.RedGuardianMark.Cleanup("CREATE_PLAYER_REPLACEMENT") end
    if Core.RoundMarkerMapVisibility then Core.RoundMarkerMapVisibility.Update(true) end
    if Core.TraitRegistration then
        Core.TraitRegistration.ResetCache()
    end
    if Core.PurplePhoenixTraitRegistration then
        Core.PurplePhoenixTraitRegistration.ResetCache()
    end
    local traitState = nil
    if Core.Runtime then
        Core.Runtime.InvalidateTraitState(lifecycleSource)
        traitState = Core.Runtime.RefreshTraitState(player, nil, false)
    end
    if Core.PurpleLifeStockController then
        Core.PurpleLifeStockController.InitializePlayer(player, lifecycleSource)
    end
    if traitState and traitState.purple == true
        and Core.PhoenixTransaction then
        Core.PhoenixTransaction.InitializePlayer(player, lifecycleSource)
    end
    if Core.RedGuardianMark and traitState and traitState.red == true then
        Core.RedGuardianMark.GrantStarter(player)
    end
    if Core.Runtime then
        Core.Runtime.RebuildTraitUI(player, lifecycleSource, traitState)
    end
    print("[XNP PLAYER IDENTITY] new_character_runtime_initialized=true source="
        .. tostring(lifecycleSource)
        .. " trait_rescan=true ui_rebuild=true input_rebind=true old_state_copied=false")
    return true
end

function Bootstrap.OnCreatePlayer(player_index)
    if Core.SandboxTuning then Core.SandboxTuning.Refresh(true) end
    if Core.Runtime and Core.Runtime.RefreshRuntimeSnapshot then Core.Runtime.RefreshRuntimeSnapshot() end
    local index = tonumber(player_index) or 0
    local player = playerAt(index)
    local bound, bindReason = Core.CanonicalPlayerIdentity.Bind(player, index, "CREATE_PLAYER")
    if not bound then
        local pending = bindReason == "SUCCESSOR_CONFIRMATION_PENDING"
        print("[XNP PLAYER IDENTITY] create_player_blocked=" .. tostring(not pending)
            .. " successor_pending=" .. tostring(pending)
            .. " auto_rebind=false reason=" .. tostring(bindReason))
        return pending
    end
    return initializeBoundPlayer(player, "CREATE_PLAYER")
end

function Bootstrap.OnSuccessorConfirmed(player)
    local valid, reason = Core.CanonicalPlayerIdentity.Validate(player, true)
    if not valid then
        print("[XNP PLAYER IDENTITY] successor_runtime_init_blocked=true reason=" .. tostring(reason))
        return false
    end
    return initializeBoundPlayer(player, "POST_DEATH_NEW_CHARACTER")
end

function Bootstrap.OnPlayerDeath(player)
    local marked, markReason = Core.CanonicalPlayerIdentity.MarkDead(player, "PLAYER_DEATH")
    if not marked then
        print("[XNP PLAYER IDENTITY] noncanonical_death_ignored=true reason=" .. tostring(markReason))
        return false
    end
    if Core.PurplePhoenixDamageGuard then
        Core.PurplePhoenixDamageGuard.CancelForDeath(
            player, "ACTUAL_PLAYER_DEATH")
    end
    -- Phoenix must classify any tentative recovery before the frozen Life
    -- Stock chain records the real death. This does not gate that chain.
    if Core.PurpleLifeStockController then
        Core.PurpleLifeStockController.OnPlayerDeath(player)
    end
    if Core.PurplePhoenixTrait then Core.PurplePhoenixTrait.ResetCache() end
    if Core.Trait then Core.Trait.ResetCache() end
    if Core.ExtraTraits then Core.ExtraTraits.ResetCaches() end
    if Core.Runtime then
        Core.Runtime.Cleanup("player_death", player)
    end
    return true
end

function Bootstrap.OnMainMenuEnter()
    if Core.Trait then
        Core.Trait.ResetCache()
    end
    if Core.PurplePhoenixTrait then
        Core.PurplePhoenixTrait.ResetCache()
    end
    if Core.PurplePhoenixTraitRegistration then
        Core.PurplePhoenixTraitRegistration.ResetCache()
    end
    if Core.ExtraTraits then
        Core.ExtraTraits.ResetCaches()
    end
    if Core.Runtime then
        Core.Runtime.Cleanup("main_menu")
    end
    if Core.PurpleLifeStockController then Core.PurpleLifeStockController.Cleanup("MAIN_MENU") end
    if Core.CanonicalPlayerIdentity then Core.CanonicalPlayerIdentity.ResetSession("MAIN_MENU") end
end

function Bootstrap.OnGameExit()
    if Core.Runtime then
        Core.Runtime.Cleanup("game_exit")
    end
    if Core.PurpleLifeStockController then Core.PurpleLifeStockController.Cleanup("GAME_EXIT") end
    if Core.CanonicalPlayerIdentity then Core.CanonicalPlayerIdentity.ResetSession("GAME_EXIT") end
end

function Bootstrap.OnPlayerUpdateEvent(eventPlayer)
    if not Core.Runtime then return false end
    return Core.Runtime.Update(eventPlayer)
end

Bootstrap.EventAdapters = {}

local function dispatchEvent(system, name, fn)
    local ok, first, second = Core.SubsystemGuard.Execute(system, name, fn)
    if not ok then return false, first end
    return first, second
end

function Bootstrap.EventAdapters.OnGameStart()
    return dispatchEvent("CORE", "EVENT_ON_GAME_START", Bootstrap.OnGameStart)
end

function Bootstrap.EventAdapters.OnCreatePlayer(playerIndex)
    return dispatchEvent("CORE", "EVENT_ON_CREATE_PLAYER", function()
        return Bootstrap.OnCreatePlayer(playerIndex)
    end)
end

function Bootstrap.EventAdapters.OnPlayerUpdate(eventPlayer)
    return dispatchEvent("CORE", "EVENT_ON_PLAYER_UPDATE", function()
        return Bootstrap.OnPlayerUpdateEvent(eventPlayer)
    end)
end

function Bootstrap.EventAdapters.OnPlayerDeath(player)
    return dispatchEvent("CORE", "EVENT_ON_PLAYER_DEATH", function()
        return Bootstrap.OnPlayerDeath(player)
    end)
end

function Bootstrap.EventAdapters.OnMainMenuEnter()
    return dispatchEvent("CORE", "EVENT_ON_MAIN_MENU_ENTER", Bootstrap.OnMainMenuEnter)
end

function Bootstrap.RegisterEvents()
    -- Refresh the callback in place on Lua reload. The scheduler keeps one
    -- ordered task per stable ID, while the event gate below remains untouched.
    if Core.RedGuardianMark and Core.RedGuardianMark.RegisterSchedulerTask then
        Core.RedGuardianMark.RegisterSchedulerTask()
    end
    if Core.events_registered then
        return true
    end
    if Core.SandboxTuning then
        Core.SandboxTuning.Load()
    end
    if Core.Runtime and Core.Runtime.RefreshRuntimeSnapshot then Core.Runtime.RefreshRuntimeSnapshot() end
    if Events and Events.OnGameStart then
        Events.OnGameStart.Add(Bootstrap.EventAdapters.OnGameStart)
    end
    if Events and Events.OnCreatePlayer then
        Events.OnCreatePlayer.Add(Bootstrap.EventAdapters.OnCreatePlayer)
    end
    if Events and Events.OnPlayerUpdate and Core.Runtime then
        Events.OnPlayerUpdate.Add(Bootstrap.EventAdapters.OnPlayerUpdate)
        if Config.RUNTIME_UPDATE_REGISTRATION_LOGS then
            print("[XNP RUNTIME] update_registered=true event=OnPlayerUpdate")
        end
    end
    if Events and Events.OnPlayerDeath then
        Events.OnPlayerDeath.Add(Bootstrap.EventAdapters.OnPlayerDeath)
    end
    if Events and Events.OnMainMenuEnter then
        Events.OnMainMenuEnter.Add(Bootstrap.EventAdapters.OnMainMenuEnter)
    end
    if Core.RedGuardianMark then
        Core.RedGuardianMark.RegisterEvents()
    end
    if Core.PurplePhoenixDamageGuard then
        Core.PurplePhoenixDamageGuard.RegisterEvents()
    end
    Core.events_registered = true
    print("[XNP DR] BUILD_MARKER=" .. tostring(Constants.BUILD_ID))
    print("[XNP PURPLE DUAL] phoenix_survival_reachable=true"
        .. " life_stock_inheritance_reachable=true"
        .. " life_stock_gated_by_phoenix=false"
        .. " invulnerability=CANONICAL_0_TO_30_DEFAULT_10")
    Constants.Log("loaded version=" .. Constants.VERSION .. " internal=" .. Constants.INTERNAL_VERSION .. " build=" .. Constants.BUILD_ID)
    if Core.LogThrottle then
        Core.LogThrottle.Startup()
    end
    logModuleStartup()
    return true
end

Core.Bootstrap = Bootstrap
Bootstrap.RegisterEvents()
return Bootstrap
