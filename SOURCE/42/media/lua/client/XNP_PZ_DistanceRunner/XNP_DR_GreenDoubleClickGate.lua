XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Gate = {
    WINDOW_MS = 500,
    serial = 0,
    tickets = setmetatable({}, { __mode = "k" }),
}

function Gate.Create(player, firstEdgeId, secondEdgeId, nowMs)
    if not player or not firstEdgeId or not secondEdgeId then return nil, "DOUBLE_CLICK_PROOF_REQUIRED" end
    Gate.serial = Gate.serial + 1
    local ticket = {
        ticket_id = Gate.serial,
        player = player,
        first_edge_id = firstEdgeId,
        second_edge_id = secondEdgeId,
        created_ms = tonumber(nowMs) or 0,
        consumed = false,
    }
    Gate.tickets[player] = ticket
    return ticket, "DOUBLE_CLICK_TICKET_CREATED"
end

function Gate.Consume(player, source, ticket)
    if source ~= "GREEN_LEFT_DOUBLE_CLICK" or type(ticket) ~= "table" then
        return false, "DOUBLE_CLICK_PROOF_REQUIRED"
    end
    if ticket.player ~= player or Gate.tickets[player] ~= ticket then
        return false, "DOUBLE_CLICK_TICKET_PLAYER_MISMATCH"
    end
    if ticket.consumed == true then return false, "DOUBLE_CLICK_TICKET_ALREADY_CONSUMED" end
    ticket.consumed = true
    Gate.tickets[player] = nil
    return true, "DOUBLE_CLICK_TICKET_CONSUMED"
end

function Gate.Clear(player)
    if player then Gate.tickets[player] = nil else Gate.tickets = setmetatable({}, { __mode = "k" }) end
end

Core.GreenDoubleClickGate = Gate
return Gate
