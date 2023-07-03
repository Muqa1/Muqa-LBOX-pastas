-- edit the numbers to change the colours, the format is rgba (RED, GREEN, BLUE, ALPHA)

enemy = {82, 163, 255, 255}
enemyInvisible = {51, 101, 158, 255}

friendly = {255, 204, 110, 255}
friendlyInvisible = {150, 120, 65, 255}

menu = {82, 163, 255, 255}

AimbotTarget = {201, 222, 255, 255}

nightmode = {230, 201, 255, 255}

backtrack = {82, 163, 255, 255}

AntiAimIndicator = {255, 255, 255, 255}


--====================================================================================--
-- dont touch anything from down here unless you know what ur doing
function rgbaToHex(r, g, b, a)
    r = math.floor(r)
    g = math.floor(g)
    b = math.floor(b)
    a = math.floor(a)
    return tonumber("0x".. string.format("%02x%02x%02x%02x", r, g, b, a))
end
enemy_hex = rgbaToHex(table.unpack(enemy)) 
enemyInvisible_hex = rgbaToHex(table.unpack(enemyInvisible)) 
friendly_hex = rgbaToHex(table.unpack(friendly))
friendlyInvisible_hex = rgbaToHex(table.unpack(friendlyInvisible)) 
menu_hex = rgbaToHex(table.unpack(menu))
AimbotTarget_hex = rgbaToHex(table.unpack(AimbotTarget))
nightmode_hex = rgbaToHex(table.unpack(nightmode)) 
backtrack_hex = rgbaToHex(table.unpack(backtrack)) 
AntiAimIndicator_hex = rgbaToHex(table.unpack(AntiAimIndicator)) 
local function colors()
if engine.IsGameUIVisible() == false then
    if entities.GetLocalPlayer():GetTeamNumber() == 2 then 
        gui.SetValue("blue team color", enemy_hex) -- enemy 
        gui.SetValue("blue team (invisible)", enemyInvisible_hex)

        gui.SetValue("red team (invisible)", friendlyInvisible_hex)
        gui.SetValue( "red team color", friendly_hex) --friendly 
    else
        gui.SetValue("blue team color", friendly_hex) --friendly
        gui.SetValue("blue team (invisible)", friendlyInvisible_hex)

        gui.SetValue("red team (invisible)", enemyInvisible_hex)
        gui.SetValue( "red team color", enemy_hex) -- enemy
    end
    gui.SetValue( "gui color", menu_hex) 
    gui.SetValue( "aimbot target color", AimbotTarget_hex)
    gui.SetValue( "night mode color", nightmode_hex)
    gui.SetValue( "backtrack ticks color", backtrack_hex)
    gui.SetValue( "Anti aim indicator color", AntiAimIndicator_hex)
    end
end
callbacks.Register( "Draw", "colors", colors)
