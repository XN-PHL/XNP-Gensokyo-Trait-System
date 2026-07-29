require "TimedActions/ISBaseTimedAction"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Sound"

XNPPurpleLifeStockRestoreAction = ISBaseTimedAction:derive(
    "XNPPurpleLifeStockRestoreAction")

local function transactions()
    return XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.PurpleLifeStockTransactions or nil
end

local function sound()
    return XNP_PZ_DistanceRunner
        and XNP_PZ_DistanceRunner.PurpleLifeStockSound or nil
end

local function clear(action)
    local tx = transactions()
    if tx and type(tx.ClearRestoreAction) == "function" then
        tx.ClearRestoreAction(action)
    end
end

function XNPPurpleLifeStockRestoreAction:isValid()
    local tx = transactions()
    if not self.character or not self.item or not tx then return false end
    if type(self.character.isDead) == "function" and self.character:isDead() then
        return false
    end
    if type(self.character.isAiming) == "function" and self.character:isAiming() then
        return false
    end
    if type(self.character.isAttacking) == "function"
        and self.character:isAttacking() then return false end
    local ok = tx.PreflightRestore(self.character, self.item, self)
    return ok == true
end

function XNPPurpleLifeStockRestoreAction:start()
    if self.item and type(self.item.setJobType) == "function" then
        self.item:setJobType(getText("ContextMenu_XNPPurpleUseBackup"))
        self.item:setJobDelta(0.0)
    end
    self.animationSet = false
    if CharacterActionAnims and CharacterActionAnims.Eat then
        self:setActionAnim(CharacterActionAnims.Eat)
        self.animationSet = true
    end
    if type(self.setOverrideHandModels) == "function" then
        self:setOverrideHandModels(self.item, nil)
    end
    local audio = sound()
    if audio then audio.LogDeferred("RESTORE_START", "SUCCESS_SOUND_DEFERRED") end
    print("[XNP PURPLE RESTORE ACTION] start=true animation=Eat"
        .. " animation_set_success=" .. tostring(self.animationSet)
        .. " max_time=" .. tostring(self.maxTime)
        .. " progress_bar_route=ISBaseTimedAction")
end

function XNPPurpleLifeStockRestoreAction:update()
    if self.item and type(self.item.setJobDelta) == "function" then
        self.item:setJobDelta(self:getJobDelta())
    end
end

function XNPPurpleLifeStockRestoreAction:stop()
    if self.item and type(self.item.setJobDelta) == "function" then
        self.item:setJobDelta(0.0)
    end
    clear(self)
    local audio = sound()
    if audio then
        audio.NotifyFailure(self.character, "UI_XNPPurpleRestoreCancelled",
            "Extra Life restore cancelled; the backup was not consumed.",
            "TIMED_ACTION_CANCELLED")
    end
    print("[XNP PURPLE RESTORE ACTION] complete=false"
        .. " item_preserved=true success_sound_call=false reason=INTERRUPTED")
    ISBaseTimedAction.stop(self)
end

function XNPPurpleLifeStockRestoreAction:perform()
    if self.item and type(self.item.setJobDelta) == "function" then
        self.item:setJobDelta(0.0)
    end
    clear(self)
    ISBaseTimedAction.perform(self)
end

function XNPPurpleLifeStockRestoreAction:complete()
    if self.completionHandled then return self.completionResult == true end
    self.completionHandled = true
    self.completionResult = false
    if not self:isValid() then
        clear(self)
        return false
    end
    local tx = transactions()
    local okCall, restored, reason = pcall(
        tx.CommitRestore, self.character, self.item)
    self.completionResult = okCall and restored == true
    if not self.completionResult then
        local audio = sound()
        if audio then
            audio.NotifyFailure(self.character, "UI_XNPPurpleRestoreFailed",
                "Extra Life restore failed; the backup was not consumed.",
                okCall and reason or restored)
        end
    end
    clear(self)
    return self.completionResult
end

function XNPPurpleLifeStockRestoreAction:getDuration()
    return self.maxTime
end

function XNPPurpleLifeStockRestoreAction:new(character, item, durationSeconds)
    local action = ISBaseTimedAction.new(self, character)
    action.character = character
    action.item = item
    action.maxTime = math.max(1,
        math.floor((tonumber(durationSeconds) or 4) * 60 + 0.5))
    action.completionHandled = false
    action.completionResult = false
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    return action
end

return XNPPurpleLifeStockRestoreAction
