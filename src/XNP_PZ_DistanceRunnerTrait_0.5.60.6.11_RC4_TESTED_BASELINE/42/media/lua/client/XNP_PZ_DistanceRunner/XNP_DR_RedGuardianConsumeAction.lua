require "TimedActions/ISBaseTimedAction"

XNPRedGuardianConsumeAction = ISBaseTimedAction:derive("XNPRedGuardianConsumeAction")

local function clearQueued(action)
    local module = XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.RedGuardianMark or nil
    if module and type(module.ClearConsumeAction) == "function" then module.ClearConsumeAction(action) end
end

function XNPRedGuardianConsumeAction:isValid()
    if not self.item or not self.character then return false end
    local module = XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.RedGuardianMark or nil
    if not module or module.PlayerHasTrait(self.character) ~= true then return false end
    if type(self.character.isDead) == "function" and self.character:isDead() then return false end
    if type(self.character.isAiming) == "function" and self.character:isAiming() then return false end
    local okType, fullType = pcall(function() return self.item:getFullType() end)
    local okContainer, container = pcall(function() return self.item:getContainer() end)
    return okType and fullType == "XNP_PZ_DistanceRunner.RedGuardianMark" and okContainer and container ~= nil
end

function XNPRedGuardianConsumeAction:start()
    if self.item and type(self.item.setJobType) == "function" then
        self.item:setJobType(getText("ContextMenu_UseRedMagicMark"))
        self.item:setJobDelta(0.0)
    end
    if CharacterActionAnims and CharacterActionAnims.Eat then self:setActionAnim(CharacterActionAnims.Eat) end
    if type(self.setOverrideHandModels) == "function" then self:setOverrideHandModels(self.item, nil) end
end

function XNPRedGuardianConsumeAction:update()
    if self.item and type(self.item.setJobDelta) == "function" then self.item:setJobDelta(self:getJobDelta()) end
end

function XNPRedGuardianConsumeAction:stop()
    if self.item and type(self.item.setJobDelta) == "function" then self.item:setJobDelta(0.0) end
    clearQueued(self)
    ISBaseTimedAction.stop(self)
end

function XNPRedGuardianConsumeAction:perform()
    if self.item and type(self.item.setJobDelta) == "function" then self.item:setJobDelta(0.0) end
    clearQueued(self)
    ISBaseTimedAction.perform(self)
end

function XNPRedGuardianConsumeAction:complete()
    if not self:isValid() then clearQueued(self); return false end
    local module = XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.RedGuardianMark or nil
    if not module or type(module.TryUse) ~= "function" then
        print("[XNP RED USE] result=BLOCKED reason=EFFECT_FAILED effect_transaction_count=0 consumed=0 detail=MODULE_UNAVAILABLE")
        clearQueued(self)
        return false
    end
    local callOk, used, reason = pcall(module.TryUse, self.character, self.item)
    if not callOk or used ~= true then
        if not callOk then
            print("[XNP RED USE] result=BLOCKED reason=EFFECT_FAILED effect_transaction_count=0 consumed=0 detail=" .. tostring(used))
        end
        clearQueued(self)
        return false
    end
    print("[XNP RED MAGIC] consume_complete=true mode=" .. tostring(reason) .. " whole_item_consumed=true")
    clearQueued(self)
    return true
end

function XNPRedGuardianConsumeAction:getDuration()
    return self.maxTime
end

function XNPRedGuardianConsumeAction:new(character, item, mode)
    local action = ISBaseTimedAction.new(self, character)
    action.character = character
    action.item = item
    action.mode = mode or "GREEN_STAMINA"
    action.maxTime = 96
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    return action
end

return XNPRedGuardianConsumeAction
