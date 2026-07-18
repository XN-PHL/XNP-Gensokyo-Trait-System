XNPDistanceRunnerTraitRegistries = XNPDistanceRunnerTraitRegistries or {}

local XNP_DR_TRAIT_ID = "XNPDistanceRunner"
local XNP_DR_TRAIT_FULL_ID = "XNPDistanceRunnerTrait:XNPDistanceRunner"
local XNP_PHOENIX_TRAIT_FULL_ID = "XNPPhoenixTrait:XNPPurplePhoenix"
local XNP_GREEN_TRAIT_FULL_ID = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage"
local XNP_RED_TRAIT_FULL_ID = "XNPFeastGuardianTrait:XNPFeastGuardian"
local XNP_DR_BACKEND = "BACKEND_C_SCRIPT_DEFINITION"
local XNP_DR_REGISTERED = false
local XNP_PHOENIX_REGISTERED = false
local XNP_GREEN_REGISTERED = false
local XNP_RED_REGISTERED = false

local function log(message)
    print("[XNP DISTANCE RUNNER] " .. tostring(message))
end

log("trait definition begin id=" .. XNP_DR_TRAIT_ID .. " full_id=" .. XNP_DR_TRAIT_FULL_ID .. " backend=" .. XNP_DR_BACKEND)

if CharacterTrait and type(CharacterTrait.register) == "function" then
    local ok, result = pcall(function()
        return CharacterTrait.register(XNP_DR_TRAIT_FULL_ID)
    end)
    if ok and result then
        XNPDistanceRunnerTraitRegistries.XNPDistanceRunner = result
        XNP_DR_REGISTERED = true
        log("native CharacterTrait registered id=" .. XNP_DR_TRAIT_FULL_ID)
    else
        log("trait definition failed stage=CharacterTrait.register reason=" .. tostring(result))
    end
else
    log("trait definition failed stage=CharacterTrait.register reason=api_unavailable")
end

-- Register Phoenix as a second native CharacterTrait object. Keeping the
-- registration separate ensures that it can coexist with Distance Runner and
-- never replaces the existing yellow trait in the character-creation screen.
if CharacterTrait and type(CharacterTrait.register) == "function" then
    local ok, result = pcall(function()
        return CharacterTrait.register(XNP_PHOENIX_TRAIT_FULL_ID)
    end)
    if ok and result then
        XNPDistanceRunnerTraitRegistries.XNPPurplePhoenix = result
        XNP_PHOENIX_REGISTERED = true
        log("native CharacterTrait registered id=" .. XNP_PHOENIX_TRAIT_FULL_ID)
    else
        log("phoenix trait definition failed stage=CharacterTrait.register reason=" .. tostring(result))
    end
else
    log("phoenix trait definition failed stage=CharacterTrait.register reason=api_unavailable")
end

local function registerExtra(fullId, registryKey, label)
    if not CharacterTrait or type(CharacterTrait.register) ~= "function" then
        log(label .. " trait definition failed reason=api_unavailable")
        return false
    end
    local ok, result = pcall(function() return CharacterTrait.register(fullId) end)
    if ok and result then
        XNPDistanceRunnerTraitRegistries[registryKey] = result
        log("native CharacterTrait registered id=" .. fullId)
        return true
    end
    log(label .. " trait definition failed reason=" .. tostring(result))
    return false
end

XNP_GREEN_REGISTERED = registerExtra(XNP_GREEN_TRAIT_FULL_ID, "XNPBlueEcoBarrage", "green")
XNP_RED_REGISTERED = registerExtra(XNP_RED_TRAIT_FULL_ID, "XNPFeastGuardian", "red")

print("[XNP TRAITS] distance_runner=" .. tostring(XNP_DR_REGISTERED) .. " phoenix=" .. tostring(XNP_PHOENIX_REGISTERED) .. " green=" .. tostring(XNP_GREEN_REGISTERED) .. " red=" .. tostring(XNP_RED_REGISTERED) .. " cost_each=1")
print("[XNP TRAITS] all_four_available=" .. tostring(XNP_DR_REGISTERED and XNP_PHOENIX_REGISTERED and XNP_GREEN_REGISTERED and XNP_RED_REGISTERED) .. " mutual_exclusions=0")
