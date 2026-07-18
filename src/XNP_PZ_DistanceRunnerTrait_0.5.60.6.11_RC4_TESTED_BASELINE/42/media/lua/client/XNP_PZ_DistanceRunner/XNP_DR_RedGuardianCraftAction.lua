require "TimedActions/ISBaseTimedAction"

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
    if XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.Audio then
        local stamp = type(getTimestampMs) == "function" and getTimestampMs() or os.time()
        XNP_PZ_DistanceRunner.Audio.PlayOnce(self.character, "RED_USE_OR_PHOENIX_READY", "red-craft-start:" .. tostring(stamp))
    end
end

function XNPRedGuardianCraftAction:stop()
    clear(self)
    print("[XNP RED CRAFT] complete=false costs_applied=false item_created=false reason=INTERRUPTED")
    ISBaseTimedAction.stop(self)
end

function XNPRedGuardianCraftAction:perform()
    clear(self)
    ISBaseTimedAction.perform(self)
end

function XNPRedGuardianCraftAction:complete()
    if not self:isValid() then clear(self); return false end
    local red = module()
    local ok, reason = red.CommitCraft(self.character)
    if not ok then print("[XNP RED CRAFT] complete=false reason=" .. tostring(reason) .. " costs_applied=false item_created=false") end
    clear(self)
    return ok == true
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
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    return action
end

return XNPRedGuardianCraftAction
