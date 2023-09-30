local menu = {
    x = 500,
    y = 500,

    w = 405,
    h = 330,

    rX = 0,
    rY = 0,

    tabs = {
        tab_1 = true,
        tab_2 = false,
        tab_3 = false,
        tab_4 = false,
    },

    buttons = {
        antiaim = false,
        visuals = false,
        misc = false,
        cfg = false
    },

    toggles = {
        AA_spin_enable = false,
        AA_spin_inverted = false,
        AA_spin_rand_speed = false,
        AA_spin_rand_invert = false,

        pitch_rand_up = false,
        pitch_rand_down = false,

        rotate_dyn_enable = false,

        rand_fakelag = false,

        leg_jitter = false,

        crosshair_indicators = false,

        AA_lines = false,
        AA_lines_alt = false,
    },

    sliders = {
        AA_spin_speed = 5,

        rotate_dyn_delay = 500,
        rotate_dyn_fake1 = 90,
        rotate_dyn_fake2 = -90,
        rotate_dyn_real1 = -90,
        rotate_dyn_real2 = 90,

        rand_fakelag_min = 15,
        rand_fakelag_max = 22,

        leg_jitter_value = 20,

        AA_lines_size = 20,

    },
}

local tahoma = draw.CreateFont( "Tahoma", 12, 400, FONTFLAG_OUTLINE )
local tahoma2 = draw.CreateFont( "Tahoma", 12, 400)
local tahoma_bold = draw.CreateFont( "Tahoma", 12, 800, FONTFLAG_OUTLINE )

local f = math.floor

local function IsMouseInBounds(x,y,x2,y2)
    local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2]
    if mX >= x and mX <= x2 and mY >= y and mY <= y2 then
        return true 
    end
    return false
end

local function LerpBetweenColors(color1, color2, frequency)
    local curtime = globals.CurTime()
    local t = (math.sin(curtime * frequency) + 1) / 2
    t = math.max(0, math.min(1, t))
    local r1, g1, b1 = color1[1], color1[2], color1[3]
    local r2, g2, b2 = color2[1], color2[2], color2[3]
    local r = math.floor(r1 + (r2 - r1) * t)
    local g = math.floor(g1 + (g2 - g1) * t)
    local b = math.floor(b1 + (b2 - b1) * t)
    return r, g, b
end

local function ColorWaveTextEffect(x, y, text_string, startColor, endColor, speed)
    local numChars = #text_string
    local currentTime = globals.RealTime()
    if numChars > 0 then
        for i = 1, numChars do
            local t = (i - 1) / (numChars - 1)
            local waveOffset = math.sin(currentTime * speed + t * math.pi * 2) * 0.5 + 0.5  -- Create a wave effect
            local color = {
                math.floor(startColor[1] + (endColor[1] - startColor[1]) * waveOffset),
                math.floor(startColor[2] + (endColor[2] - startColor[2]) * waveOffset),
                math.floor(startColor[3] + (endColor[3] - startColor[3]) * waveOffset),
                math.floor(startColor[4] + (endColor[4] - startColor[4]) * waveOffset)}
            draw.Color(color[1], color[2], color[3], color[4])
            draw.Text(x, y, text_string:sub(i, i))
            local width = draw.GetTextSize(text_string:sub(i, i))
            x = x + width
        end
    end
end

local function TextInCenter(x,y,x2,y2,string)
    local w, h = draw.GetTextSize(string)
    local width, height = x2-x, y2-y
    draw.Text(math.floor(x+(width/2)-(w/2)), math.floor(y+(height/2)-(h/2)), string)
end

local Toggles = {}
local function Toggle(x, y, name, toggle_bool)
    local w, h = draw.GetTextSize(name)
    local pos = {x, y, x + 20, y + 20}
    if Toggles[toggle_bool] == nil then
        table.insert(Toggles, toggle_bool)
    end
    local clr = {10, 10, 10, 50}
    if IsMouseInBounds(table.unpack(pos)) and input.IsButtonPressed(MOUSE_LEFT) then
        local currentTime = globals.RealTime()
        if currentTime - (Toggles[toggle_bool] or 0) >= 0.1 then
            menu.toggles[toggle_bool] = not menu.toggles[toggle_bool]
            Toggles[toggle_bool] = currentTime
        end
        clr = {40, 40, 40, 50}
    end
    draw.Color(table.unpack(clr))
    draw.FilledRect(table.unpack(pos))
    draw.Color(45, 45, 45, 255)
    draw.OutlinedRect(table.unpack(pos))
    draw.Color(255, 255, 255, 255)
    draw.Text(pos[3]+5,y+f(h/4), name)
    if menu.toggles[toggle_bool] == true then
        draw.Color(60, 60, 60, 255)
        draw.FilledRect(pos[1] + 5, pos[2] + 5, pos[3] - 5, pos[4] - 5)
    end
end

local function Island(x,y,x2,y2, name)
    local r,g,b = LerpBetweenColors({135, 141, 250}, {196, 147, 165}, 1)
    draw.Color(10, 10, 10, 50)
    draw.FilledRect(x,y,x2,y2)
    draw.Color( r,g,b,125 )
    draw.OutlinedRect(x, y, x2, y2)
    draw.Color( r,g,b,40 )
    draw.FilledRect(x, y - 15, x2, y)
    draw.Color( r,g,b,125 )
    draw.OutlinedRect(x, y - 15, x2, y)
    draw.Color( 255,255,255,255 )
    local w,h = draw.GetTextSize(name)
    draw.Text(math.floor(x+((x2-x)/2)-(w/2)), math.floor(y-15), name )
end

local function Slider(x,y,x2,y2, sliderValue ,min,max, name)
    local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2]
    local value = menu.sliders[sliderValue]

    if IsMouseInBounds(x,y,x2,y2) and input.IsButtonDown(MOUSE_LEFT) then 
        function clamp(value, min, max) -- math.clamp was causing errors :shrug:
            return math.max(min, math.min(max, value))
        end
        local percent = clamp((mX - x) / (x2-x), 0, 1)
        local value2 = math.floor((min + (max - min) * percent))
        menu.sliders[sliderValue] = value2
    end

    draw.Color(40,40,40,255)
    draw.OutlinedRect(x,y,x2,y2)
    draw.Color(10,10,10,50)
    draw.FilledRect(x,y,x2,y2)

    local r,g,b = LerpBetweenColors({135, 141, 250}, {196, 147, 165}, 1)
    draw.Color( r,g,b,40 )

    local sliderWidth = math.floor((x2-x) * (value - min) / (max - min))
    local pos = {x, y, x + sliderWidth, y2}
    draw.FilledRect(table.unpack(pos))
    draw.Color( r,g,b,255 )
    draw.OutlinedRect(table.unpack(pos))
    
    draw.Color(255,255,255,255)
    local w,h = draw.GetTextSize( value )
    draw.Text(x2-w, pos[2]-h, value)

    w,h = draw.GetTextSize( name )
    draw.Text(x, pos[2]-h, name)
end


local lastToggleTime = 0
local Lbox_Menu_Open = true
local function toggleMenu()
    local currentTime = globals.RealTime()
    if currentTime - lastToggleTime >= 0.1 then
        Lbox_Menu_Open = not Lbox_Menu_Open
        lastToggleTime = currentTime
    end
end

local buttons = {
    [1] = {name="Anti Aim", table="antiaim"},
    [2] = {name="Visuals", table="visuals"},
    [3] = {name="Misc", table="misc"},
    [4] = {name="Cfg", table="cfg"}
}

local left_islands = {
    [1] = {
        name="Island 1",
    }
}

local function DrawMenu()
    if not Lbox_Menu_Open then return end
    draw.SetFont( tahoma )

    local x, y = menu.x, menu.y
    local bW, bH = menu.w, menu.h
    local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2]

    if IsMouseInBounds(x, y - 15, x + bW, y) then
        if not input.IsButtonDown(MOUSE_LEFT) then
            menu.rX = ((mX - x) / bW)
            menu.rY = ((mY - y) / 15)
        else
            menu.x = mX - math.floor(bW * menu.rX)
            menu.y = mY - math.floor(15 * menu.rY)
        end
    end


    draw.Color( 30, 30, 30, 255 )
    draw.FilledRect(x, y, x + bW, y + bH) -- main backround

    local r,g,b = LerpBetweenColors({135, 141, 250}, {196, 147, 165}, 1)
    draw.Color( r,g,b,255 )
    draw.OutlinedRect(x, y - 15, x + bW, y + bH) -- outline to the main menu
    draw.OutlinedRect(x, y - 15, x + bW, y) -- outline of blue bar

    draw.Color( r,g,b,40 )
    draw.FilledRect(x, y - 15, x + bW, y) -- blue bar

    local string = "Getterhook lua by muqapaszter0081 (bloat text here aaaaaaaaaa)"
    local w, h = draw.GetTextSize(string)
    draw.Color(255, 255, 255, 255)
    draw.Text(math.floor(x+(bW/2)-(w/2)), math.floor(y-h), string) -- name
    --ColorWaveTextEffect(math.floor(x+(bW/2)-(w/2)), math.floor(y-15), string, {255,255,255,255}, {50,50,50,0}, -1)
    --TextInCenter(x, y - 15, x + bW, y, string)

    local time = os.date("%H:%M")
    w,h = draw.GetTextSize(time)
    draw.Text(x+bW-w-2,y-h,time)


    draw.Color(150,150,150,255)
    draw.Line(x+bW-5,y+bH-1,x+bW-1,y+bH-5) -- resize window
    draw.Line(x+bW-10,y+bH-1,x+bW-1,y+bH-10)
    draw.Line(x+bW-15,y+bH-1,x+bW-1,y+bH-15)
    draw.Text(x+bW, y+bH, "w: ".. menu.w.. " | h: ".. menu.h)
    if IsMouseInBounds(x+bW-15,y+bH-15,x+bW,y+bH) and input.IsButtonDown(MOUSE_LEFT) then 
        menu.w = mX-x+10
        menu.h = mY-y+10
        if menu.w < 405 then 
            menu.w = 405
        end
        if menu.h < 330 then 
            menu.h = 330
        end
    end


    -- button  
    local startY = 0
    for i = 1, #buttons do 
        local b = buttons[i]
        local w, h = draw.GetTextSize(b.name)
        local pos = {x+5, y+startY+5, x+85, y+startY+25}
        local clr = {10, 10, 10, 50}
        
        -- Check if the mouse is inside the button bounds and the left mouse button is pressed
        if IsMouseInBounds(table.unpack(pos)) and input.IsButtonPressed(MOUSE_LEFT) then 
            clr = {40, 40, 40, 50}
            -- Toggle the button state in the menu.buttons table
            menu.buttons[b.table] = true
        else
            menu.buttons[b.table] = false
        end
        
        draw.Color(table.unpack(clr))
        draw.FilledRect(table.unpack(pos))
        draw.Color(45, 45, 45, 255)
        draw.OutlinedRect(table.unpack(pos))
        draw.Color(255, 255, 255, 255)
        TextInCenter(pos[1], pos[2], pos[3], pos[4], b.name)
        startY = startY + 25
    end

    if menu.buttons.antiaim then 
        menu.tabs.tab_1=true
        menu.tabs.tab_2=false
        menu.tabs.tab_3=false
        menu.tabs.tab_4=false
    end
    if menu.buttons.visuals then 
        menu.tabs.tab_1=false
        menu.tabs.tab_2=true
        menu.tabs.tab_3=false
        menu.tabs.tab_4=false
    end
    if menu.buttons.misc then 
        menu.tabs.tab_1=false
        menu.tabs.tab_2=false
        menu.tabs.tab_3=true
        menu.tabs.tab_4=false
    end
    if menu.buttons.cfg then 
        menu.tabs.tab_1=false
        menu.tabs.tab_2=false
        menu.tabs.tab_3=false
        menu.tabs.tab_4=true
    end

    draw.Color(45, 45, 45, 255)
    draw.Line(x+90,y+1, x+90, y+bH-1)
    x = x + 90

    if menu.tabs.tab_1 then
        local x1,y1 = x+5, y+20

        Island(x1,y1,x1+150,y1+130,"Antiaim Spin (real angle only)")
        Toggle(x1+5, y1+5,"Enable", "AA_spin_enable")
        Slider(x1+5,y1+40,x1+145,y1+50, "AA_spin_speed" ,1,10, "Spin speed")
        y1=y1+50
        Toggle(x1+5, y1+5,"Inverted", "AA_spin_inverted")
        y1=y1+25
        Toggle(x1+5, y1+5,"Random Inverted", "AA_spin_rand_invert")
        y1=y1+25
        Toggle(x1+5, y1+5,"Random Speed", "AA_spin_rand_speed")

        y1 = y1+50
        Island(x1,y1,x1+150,y1+55,"Pitch")
        Toggle(x1+5, y1+5,"Random Pitch Up", "pitch_rand_up")
        Toggle(x1+5, y1+30,"Random Pitch Down", "pitch_rand_down")

        y1 = y1+75
        Island(x1,y1,x1+150,y1+80,"Random Fakelag")
        Toggle(x1+5, y1+5,"Enable", "rand_fakelag")
        Slider(x1+5,y1+40,x1+145,y1+50, "rand_fakelag_max" ,1,22, "Max Ticks")
        y1 = y1+65
        Slider(x1+5,y1+0,x1+145,y1+10, "rand_fakelag_min" ,1,22, "Min Ticks")

        x1,y1 = x+160, y+20
        Island(x1,y1,x1+150,y1+175,"Rotate Dynamic")
        Toggle(x1+5, y1+5,"Enable", "rotate_dyn_enable")
        Slider(x1+5,y1+40,x1+145,y1+50, "rotate_dyn_delay" ,0,5000, "Delay")
        y1 = y1+60
        Slider(x1+5,y1+15,x1+145,y1+25, "rotate_dyn_fake1" ,-180,180, "Fake Angle #1")
        y1 = y1+25
        Slider(x1+5,y1+15,x1+145,y1+25, "rotate_dyn_real1" ,-180,180, "Real Angle #1")
        y1 = y1+50
        Slider(x1+5,y1+0,x1+145,y1+10, "rotate_dyn_fake2" ,-180,180, "Fake Angle #2")
        y1 = y1+25
        Slider(x1+5,y1,x1+145,y1+10, "rotate_dyn_real2" ,-180,180, "Real Angle #2")

        y1 = y1+35
        Island(x1,y1,x1+150,y1+55,"Leg Jitter")
        Toggle(x1+5, y1+5,"Enable", "leg_jitter")
        Slider(x1+5,y1+40,x1+145,y1+50, "leg_jitter_value" ,10,60, "Amount")
    end

    if menu.tabs.tab_2 then
        local x1,y1 = x+5, y+20

        Island(x1,y1,x1+150,y1+30,"Crosshair Indicators")
        Toggle(x1+5, y1+5,"Enable", "crosshair_indicators")

        y1 = y1+50
        Island(x1,y1,x1+150,y1+80,"Antiaim Lines")
        Toggle(x1+5, y1+5,"Enable", "AA_lines")
        Toggle(x1+5, y1+30,"Godly HVH Lines", "AA_lines_alt")
        Slider(x1+5,y1+65,x1+145,y1+75, "AA_lines_size" ,1,100, "AA Lines Size")
    end

end

callbacks.Unregister( "Draw", "awftgybhdunjmiko")
callbacks.Register( "Draw", "awftgybhdunjmiko", DrawMenu )

local function NonMenuDraw()
    if input.IsButtonPressed( KEY_END ) or input.IsButtonPressed( KEY_INSERT ) or input.IsButtonPressed( KEY_F11 ) then 
        toggleMenu()
    end
end

callbacks.Register( "Draw", "awbtyngfuimhdj", NonMenuDraw )
