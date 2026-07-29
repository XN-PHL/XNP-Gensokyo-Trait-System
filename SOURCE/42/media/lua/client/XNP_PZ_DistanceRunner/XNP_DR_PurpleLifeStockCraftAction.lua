require "TimedActions/ISBaseTimedAction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Sound"

XNPPurpleLifeStockCraftAction = ISBaseTimedAction:derive(
    "XNPPurpleLifeStockCraftAction")

local function transactions()
    return XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.PurpleLifeStockTransactions or nil
end

local function sound()
    return XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.PurpleLifeStockSound or nil
end

local function currentHealth(character)
    if not character or type(character.getHealth) ~= "function" then return nil end
    local ok, value = pcall(function() return character:getHealth() end)
    return ok and tonumber(value) or nil
end

local function clear(action)
    local tx = transactions()
    if tx and type(tx.ClearCraftAction) == "function" then
        tx.ClearCraftAction(action)
    end
end

function XNPPurpleLifeStockCraftAction:isValid()
    local tx = transactions()
    if not self.character or not tx then return false end
    if type(self.character.isDead) == "function" and self.character:isDead() then
        return false
    end
    if type(self.character.isAiming) == "function" and self.character:isAiming() then
        return false
    end
    if type(self.character.isAttacking) == "function"
        and self.character:isAttacking() then return false end
    if type(self.character.getHitReaction) == "function" then
        local reaction = self.character:getHitReaction()
        if reaction ~= nil and tostring(reaction) ~= "" then return false end
    end
    local health = currentHealth(self.character)
    if health and self.initialHealth and health < self.initialHealth - 0.001 then
        return false
    end
    local ok = tx.PreflightCraft(self.character, self)
    return ok == true
end

function XNPPurpleLifeStockCraftAction:start()
    self.animationSet = false
    if CharacterActionAnims and CharacterActionAnims.Craft then
        self:setActionAnim(CharacterActionAnims.Craft)
        self.animationSet = true
    end
    local audio = sound()
    if audio then audio.LogDeferred("CRAFT_START", "SUCCESS_SOUND_DEFERRED") end
    print("[XNP PURPLE CRAFT ACTION] start=true animation=Craft"
        .. " animation_set_success=" .. tostring(self.animationSet)
        .. " max_time=" .. tostring(self.maxTime)
        .. " progress_bar_route=ISBaseTimedAction")
end

function XNPPurpleLifeStockCraftAction:stop()
    clear(self)
    local audio = sound()
    if audio then
        audio.NotifyFailure(self.character, "UI_XNPPurpleCraftCancelled",
            "Extra Life backup crafting cancelled; no cost or item was committed.",
            "TIMED_ACTION_CANCELLED")
    end
    print("[XNP PURPLE CRAFT ACTION] complete=false costs_applied=false"
        .. " token_created=false item_created=false reason=INTERRUPTED")
    ISBaseTimedAction.stop(self)
end

function XNPPurpleLifeStockCraftAction:perform()
    clear(self)
    ISBaseTimedAction.perform(self)
end

function XNPPurpleLifeStockCraftAction:complete()
    if self.completionHandled then return self.completionResult == true end
    self.completionHandled = true
    self.completionResult = false
    if not self:isValid() then
        clear(self)
        return false
    end
    local tx = transactions()
    local okCall, committed, reason = pcall(tx.CommitCraft, self.character)
    self.completionResult = okCall and committed == true
    if not self.completionResult then
        local audio = sound()
        if audio then
            audio.NotifyFailure(self.character, "UI_XNPPurpleCraftFailed",
                "Extra Life backup crafting failed; no item was created.",
                okCall and reason or committed)
        end
    end
    clear(self)
    return self.completionResult
end

function XNPPurpleLifeStockCraftAction:getDuration()
    return self.maxTime
end

function XNPPurpleLifeStockCraftAction:new(character, durationSeconds)
    local action = ISBaseTimedAction.new(self, character)
    action.character = character
    action.maxTime = math.max(1,
        math.floor((tonumber(durationSeconds) or 4) * 60 + 0.5))
    action.initialHealth = currentHealth(character)
    action.completionHandled = false
    action.completionResult = false
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    return action
end

return XNPPurpleLifeStockCraftAction
