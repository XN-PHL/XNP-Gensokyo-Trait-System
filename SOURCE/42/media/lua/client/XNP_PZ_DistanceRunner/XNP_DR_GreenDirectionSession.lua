local Core = XNP_PZ_DistanceRunner

local Session = { RESET_MS = 2000, owners = setmetatable({}, { __mode = "k" }) }

function Session.Preview(player, nowMs)
    nowMs = math.floor(tonumber(nowMs) or 0)
    local current = Session.owners[player]
    local elapsed = current and nowMs - current.lastAcceptedCastMs or nil
    local reset = current == nil or elapsed == nil or elapsed >= Session.RESET_MS
    return {
        random = not reset,
        sequence = reset and 1 or current.sessionSequence + 1,
        generation = reset and ((current and current.sessionGeneration or 0) + 1)
            or current.sessionGeneration,
        elapsedMs = elapsed,
    }
end

function Session.Commit(player, nowMs, candidate)
    if not player or type(candidate) ~= "table" then return false end
    Session.owners[player] = { lastAcceptedCastMs = math.floor(tonumber(nowMs) or 0),
        sessionSequence = candidate.sequence, sessionGeneration = candidate.generation }
    return true
end

function Session.Clear(player)
    if player then Session.owners[player] = nil
    else Session.owners = setmetatable({}, { __mode = "k" }) end
end

Core.GreenDirectionSession = Session
return Session
