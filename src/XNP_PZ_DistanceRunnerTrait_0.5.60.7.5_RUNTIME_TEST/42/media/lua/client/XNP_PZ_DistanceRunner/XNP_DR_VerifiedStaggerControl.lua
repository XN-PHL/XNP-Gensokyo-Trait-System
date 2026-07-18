require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local VerifiedStaggerControl = {
    configLogged = false,
    contactFalls = 0,
    grabFalls = 0,
    grabInterruptDisabled = false,
}

XNP_DR_VerifiedStaggerControl = VerifiedStaggerControl

local function safeCall(route, fn)
    local ok, result = pcall(fn)
    if not ok then
        print("[XNP STAGGER CONTROL FAIL] reason=API_NOT_AVAILABLE route=" .. tostring(route) .. " error=" .. tostring(result))
        return false
    end
    return result ~= false
end

local function logConfigOnce()
    if VerifiedStaggerControl.configLogged then
        return
    end
    VerifiedStaggerControl.configLogged = true
    print("[XNP STAGGER CONTROL] method=VERIFIED_STAGGER_KNOCKDOWN")
end

function VerifiedStaggerControl.LogConfigOnce()
    logConfigOnce()
end

function VerifiedStaggerControl.verifyVisibleControlCandidate(zombie)
    if not zombie then
        return false, "NO_ZOMBIE"
    end
    if type(zombie.setStaggerBack) == "function" then
        return true, "setStaggerBack"
    end
    if type(zombie.setKnockedDown) == "function" then
        return true, "setKnockedDown"
    end
    if type(zombie.knockDown) == "function" then
        return true, "knockDown"
    end
    if type(zombie.setHitReaction) == "function" then
        return true, "setHitReaction"
    end
    return false, "NO_VERIFIED_ZOMBIE_ANIMATION"
end

local function applyVerifiedStaggerKnockdown(zombie, allowKnockdown)
    local visible = false
    local effect = "none"
    if type(zombie.setStaggerBack) == "function" then
        visible = safeCall("setStaggerBack", function()
            zombie:setStaggerBack(true)
            return true
        end) or visible
        if visible then
            effect = "stagger"
        end
    end
    if allowKnockdown and type(zombie.setKnockedDown) == "function" then
        local ok = safeCall("setKnockedDown", function()
            zombie:setKnockedDown(true)
            return true
        end)
        visible = ok or visible
        if ok then
            effect = "stagger_knockdown"
        end
    elseif allowKnockdown and type(zombie.knockDown) == "function" then
        local ok = safeCall("knockDown", function()
            zombie:knockDown(false)
            return true
        end)
        visible = ok or visible
        if ok then
            effect = "stagger_knockdown"
        end
    end
    if not visible and type(zombie.setHitReaction) == "function" then
        visible = safeCall("setHitReaction", function()
            zombie:setHitReaction("StaggerBack")
            return true
        end) or visible
        if visible then
            effect = "hit_reaction"
        end
    end
    print("[XNP STAGGER CONTROL] visible_effect=" .. tostring(effect))
    return visible, effect
end

function VerifiedStaggerControl.registerControlOutcome(triggerId, triggerType, result, effect)
    print("[XNP STAGGER CONTROL] trigger_id=" .. tostring(triggerId) .. " type=" .. tostring(triggerType) .. " method=VERIFIED_STAGGER_KNOCKDOWN result=" .. tostring(result) .. " visible_effect=" .. tostring(effect))
end

function VerifiedStaggerControl.applySprintStaggerKnockdown(player, zombie, context)
    local triggerId = context and context.triggerId or "NA"
    local ok, reason = VerifiedStaggerControl.verifyVisibleControlCandidate(zombie)
    if not ok then
        print("[XNP STAGGER CONTROL FAIL] reason=NO_VERIFIED_ZOMBIE_ANIMATION trigger_id=" .. tostring(triggerId))
        VerifiedStaggerControl.registerControlOutcome(triggerId, "SPRINT_PRECOLLISION", "fail", "none")
        return false, "none"
    end
    local visible, effect = applyVerifiedStaggerKnockdown(zombie, true)
    VerifiedStaggerControl.registerControlOutcome(triggerId, "SPRINT_PRECOLLISION", visible and "ok" or "fail", effect)
    if not visible then
        print("[XNP STAGGER CONTROL FAIL] reason=NO_VERIFIED_ZOMBIE_ANIMATION trigger_id=" .. tostring(triggerId))
    end
    return visible, effect
end

function VerifiedStaggerControl.applyContactStagger(player, zombie, context)
    local triggerId = context and context.triggerId or "NA"
    local visible, effect = applyVerifiedStaggerKnockdown(zombie, false)
    VerifiedStaggerControl.registerControlOutcome(triggerId, "CONTACT", visible and "ok" or "fail", effect)
    if not visible then
        print("[XNP STAGGER CONTROL FAIL] reason=NO_VERIFIED_ZOMBIE_ANIMATION trigger_id=" .. tostring(triggerId))
    end
    return visible, effect
end

function VerifiedStaggerControl.applyCrowdStagger(player, zombie, context)
    local triggerId = context and context.triggerId or "NA"
    local visible, effect = applyVerifiedStaggerKnockdown(zombie, false)
    VerifiedStaggerControl.registerControlOutcome(triggerId, "CROWD", visible and "ok" or "fail", effect)
    if not visible then
        print("[XNP STAGGER CONTROL FAIL] reason=NO_VERIFIED_ZOMBIE_ANIMATION trigger_id=" .. tostring(triggerId))
    end
    return visible, effect
end

function VerifiedStaggerControl.applyGrabPreBiteBreak(player, zombie, context)
    local triggerId = context and context.triggerId or "NA"
    if VerifiedStaggerControl.grabInterruptDisabled then
        print("[XNP GRAB BREAK] interrupt_disabled reason=REPEATED_STUCK_OR_FALL")
    end
    local visible, effect = applyVerifiedStaggerKnockdown(zombie, false)
    VerifiedStaggerControl.registerControlOutcome(triggerId, "GRAB_PREBITE", visible and "ok" or "fail", effect)
    if not visible then
        print("[XNP STAGGER CONTROL FAIL] reason=NO_VERIFIED_ZOMBIE_ANIMATION trigger_id=" .. tostring(triggerId))
    end
    return visible, effect
end

function VerifiedStaggerControl.NotePlayerFall(triggerType)
    if triggerType == "CONTACT" then
        VerifiedStaggerControl.contactFalls = VerifiedStaggerControl.contactFalls + 1
        if VerifiedStaggerControl.contactFalls >= 3 then
            print("[XNP CONTACT METHOD FAIL] reason=REPEATED_PLAYER_FALL")
        end
    elseif triggerType == "GRAB_PREBITE" or triggerType == "GRAB" then
        VerifiedStaggerControl.grabFalls = VerifiedStaggerControl.grabFalls + 1
        print("[XNP GRAB BREAK FAIL] reason=PLAYER_FELL_AFTER_GRAB_BREAK")
        if VerifiedStaggerControl.grabFalls >= 2 then
            VerifiedStaggerControl.grabInterruptDisabled = true
            print("[XNP GRAB BREAK] interrupt_disabled reason=REPEATED_STUCK_OR_FALL")
        end
    end
end

function VerifiedStaggerControl.Apply(player, zombie, triggerType, context)
    logConfigOnce()
    if triggerType == "SPRINT_PRECOLLISION" then
        return VerifiedStaggerControl.applySprintStaggerKnockdown(player, zombie, context)
    elseif triggerType == "CONTACT" then
        return VerifiedStaggerControl.applyContactStagger(player, zombie, context)
    elseif triggerType == "CROWD" then
        return VerifiedStaggerControl.applyCrowdStagger(player, zombie, context)
    elseif triggerType == "GRAB" or triggerType == "GRAB_PREBITE" then
        return VerifiedStaggerControl.applyGrabPreBiteBreak(player, zombie, context)
    end
    print("[XNP STAGGER CONTROL FAIL] reason=NO_VERIFIED_ZOMBIE_ANIMATION trigger_id=" .. tostring(context and context.triggerId or "NA"))
    return false, "none"
end

Core.VerifiedStaggerControl = VerifiedStaggerControl
return VerifiedStaggerControl
