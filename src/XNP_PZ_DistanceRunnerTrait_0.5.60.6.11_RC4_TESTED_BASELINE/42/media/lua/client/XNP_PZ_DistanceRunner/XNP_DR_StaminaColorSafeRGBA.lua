require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner

local SafeRGBA = {
    logged = false,
    colors = {
        green = { r = 0.15, g = 0.95, b = 0.25, a = 1.0 },
        blue = { r = 0.20, g = 0.55, b = 1.00, a = 1.0 },
        yellow = { r = 1.00, g = 0.80, b = 0.10, a = 1.0 },
        red = { r = 1.00, g = 0.15, b = 0.10, a = 1.0 },
        grey = { r = 0.55, g = 0.55, b = 0.55, a = 1.0 },
        white = { r = 1.00, g = 1.00, b = 1.00, a = 1.0 },
    },
}

function SafeRGBA.LogOnce()
    if SafeRGBA.logged then
        return
    end
    SafeRGBA.logged = true
    print("[XNP STAMINA ICON COLOR] mode=SAFE_RGBA no_named_color=true")
    Core.LogThrottle.Event("[XNP STAMINA ICON COLOR] configured=true")
end

function SafeRGBA.Get(name)
    SafeRGBA.LogOnce()
    return SafeRGBA.colors[name] or SafeRGBA.colors.white
end

function SafeRGBA.Unpack(name)
    local c = SafeRGBA.Get(name)
    return c.r, c.g, c.b, c.a
end

Core.StaminaColorSafeRGBA = SafeRGBA
return SafeRGBA
