require "TimedActions/ISBaseTimedAction"
require "XNP_PZ_DistanceRunner/XNP_DR_RedCraftFeedback"

XNPRedGuardianCraftAction = ISBaseTimedAction:derive("XNPRedGuardianCraftAction")

local function module()
    return XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.RedGuardianMark or nil
end

local function clear(action)
    local red = module()
    if red and type(red.ClearCraftAction) == "function" then red.ClearCraftAction(action) end
    if XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.RedMagicUI then
        XNP_PZ_DistanceRunner.RedMagicUI.SetCrafting(false)
    end
end

function XNPRedGuardianCraftAction:isValid()
    local red = module()
    if not self.character or not red or red.PlayerHasTrait(self.character) ~= true then return false end
    if type(self.character.isDead) == "function" and self.character:isDead() then return false end
    if type(self.character.isAiming) == "function" and self.character:isAiming() then return false end
    if type(self.character.isAttacking) == "function" and self.character:isAttacking() then return false end
    if type(self.character.getHitReaction) == "function" then
        local reaction = self.character:getHitReaction()
        if reaction ~= nil and tostring(reaction) ~= "" then return false end
    end
    local cost = red.GetCraftCost(self.character)
    return cost ~= nil
end

function XNPRedGuardianCraftAction:start()
    if CharacterActionAnims and CharacterActionAnims.Craft then self:setActionAnim(CharacterActionAnims.Craft) end
    if XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.RedMagicUI then XNP_PZ_DistanceRunner.RedMagicUI.SetCrafting(true) end
    local tuning = XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.SandboxTuning or nil
    local craftSoundEnabled = not tuning or tuning.GetBoolean("RedCraftSoundEnabled", true) ~= false
    if craftSoundEnabled and XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.Audio then
        local stamp = type(getTimestampMs) == "function" and getTimestampMs() or os.time()
        XNP_PZ_DistanceRunner.Audio.PlayOnce(self.character, "RED_USE_OR_PHOENIX_READY", "red-craft-start:" .. tostring(stamp))
    end
    local feedback = XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.RedCraftFeedback or nil
    if feedback and type(feedback.Begin) == "function" then
        feedback.Begin(self, self.character)
    end
end

function XNPRedGuardianCraftAction:update()
    local feedback = XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.RedCraftFeedback or nil
    if feedback and type(feedback.Update) == "function" then
        feedback.Update(self, self.character)
    end
end

function XNPRedGuardianCraftAction:stop()
    local feedback = XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.RedCraftFeedback or nil
    if feedback and type(feedback.Settle) == "function" then
        feedback.Settle(self, self.character, false)
    end
    self.completionHandled = true
    self.completionResult = false
    clear(self)
    print("[XNP RED CRAFT] complete=false costs_applied=false item_created=false reason=INTERRUPTED")
    ISBaseTimedAction.stop(self)
end

function XNPRedGuardianCraftAction:perform()
    clear(self)
    ISBaseTimedAction.perform(self)
end

function XNPRedGuardianCraftAction:complete()
    if self.completionHandled == true then
        clear(self)
        return self.completionResult == true
    end
    self.completionHandled = true
    self.completionResult = false
    if not self:isValid() then
        local feedback = XNP_PZ_DistanceRunner
            and XNP_PZ_DistanceRunner.RedCraftFeedback or nil
        if feedback and type(feedback.Settle) == "function" then
            feedback.Settle(self, self.character, false)
        end
        clear(self)
        return false
    end
    local red = module()
    local ok, reason, transactionInfo = red.CommitCraft(self.character)
    local feedback = XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.RedCraftFeedback or nil
    if ok and feedback and type(feedback.MarkCommitted) == "function" then
        feedback.MarkCommitted(self, self.character, transactionInfo)
    elseif not ok and feedback and type(feedback.CancelFailedCommit) == "function" then
        feedback.CancelFailedCommit(self)
    end
    if not ok then
        print("[XNP RED CRAFT] complete=false reason=" .. tostring(reason)
            .. " costs_applied=false item_created=false")
    end
    self.completionResult = ok == true
    clear(self)
    return self.completionResult
end

function XNPRedGuardianCraftAction:getDuration()
    return self.maxTime
end

function XNPRedGuardianCraftAction:new(character)
    local action = ISBaseTimedAction.new(self, character)
    action.character = character
    local red = module()
    local seconds = red and red.GetCraftDurationSeconds and red.GetCraftDurationSeconds() or 4.0
    action.maxTime = math.max(1, math.floor(seconds * 60 + 0.5))
    action.completionHandled = false
    action.completionResult = false
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    return action
end

return XNPRedGuardianCraftAction
