require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState"
require "XNP_PZ_DistanceRunner/XNP_DR_MeleeClassifier"
require "XNP_PZ_DistanceRunner/XNP_DR_MeleeMode"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local MeleePower = {
    registered = false,
    tokens = {},
    tokenTtl = 2.0,
    eventContract = "SP_ONLY_POST_HIT_ENGINE_COMPUTED_DAMAGE_INPUT",
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then return getTimestampMs() / 1000 end
    return os.time()
end

local function call(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function() return obj[method](obj) end)
        if ok then return value end
    end
    return nil
end

local function identity(obj, methods)
    for i = 1, #methods do
        local value = call(obj, methods[i])
        if value ~= nil then return tostring(value) end
    end
    return tostring(obj)
end

local function cleanTokens(now)
    for token, timestamp in pairs(MeleePower.tokens) do
        if now - timestamp > MeleePower.tokenTtl then
            MeleePower.tokens[token] = nil
        end
    end
end

local function hitToken(attacker, weapon, target, hitCount)
    local now = nowSeconds()
    cleanTokens(now)
    local bucket = math.floor(now * 10)
    return table.concat({
        "SP_AUTHORITY",
        identity(attacker, { "getOnlineID", "getUsername", "getPlayerNum" }),
        identity(target, { "getOnlineID", "getPersistentOutfitID" }),
        identity(weapon, { "getID", "getFullType" }),
        tostring(hitCount or 0),
        tostring(bucket),
    }, "|")
end

local function acceptToken(token)
    if MeleePower.tokens[token] then return false end
    MeleePower.tokens[token] = nowSeconds()
    return true
end

local function statEndurance(owner)
    local stats = call(owner, "getStats")
    if not stats then return nil end
    if CharacterStat and CharacterStat.ENDURANCE and type(stats.get) == "function" then
        local ok, value = pcall(function() return stats:get(CharacterStat.ENDURANCE) end)
        if ok then return value end
    end
    return call(stats, "getEndurance")
end

function MeleePower.GetEnduranceMultiplier(owner)
    if not Core.GreenSkill then return 1.0, "GREEN_SKILL_UNAVAILABLE", nil end
    local tier = Core.GreenSkill.GetTier(owner)
    if not tier.enabled then return 1.0, "GREEN_MELEE_DISABLED", tier end
    if not Constants.IsFiniteNumber(tier.endurance) then return 1.0, "NO_ENDURANCE", tier end
    return tier.multiplier, "OK", tier
end

function MeleePower.ApplyExtraDamageOnce(target, baseDamage, multiplier)
    local health = call(target, "getHealth")
    if not Constants.IsFiniteNumber(health) or type(target.setHealth) ~= "function" then
        return false, "TARGET_HEALTH_UNAVAILABLE"
    end
    local extra = math.max((tonumber(baseDamage) or 0) * ((tonumber(multiplier) or 1) - 1), 0)
    if extra <= 0 then return false, "NO_EXTRA_DAMAGE" end
    local nextHealth = math.max(health - extra, 0.0001)
    local ok = pcall(function() target:setHealth(nextHealth) end)
    return ok, ok and "OK" or "TARGET_HEALTH_WRITE_FAILED", extra
end

function MeleePower.ValidateEventContract()
    local available = Events and Events.OnWeaponHitXp and type(Events.OnWeaponHitXp.Add) == "function"
    local client = type(isClient) == "function" and isClient() == true
    local server = type(isServer) == "function" and isServer() == true
    if client or server then
        return false, "ONWEAPONHITXP_BYTECODE_EXCLUDES_MULTIPLAYER"
    end
    return available == true, available and "SINGLEPLAYER_CONTRACT" or "EVENT_UNAVAILABLE"
end

local function logMultiplayerDisabledOnce()
    Core.MeleeMode.LogDisabledInMultiplayer()
end

function MeleePower.OnWeaponHitXp(owner, weapon, hitObject, damage, hitCount)
    local valid, reason = Core.MeleeClassifier.Classify(owner, weapon, hitObject)
    if not valid then Core.LogThrottle.Blocked("MELEE_POWER", reason); return end
    local baseDamage = tonumber(damage) or 0
    if baseDamage <= 0 then Core.LogThrottle.Blocked("MELEE_POWER", "NO_BASE_DAMAGE"); return end
    local token = hitToken(owner, weapon, hitObject, hitCount)
    if not acceptToken(token) then Core.LogThrottle.Blocked("MELEE_POWER", "DUPLICATE_HIT_TOKEN"); return end
    local multiplier, multiplierReason, tier = MeleePower.GetEnduranceMultiplier(owner)
    if multiplier <= 1.0 then Core.LogThrottle.Blocked("MELEE_POWER", multiplierReason); return end
    local ok, applyReason, extra = MeleePower.ApplyExtraDamageOnce(hitObject, baseDamage, multiplier)
    if ok then
        local paid, enduranceBefore, enduranceAfter = Core.GreenSkill.DeductEndurance(owner, tier.enduranceCost)
        print("[XNP GREEN MELEE HIT] target=" .. identity(hitObject, { "getOnlineID", "getPersistentOutfitID" })
            .. " tier=" .. tostring(tier.name)
            .. " multiplier=" .. string.format("%.2f", multiplier)
            .. " endurance_cost=" .. string.format("%.2f", tier.enduranceCost)
            .. " extra_damage=" .. string.format("%.3f", extra or 0)
            .. " cost_applied=" .. tostring(paid)
            .. " endurance_before=" .. tostring(enduranceBefore)
            .. " endurance_after=" .. tostring(enduranceAfter)
            .. " cost_order=AFTER_SUCCESSFUL_EXTRA_DAMAGE ttl_seconds=2.0")
    else
        Core.LogThrottle.Blocked("MELEE_POWER", applyReason)
    end
end

local function onWeaponHitXpAdapter(owner, weapon, hitObject, damage, hitCount)
    return MeleePower.OnWeaponHitXp(owner, weapon, hitObject, damage, hitCount)
end

function MeleePower.Register()
    if MeleePower.registered then return true end
    local valid, reason = MeleePower.ValidateEventContract()
    if not valid then
        if reason == "ONWEAPONHITXP_BYTECODE_EXCLUDES_MULTIPLAYER" then
            logMultiplayerDisabledOnce()
        elseif Core.LogThrottle then
            Core.LogThrottle.Blocked("MELEEPOWER", reason)
        end
        return false
    end
    Events.OnWeaponHitXp.Add(onWeaponHitXpAdapter)
    MeleePower.registered = true
    print("[XNP MELEE POWER] registered=true event=OnWeaponHitXp side=SINGLEPLAYER_ONLY order=POST_HIT base_damage=ENGINE_COMPUTED_INPUT classifier=STRICT_HANDWEAPON")
    return true
end

MeleePower.Register()
MeleePower.DeductEndurance = Core.GreenSkill.DeductEndurance
Core.MeleePower = MeleePower
return MeleePower
