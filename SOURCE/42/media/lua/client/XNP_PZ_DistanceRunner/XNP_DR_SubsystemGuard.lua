local Core = XNP_PZ_DistanceRunner

local Guard = {
    counters = {},
    lastError = {},
}

local VALID_SYSTEMS = { YELLOW = true, PURPLE = true, GREEN = true, RED = true, CORE = true }

local function record(system, field)
    local state = Guard.counters[system]
    if not state then
        state = { attempts = 0, successes = 0, failures = 0 }
        Guard.counters[system] = state
    end
    state[field] = (state[field] or 0) + 1
    return state
end

function Guard.Execute(system, transactionName, fn)
    system = string.upper(tostring(system or "CORE"))
    if not VALID_SYSTEMS[system] then system = "CORE" end
    transactionName = tostring(transactionName or "TRANSACTION")
    record(system, "attempts")
    local ok, first, second, third = pcall(fn)
    if ok then
        record(system, "successes")
        return true, first, second, third
    end
    local state = record(system, "failures")
    Guard.lastError[system] = tostring(first)
    print("[XNP SUBSYSTEM ERROR] system=" .. system
        .. " transaction=" .. transactionName
        .. " failure_count=" .. tostring(state.failures)
        .. " retry_next_transaction=true error=" .. tostring(first))
    return false, "SUBSYSTEM_EXCEPTION", tostring(first)
end

function Guard.GetAuditSnapshot()
    local snapshot = { sticky_global_disable = false }
    for system, counters in pairs(Guard.counters) do
        snapshot[system] = {
            attempts = counters.attempts,
            successes = counters.successes,
            failures = counters.failures,
            last_error = Guard.lastError[system],
            retry_allowed = true,
        }
    end
    return snapshot
end

Core.SubsystemGuard = Guard
return Guard
