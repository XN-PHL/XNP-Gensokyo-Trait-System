require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"

local Core = XNP_PZ_DistanceRunner

local LifeGate = {
    deadInstances = setmetatable({}, { __mode = "k" }),
    cancellationLogged = setmetatable({}, { __mode = "k" }),
    identityTokens = setmetatable({}, { __mode = "k" }),
    nextIdentityToken = 0,
    activeIdentity = nil,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    return pcall(object[method], object, ...)
end

local function identityOf(player)
    if not player then return "nil" end
    local token = LifeGate.identityTokens[player]
    if not token then
        LifeGate.nextIdentityToken = LifeGate.nextIdentityToken + 1
        token = "local-player-" .. tostring(LifeGate.nextIdentityToken)
        LifeGate.identityTokens[player] = token
    end
    return token
end

local function normalizeHealth(value)
    if type(value) ~= "number" then return nil end
    return value > 1 and value / 100 or value
end

local function currentPlayerFor(player)
    local okIndex, index = invoke(player, "getPlayerNum")
    if okIndex and type(getSpecificPlayer) == "function" then
        local ok, current = pcall(getSpecificPlayer, tonumber(index) or 0)
        if ok then return current end
    end
    if type(getPlayer) == "function" then
        local ok, current = pcall(getPlayer)
        if ok then return current end
    end
    return player
end

function LifeGate.IdentityOf(player)
    return identityOf(player)
end

function LifeGate.InitializePlayer(player, source)
    if not player then return false, "PLAYER_MISSING" end
    local valid, reason = Core.CanonicalPlayerIdentity.Validate(player, true)
    if not valid then return false, "IDENTITY_REJECTED:" .. tostring(reason) end
    LifeGate.deadInstances[player] = nil
    LifeGate.cancellationLogged[player] = nil
    LifeGate.activeIdentity = identityOf(player)
    print("[XNP PHOENIX SURVIVAL] life_gate_initialized=true source="
        .. tostring(source or "UNKNOWN")
        .. " identity=" .. LifeGate.activeIdentity)
    return true, LifeGate.activeIdentity
end

function LifeGate.MarkDead(player, source)
    if not player then return false, "PLAYER_MISSING" end
    LifeGate.deadInstances[player] = true
    local identity = identityOf(player)
    if LifeGate.activeIdentity == identity then LifeGate.activeIdentity = nil end
    print("[XNP PHOENIX SURVIVAL] life_gate_tombstoned=true source="
        .. tostring(source or "PLAYER_DEATH")
        .. " identity=" .. identity)
    return true, identity
end

function LifeGate.IsTombstoned(player)
    return player ~= nil and LifeGate.deadInstances[player] == true
end

function LifeGate.IsLivingPlayer(player)
    if not player then return false, "PLAYER_MISSING" end
    local identityValid, identityReason =
        Core.CanonicalPlayerIdentity.Validate(player, true)
    if not identityValid then
        return false, "IDENTITY_REJECTED:" .. tostring(identityReason)
    end
    if LifeGate.deadInstances[player] == true then
        return false, "DEAD_INSTANCE_TOMBSTONE"
    end
    if currentPlayerFor(player) ~= player then return false, "PLAYER_REPLACED" end

    local okDeathDone, deathDone = invoke(player, "isOnDeathDone")
    if okDeathDone and deathDone == true then return false, "DEATH_DONE" end
    local okDead, dead = invoke(player, "isDead")
    if okDead and dead == true then return false, "ENGINE_DEAD" end
    local okAlive, alive = invoke(player, "isAlive")
    if okAlive and alive ~= true then return false, "ENGINE_NOT_ALIVE" end

    local okHealth, health = invoke(player, "getHealth")
    local directHealth = okHealth and normalizeHealth(health) or nil
    if not directHealth or directHealth <= 0 then
        return false, "DIRECT_HEALTH_NONPOSITIVE"
    end
    local okBody, body = invoke(player, "getBodyDamage")
    local okBodyHealth, bodyHealth = invoke(body, "getOverallBodyHealth")
    bodyHealth = okBodyHealth and normalizeHealth(bodyHealth) or nil
    if not okBody or not body or not bodyHealth or bodyHealth <= 0 then
        return false, "BODY_HEALTH_NONPOSITIVE"
    end
    return true, "LIVING", {
        identity = identityOf(player),
        directHealth = directHealth,
        bodyHealth = bodyHealth,
        body = body,
    }
end

function LifeGate.LogCommittedCancellationOnce(player, source, detail)
    if not player or LifeGate.cancellationLogged[player] == true then return false end
    LifeGate.cancellationLogged[player] = true
    print("[XNP PHOENIX SURVIVAL] cancel=true reason=DEATH_ALREADY_COMMITTED"
        .. " source=" .. tostring(source or "UNKNOWN")
        .. " detail=" .. tostring(detail or "UNKNOWN"))
    return true
end

function LifeGate.ReleasePlayer(player)
    local identity = identityOf(player)
    if LifeGate.activeIdentity == identity then LifeGate.activeIdentity = nil end
    return true
end

function LifeGate.ResetSession()
    LifeGate.deadInstances = setmetatable({}, { __mode = "k" })
    LifeGate.cancellationLogged = setmetatable({}, { __mode = "k" })
    LifeGate.identityTokens = setmetatable({}, { __mode = "k" })
    LifeGate.nextIdentityToken = 0
    LifeGate.activeIdentity = nil
    return true
end

function LifeGate.GetAuditSnapshot()
    return {
        active_identity = LifeGate.activeIdentity,
        predeath_gate_active = true,
        death_allowed_when_not_intercepted = true,
    }
end

Core.PhoenixLifeGate = LifeGate
return LifeGate
