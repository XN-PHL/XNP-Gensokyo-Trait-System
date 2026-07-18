require "ISUI/ISPanel"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Frame = {
    PANEL_SIZE = 32,
    CENTER_SIZE = 16,
    CENTER_OFFSET = 8,
    GAP = 4,
    RIGHT_MARGIN = 8,
    DEFAULT_Y = 76,
    UPDATE_INTERVAL_MS = 250,
    shellAttempted = false,
    shellSolid = nil,
    shellOutline = nil,
}

Frame.COLORS = {
    WHITE = { r = 0.92, g = 0.92, b = 0.92, a = 0.94 },
    GREEN = { r = 0.18, g = 0.86, b = 0.28, a = 0.96 },
    BLUE = { r = 0.18, g = 0.52, b = 1.00, a = 0.96 },
    YELLOW = { r = 1.00, g = 0.82, b = 0.10, a = 0.97 },
    RED = { r = 0.96, g = 0.16, b = 0.14, a = 0.97 },
}

        print("[XNP ROUND UI] draw_api_contract=READY version=0.5.60.3")

local SOLID_PATH = "media/ui/Moodles/32/_Moodles_BGsolid.png"
local OUTLINE_PATH = "media/ui/Moodles/32/_Moodles_BGoutline.png"

function Frame.NowMs()
    return type(getTimestampMs) == "function" and getTimestampMs() or os.time() * 1000
end

function Frame.ScreenSize()
    if type(getCore) == "function" then
        local core = getCore()
        if core then
            local width = type(core.getScreenWidth) == "function" and core:getScreenWidth() or 1280
            local height = type(core.getScreenHeight) == "function" and core:getScreenHeight() or 720
            return width, height
        end
    end
    return 1280, 720
end

function Frame.DefaultPosition(rightIndex)
    local width = Frame.ScreenSize()
    local index = math.max(0, tonumber(rightIndex) or 0)
    local x = width - Frame.RIGHT_MARGIN - Frame.PANEL_SIZE - index * (Frame.PANEL_SIZE + Frame.GAP)
    return math.max(0, x), Frame.DEFAULT_Y
end

function Frame.Clamp(x, y)
    local width, height = Frame.ScreenSize()
    local maxX = math.max(0, width - Frame.PANEL_SIZE)
    local maxY = math.max(0, height - Frame.PANEL_SIZE)
    return math.max(0, math.min(tonumber(x) or 0, maxX)),
        math.max(0, math.min(tonumber(y) or 0, maxY))
end

function Frame.ClampPanel(panel, x, y)
    if not panel then return end
    local px, py = Frame.Clamp(x, y)
    panel:setX(px)
    panel:setY(py)
end

function Frame.PlayerData(player)
    if player and type(player.getModData) == "function" then
        local ok, data = pcall(function() return player:getModData() end)
        if ok and type(data) == "table" then return data end
    end
    return nil
end

local function validPoint(point)
    return type(point) == "table" and type(point.x) == "number" and type(point.y) == "number"
        and point.x == point.x and point.y == point.y
end

local function pointInsideViewport(point)
    if not validPoint(point) then return false end
    local width, height = Frame.ScreenSize()
    return point.x >= 0 and point.y >= 0
        and point.x <= math.max(0, width - Frame.PANEL_SIZE)
        and point.y <= math.max(0, height - Frame.PANEL_SIZE)
end

function Frame.LoadPosition(player, newKey, legacyKeys, defaultRightIndex)
    local data = Frame.PlayerData(player)
    local defaultX, defaultY = Frame.DefaultPosition(defaultRightIndex)
    if not data then return defaultX, defaultY, "DEFAULT_NO_MODDATA" end

    local current = data[newKey]
    if validPoint(current) then
        local x, y = Frame.Clamp(current.x, current.y)
        data[newKey] = { x = x, y = y }
        return x, y, "CURRENT_0557"
    end

    for _, key in ipairs(legacyKeys or {}) do
        local legacy = data[key]
        if pointInsideViewport(legacy) then
            data[newKey] = { x = legacy.x, y = legacy.y }
            return legacy.x, legacy.y, "LEGACY_READ_ONLY:" .. tostring(key)
        end
    end

    data[newKey] = { x = defaultX, y = defaultY }
    return defaultX, defaultY, "DEFAULT_INVALID_OR_MISSING_LEGACY"
end

function Frame.SavePosition(player, newKey, panel)
    local data = Frame.PlayerData(player)
    if not data or not panel then return false end
    local x, y = Frame.Clamp(panel:getX(), panel:getY())
    data[newKey] = { x = x, y = y }
    return true
end

function Frame.PointInside(x, y)
    return (tonumber(x) or -1) >= 0 and (tonumber(y) or -1) >= 0
        and (tonumber(x) or -1) <= Frame.PANEL_SIZE
        and (tonumber(y) or -1) <= Frame.PANEL_SIZE
end

function Frame.LoadShellTextures()
    if Frame.shellAttempted then return Frame.shellSolid ~= nil and Frame.shellOutline ~= nil end
    Frame.shellAttempted = true
    if type(getTexture) == "function" then
        Frame.shellSolid = getTexture(SOLID_PATH)
        Frame.shellOutline = getTexture(OUTLINE_PATH)
    end
    print("[XNP ROUND FRAME] solid=" .. tostring(Frame.shellSolid ~= nil)
        .. " outline=" .. tostring(Frame.shellOutline ~= nil)
        .. " center_tint=false center_size=16 shell_size=32")
    return Frame.shellSolid ~= nil and Frame.shellOutline ~= nil
end

function Frame.Draw(panel, centerTexture, colorName)
    if not panel then error("[XNP ROUND UI] draw contract failed: panel is nil") end
    if not centerTexture then error("[XNP ROUND UI] draw contract failed: center texture is nil") end
    if not Frame.LoadShellTextures() then error("[XNP ROUND UI] draw contract failed: shell texture is nil") end
    local color = Frame.COLORS[colorName] or Frame.COLORS.WHITE
    panel:drawTextureScaled(Frame.shellSolid, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
        color.a, color.r, color.g, color.b)
    panel:drawTextureScaled(Frame.shellOutline, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
        1.0, 1.0, 1.0, 1.0)
    panel:drawTextureScaled(centerTexture, Frame.CENTER_OFFSET, Frame.CENTER_OFFSET,
        Frame.CENTER_SIZE, Frame.CENTER_SIZE, 1.0, 1.0, 1.0, 1.0)
    return true
end

function Frame.DrawAtOffset(panel, centerTexture, colorName, offsetX, offsetY)
    if not panel then error("[XNP ROUND UI] offset draw contract failed: panel is nil") end
    if not centerTexture then error("[XNP ROUND UI] offset draw contract failed: center texture is nil") end
    if not Frame.LoadShellTextures() then error("[XNP ROUND UI] offset draw contract failed: shell texture is nil") end
    local color = Frame.COLORS[colorName] or Frame.COLORS.WHITE
    local ox = tonumber(offsetX) or 0
    local oy = tonumber(offsetY) or 0
    panel:drawTextureScaled(Frame.shellSolid, ox, oy, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
        color.a, color.r, color.g, color.b)
    panel:drawTextureScaled(Frame.shellOutline, ox, oy, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
        1.0, 1.0, 1.0, 1.0)
    panel:drawTextureScaled(centerTexture, Frame.CENTER_OFFSET + ox, Frame.CENTER_OFFSET + oy,
        Frame.CENTER_SIZE, Frame.CENTER_SIZE, 1.0, 1.0, 1.0, 1.0)
    return true
end

function Frame.PreparePanel(panel)
    panel:noBackground()
    panel.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    panel.moveWithMouse = false
end

XNP_PZ_DistanceRunner.RoundMarkerFrame = Frame
return Frame
