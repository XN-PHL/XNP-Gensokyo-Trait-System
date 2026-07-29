local Core = XNP_PZ_DistanceRunner

local Stabilizer = {
    primaryCount = 0,
    secondaryCount = 0,
    failedCount = 0,
    fullRestoreCount = 0,
    visibleWoundCountAfter = 0,
}

local FULL_PART_HEALTH = 99.99
local HEALTH_EPSILON = 0.0001

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function numberRead(object, method)
    local ok, value = invoke(object, method)
    if not ok or tonumber(value) == nil then return nil, false end
    return tonumber(value), true
end

local function booleanRead(object, methods)
    for index = 1, #methods do
        local ok, value = invoke(object, methods[index])
        if ok then return value == true, true, methods[index] end
    end
    return false, false, "UNAVAILABLE"
end

local function partName(part, index)
    local ok, partType = invoke(part, "getType")
    if ok and partType ~= nil and BodyPartType
        and type(BodyPartType.ToString) == "function" then
        local nameOk, name = pcall(BodyPartType.ToString, partType)
        if nameOk and name ~= nil then return tostring(name) end
    end
    if ok and partType ~= nil then return tostring(partType) end
    return "BODY_PART_" .. tostring(index)
end

local function woundWithDuration(part, booleanMethods, durationMethod)
    local value, booleanReadable = booleanRead(part, booleanMethods)
    local duration, durationReadable = numberRead(part, durationMethod)
    duration = duration or 0
    return value == true or duration > HEALTH_EPSILON,
        booleanReadable or durationReadable, duration
end

local function partEvidence(part, index)
    local health, healthReadable = numberRead(part, "getHealth")
    local bleeding, bleedingReadable, bleedingMethod =
        booleanRead(part, { "bleeding", "isBleeding" })
    local bleedingTime, bleedingTimeReadable =
        numberRead(part, "getBleedingTime")
    bleedingTime = bleedingTime or 0

    local deepWound, deepReadable, deepTime = woundWithDuration(
        part, { "deepWounded", "isDeepWounded" }, "getDeepWoundTime")
    local cut, cutReadable, cutTime =
        woundWithDuration(part, { "isCut" }, "getCutTime")
    local scratch, scratchReadable, scratchTime = woundWithDuration(
        part, { "scratched", "isScratched" }, "getScratchTime")
    local bite, biteReadable, biteTime = woundWithDuration(
        part, { "bitten", "isBitten" }, "getBiteTime")
    local burn, burnReadable, burnTime =
        woundWithDuration(part, { "isBurnt" }, "getBurnTime")
    local bullet, bulletReadable =
        booleanRead(part, { "haveBullet", "hasBullet" })
    local glass, glassReadable =
        booleanRead(part, { "haveGlass", "hasGlass" })
    local fractureTime, fractureReadable =
        numberRead(part, "getFractureTime")
    fractureTime = fractureTime or 0

    return {
        part = part,
        index = index,
        body_part = partName(part, index),
        health = health,
        health_readable = healthReadable,
        active = bleeding == true or bleedingTime > HEALTH_EPSILON,
        bleeding_time = bleedingTime,
        bleeding_readable = bleedingReadable or bleedingTimeReadable,
        bleeding_read_method = bleedingMethod,
        deep_wound = deepWound,
        deep_wound_readable = deepReadable,
        deep_wound_time = deepTime,
        cut = cut,
        cut_readable = cutReadable,
        cut_time = cutTime,
        scratch = scratch,
        scratch_readable = scratchReadable,
        scratch_time = scratchTime,
        bite = bite,
        bite_readable = biteReadable,
        bite_time = biteTime,
        burn = burn,
        burn_readable = burnReadable,
        burn_time = burnTime,
        bullet = bullet == true,
        bullet_readable = bulletReadable,
        glass = glass == true,
        glass_readable = glassReadable,
        fracture = fractureTime > HEALTH_EPSILON,
        fracture_readable = fractureReadable,
        fracture_time = fractureTime,
    }
end

local function partCollection(body)
    local ok, parts = invoke(body, "getBodyParts")
    if not ok or not parts then return nil, "BODY_PARTS_UNAVAILABLE" end
    local sizeOk, size = invoke(parts, "size")
    size = sizeOk and tonumber(size) or nil
    if not size or size <= 0 then
        return nil, "BODY_PART_COUNT_UNAVAILABLE_OR_ZERO"
    end
    return parts, size
end

local function incrementWounds(evidence, item)
    local fields = {
        { "deep_wound_count", "deep_wound" },
        { "cut_count", "cut" },
        { "scratch_count", "scratch" },
        { "bite_count", "bite" },
        { "burn_count", "burn" },
        { "bullet_count", "bullet" },
        { "glass_count", "glass" },
        { "fracture_count", "fracture" },
    }
    for index = 1, #fields do
        local counter = fields[index][1]
        local value = fields[index][2]
        if item[value] == true then
            evidence[counter] = evidence[counter] + 1
        end
    end
end

local function finalizeEvidence(evidence)
    evidence.visible_wound_count =
        evidence.deep_wound_count
        + evidence.cut_count
        + evidence.scratch_count
        + evidence.bite_count
        + evidence.burn_count
        + evidence.bullet_count
        + evidence.glass_count
        + evidence.fracture_count
    evidence.all_body_parts_full =
        evidence.body_part_count > 0
        and evidence.unreadable_body_part_health_count == 0
        and evidence.body_part_health_min ~= nil
        and evidence.body_part_health_min >= FULL_PART_HEALTH
    evidence.all_wound_readbacks_available =
        evidence.unreadable_wound_field_count == 0
    evidence.full_recovery_readback =
        evidence.all_body_parts_full
        and evidence.all_wound_readbacks_available
        and evidence.active_bleed_parts == 0
        and evidence.bleeding_severity <= HEALTH_EPSILON
        and evidence.visible_wound_count == 0
    return evidence
end

function Stabilizer.ReadEvidence(body, player)
    local parts, sizeOrReason = partCollection(body)
    if not parts then return false, sizeOrReason end
    local evidence = {
        body_part_count = sizeOrReason,
        body_part_health_min = nil,
        unreadable_body_part_health_count = 0,
        unreadable_wound_field_count = 0,
        active_bleed_parts = 0,
        bleeding_severity = 0,
        deep_wound_count = 0,
        cut_count = 0,
        scratch_count = 0,
        bite_count = 0,
        burn_count = 0,
        bullet_count = 0,
        glass_count = 0,
        fracture_count = 0,
        overall_health = nil,
        player_health = nil,
        parts = {},
    }
    evidence.overall_health = numberRead(body, "getOverallBodyHealth")
    if player then
        evidence.player_health = numberRead(player, "getHealth")
    end

    for index = 0, sizeOrReason - 1 do
        local ok, part = invoke(parts, "get", index)
        if not ok or not part then
            evidence.unreadable_body_part_health_count =
                evidence.unreadable_body_part_health_count + 1
            evidence.unreadable_wound_field_count =
                evidence.unreadable_wound_field_count + 8
        else
            local item = partEvidence(part, index)
            evidence.parts[#evidence.parts + 1] = item
            if item.health_readable then
                if evidence.body_part_health_min == nil
                    or item.health < evidence.body_part_health_min then
                    evidence.body_part_health_min = item.health
                end
            else
                evidence.unreadable_body_part_health_count =
                    evidence.unreadable_body_part_health_count + 1
            end
            local readableFields = {
                item.deep_wound_readable,
                item.cut_readable,
                item.scratch_readable,
                item.bite_readable,
                item.burn_readable,
                item.bullet_readable,
                item.glass_readable,
                item.fracture_readable,
            }
            for fieldIndex = 1, #readableFields do
                if readableFields[fieldIndex] ~= true then
                    evidence.unreadable_wound_field_count =
                        evidence.unreadable_wound_field_count + 1
                end
            end
            if item.active then
                evidence.active_bleed_parts =
                    evidence.active_bleed_parts + 1
                evidence.bleeding_severity =
                    evidence.bleeding_severity
                    + math.max(item.bleeding_time, 1)
            end
            incrementWounds(evidence, item)
        end
    end
    return true, finalizeEvidence(evidence)
end

local function auditText(evidence, suffix)
    suffix = suffix or ""
    return " body_part_count" .. suffix .. "="
        .. tostring(evidence.body_part_count)
        .. " body_part_health_min" .. suffix .. "="
        .. tostring(evidence.body_part_health_min)
        .. " deep_wound_count" .. suffix .. "="
        .. tostring(evidence.deep_wound_count)
        .. " cut_count" .. suffix .. "="
        .. tostring(evidence.cut_count)
        .. " scratch_count" .. suffix .. "="
        .. tostring(evidence.scratch_count)
        .. " bite_count" .. suffix .. "="
        .. tostring(evidence.bite_count)
        .. " burn_count" .. suffix .. "="
        .. tostring(evidence.burn_count)
        .. " bullet_count" .. suffix .. "="
        .. tostring(evidence.bullet_count)
        .. " glass_count" .. suffix .. "="
        .. tostring(evidence.glass_count)
        .. " fracture_count" .. suffix .. "="
        .. tostring(evidence.fracture_count)
        .. " visible_wound_count" .. suffix .. "="
        .. tostring(evidence.visible_wound_count)
        .. " active_bleed_parts" .. suffix .. "="
        .. tostring(evidence.active_bleed_parts)
        .. " overall_health" .. suffix .. "="
        .. tostring(evidence.overall_health)
        .. " player_health" .. suffix .. "="
        .. tostring(evidence.player_health)
end

function Stabilizer.Stabilize(body, transactionId, mode, player)
    mode = tostring(mode or "PRIMARY_FULL_RECOVERY")
    local beforeOk, before = Stabilizer.ReadEvidence(body, player)
    if not beforeOk then
        Stabilizer.failedCount = Stabilizer.failedCount + 1
        return false, {
            reason = before,
            pass = false,
        }
    end
    if type(body.RestoreToFullHealth) ~= "function" then
        Stabilizer.failedCount = Stabilizer.failedCount + 1
        return false, {
            reason = "RESTORE_TO_FULL_HEALTH_API_UNAVAILABLE",
            before = before,
            pass = false,
        }
    end

    local restoreOk, restoreError =
        pcall(function() body:RestoreToFullHealth() end)
    if not restoreOk then
        Stabilizer.failedCount = Stabilizer.failedCount + 1
        return false, {
            reason = "RESTORE_TO_FULL_HEALTH_FAILED:"
                .. tostring(restoreError),
            before = before,
            pass = false,
        }
    end

    local afterOk, after = Stabilizer.ReadEvidence(body, player)
    if not afterOk then
        Stabilizer.failedCount = Stabilizer.failedCount + 1
        return false, {
            reason = after,
            before = before,
            pass = false,
        }
    end

    local pass = after.full_recovery_readback == true
    if mode == "SECONDARY_FULL_RECOVERY" then
        Stabilizer.secondaryCount = Stabilizer.secondaryCount + 1
    else
        Stabilizer.primaryCount = Stabilizer.primaryCount + 1
    end
    Stabilizer.fullRestoreCount = Stabilizer.fullRestoreCount + 1
    Stabilizer.visibleWoundCountAfter = after.visible_wound_count
    if not pass then Stabilizer.failedCount = Stabilizer.failedCount + 1 end

    local report = {
        reason = pass and "FULL_BODY_RECOVERY_READBACK_PASS"
            or "FULL_BODY_RECOVERY_READBACK_FAILED",
        mode = mode,
        before = before,
        after = after,
        body_part_count = after.body_part_count,
        body_part_health_min_before = before.body_part_health_min,
        body_part_health_min_after = after.body_part_health_min,
        visible_wound_count_before = before.visible_wound_count,
        visible_wound_count_after = after.visible_wound_count,
        active_bleed_parts_before = before.active_bleed_parts,
        active_bleed_parts_after = after.active_bleed_parts,
        bleeding_severity_before = before.bleeding_severity,
        bleeding_severity_after = after.bleeding_severity,
        full_recovery_readback = after.full_recovery_readback,
        pass = pass,
    }
    print("[XNP PHOENIX FULL BODY RECOVERY]"
        .. " transaction_id=" .. tostring(transactionId)
        .. " mode=" .. mode
        .. auditText(before, "_before")
        .. auditText(after, "_after")
        .. " unreadable_body_part_health_count="
        .. tostring(after.unreadable_body_part_health_count)
        .. " unreadable_wound_field_count="
        .. tostring(after.unreadable_wound_field_count)
        .. " restore_method=BodyDamage.RestoreToFullHealth"
        .. " full_recovery_readback=" .. tostring(pass))
    return pass, report
end

function Stabilizer.IsFullRecoveryEvidence(evidence)
    return type(evidence) == "table"
        and evidence.full_recovery_readback == true
end

function Stabilizer.GetAuditSnapshot()
    return {
        primary_full_recovery_count = Stabilizer.primaryCount,
        secondary_full_recovery_count = Stabilizer.secondaryCount,
        failed_full_recovery_count = Stabilizer.failedCount,
        restore_to_full_health_count = Stabilizer.fullRestoreCount,
        visible_wound_count_after = Stabilizer.visibleWoundCountAfter,
        broad_unconditional_cure = true,
        full_body_part_readback_required = true,
        all_visible_wounds_zero_required = true,
        body_part_health_min_required = FULL_PART_HEALTH,
        persistent_invulnerability = false,
    }
end

Core.PhoenixMedicalStabilizer = Stabilizer
return Stabilizer
