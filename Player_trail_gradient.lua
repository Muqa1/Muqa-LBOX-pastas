-- these are the settings that you can edit
local trail_length = 100 -- this is in ticks, also if you use high values like 1000, it can decrease your FPS

local startColorR, startColorG, startColorB = 255, 0, 128 -- The color towards the start of the line (insert a rgb color)
local endColorR, endColorG, endColorB = 0, 255, 247 -- The color towards the end of the line (insert a rgb color)

--==========================================================================--
local playerPositions = {}

local function aUpdate()
    if engine.IsGameUIVisible() == true and not entities.GetLocalPlayer():IsAlive() then
        playerPositions = {}
        return
    end
    table.insert(playerPositions, 1, entities.GetLocalPlayer():GetAbsOrigin())
    if #playerPositions > trail_length then
        table.remove(playerPositions)
    end
end
callbacks.Register("CreateMove", "aUpdate", aUpdate)

local function aDraw()
    if engine.IsGameUIVisible() == true and not entities.GetLocalPlayer():IsAlive() then
        playerPositions = {}
        return
    end

    if #playerPositions > 1 then

        for i = 1, #playerPositions - 1 do
            local startPos = client.WorldToScreen(playerPositions[i])
            local endPos = client.WorldToScreen(playerPositions[i + 1])
            if startPos ~= nil and endPos ~= nil then
                local gradientRatio = i / (#playerPositions - 1)
                local r = math.floor(startColorR + (endColorR - startColorR) * gradientRatio)
                local g = math.floor(startColorG + (endColorG - startColorG) * gradientRatio)
                local b = math.floor(startColorB + (endColorB - startColorB) * gradientRatio)
                draw.Color(r, g, b, 255)
                draw.Line(startPos[1], startPos[2], endPos[1], endPos[2])
            end
        end
    end
end
callbacks.Register("Draw", "aDraw", aDraw)
