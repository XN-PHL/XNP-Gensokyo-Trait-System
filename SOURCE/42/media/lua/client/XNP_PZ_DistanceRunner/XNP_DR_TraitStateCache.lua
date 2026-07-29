require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_CanonicalPlayerIdentity"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner

local Cache = {
    INTERVAL_MS = 30000,
    player = nil,
    identityGeneration = "UNBOUND",
    sandboxHash = "UNSET",
    state = nil,
    fingerprint = nil,
    dirty = true,
    dirtyReason = "BOOT",
    nextFullScanMs = 0,
    fullTraitScanCount = 0,
    uiRebuildCount = 0,
    zeroTraitsLogCount = 0,
    stableFrameCount = 0,
    lastScanReason = "NONE",
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function generationKey()
    if not Core.CanonicalPlayerIdentity
        or type(Core.CanonicalPlayerIdentity.GetAuditSnapshot) ~= "function" then
        return "IDENTITY_AUDIT_UNAVAILABLE"
    end
    local audit = Core.CanonicalPlayerIdentity.GetAuditSnapshot() or {}
    return tostring(audit.world_generation or 0)
        .. ":" .. tostring(audit.binding_generation or 0)
        .. ":" .. tostring(audit.character_generation or 0)
end

local function protectedBoolean(callback)
    local ok, value = pcall(callback)
    return ok and value == true
end

local function refreshYellow(player)
    return protectedBoolean(function()
        if Core.Trait and type(Core.Trait.RefreshForPlayer) == "function" then
            return Core.Trait.RefreshForPlayer(player)
        end
        return Core.Trait and Core.Trait.PlayerHasTrait(player)
    end)
end

local function refreshPurple(player)
    return protectedBoolean(function()
        if Core.PurplePhoenixTrait
            and type(Core.PurplePhoenixTrait.Refresh) == "function" then
            return Core.PurplePhoenixTrait.Refresh(player)
        end
        return Core.PurplePhoenixTrait
            and Core.PurplePhoenixTrait.PlayerHasTrait(player)
    end)
end

local function refreshExtra(player, key)
    return protectedBoolean(function()
        if Core.ExtraTraits and type(Core.ExtraTraits.Refresh) == "function" then
            return Core.ExtraTraits.Refresh(player, key)
        end
        return Core.ExtraTraits and Core.ExtraTraits.PlayerHas(player, key)
    end)
end

local function makeState(player)
    local state = {
        yellow = refreshYellow(player),
        purple = refreshPurple(player),
        green = refreshExtra(player, "GREEN"),
        red = refreshExtra(player, "RED"),
    }
    state.count = (state.yellow and 1 or 0)
        + (state.purple and 1 or 0)
        + (state.green and 1 or 0)
        + (state.red and 1 or 0)
    state.any = state.count > 0
    state.fingerprint = table.concat({
        state.yellow and "Y1" or "Y0",
        state.purple and "P1" or "P0",
        state.green and "G1" or "G0",
        state.red and "R1" or "R0",
    }, "|")
    return state
end

function Cache.Invalidate(reason)
    Cache.dirty = true
    Cache.dirtyReason = tostring(reason or "EXPLICIT_INVALIDATION")
    Cache.nextFullScanMs = 0
    return true
end

function Cache.Scan(player, sandboxHash, reason)
    local previousFingerprint = Cache.fingerprint
    local previousPlayer = Cache.player
    local previousGeneration = Cache.identityGeneration
    local previousSandboxHash = Cache.sandboxHash
    local generation = generationKey()
    local hash = tostring(sandboxHash or "NO_SANDBOX_SNAPSHOT")
    local state = makeState(player)

    Cache.player = player
    Cache.identityGeneration = generation
    Cache.sandboxHash = hash
    Cache.state = state
    Cache.fingerprint = state.fingerprint
    Cache.dirty = false
    Cache.dirtyReason = "NONE"
    Cache.nextFullScanMs = nowMs() + Cache.INTERVAL_MS
    Cache.fullTraitScanCount = Cache.fullTraitScanCount + 1
    Cache.lastScanReason = tostring(reason or "PERIODIC_INTERVAL")

    local changed = previousPlayer ~= player
        or previousGeneration ~= generation
        or previousSandboxHash ~= hash
        or previousFingerprint ~= state.fingerprint
    if changed then
        print("[XNP TRAIT STATE] changed=true reason=" .. Cache.lastScanReason
            .. " fingerprint=" .. state.fingerprint
            .. " character_generation=" .. generation
            .. " full_trait_scan_count=" .. tostring(Cache.fullTraitScanCount))
    end
    return state, changed, true
end

function Cache.Get(player, sandboxHash)
    local generation = generationKey()
    local hash = tostring(sandboxHash or "NO_SANDBOX_SNAPSHOT")
    local reason = nil
    if Cache.dirty then
        reason = Cache.dirtyReason
    elseif Cache.player ~= player then
        reason = "PLAYER_REFERENCE_CHANGED"
    elseif Cache.identityGeneration ~= generation then
        reason = "PLAYER_GENERATION_CHANGED"
    elseif Cache.sandboxHash ~= hash then
        reason = "SANDBOX_HASH_CHANGED"
    elseif nowMs() >= Cache.nextFullScanMs then
        reason = "PERIODIC_INTERVAL"
    end
    if reason then return Cache.Scan(player, hash, reason) end
    Cache.stableFrameCount = Cache.stableFrameCount + 1
    return Cache.state or {
        yellow = false, purple = false, green = false, red = false,
        count = 0, any = false, fingerprint = "Y0|P0|G0|R0",
    }, false, false
end

function Cache.MarkUiRebuild(state, reason)
    Cache.uiRebuildCount = Cache.uiRebuildCount + 1
    if not state or state.count == 0 then
        Cache.zeroTraitsLogCount = Cache.zeroTraitsLogCount + 1
    end
    print("[XNP UI REBUILD] visible_marker_count="
        .. tostring(state and state.count or 0)
        .. " stale_marker_hitbox_count=0 reason="
        .. tostring(reason or "TRAIT_STATE_CHANGED")
        .. " ui_rebuild_count=" .. tostring(Cache.uiRebuildCount))
    return Cache.uiRebuildCount
end

function Cache.GetAuditSnapshot()
    return {
        full_trait_scan_count = Cache.fullTraitScanCount,
        ui_rebuild_count = Cache.uiRebuildCount,
        zero_traits_log_count = Cache.zeroTraitsLogCount,
        stable_frame_count = Cache.stableFrameCount,
        fingerprint = Cache.fingerprint,
        identity_generation = Cache.identityGeneration,
        sandbox_hash = Cache.sandboxHash,
        dirty = Cache.dirty,
        last_scan_reason = Cache.lastScanReason,
        interval_ms = Cache.INTERVAL_MS,
    }
end

function Cache.ResetSession(reason)
    Cache.player = nil
    Cache.identityGeneration = "UNBOUND"
    Cache.sandboxHash = "UNSET"
    Cache.state = nil
    Cache.fingerprint = nil
    Cache.dirty = true
    Cache.dirtyReason = tostring(reason or "SESSION_RESET")
    Cache.nextFullScanMs = 0
    Cache.fullTraitScanCount = 0
    Cache.uiRebuildCount = 0
    Cache.zeroTraitsLogCount = 0
    Cache.stableFrameCount = 0
    Cache.lastScanReason = "NONE"
end

Core.TraitStateCache = Cache
return Cache
