local Core = XNP_PZ_DistanceRunner

local LifeGate = {
    deadInstances = setmetatable({}, { __mode = "k" }),
    cancellationLogged = setmetatable({}, { __mode = "k" }),
    deathDiagnosticLogged = setmetatable({}, { __mode = "k" }),
    identityTokens = setmetatable({}, { __mode = "k" }),
    nextIdentityToken = 0,
    activeIdentity = nil,
    initializedCount = 0,
    tombstoneCount = 0,
}

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

local function currentPlayerFor(player)
    if type(getSpecificPlayer) == "function" and type(player.getPlayerNum) == "function" then
        return getSpecificPlayer(player:getPlayerNum())
    end
    if type(getPlayer) == "function" then return getPlayer() end
    return nil
end

local function normalizeHealth(value)
    if type(value) ~= "number" then return nil end
    if value > 1 then return value / 100 end
    return value
end

function LifeGate.IdentityOf(player)
    return identityOf(player)
end

function LifeGate.InitializePlayer(player, source)
    if not player then return false, "PLAYER_MISSING" end
    local identity = identityOf(player)
    if LifeGate.deadInstances[player] == true then
        return false, "DEAD_INSTANCE_TOMBSTONE"
    end
    LifeGate.activeIdentity = identity
    LifeGate.cancellationLogged[player] = nil
    LifeGate.deathDiagnosticLogged[player] = nil
    LifeGate.initializedCount = LifeGate.initializedCount + 1
    print("[XNP PHOENIX LIFE GATE] initialize identity=" .. identity .. " source=" .. tostring(source or "UNKNOWN"))
    return true, identity
end

function LifeGate.MarkDead(player, source)
    if not player then return false, "PLAYER_MISSING" end
    local identity = identityOf(player)
    if LifeGate.deadInstances[player] ~= true then
        LifeGate.deadInstances[player] = true
        LifeGate.tombstoneCount = LifeGate.tombstoneCount + 1
        if LifeGate.deathDiagnosticLogged[player] ~= true then
            LifeGate.deathDiagnosticLogged[player] = true
            print("[XNP PHOENIX LIFE GATE] tombstone identity=" .. identity .. " source=" .. tostring(source or "PLAYER_DEATH"))
        end
    end
    if LifeGate.activeIdentity == identity then LifeGate.activeIdentity = nil end
    return true, identity
end

function LifeGate.IsTombstoned(player)
    return player ~= nil and LifeGate.deadInstances[player] == true
end

-- This is the only authoritative Phoenix living check. It combines object and
-- local-player identity, the pre-corpse OnPlayerDeath tombstone, committed-death
-- state, direct health, and BodyDamage health before any Phoenix health write.
function LifeGate.IsLivingPlayer(player)
    if not player then return false, "PLAYER_MISSING" end
    if type(player.getHealth) ~= "function"
        or type(player.getBodyDamage) ~= "function"
        or type(player.isDead) ~= "function"
        or type(player.isOnDeathDone) ~= "function" then
        return false, "PLAYER_API_INCOMPLETE"
    end

    local identity = identityOf(player)
    if LifeGate.deadInstances[player] == true then
        return false, "DEAD_INSTANCE_TOMBSTONE"
    end

    local current = currentPlayerFor(player)
    if current ~= player then return false, "PLAYER_REPLACED" end
    if type(player.isLocalPlayer) == "function" and player:isLocalPlayer() ~= true then
        return false, "NOT_LOCAL_PLAYER"
    end
    if player:isOnDeathDone() == true then return false, "DEATH_DONE" end
    if player:isDead() == true then return false, "ENGINE_DEAD" end
    if type(player.isAlive) == "function" and player:isAlive() ~= true then
        return false, "ENGINE_NOT_ALIVE"
    end

    local directHealth = normalizeHealth(player:getHealth())
    if not directHealth or directHealth <= 0 then return false, "DIRECT_HEALTH_NONPOSITIVE" end

    local body = player:getBodyDamage()
    if not body or type(body.getOverallBodyHealth) ~= "function" then
        return false, "BODY_DAMAGE_UNAVAILABLE"
    end
    local bodyHealth = normalizeHealth(body:getOverallBodyHealth())
    if not bodyHealth or bodyHealth <= 0 then return false, "BODY_HEALTH_NONPOSITIVE" end

    return true, "LIVING", {
        identity = identity,
        directHealth = directHealth,
        bodyHealth = bodyHealth,
        body = body,
    }
end

function LifeGate.LogCommittedCancellationOnce(player, source, detail)
    if not player or LifeGate.cancellationLogged[player] == true
        or LifeGate.deathDiagnosticLogged[player] == true then return false end
    LifeGate.cancellationLogged[player] = true
    LifeGate.deathDiagnosticLogged[player] = true
    print("[XNP PHOENIX] cancel reason=DEATH_ALREADY_COMMITTED source="
        .. tostring(source or "UNKNOWN") .. " detail=" .. tostring(detail or "UNKNOWN"))
    return true
end

function LifeGate.ReleasePlayer(player)
    local identity = identityOf(player)
    if LifeGate.activeIdentity == identity then LifeGate.activeIdentity = nil end
end

function LifeGate.ResetSession()
    LifeGate.deadInstances = setmetatable({}, { __mode = "k" })
    LifeGate.cancellationLogged = setmetatable({}, { __mode = "k" })
    LifeGate.deathDiagnosticLogged = setmetatable({}, { __mode = "k" })
    LifeGate.identityTokens = setmetatable({}, { __mode = "k" })
    LifeGate.nextIdentityToken = 0
    LifeGate.activeIdentity = nil
end

function LifeGate.GetAuditSnapshot()
    return {
        activeIdentity = LifeGate.activeIdentity,
        initializedCount = LifeGate.initializedCount,
        tombstoneCount = LifeGate.tombstoneCount,
    }
end

Core.PhoenixLifeGate = LifeGate
return LifeGate
