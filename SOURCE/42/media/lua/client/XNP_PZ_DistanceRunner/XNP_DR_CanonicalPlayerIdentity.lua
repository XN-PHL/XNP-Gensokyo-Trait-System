local Core = XNP_PZ_DistanceRunner

local Identity = {
    player_ref = nil,
    player_index = nil,
    player_num = nil,
    online_id_or_local_id = nil,
    username_or_forename_for_diagnostic_only = nil,
    descriptor_ref = nil,
    visual_ref = nil,
    world_generation = 0,
    binding_generation = 0,
    character_generation = 0,
    bound_at_event = nil,
    tombstoned = false,
    tombstoned_player_ref = nil,
    tombstoned_descriptor_ref = nil,
    tombstoned_binding_generation = nil,
    tombstoned_character_generation = nil,
    tombstoned_at_ms = nil,
    next_diagnostic_ms = 0,
    last_descriptor_ref = nil,
    last_visual_ref = nil,
    successor_candidate_ref = nil,
    successor_candidate_index = nil,
    successor_confirmation_frames = 0,
    successor_source = nil,
    successor_lifecycle_evidence = false,
    successor_npc_rejected_count = 0,
    duplicate_tombstone_count = 0,
    next_tombstone_summary_ms = 0,
    local_rejection_count = 0,
}

local SUCCESSOR_CONFIRM_FRAMES = 3
local TOMBSTONE_SUMMARY_INTERVAL_MS = 10000

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function specificPlayer(index)
    if type(getSpecificPlayer) ~= "function" then return nil end
    local ok, player = pcall(getSpecificPlayer, index or 0)
    return ok and player or nil
end

local function primaryPlayer()
    if type(getPlayer) ~= "function" then return nil end
    local ok, player = pcall(getPlayer)
    return ok and player or nil
end

local function objectId(object)
    return object and tostring(object) or "nil"
end

local function numericIdentity(player, index)
    local ok, value = invoke(player, "getOnlineID")
    if ok and value ~= nil then return value end
    ok, value = invoke(player, "getPlayerNum")
    if ok and value ~= nil then return value end
    return index
end

local function diagnosticName(player)
    local ok, value = invoke(player, "getUsername")
    if ok and value and tostring(value) ~= "" then return tostring(value) end
    ok, value = invoke(player, "getForename")
    if ok and value and tostring(value) ~= "" then return tostring(value) end
    return "<empty>"
end

local function isDead(player)
    local ok, value = invoke(player, "isDead")
    if ok and value == true then return true end
    ok, value = invoke(player, "isOnDeathDone")
    if ok and value == true then return true end
    ok, value = invoke(player, "isAlive")
    return ok and value == false
end

local function rejectFlag(player, method)
    local ok, value = invoke(player, method)
    return ok and value == true
end

local function validateControlledCandidate(player, index, requireLiving)
    if not player then return false, "PLAYER_MISSING" end
    if specificPlayer(index) ~= player then return false, "SPECIFIC_PLAYER_MISMATCH" end
    local primary = index == 0 and primaryPlayer() or player
    if index == 0 and primary and primary ~= player then return false, "PRIMARY_PLAYER_MISMATCH" end
    if requireLiving ~= false and isDead(player) then return false, "DEAD_PLAYER" end
    local localOk, localValue = invoke(player, "isLocalPlayer")
    if localOk and localValue ~= true then return false, "NOT_LOCAL_PLAYER" end
    for _, method in ipairs({ "isNPC", "isBandit", "isSpectator", "isProxyPlayer" }) do
        if rejectFlag(player, method) then return false, string.upper(method) .. "_REJECTED" end
    end
    return true, "CONTROLLED_LOCAL_PLAYER"
end

local function clearSuccessorCandidate()
    Identity.successor_candidate_ref = nil
    Identity.successor_candidate_index = nil
    Identity.successor_confirmation_frames = 0
    Identity.successor_source = nil
    Identity.successor_lifecycle_evidence = false
end

local function assignCurrent(player, index, source, isSuccessor)
    local _, playerNum = invoke(player, "getPlayerNum")
    local _, descriptor = invoke(player, "getDescriptor")
    local _, visual = invoke(player, "getHumanVisual")
    local oldBindingGeneration = Identity.binding_generation
    local oldCharacterGeneration = Identity.character_generation
    Identity.player_ref = player
    Identity.player_index = index
    Identity.player_num = tonumber(playerNum) or index
    Identity.online_id_or_local_id = numericIdentity(player, index)
    Identity.username_or_forename_for_diagnostic_only = diagnosticName(player)
    Identity.descriptor_ref = descriptor
    Identity.visual_ref = visual
    Identity.last_descriptor_ref = descriptor
    Identity.last_visual_ref = visual
    Identity.binding_generation = Identity.binding_generation + 1
    Identity.character_generation = Identity.character_generation + 1
    Identity.bound_at_event = source or "UNKNOWN"
    Identity.tombstoned = false
    clearSuccessorCandidate()
    if isSuccessor then
        print("[XNP PLAYER IDENTITY] successor_confirmed=true source=POST_DEATH_NEW_CHARACTER"
            .. " old_binding_generation=" .. tostring(oldBindingGeneration)
            .. " new_binding_generation=" .. tostring(Identity.binding_generation)
            .. " old_character_generation=" .. tostring(oldCharacterGeneration)
            .. " new_character_generation=" .. tostring(Identity.character_generation)
            .. " player_index=" .. tostring(index)
            .. " npc_rejected_count=" .. tostring(Identity.successor_npc_rejected_count))
    else
        print("[XNP PLAYER IDENTITY] bound=true player_index=" .. tostring(index)
            .. " binding_generation=" .. tostring(Identity.binding_generation)
            .. " character_generation=" .. tostring(Identity.character_generation)
            .. " world_generation=" .. tostring(Identity.world_generation)
            .. " source=" .. tostring(Identity.bound_at_event))
    end
    return true, isSuccessor and "POST_DEATH_SUCCESSOR_BOUND" or "CANONICAL_PLAYER_BOUND"
end

function Identity.BeginWorld(source)
    Identity.world_generation = Identity.world_generation + 1
    Identity.player_ref = nil
    Identity.player_index = nil
    Identity.player_num = nil
    Identity.online_id_or_local_id = nil
    Identity.username_or_forename_for_diagnostic_only = nil
    Identity.descriptor_ref = nil
    Identity.visual_ref = nil
    Identity.character_generation = 0
    Identity.bound_at_event = source or "WORLD_BEGIN"
    Identity.tombstoned = false
    Identity.tombstoned_player_ref = nil
    Identity.tombstoned_descriptor_ref = nil
    Identity.tombstoned_binding_generation = nil
    Identity.tombstoned_character_generation = nil
    Identity.tombstoned_at_ms = nil
    Identity.next_diagnostic_ms = 0
    Identity.last_descriptor_ref = nil
    Identity.last_visual_ref = nil
    Identity.successor_npc_rejected_count = 0
    Identity.duplicate_tombstone_count = 0
    Identity.next_tombstone_summary_ms = 0
    Identity.local_rejection_count = 0
    clearSuccessorCandidate()
    print("[XNP PLAYER IDENTITY] world_begin generation=" .. tostring(Identity.world_generation)
        .. " source=" .. tostring(source or "WORLD_BEGIN"))
end

function Identity.Bind(player, playerIndex, source)
    local index = tonumber(playerIndex) or 0
    local valid, reason = validateControlledCandidate(player, index, true)
    if not valid then return false, reason end
    if Identity.player_ref == player and not Identity.tombstoned then
        return true, "CANONICAL_PLAYER_ALREADY_BOUND"
    end
    if Identity.player_ref and Identity.player_ref ~= player then
        if Identity.tombstoned and Identity.tombstoned_player_ref == Identity.player_ref
            and tostring(source or "") == "CREATE_PLAYER" then
            Identity.successor_candidate_ref = player
            Identity.successor_candidate_index = index
            Identity.successor_confirmation_frames = 0
            Identity.successor_source = source
            Identity.successor_lifecycle_evidence = true
            print("[XNP PLAYER IDENTITY] successor_candidate=true source=POST_DEATH_NEW_CHARACTER"
                .. " player_index=" .. tostring(index)
                .. " confirm_frames=" .. tostring(SUCCESSOR_CONFIRM_FRAMES))
            return false, "SUCCESSOR_CONFIRMATION_PENDING"
        end
        Identity.local_rejection_count = Identity.local_rejection_count + 1
        return false, "UNKNOWN_PLAYER_REBIND_BLOCKED"
    end
    return assignCurrent(player, index, source, false)
end

-- This resolver never mutates a global lock. A mismatch rejects only the
-- current call; the next input or frame performs a fresh slot comparison.
function Identity.ResolveCurrentControlledPlayer(playerIndex, optionalEventCandidate, requireLiving)
    local index = tonumber(playerIndex)
    if index == nil then index = Identity.player_index or 0 end
    local slotPlayer = specificPlayer(index)
    if not slotPlayer then return nil, "SPECIFIC_PLAYER_UNAVAILABLE" end
    local primary = index == 0 and primaryPlayer() or slotPlayer
    if index == 0 and primary and primary ~= slotPlayer then
        Identity.local_rejection_count = Identity.local_rejection_count + 1
        return nil, "PRIMARY_SLOT_TRANSIENT_MISMATCH"
    end
    if optionalEventCandidate and optionalEventCandidate ~= slotPlayer then
        Identity.local_rejection_count = Identity.local_rejection_count + 1
        return nil, "NONCANONICAL_EVENT_CANDIDATE"
    end
    if Identity.tombstoned and slotPlayer == Identity.tombstoned_player_ref then
        return nil, "CANONICAL_PLAYER_TOMBSTONED"
    end
    if not Identity.player_ref then return nil, "CANONICAL_PLAYER_UNBOUND" end
    if Identity.player_ref ~= slotPlayer then
        Identity.local_rejection_count = Identity.local_rejection_count + 1
        return nil, "BOUND_PLAYER_SLOT_MISMATCH"
    end
    local valid, reason = validateControlledCandidate(slotPlayer, index, requireLiving)
    if not valid then
        Identity.local_rejection_count = Identity.local_rejection_count + 1
        return nil, reason
    end
    return slotPlayer, "IDENTITY_MATCH"
end

Identity.resolveCurrentControlledPlayer = Identity.ResolveCurrentControlledPlayer

function Identity.ObserveSuccessor(candidate, source)
    local pending = Identity.successor_candidate_ref
    if not pending then return false, "NO_SUCCESSOR_PENDING" end
    if candidate ~= pending then
        Identity.successor_npc_rejected_count = Identity.successor_npc_rejected_count + 1
        return false, "NON_CANDIDATE_OBJECT_REJECTED"
    end
    if not Identity.successor_lifecycle_evidence then
        clearSuccessorCandidate()
        return false, "CREATE_PLAYER_EVIDENCE_MISSING"
    end
    if not Identity.tombstoned or Identity.tombstoned_player_ref ~= Identity.player_ref then
        clearSuccessorCandidate()
        return false, "OLD_PLAYER_NOT_TOMBSTONED"
    end
    local valid, reason = validateControlledCandidate(candidate, Identity.successor_candidate_index, true)
    if not valid then
        Identity.successor_npc_rejected_count = Identity.successor_npc_rejected_count + 1
        clearSuccessorCandidate()
        return false, "SUCCESSOR_REJECTED:" .. tostring(reason)
    end
    Identity.successor_confirmation_frames = Identity.successor_confirmation_frames + 1
    if Identity.successor_confirmation_frames < SUCCESSOR_CONFIRM_FRAMES then
        return false, "SUCCESSOR_CONFIRMATION_PENDING"
    end
    local index = Identity.successor_candidate_index
    return assignCurrent(candidate, index, source or "POST_DEATH_NEW_CHARACTER", true)
end

function Identity.Validate(candidate, requireLiving)
    if not candidate then return false, "PLAYER_MISSING" end
    if candidate == Identity.tombstoned_player_ref then return false, "TOMBSTONED_PLAYER" end
    local resolved, reason = Identity.ResolveCurrentControlledPlayer(
        Identity.player_index or 0, candidate, requireLiving)
    return resolved == candidate, reason
end

function Identity.GetPlayer(requireLiving)
    return Identity.ResolveCurrentControlledPlayer(Identity.player_index or 0, nil, requireLiving)
end

local function logDuplicateTombstoneSummary(now)
    if Identity.duplicate_tombstone_count <= 0 or now < Identity.next_tombstone_summary_ms then return end
    print("[XNP PLAYER IDENTITY] tombstone_duplicate_summary count="
        .. tostring(Identity.duplicate_tombstone_count)
        .. " interval_ms=" .. tostring(TOMBSTONE_SUMMARY_INTERVAL_MS))
    Identity.duplicate_tombstone_count = 0
    Identity.next_tombstone_summary_ms = now + TOMBSTONE_SUMMARY_INTERVAL_MS
end

function Identity.MarkDead(player, source)
    if player == Identity.tombstoned_player_ref then
        local now = nowMs()
        Identity.duplicate_tombstone_count = Identity.duplicate_tombstone_count + 1
        logDuplicateTombstoneSummary(now)
        return false, "ALREADY_TOMBSTONED"
    end
    if player and Identity.player_ref and player ~= Identity.player_ref then
        return false, "NON_CANONICAL_DEATH_EVENT"
    end
    if player == Identity.player_ref then
        Identity.tombstoned = true
        Identity.tombstoned_player_ref = player
        Identity.tombstoned_descriptor_ref = Identity.descriptor_ref
        Identity.tombstoned_binding_generation = Identity.binding_generation
        Identity.tombstoned_character_generation = Identity.character_generation
        Identity.tombstoned_at_ms = nowMs()
        Identity.next_tombstone_summary_ms = Identity.tombstoned_at_ms + TOMBSTONE_SUMMARY_INTERVAL_MS
        print("[XNP PLAYER IDENTITY] tombstoned=true binding_generation="
            .. tostring(Identity.binding_generation)
            .. " character_generation=" .. tostring(Identity.character_generation)
            .. " source=" .. tostring(source or "PLAYER_DEATH"))
        return true, "CANONICAL_PLAYER_TOMBSTONED"
    end
    return false, "CANONICAL_PLAYER_UNBOUND"
end

function Identity.IsTombstoned(player)
    return player ~= nil and player == Identity.tombstoned_player_ref
end

function Identity.UpdateDiagnostic(candidate)
    local now = nowMs()
    logDuplicateTombstoneSummary(now)
    if now < Identity.next_diagnostic_ms then return false end
    local level = Core.SandboxTuning and Core.SandboxTuning.GetNumber
        and Core.SandboxTuning.GetNumber("DiagnosticLogLevel", 2, 1, 4) or 2
    if level < 3 then return false end
    Identity.next_diagnostic_ms = now + 1000
    local valid = Identity.Validate(candidate, false) == true
    local _, descriptor = invoke(candidate, "getDescriptor")
    local _, visual = invoke(candidate, "getHumanVisual")
    local _, dead = invoke(candidate, "isDead")
    print("[XNP PLAYER IDENTITY SNAPSHOT] binding_generation=" .. tostring(Identity.binding_generation)
        .. " character_generation=" .. tostring(Identity.character_generation)
        .. " canonical_ref=" .. objectId(Identity.player_ref)
        .. " specific_player_ref=" .. objectId(specificPlayer(Identity.player_index))
        .. " player_num=" .. tostring(Identity.player_num)
        .. " name=" .. tostring(Identity.username_or_forename_for_diagnostic_only)
        .. " local_controlled=" .. tostring(valid)
        .. " dead=" .. tostring(dead == true)
        .. " descriptor_ref=" .. objectId(descriptor)
        .. " visual_ref=" .. objectId(visual)
        .. " identity_match=" .. tostring(valid))
    if candidate == Identity.player_ref
        and (descriptor ~= Identity.last_descriptor_ref or visual ~= Identity.last_visual_ref) then
        print("[XNP PLAYER RENDER IDENTITY CHANGE] canonical_ref_unchanged=true"
            .. " descriptor_ref_changed=" .. tostring(descriptor ~= Identity.last_descriptor_ref)
            .. " visual_ref_changed=" .. tostring(visual ~= Identity.last_visual_ref)
            .. " outfit_signature_changed=NOT_VERIFIABLE"
            .. " xnp_visual_write_count=0 ownership=UNKNOWN_NEEDS_ISOLATION")
        Identity.last_descriptor_ref = descriptor
        Identity.last_visual_ref = visual
    end
    return true
end

function Identity.ResetSession(source)
    Identity.player_ref = nil
    Identity.player_index = nil
    Identity.player_num = nil
    Identity.online_id_or_local_id = nil
    Identity.username_or_forename_for_diagnostic_only = nil
    Identity.descriptor_ref = nil
    Identity.visual_ref = nil
    Identity.bound_at_event = source or "SESSION_RESET"
    Identity.tombstoned = false
    Identity.tombstoned_player_ref = nil
    Identity.tombstoned_descriptor_ref = nil
    Identity.tombstoned_binding_generation = nil
    Identity.tombstoned_character_generation = nil
    Identity.tombstoned_at_ms = nil
    Identity.next_diagnostic_ms = 0
    Identity.successor_npc_rejected_count = 0
    Identity.duplicate_tombstone_count = 0
    Identity.next_tombstone_summary_ms = 0
    Identity.local_rejection_count = 0
    clearSuccessorCandidate()
end

function Identity.GetAuditSnapshot()
    return {
        player_ref = Identity.player_ref,
        player_index = Identity.player_index,
        player_num = Identity.player_num,
        online_id_or_local_id = Identity.online_id_or_local_id,
        username_or_forename_for_diagnostic_only = Identity.username_or_forename_for_diagnostic_only,
        descriptor_ref = Identity.descriptor_ref,
        visual_ref = Identity.visual_ref,
        world_generation = Identity.world_generation,
        binding_generation = Identity.binding_generation,
        character_generation = Identity.character_generation,
        bound_at_event = Identity.bound_at_event,
        tombstoned = Identity.tombstoned,
        tombstoned_player_ref = Identity.tombstoned_player_ref,
        tombstoned_descriptor_ref = Identity.tombstoned_descriptor_ref,
        tombstoned_binding_generation = Identity.tombstoned_binding_generation,
        tombstoned_character_generation = Identity.tombstoned_character_generation,
        tombstoned_at_ms = Identity.tombstoned_at_ms,
        global_write_suspension = false,
        local_rejection_count = Identity.local_rejection_count,
        successor_candidate_ref = Identity.successor_candidate_ref,
        successor_confirmation_frames = Identity.successor_confirmation_frames,
        successor_confirm_frames_required = SUCCESSOR_CONFIRM_FRAMES,
        successor_npc_rejected_count = Identity.successor_npc_rejected_count,
        duplicate_tombstone_count = Identity.duplicate_tombstone_count,
    }
end

Core.CanonicalPlayerIdentity = Identity
return Identity
