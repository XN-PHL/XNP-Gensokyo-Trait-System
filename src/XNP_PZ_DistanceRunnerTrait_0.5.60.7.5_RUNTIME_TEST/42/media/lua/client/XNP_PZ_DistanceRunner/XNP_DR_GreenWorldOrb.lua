require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Audio"
require "XNP_PZ_DistanceRunner/XNP_DR_MeleeMode"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenHumanSafeClassifier"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenVisibleProxy"

local Core = XNP_PZ_DistanceRunner

local Orb = {
    FINAL_GREEN_MODE = "VIRTUAL_TRACKING_BLAST",
    GREEN_RUNTIME_ENTITY_RENDERING_ENABLED = false,
    GREEN_NATIVE_VISIBLE_PROXY_ENABLED = true,
    GREEN_PROJECTILE_VISUAL = "PER_PLAYER_ZOOM_VIEWPORT_PROJECTED_DRAW_PROOF",
    DAMAGE_TYPE = "XNP_GREEN_VIRTUAL_TRACKING_RADIAL_SHOCK",
    DAMAGE_WEAPON = "XNP_PZ_DistanceRunner.GreenOrbRadialShock",
    TARGET_SEARCH_INTERVAL_MS = 250,
    WALK_SPEED_FALLBACK_TPS = 1.45,
    WALK_SPEED_MIN_TPS = 0.50,
    WALK_SPEED_MAX_TPS = 3.00,
    IMPACT_VISUAL_HOLD_MS_FALLBACK = 300,
    active = nil,
    serial = 0,
    mapHidden = false,
    cooldownByPlayer = setmetatable({}, { __mode = "k" }),
    walkSamples = setmetatable({}, { __mode = "k" }),
    outlineOwners = setmetatable({}, { __mode = "k" }),
    outlineSerial = 0,
    failureLogged = {},
}

local MODE = {
    [1] = "OFF",
    [2] = "VIRTUAL_TRACKING_BLAST",
    [3] = "LOCAL_BLAST",
}

local SHUTDOWN_REASON = {
    game_exit = "WORLD_EXIT",
    main_menu = "MAIN_MENU",
    player_death = "PLAYER_DEATH",
    player_replaced = "PLAYER_REPLACED",
}

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function isType(object, className)
    if not object or type(instanceof) ~= "function" then return false end
    local ok, result = pcall(function() return instanceof(object, className) end)
    return ok and result == true
end

local function coordinate(object, method)
    local ok, value = invoke(object, method)
    return ok and tonumber(value) or nil
end

local function tuningBoolean(name, fallback)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean then
        return Core.SandboxTuning.GetBoolean(name, fallback)
    end
    return fallback == true
end

local function tuningNumber(name, fallback, minimum, maximum)
    if Core.SandboxTuning and Core.SandboxTuning.GetNumber then
        return Core.SandboxTuning.GetNumber(name, fallback, minimum, maximum)
    end
    return fallback
end

local function activeMode()
    local index = math.floor(tuningNumber("GreenActiveMode", 2, 1, 3) + 0.5)
    return MODE[index] or "VIRTUAL_TRACKING_BLAST"
end

local function settings()
    local initialSpeedTiles = tuningNumber("GreenInitialSpeedTilesPerSecond", 1.45, 0.1, 30.0)
    local lockAreaEnabled = tuningBoolean("GreenLockAreaEnabled", true)
    local lockAreaRadius = tuningNumber("GreenLockAreaRadiusTiles", 4.0, 1.0, 12.0)
    return {
        mode = activeMode(),
        cooldownMs = tuningNumber("GreenCooldownRealSeconds", 5.0, 0.5, 120.0) * 1000,
        testNoCooldown = tuningBoolean("GreenRuntimeTestNoCooldown", true),
        lockAreaEnabled = lockAreaEnabled,
        lockAreaRadius = lockAreaRadius,
        targetRadius = lockAreaEnabled and lockAreaRadius
            or tuningNumber("GreenTargetSearchRadiusTiles", 12.0, 1.0, 30.0),
        maximumTargetCount = math.floor(tuningNumber("GreenMaximumTargetCount", 0, 0, 128) + 0.5),
        targetPriorityMode = math.floor(tuningNumber("GreenTargetPriorityMode", 1, 1, 3) + 0.5),
        noTargetMs = tuningNumber("GreenNoTargetSearchSeconds", 3.0, 0.1, 10.0) * 1000,
        impactVisualHoldMs = tuningNumber("GreenImpactVisualHoldMs", 300, 100, 1000),
        minimumVisibleFlightMs = tuningNumber("GreenMinimumVisibleFlightMs", 500, 100, 5000),
        minimumInflightRenderFrames = math.floor(
            tuningNumber("GreenMinimumInflightRenderFrames", 2, 2, 30) + 0.5),
        inflightDiagnosticBorder = tuningBoolean("GreenInflightDiagnosticBorderEnabled", true),
        initialMultiplier = tuningNumber("GreenInitialSpeedMultiplier", 1.0, 0.1, 5.0),
        initialSpeedScale = initialSpeedTiles / 1.45,
        accelerationStart = math.max(
            tuningNumber("GreenAccelerationStartSeconds", 3.0, 0.0, 10.0),
            tuningNumber("GreenLowSpeedDurationSeconds", 3.0, 0.0, 10.0)),
        accelerationPerSecond = tuningNumber("GreenAccelerationMultiplierPerSecond", 1.5, 1.0, 3.0),
        speedCap = tuningNumber("GreenMaximumVirtualSpeedTilesPerSecond", 8.0, 0.5, 30.0),
        maximumFlightMs = tuningNumber("GreenMaximumFlightSeconds", 8.0, 0.5, 30.0) * 1000,
        impactDistance = tuningNumber("GreenImpactDistanceTiles", 0.55, 0.1, 2.0),
        explosionRadius = tuningNumber("GreenExplosionRadiusTiles", 7.0, 0.5, 15.0),
        explosionDamage = tuningNumber("GreenExplosionBaseDamage", 10.0, 0.1, 100.0),
        falloff = tuningBoolean("GreenExplosionFalloffEnabled", true),
        targetOutline = tuningBoolean("EnableTargetOutline", true)
            and tuningBoolean("GreenTargetOutlineEnabled", true),
        outlinePulseEnabled = tuningBoolean("GreenLockOutlinePulseEnabled", true),
        outlinePulseIntervalMs = tuningNumber("GreenLockOutlinePulseIntervalSeconds", 3.0, 0.5, 30.0) * 1000,
        outlinePulseDurationMs = tuningNumber("GreenLockOutlinePulseDurationSeconds", 0.65, 0.1, 5.0) * 1000,
        npcDamageEnabled = tuningBoolean("GreenNPCDamageEnabled", true),
        banditDamageEnabled = tuningBoolean("GreenBanditDamageEnabled", true),
        playerDamageEnabled = false,
        castSound = tuningBoolean("EnableSounds", true)
            and tuningBoolean("GreenCastSoundEnabled", true),
        impactSound = tuningBoolean("EnableSounds", true)
            and tuningBoolean("GreenImpactSoundEnabled", true),
        refundNoTarget = tuningBoolean("GreenRefundCooldownOnNoTarget", true),
        reacquisitionEnabled = tuningBoolean("GreenTargetReacquisitionEnabled", true),
        reacquisitionRadius = tuningNumber("GreenTargetReacquisitionRadiusTiles", 12.0, 1.0, 30.0),
        maximumReacquisitionCount = math.floor(tuningNumber("GreenMaximumReacquisitionCount", 0, 0, 64) + 0.5),
        targetSearchIntervalMs = tuningNumber("TargetReacquisitionIntervalFrames", 15, 1, 120) * (1000 / 60),
        wallBlocking = tuningBoolean("GreenWallBlockingEnabled", true),
    }
end

local function playerDead(player)
    local ok, value = invoke(player, "isDead")
    if ok and value == true then return true end
    ok, value = invoke(player, "isOnDeathDone")
    return ok and value == true
end

local function damagePolicy(options)
    return {
        npcDamageEnabled = tuningBoolean("GreenNPCDamageEnabled",
            options and options.npcDamageEnabled == true),
        banditDamageEnabled = tuningBoolean("GreenBanditDamageEnabled",
            options and options.banditDamageEnabled == true),
        playerDamageEnabled = false,
    }
end

local function validTarget(target, options)
    local classification = Core.GreenHumanSafeClassifier.Classify(target, true)
    if Core.GreenHumanSafeClassifier.IsDamageAllowed(classification, damagePolicy(options)) ~= true then
        return false
    end
    local ok, dead = invoke(target, "isDead")
    if ok and dead == true then return false end
    local health = coordinate(target, "getHealth")
    return health == nil or health > 0
end

local function zombieList()
    if type(getCell) ~= "function" then return nil end
    local cell = getCell()
    if not cell or type(cell.getZombieList) ~= "function" then return nil end
    local ok, list = pcall(function() return cell:getZombieList() end)
    if not ok or not list or type(list.size) ~= "function" or type(list.get) ~= "function" then return nil end
    return list
end

local function forwardComponents(player)
    local ok, vector = invoke(player, "getForwardDirection")
    if not ok or not vector then return nil, nil end
    local fx = tonumber(vector.x)
    local fy = tonumber(vector.y)
    if fx == nil then local xOk, value = invoke(vector, "getX"); if xOk then fx = tonumber(value) end end
    if fy == nil then local yOk, value = invoke(vector, "getY"); if yOk then fy = tonumber(value) end end
    if fx == nil or fy == nil then return nil, nil end
    local length = math.sqrt(fx * fx + fy * fy)
    if length <= 0.0001 then return nil, nil end
    return fx / length, fy / length
end

local function targetScore(zombie, dx, dy, distance, priorityMode, player)
    if priorityMode == 2 then
        return -(coordinate(zombie, "getHealth") or math.huge), "LOWEST_HEALTH"
    end
    if priorityMode == 3 then
        local fx, fy = forwardComponents(player)
        if fx and distance > 0.0001 then
            return (dx / distance) * fx + (dy / distance) * fy - distance * 0.0001, "FORWARD_SECTOR"
        end
    end
    return -distance, "NEAREST"
end

local function candidateEntries(originX, originY, originZ, radius, options)
    local entries = {}
    local seen = setmetatable({}, { __mode = "k" })
    local policy = damagePolicy(options)

    local function add(object, fromZombieRegistry)
        if not object or seen[object] then return end
        if not isType(object, "IsoGameCharacter") and not isType(object, "IsoZombie") then return end
        seen[object] = true
        local x = coordinate(object, "getX")
        local y = coordinate(object, "getY")
        local z = coordinate(object, "getZ")
        if not x or not y or not z or math.abs(z - originZ) >= 0.6 then return end
        local dx, dy = x - originX, y - originY
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > radius then return end
        local classification = Core.GreenHumanSafeClassifier.Classify(object, fromZombieRegistry)
        entries[#entries + 1] = {
            target = object,
            distance = distance,
            dx = dx,
            dy = dy,
            classification = classification,
            damageAllowed = Core.GreenHumanSafeClassifier.IsDamageAllowed(classification, policy),
        }
    end

    local zombies = zombieList()
    if zombies then
        local ok, size = pcall(function() return zombies:size() end)
        size = ok and tonumber(size) or 0
        for index = 0, size - 1 do
            local itemOk, item = pcall(function() return zombies:get(index) end)
            if itemOk then add(item, true) end
        end
    end

    if type(getCell) == "function" then
        local cellOk, cell = pcall(getCell)
        if cellOk and cell and type(cell.getGridSquare) == "function" then
            local minX, maxX = math.floor(originX - radius), math.ceil(originX + radius)
            local minY, maxY = math.floor(originY - radius), math.ceil(originY + radius)
            local level = math.floor(originZ)
            for x = minX, maxX do
                for y = minY, maxY do
                    local squareOk, square = pcall(function() return cell:getGridSquare(x, y, level) end)
                    if squareOk and square and type(square.getMovingObjects) == "function" then
                        local listOk, list = pcall(function() return square:getMovingObjects() end)
                        if listOk and list and type(list.size) == "function" and type(list.get) == "function" then
                            local sizeOk, size = pcall(function() return list:size() end)
                            size = sizeOk and tonumber(size) or 0
                            for index = 0, size - 1 do
                                local itemOk, item = pcall(function() return list:get(index) end)
                                if itemOk then add(item, false) end
                            end
                        end
                    end
                end
            end
        end
    end
    return entries
end

local function localOutlineEntries(originX, originY, originZ, radius)
    local entries = {}
    local seen = setmetatable({}, { __mode = "k" })
    if type(getCell) ~= "function" then return entries, "CELL_API_UNAVAILABLE" end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell or type(cell.getGridSquare) ~= "function" then
        return entries, "CELL_UNAVAILABLE"
    end
    local minX, maxX = math.floor(originX - radius), math.ceil(originX + radius)
    local minY, maxY = math.floor(originY - radius), math.ceil(originY + radius)
    local level = math.floor(originZ)
    for x = minX, maxX do
        for y = minY, maxY do
            local squareOk, square = pcall(function() return cell:getGridSquare(x, y, level) end)
            if squareOk and square and type(square.getMovingObjects) == "function" then
                local listOk, list = pcall(function() return square:getMovingObjects() end)
                if listOk and list and type(list.size) == "function" and type(list.get) == "function" then
                    local sizeOk, size = pcall(function() return list:size() end)
                    size = sizeOk and tonumber(size) or 0
                    for index = 0, size - 1 do
                        local itemOk, item = pcall(function() return list:get(index) end)
                        if itemOk and item and not seen[item] and isType(item, "IsoZombie")
                            and not isType(item, "IsoPlayer") then
                            seen[item] = true
                            local itemX = coordinate(item, "getX")
                            local itemY = coordinate(item, "getY")
                            local itemZ = coordinate(item, "getZ")
                            if itemX and itemY and itemZ and math.abs(itemZ - originZ) < 0.6 then
                                local dx, dy = itemX - originX, itemY - originY
                                local distance = math.sqrt(dx * dx + dy * dy)
                                if distance <= radius then
                                    entries[#entries + 1] = {
                                        target = item,
                                        distance = distance,
                                        classification = Core.GreenHumanSafeClassifier.Classify(item, false),
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return entries, "BOUNDED_LOCAL_SQUARE_SCAN"
end

local function nearestTarget(originX, originY, originZ, radius, priorityMode, player, options)
    local selected, selectedScore, selectedReason = nil, nil, "NEAREST"
    local entries = candidateEntries(originX, originY, originZ, radius, options)
    for _, entry in ipairs(entries) do
        if entry.damageAllowed and validTarget(entry.target, options) then
            local score, reason = targetScore(entry.target, entry.dx, entry.dy, entry.distance,
                priorityMode, player)
            if selectedScore == nil or score > selectedScore then
                selected, selectedScore, selectedReason = entry.target, score, reason
            end
        end
    end
    if selected then return selected, selectedReason .. "_DAMAGE_ALLOWED_FROM_VIRTUAL_POSITION" end
    return nil, "NO_DAMAGE_ALLOWED_TARGET_YET"
end

local function normalized(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0.0001 then return nil, nil, 0 end
    return dx / length, dy / length, length
end

local function vectorComponent(vector, field, method)
    if not vector then return nil end
    local direct = tonumber(vector[field])
    if direct then return direct end
    local ok, value = invoke(vector, method)
    return ok and tonumber(value) or nil
end

local function playerForward(player)
    local ok, vector = invoke(player, "getForwardDirection")
    if ok and vector then
        local x = vectorComponent(vector, "x", "getX")
        local y = vectorComponent(vector, "y", "getY")
        local nx, ny = normalized(x or 0, y or 0)
        if nx then return nx, ny, "PLAYER_FORWARD_DIRECTION" end
    end
    return 1.0, 0.0, "SAFE_EAST_FALLBACK"
end

local function angleDelta(from, target)
    local delta = target - from
    while delta > math.pi do delta = delta - math.pi * 2 end
    while delta < -math.pi do delta = delta + math.pi * 2 end
    return delta
end

local function sampleWalkingSpeed(player, now)
    local x = coordinate(player, "getX")
    local y = coordinate(player, "getY")
    if not x or not y then return end
    local sample = Orb.walkSamples[player]
    if not sample then
        Orb.walkSamples[player] = { x = x, y = y, at = now, observed = nil }
        return
    end
    local elapsed = (now - sample.at) / 1000
    if elapsed < 0.05 then return end
    local dx, dy = x - sample.x, y - sample.y
    local tps = math.sqrt(dx * dx + dy * dy) / elapsed
    sample.x, sample.y, sample.at = x, y, now
    local _, sprinting = invoke(player, "isSprinting")
    local _, running = invoke(player, "isRunning")
    if sprinting == true or running == true or elapsed > 0.50 then return end
    if tps >= Orb.WALK_SPEED_MIN_TPS and tps <= Orb.WALK_SPEED_MAX_TPS then
        sample.observed = sample.observed and (sample.observed * 0.75 + tps * 0.25) or tps
    end
end

local function walkingSpeed(player)
    local sample = Orb.walkSamples[player]
    if sample and sample.observed then
        return math.max(Orb.WALK_SPEED_MIN_TPS, math.min(sample.observed, Orb.WALK_SPEED_MAX_TPS)),
            "OBSERVED_PLAYER_WORLD_WALK_DISPLACEMENT_TPS"
    end
    return Orb.WALK_SPEED_FALLBACK_TPS, "CONSERVATIVE_WALK_TPS_FALLBACK_NO_VALID_SAMPLE"
end

local function currentSquare(x, y, z)
    if type(getCell) ~= "function" then return nil end
    local cell = getCell()
    if not cell or type(cell.getGridSquare) ~= "function" then return nil end
    local ok, square = pcall(function() return cell:getGridSquare(math.floor(x), math.floor(y), math.floor(z)) end)
    return ok and square or nil
end

local function blockedBetween(x, y, z, nextX, nextY)
    local current = currentSquare(x, y, z)
    local target = currentSquare(nextX, nextY, z)
    if not current or not target then return true end
    if current == target then return false end
    if type(current.isBlockedTo) ~= "function" then return false end
    local ok, blocked = pcall(function() return current:isBlockedTo(target) end)
    return ok and blocked == true
end

local function clearTargetOutline(state)
    if not state or type(state.outlineRecords) ~= "table" then return end
    local cleared, externalTakeover = 0, 0
    for _, record in ipairs(state.outlineRecords) do
        if record.target and Orb.outlineOwners[record.target] == record.token then
            local highlightOk, highlighted = invoke(record.target, "isOutlineHighlight", record.playerNum)
            local colorOk, currentColor = invoke(record.target, "getOutlineHighlightCol", record.playerNum)
            local ownedStateUnchanged = highlightOk and highlighted == true
                and colorOk and currentColor == record.ownedColor
            if ownedStateUnchanged then
                local clearOk = invoke(record.target, "setOutlineHighlight", record.playerNum, false)
                if clearOk then cleared = cleared + 1 end
            else
                externalTakeover = externalTakeover + 1
            end
            Orb.outlineOwners[record.target] = nil
        end
    end
    state.outlineRecords = {}
    state.outlinePulseEndsMs = nil
    if cleared > 0 or externalTakeover > 0 then
        print("[XNP GREEN OUTLINE CLEAR] cleared_owned=" .. tostring(cleared)
            .. " external_takeover_preserved=" .. tostring(externalTakeover)
            .. " compare_current_state_and_color=true")
    end
end

local function updateOutlinePulse(state, now)
    if not state or not state.options then return end
    if state.outlinePulseEndsMs and now >= state.outlinePulseEndsMs then clearTargetOutline(state) end
    if state.options.targetOutline ~= true or state.options.outlinePulseEnabled ~= true then return end
    if now < (state.nextOutlinePulseMs or 0) then return end
    clearTargetOutline(state)
    state.nextOutlinePulseMs = now + state.options.outlinePulseIntervalMs
    state.outlinePulseEndsMs = now + state.options.outlinePulseDurationMs
    Orb.outlineSerial = Orb.outlineSerial + 1
    local token = "xnp-green-outline-" .. tostring(state.id) .. "-" .. tostring(Orb.outlineSerial)
    local playerNum = 0
    local numOk, value = invoke(state.player, "getPlayerNum")
    if numOk then playerNum = math.max(0, math.floor(tonumber(value) or 0)) end
    local entries, scanMethod = localOutlineEntries(state.world_x, state.world_y, state.world_z,
        state.options.lockAreaRadius)
    state.outlineRecords = {}
    for _, entry in ipairs(entries) do
        if entry.classification.kind ~= Core.GreenHumanSafeClassifier.PLAYER
            and entry.classification.kind ~= Core.GreenHumanSafeClassifier.NON_HUMANOID then
            local existingOk, existing = invoke(entry.target, "isOutlineHighlight", playerNum)
            if existingOk and existing ~= true then
                local colorOk = invoke(entry.target, "setOutlineHighlightCol", playerNum,
                    0.08, 1.0, 0.18, 1.0)
                local outlineOk = invoke(entry.target, "setOutlineHighlight", playerNum, true)
                local ownedColorOk, ownedColor = invoke(entry.target, "getOutlineHighlightCol", playerNum)
                if colorOk and outlineOk and ownedColorOk then
                    Orb.outlineOwners[entry.target] = token
                    state.outlineRecords[#state.outlineRecords + 1] = {
                        target = entry.target,
                        token = token,
                        playerNum = playerNum,
                        ownedColor = ownedColor,
                    }
                elseif outlineOk then
                    invoke(entry.target, "setOutlineHighlight", playerNum, false)
                end
            end
        end
    end
    print("[XNP GREEN OUTLINE] pulse=true selected_count=" .. tostring(#state.outlineRecords)
        .. " interval_real_seconds=" .. string.format("%.2f", state.options.outlinePulseIntervalMs / 1000)
        .. " duration_real_seconds=" .. string.format("%.2f", state.options.outlinePulseDurationMs / 1000)
        .. " player_outline_reachable=0 global_zombie_list_enumeration=false"
        .. " scan_method=" .. tostring(scanMethod)
        .. " ownership_token=" .. token)
end

local function setTarget(state, target, source, now)
    if state.target == target then return end
    state.target = target
    state.targetSource = source
    if not target then
        state.noTargetSinceMs = state.noTargetSinceMs or now
        return
    end
    state.noTargetSinceMs = nil
    if state.trackingStartedMs == nil then
        state.trackingStartedMs = now
        state.lastUpdateMs = now
    end
end

local function targetDistanceFromState(state, target)
    local x = coordinate(target, "getX")
    local y = coordinate(target, "getY")
    if not x or not y then return nil end
    local dx, dy = x - state.world_x, y - state.world_y
    return math.sqrt(dx * dx + dy * dy)
end

local function logTargetAcquired(state, target, now)
    if state.targetResultLogged == true then return end
    local classification = Core.GreenHumanSafeClassifier.Classify(target, true)
    local distance = targetDistanceFromState(state, target)
    state.targetResultLogged = true
    print("[XNP GREEN TARGET] acquired=true"
        .. " target_classification=" .. tostring(classification.kind)
        .. " target_distance_tiles=" .. string.format("%.3f", distance or -1)
        .. " search_elapsed_ms=" .. tostring(now - state.startedMs)
        .. " source=" .. tostring(state.targetSource))
end

local function logTrackingStarted(state, now)
    if state.trackingStartedLogged == true then return end
    state.trackingStartedLogged = true
    print("[XNP GREEN TRACK] started=true"
        .. " cast_id=" .. tostring(state.id)
        .. " visual_granularity=SUB_TILE_EVERY_RENDER_FRAME"
        .. " tracking_clock_ms=" .. tostring(now - (state.trackingStartedMs or now))
        .. " no_target_clock_separate=true")
end

local function createDamageWeapon()
    if type(instanceItem) == "function" then
        local ok, weapon = pcall(instanceItem, Orb.DAMAGE_WEAPON)
        if ok and weapon and isType(weapon, "HandWeapon") then return weapon end
    end
    if InventoryItemFactory and type(InventoryItemFactory.CreateItem) == "function" then
        local ok, weapon = pcall(function() return InventoryItemFactory.CreateItem(Orb.DAMAGE_WEAPON) end)
        if ok and weapon and isType(weapon, "HandWeapon") then return weapon end
    end
    return nil
end

local function collectDamageTargets(state)
    local targets = {}
    local entries = candidateEntries(state.world_x, state.world_y, state.world_z,
        state.options.explosionRadius, state.options)
    for _, entry in ipairs(entries) do
        if entry.damageAllowed and validTarget(entry.target, state.options) then
            local score = targetScore(entry.target, entry.dx, entry.dy, entry.distance,
                state.options.targetPriorityMode, state.player)
            entry.priorityScore = score
            targets[#targets + 1] = entry
        else
            Core.GreenHumanSafeClassifier.CountSkip(state.humanSafetyCounters, entry.classification)
        end
    end
    table.sort(targets, function(a, b)
        if a.priorityScore == b.priorityScore then return a.distance < b.distance end
        return a.priorityScore > b.priorityScore
    end)
    return targets, "CENTRAL_CLASSIFIER_DAMAGE_POLICY_RADIUS_FILTER"
end

local function applyGreenDamage(state)
    local targets, reason = collectDamageTargets(state)
    if not targets then return false, 0, reason end
    if #targets == 0 then return true, 0, "NO_DAMAGE_ALLOWED_TARGET_IN_RADIUS" end
    local weapon = createDamageWeapon()
    if not weapon then return false, 0, "DEDICATED_HANDWEAPON_CREATE_FAILED" end
    local hitCount = 0
    state.damageLedger = setmetatable({}, { __mode = "k" })
    for _, entry in ipairs(targets) do
        if state.options.maximumTargetCount > 0 and hitCount >= state.options.maximumTargetCount then break end
        if not state.damageLedger[entry.target] then
            local finalClassification = Core.GreenHumanSafeClassifier.Classify(entry.target, true)
            if Core.GreenHumanSafeClassifier.IsDamageAllowed(finalClassification,
                damagePolicy(state.options)) == true then
                state.damageLedger[entry.target] = true
                local fraction = math.max(0, math.min(entry.distance / state.options.explosionRadius, 1.0))
                local damage = state.options.explosionDamage
                if state.options.falloff then damage = damage * (1.0 - 0.75 * fraction) end
                local hitOk = pcall(function()
                    entry.target:Hit(weapon, state.player, damage, false, 1.0, false)
                end)
                if hitOk then
                    hitCount = hitCount + 1
                    Core.GreenHumanSafeClassifier.CountDamaged(state.humanSafetyCounters, finalClassification)
                else
                    state.humanSafetyCounters.hit_failures = state.humanSafetyCounters.hit_failures + 1
                end
            else
                Core.GreenHumanSafeClassifier.CountSkip(state.humanSafetyCounters, finalClassification)
            end
        end
    end
    if hitCount == 0 and state.humanSafetyCounters.hit_failures > 0 then
        return false, 0, "ALL_DAMAGE_ALLOWED_HIT_CALLS_FAILED_NO_SETHEALTH_FALLBACK"
    end
    return true, hitCount, "CENTRAL_CLASSIFIER_NORMAL_HANDWEAPON_HIT"
end

local function logFailureOnce(state, reason)
    local key = tostring(state and state.id or "none") .. ":" .. tostring(reason)
    if Orb.failureLogged[key] then return end
    Orb.failureLogged[key] = true
    print("[XNP GREEN VIRTUAL FAIL] cast_id=" .. tostring(state and state.id or "none")
        .. " reason=" .. tostring(reason) .. " failure_log_once=true")
end

local function finallyCleanupCast(state, reason)
    if not state then return end
    clearTargetOutline(state)
    if Core.GreenVisibleProxy then Core.GreenVisibleProxy.Cleanup(state) end
    if Orb.active == state then Orb.active = nil end
    state.target = nil
    state.player = nil
    state.damageLedger = nil
    state.options = nil
    state.finished = true
    print("[XNP GREEN VIRTUAL CLEANUP] cast_id=" .. tostring(state.id)
        .. " reason=" .. tostring(reason)
        .. " virtual_state_removed=true target_outline_removed=true native_iso_markers_removed=true"
        .. " java_world_entities=0 save_persistence=false")
end

local function refundCooldown(state)
    if state and state.player then Orb.cooldownByPlayer[state.player] = 0 end
end

local function playOnce(state, route, key, enabled)
    if enabled ~= true or not Core.Audio or not Core.Audio.PlayOnce then return false, "DISABLED" end
    return Core.Audio.PlayOnce(state.player, route, key .. ":" .. tostring(state.id))
end

local function notifyIcon(kind)
    if Core.GreenSkillUI and Core.GreenSkillUI.NotifyVirtualCast then
        Core.GreenSkillUI.NotifyVirtualCast(kind)
    end
end

local function abortVisualTransaction(state, reason)
    if not state or state.resolved then return end
    state.resolved = true
    refundCooldown(state)
    logFailureOnce(state, reason)
    print("[XNP GREEN VISIBLE TRANSACTION] damage_allowed=false success_sound_allowed=false"
        .. " cooldown_refunded=true reason=" .. tostring(reason))
    finallyCleanupCast(state, reason)
end

local function beginImpactTransaction(state, reason)
    if not state or state.resolved then return end
    local now = nowMs()
    local elapsed = now - state.startedMs
    if elapsed < state.options.minimumVisibleFlightMs then
        state.pendingImpactReason = reason
        return false, "MINIMUM_VISIBLE_FLIGHT_PENDING"
    end
    local proof = Core.GreenSmoothVisual.GetProof(state,
        state.options.minimumInflightRenderFrames)
    if proof.ready ~= true then
        state.pendingImpactReason = nil
        print("[XNP GREEN INFLIGHT GATE] IMPACT_DAMAGE_ALLOWED=false"
            .. " COOLDOWN_CONSUMED=false CAST_ABORT_REASON=INFLIGHT_DRAW_NOT_PROVEN"
            .. " elapsed_ms=" .. tostring(elapsed)
            .. " required_frames=" .. tostring(proof.requiredFrames)
            .. " reason=" .. tostring(proof.reason))
        abortVisualTransaction(state, "INFLIGHT_DRAW_NOT_PROVEN")
        return false, "INFLIGHT_DRAW_NOT_PROVEN"
    end
    state.pendingImpactReason = nil
    clearTargetOutline(state)
    local visible, visibleMethod = Core.GreenVisibleProxy.ShowImpact(state)
    if not visible then
        abortVisualTransaction(state, "SHOW_IMPACT_FAILED:" .. tostring(visibleMethod))
        return
    end
    state.phase = "IMPACT_VISIBLE"
    state.impactReason = reason
    state.impactVisibleAtMs = nowMs()
    state.damageAllowedAtMs = state.impactVisibleAtMs + state.options.impactVisualHoldMs
    notifyIcon("IMPACT")
    print("[XNP GREEN VISIBLE TRANSACTION] order=CREATE_VISIBLE_PROXY>CONFIRM_VISIBLE>TRACK>SHOW_IMPACT"
        .. " cast_id=" .. tostring(state.id)
        .. " impact_method=" .. tostring(visibleMethod)
        .. " hold_visible_ms=" .. tostring(state.options.impactVisualHoldMs)
        .. " damage_allowed_after_ms=" .. tostring(state.options.impactVisualHoldMs)
        .. " inflight_draw_proven=true minimum_flight_elapsed_ms=" .. tostring(elapsed))
    return true, "IMPACT_VISIBLE"
end

local function completeImpactTransaction(state, now)
    if not state or state.phase ~= "IMPACT_VISIBLE" or state.resolved then return end
    if now < (state.damageAllowedAtMs or math.huge) then return end
    if Core.GreenVisibleProxy.ConfirmImpact(state) ~= true then
        abortVisualTransaction(state, "IMPACT_VISIBILITY_CONFIRMATION_LOST")
        return
    end
    state.resolved = true
    local damageOk, damaged, damageMethod = applyGreenDamage(state)
    if not damageOk then
        refundCooldown(state)
        logFailureOnce(state, "DAMAGE_TRANSACTION_FAILED:" .. tostring(damageMethod))
        print("[XNP GREEN VISIBLE TRANSACTION] damage=false partial_hits=" .. tostring(damaged)
            .. " cooldown_refunded=true success_sound_allowed=false java_world_entities=0")
        finallyCleanupCast(state, "DAMAGE_TRANSACTION_FAILED")
        return
    end
    local soundOk, soundMethod = playOnce(state, "GREEN_BOMB_SKILL", "green-visible-impact", state.options.impactSound)
    local counters = state.humanSafetyCounters
    print("[XNP GREEN VISIBLE TRANSACTION] order=CREATE_VISIBLE_PROXY>CONFIRM_VISIBLE>TRACK>SHOW_IMPACT>HOLD_VISIBLE>APPLY_DAMAGE>CLEANUP"
        .. " cast_id=" .. tostring(state.id)
        .. " trigger=" .. tostring(state.impactReason)
        .. " sound_ok=" .. tostring(soundOk)
        .. " sound_method=" .. tostring(soundMethod)
        .. " damage_type=" .. Orb.DAMAGE_TYPE
        .. " total_targets_damaged=" .. tostring(damaged)
        .. " damage_method=" .. tostring(damageMethod)
        .. " verified_undead_damaged=" .. tostring(counters.verified_undead_damaged)
        .. " bandits_damaged=" .. tostring(counters.bandits_damaged)
        .. " human_npcs_damaged=" .. tostring(counters.human_npcs_damaged)
        .. " players_skipped=" .. tostring(counters.players_skipped)
        .. " bandits_skipped=" .. tostring(counters.bandits_skipped)
        .. " human_npcs_skipped=" .. tostring(counters.human_npcs_skipped)
        .. " ambiguous_humanoids_skipped=" .. tostring(counters.ambiguous_humanoids_skipped)
        .. " hit_failures=" .. tostring(counters.hit_failures)
        .. " players_damaged=0 animals_damaged=0"
        .. " structures_damaged=0 vehicles_damaged=0 fires_started=0"
        .. " native_trap_damage=0 set_health_route=0 java_world_entities=0"
        .. " IMPACT_DAMAGE_ALLOWED=true COOLDOWN_CONSUMED="
        .. tostring(state.options.testNoCooldown ~= true))
    finallyCleanupCast(state, state.impactReason)
end

function Orb.CanActivate(player)
    if not player then return false, "PLAYER_MISSING" end
    if tuningBoolean("EnableGreenTraitSystem", true) ~= true then return false, "GREEN_SYSTEM_DISABLED" end
    if tuningBoolean("GreenActiveSkillEnabled", true) ~= true then return false, "GREEN_ACTIVE_DISABLED" end
    if activeMode() == "OFF" then return false, "GREEN_ACTIVE_MODE_OFF" end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then return false, "GREEN_TRAIT_MISSING" end
    if not Core.GreenSkill or Core.GreenSkill.IsEnabled(player) ~= true then return false, "GREEN_MODE_WHITE" end
    if playerDead(player) then return false, "PLAYER_DEAD" end
    if type(isGamePaused) == "function" and isGamePaused() then return false, "GAME_PAUSED" end
    if Core.MeleeMode and Core.MeleeMode.IsMultiplayerProcess() then return false, "MULTIPLAYER_GREEN_ACTIVE_AUTHORITY_NOT_VERIFIED" end
    if Orb.active then return false, "GREEN_VIRTUAL_CAST_ALREADY_ACTIVE" end
    if tuningBoolean("GreenRuntimeTestNoCooldown", true) ~= true
        and nowMs() < (Orb.cooldownByPlayer[player] or 0) then
        return false, "GREEN_ACTIVE_COOLDOWN"
    end
    return true, "READY"
end

function Orb.RequestActivate(player, source)
    if Orb.active then
        finallyCleanupCast(Orb.active, "NEW_CAST_PREEMPT")
        return false, "GREEN_CAST_PREEMPTED_COOLDOWN_RETAINED"
    end
    local allowed, reason = Orb.CanActivate(player)
    if not allowed then return false, reason end
    local x = coordinate(player, "getX")
    local y = coordinate(player, "getY")
    local z = coordinate(player, "getZ")
    if not x or not y or not z then return false, "PLAYER_COORDINATE_UNAVAILABLE" end
    local options = settings()
    local target, targetSource = nil, "LOCAL_BLAST_NO_TARGET_REQUIRED"
    if options.mode == "VIRTUAL_TRACKING_BLAST" then
        target, targetSource = nearestTarget(x, y, z, options.targetRadius,
            options.targetPriorityMode, player, options)
    end
    local directionX, directionY, directionSource
    if target then
        local tx = coordinate(target, "getX")
        local ty = coordinate(target, "getY")
        directionX, directionY = normalized((tx or x) - x, (ty or y) - y)
        directionSource = "INITIAL_TARGET"
    end
    if not directionX then directionX, directionY, directionSource = playerForward(player) end
    local baseSpeed, speedSource = walkingSpeed(player)
    local now = nowMs()
    Orb.serial = Orb.serial + 1
    local state = {
        id = Orb.serial,
        player = player,
        mode = options.mode,
        options = options,
        world_x = x,
        world_y = y,
        world_z = z,
        directionX = directionX,
        directionY = directionY,
        directionSource = directionSource,
        baseSpeed = baseSpeed * options.initialMultiplier * options.initialSpeedScale,
        speed = baseSpeed * options.initialMultiplier * options.initialSpeedScale,
        speedSource = speedSource,
        startedMs = now,
        lastUpdateMs = now,
        nextSearchMs = now,
        noTargetSinceMs = target and nil or now,
        trackingStartedMs = nil,
        targetResultLogged = false,
        trackingStartedLogged = false,
        reacquisitionCount = 0,
        phase = "TRACKING",
        nextOutlinePulseMs = now,
        outlineRecords = {},
        mapHidden = Orb.mapHidden == true,
        humanSafetyCounters = Core.GreenHumanSafeClassifier.NewCounters(),
        pendingImpactReason = nil,
    }
    Orb.active = state
    setTarget(state, target, targetSource, now)
    local visible, visibleMethod = Core.GreenVisibleProxy.Create(state)
    if not visible then
        logFailureOnce(state, "CREATE_VISIBLE_PROXY_FAILED:" .. tostring(visibleMethod))
        print("[XNP GREEN VISIBLE TRANSACTION] damage_allowed=false cooldown_refunded=true"
            .. " required_layers_ready=false reason=" .. tostring(visibleMethod))
        finallyCleanupCast(state, "CREATE_VISIBLE_PROXY_FAILED")
        return false, "GREEN_VISIBLE_PROXY_CREATE_FAILED"
    end
    if target then
        logTargetAcquired(state, target, now)
        logTrackingStarted(state, now)
    end
    Orb.cooldownByPlayer[player] = options.testNoCooldown and 0 or (now + options.cooldownMs)
    playOnce(state, "GREEN_PROJECTILE_CAST", "green-virtual-cast", options.castSound)
    notifyIcon("CAST")
    print("[XNP GREEN VIRTUAL] cast_accepted=true cast_id=" .. tostring(state.id)
        .. " mode=" .. tostring(options.mode)
        .. " projectile_visual=PER_PLAYER_ZOOM_VIEWPORT_PROJECTED_DRAW_PROOF"
        .. " visible_confirmed=false inflight_draw_proof_pending=true visible_method=" .. tostring(visibleMethod)
        .. " world_coordinate_anchored=true screen_fixed_ui=false camera_reproject_every_frame=true"
        .. " sub_tile_interpolation=true visual_update_interval_frames=1"
        .. " java_world_entities=0"
        .. " initial_target=" .. tostring(target ~= nil)
        .. " lock_area_radius_tiles=" .. string.format("%.2f", options.lockAreaRadius)
        .. " outline_pulse_interval_sec=" .. string.format("%.2f", options.outlinePulseIntervalMs / 1000)
        .. " npc_damage_enabled=" .. tostring(options.npcDamageEnabled)
        .. " bandit_damage_enabled=" .. tostring(options.banditDamageEnabled)
        .. " player_damage_enabled=false"
        .. " base_speed_tps=" .. string.format("%.3f", state.baseSpeed)
        .. " speed_cap_tps=" .. string.format("%.2f", options.speedCap)
        .. " no_target_search_sec=" .. string.format("%.2f", options.noTargetMs / 1000)
        .. " impact_visual_hold_ms=" .. tostring(options.impactVisualHoldMs)
        .. " minimum_visible_flight_ms=" .. tostring(options.minimumVisibleFlightMs)
        .. " minimum_inflight_render_frames=" .. tostring(options.minimumInflightRenderFrames)
        .. " inflight_diagnostic_border=" .. tostring(options.inflightDiagnosticBorder)
        .. " cooldown_sec=" .. string.format("%.2f", options.cooldownMs / 1000)
        .. " test_no_cooldown_active=" .. tostring(options.testNoCooldown)
        .. " source=" .. tostring(source or "GREEN_LEFT_DOUBLE_CLICK"))
    if options.mode == "LOCAL_BLAST" then
        state.pendingImpactReason = "LOCAL_BLAST"
    end
    return true, state.id
end

local function acquireIfNeeded(state, now)
    if validTarget(state.target, state.options) then return true end
    if state.target then setTarget(state, nil, "TARGET_INVALID", now) end
    if not state.options.reacquisitionEnabled then return false end
    if state.options.maximumReacquisitionCount > 0
        and state.reacquisitionCount >= state.options.maximumReacquisitionCount then return false end
    if now < state.nextSearchMs then return false end
    state.nextSearchMs = now + state.options.targetSearchIntervalMs
    state.reacquisitionCount = state.reacquisitionCount + 1
    local target, source = nearestTarget(state.world_x, state.world_y, state.world_z,
        state.options.lockAreaEnabled and state.options.lockAreaRadius or state.options.reacquisitionRadius,
        state.options.targetPriorityMode, state.player, state.options)
    if target then
        setTarget(state, target, source, now)
        logTargetAcquired(state, target, now)
        logTrackingStarted(state, now)
        return true
    end
    state.noTargetSinceMs = state.noTargetSinceMs or now
    return false
end

local function stagedSpeed(state, ageSeconds)
    if ageSeconds <= state.options.accelerationStart then return state.baseSpeed, "LOW_SPEED_STAGE" end
    local elapsed = ageSeconds - state.options.accelerationStart
    local accelerated = state.baseSpeed * math.pow(state.options.accelerationPerSecond, elapsed)
    if accelerated >= state.options.speedCap then return state.options.speedCap, "ACCELERATED_CAP" end
    return accelerated, "ACCELERATED_PER_SECOND"
end

local function cancelNoTarget(state)
    if state.options.refundNoTarget then refundCooldown(state) end
    local cancelSound, cancelMethod = playOnce(state, "MARKER_TOGGLE", "green-virtual-cancel",
        tuningBoolean("EnableSounds", true))
    notifyIcon("CANCEL")
    if state.targetResultLogged ~= true then
        state.targetResultLogged = true
        print("[XNP GREEN TARGET] acquired=false reason=NO_VERIFIED_UNDEAD"
            .. " search_elapsed_ms=" .. tostring(nowMs() - state.startedMs))
    end
    print("[XNP GREEN VIRTUAL] cancelled=true reason=NO_TARGET damage=false cooldown_refunded="
        .. tostring(state.options.refundNoTarget)
        .. " cancel_sound=" .. tostring(cancelSound)
        .. " cancel_method=" .. tostring(cancelMethod)
        .. " java_world_objects=0")
    finallyCleanupCast(state, "NO_TARGET")
end

local function updateFlight(state, now)
    updateOutlinePulse(state, now)
    if state.pendingImpactReason then
        if now - state.startedMs >= state.options.minimumVisibleFlightMs then
            beginImpactTransaction(state, state.pendingImpactReason)
        end
        return
    end
    acquireIfNeeded(state, now)
    if not state.target and state.noTargetSinceMs and now - state.noTargetSinceMs >= state.options.noTargetMs then
        cancelNoTarget(state)
        return
    end
    if not state.target then return end

    local tx = coordinate(state.target, "getX")
    local ty = coordinate(state.target, "getY")
    if not tx or not ty then
        setTarget(state, nil, "TARGET_COORDINATE_INVALID", now)
        return
    end
    local desiredX, desiredY, distance = normalized(tx - state.world_x, ty - state.world_y)
    if distance <= state.options.impactDistance
        and now - state.startedMs >= state.options.minimumVisibleFlightMs then
        beginImpactTransaction(state, "TARGET_REACHED")
        return
    end

    local delta = math.max(0, math.min((now - state.lastUpdateMs) / 1000, 0.10))
    state.lastUpdateMs = now
    if desiredX then
        local currentAngle = math.atan2(state.directionY, state.directionX)
        local desiredAngle = math.atan2(desiredY, desiredX)
        local turn = angleDelta(currentAngle, desiredAngle)
        local maxTurn = math.pi * 3.0 * delta
        turn = math.max(-maxTurn, math.min(turn, maxTurn))
        currentAngle = currentAngle + turn
        state.directionX, state.directionY = math.cos(currentAngle), math.sin(currentAngle)
    end

    local ageSeconds = (now - (state.trackingStartedMs or now)) / 1000
    state.speed, state.speedStage = stagedSpeed(state, ageSeconds)
    local step = state.speed * delta
    if distance then step = math.min(step, distance) end
    local nextX = state.world_x + state.directionX * step
    local nextY = state.world_y + state.directionY * step
    if state.options.wallBlocking and blockedBetween(state.world_x, state.world_y, state.world_z, nextX, nextY) then
        beginImpactTransaction(state, "WALL_COLLISION")
        return
    end
    state.world_x, state.world_y = nextX, nextY
    local visible, visualMethod = Core.GreenVisibleProxy.Update(state)
    if not visible then
        abortVisualTransaction(state, "TRACK_VISUAL_UPDATE_FAILED:" .. tostring(visualMethod))
        return
    end
    if state.trackingStartedMs and now - state.trackingStartedMs >= state.options.maximumFlightMs then
        beginImpactTransaction(state, "TIMEOUT")
    end
end

local function updateProtected(player)
    local now = nowMs()
    sampleWalkingSpeed(player, now)
    local state = Orb.active
    if not state then return false end
    if state.player ~= player then finallyCleanupCast(state, "PLAYER_REPLACED"); return false end
    if playerDead(player) then finallyCleanupCast(state, "PLAYER_DEATH"); return false end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then
        finallyCleanupCast(state, "PLAYER_TRAIT_INVALID")
        return false
    end
    if type(isGamePaused) == "function" and isGamePaused() then
        finallyCleanupCast(state, "WORLD_EXIT")
        return false
    end
    if state.phase == "IMPACT_VISIBLE" then
        completeImpactTransaction(state, now)
    else
        updateFlight(state, now)
    end
    return true
end

function Orb.Update(player)
    local ok, result = pcall(updateProtected, player)
    if not ok then
        local state = Orb.active
        if state then
            logFailureOnce(state, "EXCEPTION_GUARD:" .. tostring(result))
            finallyCleanupCast(state, "EXCEPTION_GUARD")
        end
        return false
    end
    return result
end

function Orb.InitializePlayer(player, source)
    if Orb.active and Orb.active.player ~= player then finallyCleanupCast(Orb.active, "PLAYER_REPLACED") end
    if Core.GreenVisibleProxy and Core.GreenVisibleProxy.Preflight then
        Core.GreenVisibleProxy.Preflight()
    end
    print("[XNP GREEN VIRTUAL] initialize=true source=" .. tostring(source or "PLAYER_LOAD")
        .. " stale_java_entity_cleanup_required=false")
    return true
end

function Orb.SetMapHidden(hidden)
    Orb.mapHidden = hidden == true
    if Orb.active then Orb.active.mapHidden = Orb.mapHidden end
end

function Orb.Cleanup(player, reason)
    if Orb.active then finallyCleanupCast(Orb.active, reason or "WORLD_EXIT") end
end

function Orb.Shutdown(reason)
    local rawReason = tostring(reason or "WORLD_EXIT")
    local cleanupReason = SHUTDOWN_REASON[string.lower(rawReason)] or string.upper(rawReason)
    if Orb.active then finallyCleanupCast(Orb.active, cleanupReason) end
    Orb.cooldownByPlayer = setmetatable({}, { __mode = "k" })
    Orb.walkSamples = setmetatable({}, { __mode = "k" })
    Orb.outlineOwners = setmetatable({}, { __mode = "k" })
    Orb.outlineSerial = 0
    Orb.failureLogged = {}
    if Core.GreenVisibleProxy and Core.GreenVisibleProxy.ResetPreflight then
        Core.GreenVisibleProxy.ResetPreflight()
    end
    if Core.GreenSmoothVisual and Core.GreenSmoothVisual.Shutdown then Core.GreenSmoothVisual.Shutdown() end
end

Core.GreenWorldOrb = Orb
if not Core.green_virtual_056075_startup_logged then
    Core.green_virtual_056075_startup_logged = true
    print("[XNP GREEN VIRTUAL] mode=VIRTUAL_TRACKING_BLAST"
        .. " projectile_visual=PER_PLAYER_ZOOM_VIEWPORT_PROJECTED_DRAW_PROOF"
        .. " world_coordinate_anchored=true screen_fixed_ui=false camera_reproject_every_frame=true"
        .. " sub_tile_interpolation=true visual_update_interval_frames=1"
        .. " minimum_visible_flight_ms=500 minimum_inflight_render_frames=2"
        .. " java_world_entity_count=0 persistent_ispanel=0")
end
return Orb
