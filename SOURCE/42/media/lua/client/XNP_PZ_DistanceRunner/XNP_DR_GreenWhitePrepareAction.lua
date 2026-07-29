require "TimedActions/ISBaseTimedAction"

XNPDRGreenWhitePrepareAction = ISBaseTimedAction:derive("XNPDRGreenWhitePrepareAction")

local function module()
    return XNP_PZ_DistanceRunner and XNP_PZ_DistanceRunner.GreenWhiteAction or nil
end

local function clear(action)
    local owner = module()
    if owner then owner.ClearAction(action.character, action) end
end

function XNPDRGreenWhitePrepareAction:isValid()
    local owner = module()
    return owner ~= nil and owner.IsActionValid(self.character, self) == true
end

function XNPDRGreenWhitePrepareAction:start()
    if CharacterActionAnims and CharacterActionAnims.Craft then self:setActionAnim(CharacterActionAnims.Craft) end
    self.soundPlayed = false
end

function XNPDRGreenWhitePrepareAction:update()
    if self.soundPlayed then return end
    local owner = module()
    if owner and owner.MidActionSoundEnabled and owner.MidActionSoundEnabled() ~= true then
        self.soundPlayed = true
        return
    end
    local ok, delta = pcall(function() return self:getJobDelta() end)
    if ok and tonumber(delta) and tonumber(delta) >= 0.50 then
        self.soundPlayed = true
        local played, handle = pcall(function() return self.character:playSound("MaleZombieDeath") end)
        print("[XNP GREEN WHITE ACTION] mid_sound=true sound=MaleZombieDeath played=" .. tostring(played)
            .. " handle=" .. tostring(handle))
    end
end

function XNPDRGreenWhitePrepareAction:stop()
    clear(self)
    print("[XNP GREEN WHITE ACTION] complete=false reason=INTERRUPTED costs_applied=false")
    ISBaseTimedAction.stop(self)
end

function XNPDRGreenWhitePrepareAction:perform()
    clear(self)
    ISBaseTimedAction.perform(self)
end

function XNPDRGreenWhitePrepareAction:complete()
    local owner = module()
    local ok, reason = false, "MODULE_UNAVAILABLE"
    if owner then ok, reason = owner.Commit(self.character, self) end
    if not ok then print("[XNP GREEN WHITE ACTION] complete=false reason=" .. tostring(reason) .. " costs_applied=false") end
    clear(self)
    return ok == true
end

function XNPDRGreenWhitePrepareAction:getDuration()
    return self.maxTime
end

function XNPDRGreenWhitePrepareAction:new(character)
    local action = ISBaseTimedAction.new(self, character)
    action.character = character
    local owner = module()
    action.maxTime = owner and owner.GetDurationTicks and owner.GetDurationTicks() or 100
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    action.soundPlayed = false
    return action
end

return XNPDRGreenWhitePrepareAction
