require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner

local MinorScrapeCost = {}
XNP_DR_MinorScrapeCost = MinorScrapeCost

local allowedSources = {
    VEHICLE_WALL_CRASH = true,
    SPRINT_OVERFLOW_WALL_CRASH = true,
    SPRINT_NATIVE_TRIP = true,
}

local safeParts = {
    "ForeArm_L", "ForeArm_R", "Hand_L", "Hand_R",
    "LowerLeg_L", "LowerLeg_R", "Foot_L", "Foot_R",
}

local function safePart(player)
    if not player or type(player.getBodyDamage) ~= "function" then
        return nil, "NO_SAFE_BODY_PART_API"
    end
    local ok, body = pcall(function()
        return player:getBodyDamage()
    end)
    if not ok or not body or type(body.getBodyPart) ~= "function" or not BodyPartType then
        return nil, "NO_SAFE_BODY_PART_API"
    end
    for _, name in ipairs(safeParts) do
        local partType = BodyPartType[name]
        if partType ~= nil then
            local okPart, part = pcall(function()
                return body:getBodyPart(partType)
            end)
            if okPart and part then
                return part, name
            end
        end
    end
    return nil, "NO_SAFE_BODY_PART_API"
end

function MinorScrapeCost.Apply(player, source)
    if not allowedSources[source] then
        print("[XNP SCRAPE FAIL] reason=SOURCE_NOT_ALLOWED fallback=SKIP")
        return false
    end
    local part, name = safePart(player)
    if not part then
        print("[XNP SCRAPE FAIL] reason=" .. tostring(name) .. " fallback=SKIP")
        print("[XNP SCRAPE] no_bite=true no_infection=true no_heal=true")
        return false
    end
    local ok = false
    if type(part.SetScratched) == "function" then
        ok = pcall(function()
            part:SetScratched(true, false)
        end)
    elseif type(part.setScratched) == "function" then
        ok = pcall(function()
            part:setScratched(true, false)
        end)
    end
    if ok then
        print("[XNP SCRAPE] type=MINOR_SCRAPE source=" .. tostring(source) .. " body_part=" .. tostring(name) .. " no_artery=true result=APPLIED")
        print("[XNP SCRAPE] no_bite=true no_infection=true no_heal=true")
        return true
    end
    print("[XNP SCRAPE FAIL] reason=NO_SAFE_BODY_PART_API fallback=SKIP")
    print("[XNP SCRAPE] no_bite=true no_infection=true no_heal=true")
    return false
end

Core.MinorScrapeCost = MinorScrapeCost
return MinorScrapeCost
