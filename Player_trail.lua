-- these are the settings that you can edit

local trail_lenght = 100 -- this is in ticks

local rainbow_speed = 2 -- the rgb rainbow effect speed


--==========================================================================--
local playerPositions = {}
local function aUpdate()
    if engine.IsGameUIVisible() == true then playerPositions = {} return end
    table.insert(playerPositions, 1, entities.GetLocalPlayer():GetAbsOrigin()) 
    if #playerPositions > trail_lenght then
        table.remove(playerPositions) 
    end
end
callbacks.Register("CreateMove", "aUpdate", aUpdate)
local function aDraw()
    if engine.IsGameUIVisible() == true then playerPositions = {} return end
    function RGBRainbow(frequency)
        local curtime = globals.CurTime() 
        local r, g, b
        r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
        g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
        b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)
        return r, g, b
    end
    local r, g, b = RGBRainbow(rainbow_speed)
    if #playerPositions > 1 then
        for i = 1, #playerPositions - 1 do
            local startPos = client.WorldToScreen(playerPositions[i])
            local endPos = client.WorldToScreen(playerPositions[i + 1])
            if startPos ~= nil and endPos ~= nil then
                draw.Color(r, g, b, 255)
                draw.Line(startPos[1], startPos[2], endPos[1], endPos[2])
            end
        end
    end
end
callbacks.Register("Draw", "aDraw", aDraw)
