function rgbaToHex(r, g, b, a)
    r = math.floor(r)
    g = math.floor(g)
    b = math.floor(b)
    a = math.floor(a)
    return tonumber("0x".. string.format("%02x%02x%02x%02x", r, g, b, a))
end

-- edit the numbers to change the colours, the format is (RED, GREEN, BLUE, ALPHA)

enemy = rgbaToHex(82, 163, 255, 255) 
enemyInvisible = rgbaToHex(51, 101, 158, 255) 

friendly = rgbaToHex(255, 204, 110, 255)
friendlyInvisible = rgbaToHex(150, 120, 65, 255) 

menu = rgbaToHex(82, 163, 255, 255)

AimbotTarget = rgbaToHex(201, 222, 255, 255)

nightmode = rgbaToHex(230, 201, 255, 255) 

backtrack = rgbaToHex(82, 163, 255, 255) 

--------

local function colors()
if engine.IsGameUIVisible() == false then
    local player = entities.GetLocalPlayer()
    
    local myteam = player:GetTeamNumber()

    if myteam == 2 then 
        gui.SetValue("blue team color", enemy) -- enemy 
        gui.SetValue("blue team (invisible)", enemyInvisible)

        gui.SetValue("red team (invisible)", friendlyInvisible)
        gui.SetValue( "red team color", friendly) --friendly 
    else
        gui.SetValue("blue team color", friendly) --friendly
        gui.SetValue("blue team (invisible)", friendlyInvisible)

        gui.SetValue("red team (invisible)", enemyInvisible)
        gui.SetValue( "red team color", enemy) -- enemy
    end
    
    gui.SetValue( "gui color", menu) 

    gui.SetValue( "aimbot target color", AimbotTarget )
    
    gui.SetValue( "night mode color", nightmode )

    gui.SetValue( "backtrack ticks color", backtrack )
    end
end
callbacks.Register( "Draw", colors)
