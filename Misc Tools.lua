local menu = {
    x = 500,
    y = 500,

    w = 405,
    h = 365,

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
        cfg = false,

        cfg_load = false,
        cfg_save = false,
    },

    toggles = {
        AA_spin_enable = false,
        AA_spin_inverted = false,
        AA_spin_rand_speed = false,
        AA_spin_rand_invert = false,

        pitch_rand_up = false,
        pitch_rand_down = false,

        rotate_dyn_enable = false,
        rotate_dyn_switch = false,

        rand_fakelag = false,

        leg_jitter = false,

        crosshair_indicators = false,
        crosshair_indicators_dt_bar = false,

        AA_lines = false,
        AA_lines_alt = false,

        info_panel = false,

        dmg_logger = false,
        dmg_logger_custom_pos = false,

        inf_respawn = false,

        spy_warning = false,
        spy_warning_call_out = false,

        fine_shot_m8 = false,

        autostrafe = false,

        smooth_on_spec = false,

        shoot_bombs = false,
        shoot_bombs_silent = false,
        shoot_bombs_silent_preventDMG = false,
        shoot_bombs_esp_enable = false,
        shoot_bombs_esp_name = false,
        shoot_bombs_esp_dist = false,
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

        spy_warning_dist = 230,

        shoot_bombs_dist = 500,

    },

    info_panel = {
        x = 5,
        y = 500,
        rX = 0,
        rY = 0,
    },

    dmg_logger = {
        x = 5,
        y = 500,
        rX = 0,
        rY = 0,
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
    draw.Text(math.floor(x+((x2-x)/2)-(w/2)), math.floor(y-14), name )
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

local function CFGbutton(x,y,x2,y2,name,button)
    local r,g,b = LerpBetweenColors({135, 141, 250}, {196, 147, 165}, 1)
    local clr = {r, g, b}
    if IsMouseInBounds(x,y,x2,y2) and input.IsButtonPressed(MOUSE_LEFT) then 
        clr = {175, 175, 175}
        menu.buttons[button] = true
    else
        menu.buttons[button] = false
    end
    draw.Color( clr[1],clr[2],clr[3],40 )
    draw.FilledRect(x, y, x2, y2)
    draw.Color( clr[1],clr[2],clr[3],125 )
    draw.OutlinedRect(x, y, x2, y2)
    local w,h = draw.GetTextSize(name)
    draw.Color( 255,255,255,255 )
    draw.Text(math.floor(x+((x2-x)/2)-(w/2)), math.floor(y+(h*0.1)),name)
end

local function NotificationBox(x,y,string,alphaProcent)
    local r,g,b = LerpBetweenColors({135, 141, 250}, {196, 147, 165}, 1)
    string = "Notification: ".. string
    local w,h = draw.GetTextSize(string)
    local padding = 5
    draw.Color(r,g,b,f(50*alphaProcent))
    draw.FilledRect(x-padding,y-padding,x+w+padding,y+h+padding)
    draw.Color(r, g, b, f(255*alphaProcent))
    draw.OutlinedRect(x-padding, y-padding, x+w+padding,y+h+padding)
    draw.Color(255,255,255,f(255*alphaProcent))
    draw.Text(x,y,string)
end

local notifications = {} 

local lastToggleTime = 0
local Lbox_Menu_Open = true
local function toggleMenu()
    local currentTime = globals.RealTime()
    if currentTime - lastToggleTime >= 0.1 then
        Lbox_Menu_Open = not Lbox_Menu_Open
        lastToggleTime = currentTime
    end
end

local IsDragging = false
local IsDraggingDMGLOG = false

local buttons = {
    [1] = {name="Anti Aim", table="antiaim"},
    [2] = {name="Visuals", table="visuals"},
    [3] = {name="Misc", table="misc"},
    [4] = {name="Cfg", table="cfg"}
}

local function DrawMenu()
    if not Lbox_Menu_Open then return end
    draw.SetFont( tahoma )

    local x, y = menu.x, menu.y
    local bW, bH = menu.w, menu.h
    local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2]
    
    if IsDragging then
        if input.IsButtonDown(MOUSE_LEFT) then
            menu.x = mX - math.floor(bW * menu.rX)
            menu.y = mY - math.floor(15 * menu.rY)
        else
            IsDragging = false
        end
    else
        if IsMouseInBounds(x, y - 15, x + bW, y) then
            if not input.IsButtonDown(MOUSE_LEFT) then
                menu.rX = ((mX - x) / bW)
                menu.rY = ((mY - y) / 15)
            else
                menu.x = mX - math.floor(bW * menu.rX)
                menu.y = mY - math.floor(15 * menu.rY)
                IsDragging = true
            end
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

    local string = "Misc Tools Lua By Muqa"
    local w, h = draw.GetTextSize(string)
    draw.Color(255, 255, 255, 255)
    --draw.Text(math.floor(x+(bW/2)-(w/2)), math.floor(y-h), string) -- name
    ColorWaveTextEffect(math.floor(x+(bW/2)-(w/2)), math.floor(y-14), string, {135, 141, 250,125}, {224, 173, 199,255}, -1)
    --TextInCenter(x, y - 15, x + bW, y, string)

    draw.Color(255,255,255,200)
    local time = os.date("%H:%M")
    w,h = draw.GetTextSize(time)
    draw.Text(x+bW-w-2,y-h,time)


    draw.Color(150,150,150,255)
    draw.Line(x+bW-5,y+bH-1,x+bW-1,y+bH-5) -- resize window
    draw.Line(x+bW-10,y+bH-1,x+bW-1,y+bH-10)
    draw.Line(x+bW-15,y+bH-1,x+bW-1,y+bH-15)
    -- draw.Text(x+bW, y+bH, "w: ".. menu.w.. " | h: ".. menu.h)
    if IsMouseInBounds(x+bW-15,y+bH-15,x+bW,y+bH) and input.IsButtonDown(MOUSE_LEFT) then 
        menu.w = mX-x+10
        menu.h = mY-y+10
        if menu.w < 405 then 
            menu.w = 405
        end
        if menu.h < 365 then 
            menu.h = 365
        end
    end


    -- button  
    local startY = 0
    for i = 1, #buttons do 
        local button = buttons[i]
        local w, h = draw.GetTextSize(button.name)
        local pos = {x+5, y+startY+5, x+85, y+startY+25}
        local clr = {10, 10, 10, 50}
        
        -- Check if the mouse is inside the button bounds and the left mouse button is pressed
        if IsMouseInBounds(table.unpack(pos)) and input.IsButtonPressed(MOUSE_LEFT) then 
            clr = {40, 40, 40, 50}
            -- Toggle the button state in the menu.buttons table
            menu.buttons[button.table] = true
        else
            menu.buttons[button.table] = false
        end
        
        draw.Color(table.unpack(clr))
        draw.FilledRect(table.unpack(pos))
        draw.Color(r, g, b, 40)--45, 45, 45, 255
        draw.OutlinedRect(table.unpack(pos))
        draw.Color(255, 255, 255, 255)
        TextInCenter(pos[1], pos[2], pos[3], pos[4], button.name)
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

    draw.Color(200, 200, 200, 50)
    draw.Text(x+5, y+bH-35, "Config")
    CFGbutton(x+5, y+bH-20,x+46, y+bH-5,"Load", "cfg_load")
    CFGbutton(x+48, y+bH-20,x+87, y+bH-5,"Save", "cfg_save")
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

        Island(x1,y1,x1+150,y1+55,"Crosshair Indicators")
        Toggle(x1+5, y1+5,"Enable", "crosshair_indicators")
        Toggle(x1+5, y1+30,"Disable Lbox's Dt Bar", "crosshair_indicators_dt_bar")

        y1 = y1+75
        Island(x1,y1,x1+150,y1+80,"Antiaim Lines")
        Toggle(x1+5, y1+5,"Enable", "AA_lines")
        Toggle(x1+5, y1+30,"Godly HVH Lines", "AA_lines_alt")
        Slider(x1+5,y1+65,x1+145,y1+75, "AA_lines_size" ,1,100, "AA Lines Size")

        x1,y1 = x+160, y+20
        Island(x1,y1,x1+150,y1+30,"Info Panel")
        Toggle(x1+5, y1+5,"Enable", "info_panel")

        y1 = y1+50
        Island(x1,y1,x1+150,y1+55,"Damage Logger")
        Toggle(x1+5, y1+5,"Enable", "dmg_logger")
        Toggle(x1+5, y1+30,"Custom Position", "dmg_logger_custom_pos")
    end

    if menu.tabs.tab_3 then
        local x1,y1 = x+5, y+20

        Island(x1,y1,x1+150,y1+30,"Infinite Respawn")
        Toggle(x1+5, y1+5,"Enable", "inf_respawn")

        y1 = y1+50
        Island(x1,y1,x1+150,y1+80,"Spy Warning")
        Toggle(x1+5, y1+5,"Enable", "spy_warning")
        Toggle(x1+5, y1+30,"Call Out", "spy_warning_call_out")
        Slider(x1+5,y1+65,x1+145,y1+75, "spy_warning_dist" ,100,1000, "Distance For Activation")
        y1 = y1+100
        Island(x1,y1,x1+150,y1+190,"Shoot Bombs")
        Toggle(x1+5, y1+5,"Enable", "shoot_bombs")
        Toggle(x1+5, y1+30,"Silent Aim", "shoot_bombs_silent")
        Slider(x1+5,y1+65,x1+145,y1+75, "shoot_bombs_dist" ,350,1000, "Max Dist")
        Toggle(x1+5, y1+80,"Prevent Self Damage", "shoot_bombs_silent_preventDMG")
        y1 = y1+100
        Toggle(x1+5, y1+15,"Bomb ESP Enable", "shoot_bombs_esp_enable")
        Toggle(x1+5, y1+40,"Bomb ESP Name", "shoot_bombs_esp_name")
        Toggle(x1+5, y1+65,"Bomb ESP Dist", "shoot_bombs_esp_dist")

        x1,y1 = x+160, y+20
        Island(x1,y1,x1+150,y1+30,"Fine Shot M8")
        Toggle(x1+5, y1+5,"Enable", "fine_shot_m8")

        y1 = y1+50
        Island(x1,y1,x1+150,y1+30,"Autostrafer only on WASD")
        Toggle(x1+5, y1+5,"Enable", "autostrafe")

        y1 = y1+50
        Island(x1,y1,x1+150,y1+30,"Smooth When Spectated")
        Toggle(x1+5, y1+5,"Enable", "smooth_on_spec")
    end
end
callbacks.Unregister( "Draw", "awftgybhdunjmiko")
callbacks.Register( "Draw", "awftgybhdunjmiko", DrawMenu )



local function CreateCFG(folder_name, table)
    local success, fullPath = filesystem.CreateDirectory(folder_name)
    local filepath = tostring(fullPath .. "/config.txt")
    local file = io.open(filepath, "w")
    
    if file then
        local function serializeTable(tbl, level)
            level = level or 0
            local result = string.rep("    ", level) .. "{\n"
            for key, value in pairs(tbl) do
                result = result .. string.rep("    ", level + 1)
                if type(key) == "string" then
                    result = result .. '["' .. key .. '"] = '
                else
                    result = result .. "[" .. key .. "] = "
                end
                if type(value) == "table" then
                    result = result .. serializeTable(value, level + 1) .. ",\n"
                elseif type(value) == "string" then
                    result = result .. '"' .. value .. '",\n'
                else
                    result = result .. tostring(value) .. ",\n"
                end
            end
            result = result .. string.rep("    ", level) .. "}"
            return result
        end
        
        local serializedConfig = serializeTable(table)
        file:write(serializedConfig)
        file:close()
    end
end

local function LoadCFG(folder_name)
    local success, fullPath = filesystem.CreateDirectory(folder_name)
    local filepath = tostring(fullPath .. "/config.txt")
    local file = io.open(filepath, "r")
    
    if file then
        local content = file:read("*a")
        file:close()
        local chunk, err = load("return " .. content)
        if chunk then
            return chunk()
        else
            print("Error loading configuration:", err)
        end
    end
end

local function TextFade(x, y, text_string, startColor, endColor)
    local startX = 0
    local numChars = #text_string
    if numChars > 1 then
        for i = 1, numChars do
            local t = (i - 1) / (numChars - 1)
            local r = math.floor(startColor[1] + (endColor[1] - startColor[1]) * t)
            local g = math.floor(startColor[2] + (endColor[2] - startColor[2]) * t)
            local b = math.floor(startColor[3] + (endColor[3] - startColor[3]) * t)
            local a = math.floor(startColor[4] + (endColor[4] - startColor[4]) * t)
            draw.Color(r, g, b, a)
            draw.Text(x + startX, y, text_string:sub(i, i))
            local width = draw.GetTextSize(text_string:sub(i, i))
            startX = startX + width
        end
    end
end

local function antiaimCross(localplayer_pos, aa_angle, size)
    local vwA = engine.GetViewAngles()
    if not aa_angle then return end
    local dir = Vector3(math.cos(math.rad(vwA.y + aa_angle)), math.sin(math.rad(vwA.y + aa_angle)), 0)
    local p = client.WorldToScreen(localplayer_pos)
    if p ~= nil then
        local a1 = localplayer_pos + dir * size
        local a2 = localplayer_pos + dir
        local a3 = localplayer_pos + dir * (size * 3)
        local a4 = localplayer_pos + dir * (size * 3)
        local a5 = localplayer_pos + dir * (size * 4.5)
        local a6 = localplayer_pos + dir * (size * 5.5)
        local b1 = client.WorldToScreen(a1)
        if b1 ~= nil then
            local pD = Vector3(-dir.y, dir.x, 0)
            local r = size * 0.75
            local c1 = a2 + pD * r
            local c2 = a2 - pD * r 
            local c3 = a3 + pD * r
            local c4 = a3 - pD * r
            local c5 = a4 + pD * (r * 2.5)
            local c6 = a4 - pD * (r * 2.5)
            local c7 = a5 + pD * (r * 2.5)
            local c8 = a5 - pD * (r * 2.5)
            local c9 = a6 + pD * r
            local c10 = a6 - pD * r
            local c11 = a5 + pD * r
            local c12 = a5 - pD * r
            local d1 = client.WorldToScreen(c1)
            local d2 = client.WorldToScreen(c2)
            local d3 = client.WorldToScreen(c3)
            local d4 = client.WorldToScreen(c4)
            local d5 = client.WorldToScreen(c5)
            local d6 = client.WorldToScreen(c6)
            local d7 = client.WorldToScreen(c7)
            local d8 = client.WorldToScreen(c8)
            local d9 = client.WorldToScreen(c9)
            local d10 = client.WorldToScreen(c10)
            local d11 = client.WorldToScreen(c11)
            local d12 = client.WorldToScreen(c12)
            if d1 and d2 and d3 and d4 and d5 and d6 and d7 and d8 and d9 and d10 and d11 and d12 then
                draw.Line(d1[1], d1[2], d2[1], d2[2])
                draw.Line(d1[1], d1[2], d3[1], d3[2])
                draw.Line(d2[1], d2[2], d4[1], d4[2])
                draw.Line(d4[1], d4[2], d6[1], d6[2])
                draw.Line(d3[1], d3[2], d5[1], d5[2])
                draw.Line(d5[1], d5[2], d7[1], d7[2])
                draw.Line(d6[1], d6[2], d8[1], d8[2])
                draw.Line(d8[1], d8[2],d12[1], d12[2])
                draw.Line(d7[1], d7[2],d11[1], d11[2])
                draw.Line(d9[1], d9[2],d11[1], d11[2])
                draw.Line(d10[1], d10[2],d12[1], d12[2])
                draw.Line(d9[1], d9[2], d10[1], d10[2])
            end
        end
    end
end

local function IsFriend(idx, inParty)
    if idx == client.GetLocalPlayerIndex() then return true end

    local playerInfo = client.GetPlayerInfo(idx)
    if steam.IsFriend(playerInfo.SteamID) then return true end
    if playerlist.GetPriority(playerInfo.UserID) < 0 then return true end

    if inParty then
        local partyMembers = party.GetMembers()
        if partyMembers == true then
            for _, member in ipairs(partyMembers) do
                if member == playerInfo.SteamID then return true end
            end
        end
    end

    return false
end

local function antiaimArrow(localplayer_pos, aa_angle, range)
    local vwA = engine.GetViewAngles()
    if not aa_angle then return end
    local direction = Vector3(math.cos(math.rad(vwA.y + aa_angle)), math.sin(math.rad(vwA.y + aa_angle)), 0)
    local screenPos = client.WorldToScreen(localplayer_pos)
    if screenPos ~= nil then
        local endPoint = localplayer_pos + direction * range
        local endPoint2 = localplayer_pos + direction * (range * 0.85)
        local screenPos1 = client.WorldToScreen(endPoint)
        if screenPos1 ~= nil then
            draw.Line(screenPos[1], screenPos[2], screenPos1[1], screenPos1[2])
            local perpendicularDirection = Vector3(-direction.y, direction.x, 0)
            local perpendicularEndPoint1 = endPoint2 + perpendicularDirection * (range * 0.1) 
            local perpendicularEndPoint2 = endPoint2 - perpendicularDirection * (range * 0.1) 
            local screenPos2 = client.WorldToScreen(perpendicularEndPoint1)
            local screenPos3 = client.WorldToScreen(perpendicularEndPoint2)
            if screenPos2 ~= nil and screenPos3 ~= nil then
                draw.Line(screenPos2[1], screenPos2[2], screenPos3[1], screenPos3[2])
                draw.Line(screenPos1[1], screenPos1[2], screenPos3[1], screenPos3[2])
                draw.Line(screenPos1[1], screenPos1[2], screenPos2[1], screenPos2[2])
            end
        end
    end
end

local function IsVisible(player, localPlayer)
    local me = localPlayer
    local source = me:GetAbsOrigin() + me:GetPropVector( "localdata", "m_vecViewOffset[0]" );
    local destination = player:GetAbsOrigin() + Vector3(0,0,75)
    local trace = engine.TraceLine( source, destination, CONTENTS_SOLID | CONTENTS_GRATE | CONTENTS_MONSTER );
    if (trace.entity ~= nil) then
        if trace.entity == player then 
            return true 
        end
    end
    return false
end

local logs = {}

local delays = {
    random_pitch_down = 0,
    random_pitch_up = 0,
    random_fakelag = 0,
    respawnExtend = 0,
    spy_warning = 0,
    rotate_dynamic_wait = 0,
    fine_shot_m8 = 0,
    rand_invert = 0,
    rand_spin = 0,
}


local sW,sH = draw.GetScreenSize()

local function NonMenuDraw()
    if input.IsButtonPressed( KEY_END ) or input.IsButtonPressed( KEY_INSERT ) or input.IsButtonPressed( KEY_F11 ) then 
        toggleMenu()
    end

    draw.SetFont(tahoma_bold)

    local notif_startY = 0
    local time = 4
    local currentTime = globals.CurTime()
    local seenNotifications = {}
    for i = #notifications, 1, -1 do 
        local notif = notifications[i]
        local logTime = notif.time or currentTime
        local elapsedTime = currentTime - logTime
        if not seenNotifications[notif.text] then
            if elapsedTime >= time then
                table.remove(notifications, i)
            else
                NotificationBox(10, 10 + notif_startY, notif.text, 1 - (elapsedTime / time))
                notif_startY = notif_startY + 30
            end
            seenNotifications[notif.text] = true
        else
            table.remove(notifications, i)
        end
    end
    

    if menu.buttons.cfg_save then 
        CreateCFG([[MiscToolsLua]], menu)
        table.insert(notifications, 1, {time = globals.CurTime(), text = "Saved Config!"})
    end
    

    if menu.buttons.cfg_load then 
        menu = LoadCFG([[MiscToolsLua]])
        table.insert(notifications, 1, {time = globals.CurTime(), text = "Loaded Config!"})
    end

    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then goto continue end
    local r,g,b = LerpBetweenColors({135, 141, 250}, {196, 147, 165}, 1)
    if menu.toggles.pitch_rand_down then
        local wait = math.random(1, 10)
        if (globals.RealTime() > (delays.random_pitch_down + wait / 10)) then
            gui.SetValue( "Anti Aim - Pitch", math.random(2,3))
            delays.random_pitch_down = globals.RealTime()
        end
    end

    if menu.toggles.pitch_rand_up then
        local wait2 = math.random(1, 10)
        if (globals.RealTime() > (delays.random_pitch_up + wait2 / 10)) then
            local random = math.random(1,2)
            local random_pitch = 0
            if random == 1 then 
                random_pitch = 1
            else
                random_pitch = 4
            end
            gui.SetValue( "Anti Aim - Pitch", random_pitch)
            delays.random_pitch_up = globals.RealTime()
        end
    end

    if menu.toggles.rotate_dyn_enable then 
        if (globals.RealTime() > (delays.rotate_dynamic_wait + menu.sliders.rotate_dyn_delay / 1000)) then 
            menu.toggles.rotate_dyn_switch = not menu.toggles.rotate_dyn_switch
            delays.rotate_dynamic_wait = globals.RealTime()
        end

        if menu.toggles.rotate_dyn_switch then 
            gui.SetValue("Anti aim - custom yaw (fake)", menu.sliders.rotate_dyn_fake1)
            gui.SetValue("Anti aim - custom yaw (real)", menu.sliders.rotate_dyn_real1)
        else
            gui.SetValue("Anti aim - custom yaw (fake)", menu.sliders.rotate_dyn_fake2)
            gui.SetValue("Anti aim - custom yaw (real)", menu.sliders.rotate_dyn_real2)
        end
    end

    if menu.toggles.rand_fakelag then 
        local random_ticks = math.random(menu.sliders.rand_fakelag_min, menu.sliders.rand_fakelag_max)
        if globals.RealTime() > (delays.random_fakelag + (gui.GetValue("Fake lag value (ms)") / 1000) ) then
            random_ticks = random_ticks * 15
            gui.SetValue("Fake lag value (ms)", random_ticks)
            delays.random_fakelag = globals.RealTime()
        end
    end

    if menu.toggles.inf_respawn then 
        if not localPlayer:IsAlive() and (globals.RealTime() > (delays.respawnExtend + 2)) then 
            client.Command("extendfreeze", true)                                             
            delays.respawnExtend = globals.RealTime()                                             
        end
    end

    if menu.toggles.fine_shot_m8 then 
        if localPlayer:IsAlive() and (globals.RealTime() > (delays.fine_shot_m8 + 2)) then 
            client.Command( "voicemenu 2 6", true )                                            
            delays.fine_shot_m8 = globals.RealTime()                                             
        end
    end

    if menu.toggles.autostrafe then 
        if not (input.IsButtonDown( KEY_A ) or input.IsButtonDown( KEY_S ) or input.IsButtonDown( KEY_D ) or input.IsButtonDown( KEY_W )) then
            gui.SetValue("Auto strafe", "none")
        else
            gui.SetValue("Auto strafe", "directional")
        end
    end

    if menu.toggles.spy_warning then 
        local players = entities.FindByClass("CTFPlayer") 
        draw.SetFont( tahoma_bold )
        for i, spy in ipairs(players) do
            if spy:GetPropInt("m_iClass") == 8 then 
                local spy_pos = spy:GetAbsOrigin()
                local local_pos = localPlayer:GetAbsOrigin()
                local distance = vector.Distance(spy_pos, local_pos)
                if (distance < menu.sliders.spy_warning_dist) and spy:IsAlive() and spy:GetTeamNumber() ~= localPlayer:GetTeamNumber() and not spy:IsDormant() and IsVisible(spy, localPlayer) then
                    draw.Color(250, 85, 85, 255)
                    local length, height = draw.GetTextSize( "There Is A Spy Nearby!" )
                    draw.Text(math.floor((sW * 0.5) - (length * 0.5)), math.floor(sH * 0.6), "There Is A Spy Nearby!")
                    if menu.toggles.spy_warning_call_out and (globals.RealTime() > (delays.spy_warning + 2.5)) then 
                        client.Command( "voicemenu 1 1", 1 )
                        delays.spy_warning = globals.RealTime()
                    end
                end
            end
        end
        draw.SetFont( tahoma )
    end

    if menu.toggles.crosshair_indicators then 
        draw.SetFont( tahoma_bold )
        local startW, startH = math.floor(sW / 2), math.floor(sH * 0.52)
        local r1, g1, b1 = LerpBetweenColors({50,50,50}, {255,255,255}, 3)
        local r2, g2, b2 = LerpBetweenColors({255,255,255}, {50,50,50}, 1)
        local startColor = {r1,g1,b1,255}
        local endColor = {r2,g2,b2,255}
        local cheatName = "lmaobox"
        local cW,cH  = draw.GetTextSize(cheatName)
        TextFade(startW - math.floor(cW / 2), startH, cheatName, startColor, endColor)
        if warp.GetChargedTicks() ~= 0 and (gui.GetValue("double tap") ~= "none" or gui.GetValue("dash move key") ~= 0) then
            local LocalWeapon = entities.GetLocalPlayer():GetPropEntity( "m_hActiveWeapon" )
            if (warp.CanDoubleTap(LocalWeapon)) and ((entities.GetLocalPlayer():GetPropInt( "m_fFlags" )) & FL_ONGROUND) == 1 then 
            else
                startColor = {25,25,25,255}
                endColor = {25,25,25,255}
            end
            local curTicks = warp.GetChargedTicks()
            local maxTicks = 23
            local percentageTicks = math.floor(curTicks / maxTicks * 100)
            local Size = math.floor(cW * (curTicks / maxTicks))
            local pos = {startW - math.floor(cW / 2), startH + cH, startW - math.floor(cW / 2) + Size, startH + cH + 3}
            draw.Color(table.unpack(startColor))
            draw.FilledRectFade(pos[1], pos[2], pos[3], pos[4], 255, 0, true)
            draw.Color(table.unpack(endColor))
            draw.FilledRectFade(pos[1], pos[2], pos[3], pos[4], 0, 255, true)
            draw.Color(0,0,0,255)
            draw.OutlinedRect(startW - math.floor(cW / 2) - 1, startH + cH - 1, startW - math.floor(cW / 2) + Size + 1, startH + cH + 3 + 1)
        end
        draw.SetFont( tahoma )
        local statuses = {}
        local wpn = localPlayer:GetPropEntity("m_hActiveWeapon")
            if wpn and localPlayer:IsAlive() then
                local critChance = wpn:GetCritChance()
                local dmgStats = wpn:GetWeaponDamageStats()
                local totalDmg = dmgStats["total"]
                local criticalDmg = dmgStats["critical"]
                local cmpCritChance = critChance + 0.1
                if cmpCritChance > wpn:CalcObservedCritChance() then
                else
                    local requiredTotalDamage = (criticalDmg * (2.0 * cmpCritChance + 1.0)) / cmpCritChance / 3.0
                    local requiredDamage = requiredTotalDamage - totalDmg
                    table.insert(statuses, {"crit ban: ".. math.floor(requiredDamage), {232, 183, 49, 255}})
                end
            end
        local startY = cH + 5
        for _, v in ipairs(statuses) do 
            local w, h = draw.GetTextSize(v[1])
            draw.Color(table.unpack(v[2]))
            draw.Text(math.floor(startW - (w/2)), startH + startY, v[1] )
            startY = startY + h
        end
        if menu.toggles.crosshair_indicators_dt_bar then 
            gui.SetValue("double tap indicator size", 0)
        end
    end

    if menu.toggles.info_panel then 

        local info = {}

        local x, y = menu.info_panel.x, menu.info_panel.y
        local bW, bH = 150, 25 -- box width , box height

        local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2] -- mouse position

        if Lbox_Menu_Open and mX >= x and mX <= x + bW and mY >= y and mY <= y + bH then

            if not input.IsButtonDown(MOUSE_LEFT) then
                menu.info_panel.rX = ((mX - x) / bW)
                menu.info_panel.rY = ((mY - y) / bH)
            else
                menu.info_panel.x = mX - f(bW * menu.info_panel.rX)
                menu.info_panel.y = mY - f(bH * menu.info_panel.rY)
            end
        end
    

        draw.Color(40, 40, 40, 255)
        --draw.FilledRect(x, y, x + bW, y + bH)
        draw.FilledRectFade(x, y, x + bW, y + bH, 255, 0, false)
        
        --draw.Color(140, 147, 255, 255)
        draw.Color(r, g, b, 255)
        draw.Line(x, y, x + bW, y)
        --draw.OutlinedRect(x, y, x + bW, y + bH)

        draw.FilledRectFade(x, y, x+1, y + bH, 255, 0, false)
        draw.FilledRectFade(x+bW-1, y, x+bW, y + bH, 255, 0, false)

        --draw.FilledRectFade(x, y, x + bW, f(y + bH/2), 0, 125, false)
        --draw.FilledRectFade(x, f(y + bH/2), x + bW, y + bH, 125, 0, false)

        -- draw.Color(29, 189, 165, 255)
        -- draw.OutlinedRect(x, y, x + bW, y + bH)

        draw.SetFont( tahoma_bold )
        local name = "Info Panel"
        local tW, tH = draw.GetTextSize(name) -- text width, text height
        -- draw.Text(f(x+(bW/2)-(tW/2)), f(y+(bH/2)-(tH/2)), name)
        -- local r1, g1, b1 = RGBRainbow(1)
        -- local r2, g2, b2 = RGBRainbow(1.5)
    
        -- local startColor = {r1, g1, b1,255} 
        -- local endColor = {r2, g2, b2,255}  
        local r1,g1,b1 = LerpBetweenColors({196, 147, 165}, {255,255,255}, 1)
        local startColor = {r1, g1, b1,255} 
        local r2,g2,b2 = LerpBetweenColors({135, 141, 250}, {255,255,255}, -1.5)
        local endColor = {r2, g2, b2,255} 
        
        TextFade(f(x+(bW/2)-(tW/2)), f(y+(bH/2)-(tH/2)), name, startColor, endColor)
        draw.SetFont( tahoma )

        --[[ statuses start ]]--
        if gui.GetValue("fake lag") ~= 0 then 
            table.insert(info, {"Fake Lag: ".. f((gui.GetValue("fake lag value (ms)") + 15) / 15).. " ticks", {35, 237, 255, 255}})
        end

        local function GetOffset()
            local real = gui.GetValue("anti aim - custom yaw (real)")
            local fake = gui.GetValue("anti aim - custom yaw (fake)")
            -- Calculate the absolute difference between real and fake values
            local offset = math.abs(real - fake)
            -- Check if the smaller desync value is greater than 180
            if offset > 180 then
                -- Return the smaller of the two possible desync values
                return 360 - offset
            else
                -- Return the calculated desync value
                return offset
            end
        end

        if gui.GetValue( "Anti Aim" ) ~= 0  then
            table.insert(info, {"Anti Aim", {255, 126, 126, 255}})
        end
        
        if gui.GetValue( "Anti Aim" ) ~= 0 and gui.GetValue( "anti aim - yaw (real)" ) == "custom" and gui.GetValue( "anti aim - yaw (fake)" ) == "custom" then
            table.insert(info, {"Yaw Offset: ".. GetOffset().. "degrees", {255, 184, 184, 255}})
        end

        if gui.GetValue( "Aim bot" ) ~= 0 then -- aimbot
            local aimbot_key = gui.GetValue( "Aim key" )
            local aimbot_mode = gui.GetValue( "Aim key mode" )
            if (input.IsButtonDown( aimbot_key )) and (aimbot_mode == "hold-to-use") then 
                table.insert(info, {"Aimbot: Held", {255, 204, 0, 255}} )
            elseif aimbot_key == 0 then 
                table.insert(info, {"Aimbot: Always On", {255, 204, 0, 255}} )
            elseif (aimbot_mode == "press-to-toggle") then
                table.insert(info, {"Aimbot: Toggled", {255, 204, 0, 255}} )
            end
        end

        if warp.GetChargedTicks() ~= 0 and (gui.GetValue("double tap") ~= "none" or gui.GetValue("dash move key") ~= 0) then -- doubletap
            local LocalWeapon = entities.GetLocalPlayer():GetPropEntity( "m_hActiveWeapon" )
            if (warp.CanDoubleTap(LocalWeapon)) and ((entities.GetLocalPlayer():GetPropInt( "m_fFlags" )) & FL_ONGROUND) == 1 then 
                table.insert(info, {"Doubletap: ".. warp.GetChargedTicks().. "/23", {255, 0, 179, 255}})
            else
                table.insert(info, {"Doubletap: ".. warp.GetChargedTicks().. "/23", {56, 0, 40, 255}})
            end
        end

        if gui.GetValue( "Fake Latency" ) == 1 then -- fake latency
            table.insert(info, {"Fake latency: ".. (gui.GetValue( "Fake latency value (ms)" ) / 1000).. " seconds", {153, 255, 0, 255}})
        end

        if gui.GetValue( "Thirdperson" ) ~= 0 then -- thirdperson
            if gui.GetValue( "thirdperson key" ) ~= 0 then
                table.insert(info, {"Thirdperson: Toggled", {175, 175, 175, 255}})
            else 
                table.insert(info, {"Thirdperson: On", {175, 175, 175, 255}})
            end
        end
        --[[ statuses end ]]--

        local startY = 0
        for _, v in ipairs(info) do 
            local w, h = draw.GetTextSize(v[1])

            -- draw.Color(99, 110, 255, 255)
            -- draw.OutlinedRect(x - 1, y + bH + startY, x + bW + 1, y + bH + startY + 15 + 1)

            -- draw.Color(46, 46, 46,255)
            -- draw.FilledRect(x, y + bH + startY, x + bW, y + bH + startY + 15)


            --draw.Color( table.unpack(v[2]) )
            --draw.Text(x + 1, y + bH + 1 + startY, v[1])
            local startColor = v[2]
            local endColor = {f(v[2][1] * 0.4), f(v[2][2] * 0.4), f(v[2][3] * 0.4), 255}
            -- local endColor = {f(255 - v[2][1]), f(255 - v[2][2]), f(255 - v[2][3]), 255}
            draw.Color(table.unpack(v[2]))
            draw.Text(x + 1, y + bH + 1 + startY, v[1])
            startY = startY + h
        end
    end

    if menu.toggles.AA_lines then 

        local yaws_real = {
            ["left"] = 90,
            ["right"] = -90,
            ["back"] = 180, 
            ["forward"] = 0,
            ["custom"] = gui.GetValue("Anti Aim - Custom Yaw (Real)")
        }

        local yaws_fake = {
            ["left"] = 90,
            ["right"] = -90,
            ["back"] = 180, 
            ["forward"] = 0,
            ["custom"] = gui.GetValue("Anti Aim - Custom Yaw (Fake)")
        }

        local center = localPlayer:GetAbsOrigin()
        local range = 100
        local ang = engine.GetViewAngles()
        local size = menu.sliders.AA_lines_size
        if not menu.toggles.AA_lines_alt then 
            draw.Color(255, 0, 0, 255)
            antiaimArrow(localPlayer:GetAbsOrigin(), yaws_fake[gui.GetValue("Anti aim - yaw (fake)")], size)
            draw.Color(0, 255, 0, 255)
            antiaimArrow(localPlayer:GetAbsOrigin(), yaws_real[gui.GetValue("Anti aim - yaw (real)")], size)
        else
            draw.Color(255, 0, 0, 255)
            antiaimCross(localPlayer:GetAbsOrigin(), yaws_fake[gui.GetValue("Anti aim - yaw (fake)")], size)
            draw.Color(0, 255, 0, 255)
            antiaimCross(localPlayer:GetAbsOrigin(), yaws_real[gui.GetValue("Anti aim - yaw (real)")], size)
        end
    end

    if menu.toggles.dmg_logger then 
        local startY = 0
        local currentTime = globals.RealTime()
        local startW, startH
        local x, y = menu.dmg_logger.x, menu.dmg_logger.y
        local bW, bH = 100, 20
        local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2] -- mouse position
        if not menu.toggles.dmg_logger_custom_pos then
            startW, startH = math.floor(sW / 2), math.floor(sH * 0.6)
        else
            if Lbox_Menu_Open then
                if IsDraggingDMGLOG then
                    if input.IsButtonDown(MOUSE_LEFT) then
                        menu.dmg_logger.x = mX - math.floor(bW * menu.dmg_logger.rX)
                        menu.dmg_logger.y = mY - math.floor(bH * menu.dmg_logger.rY)
                    else
                        IsDraggingDMGLOG = false
                    end
                else
                    if IsMouseInBounds(x, y, x + bW, y + bH) then
                        if not input.IsButtonDown(MOUSE_LEFT) then
                            menu.dmg_logger.rX = ((mX - x) / bW)
                            menu.dmg_logger.rY = ((mY - y) / bH)
                        else
                            menu.dmg_logger.x = mX - math.floor(bW * menu.dmg_logger.rX)
                            menu.dmg_logger.y = mY - math.floor(bH * menu.dmg_logger.rY)
                            IsDraggingDMGLOG = true
                        end
                    end
                end
                draw.Color(r, g, b, 50)
                draw.FilledRect(x, y, x + bW, y + bH)
                draw.Color(r, g, b, 255)
                draw.OutlinedRect(x, y, x + bW, y + bH)
                local string = "DMG Log Position"
                local w, h = draw.GetTextSize(string)
                draw.Color(255, 255, 255, 255)
                draw.Text(math.floor(x+(bW/2)-(w/2)), math.floor(y+(bH/2)-(h/2)), string)
            end
            startW, startH = x + math.floor(bW/2), y + bH
        end
        local time = 4
        for i = #logs, 1, -1 do 
            local l = logs[i]
            local logTime = l.time or currentTime
            local elapsedTime = currentTime - logTime
            if elapsedTime >= time then
                table.remove(logs, i)
            else
                local alpha = math.max(255 - math.floor(elapsedTime * (255 / time)), 0)
                local r1, g1, b1 = LerpBetweenColors({255, 93, 93}, {255,255,255}, l.r1)
                local r2, g2, b2 = LerpBetweenColors({255,255,255}, {255, 93, 93}, l.r2)
                local startColor = {r1,g1,b1,alpha}
                local endColor = {r2,g2,b2,alpha}
                -- draw.Color(255, 255, 255, alpha)
                -- local text = tostring(l.player .. " damage: " .. l.dmg .. " health: " .. l.health)
                local text = tostring("hit ".. l.player.. " for ".. l.dmg.. " dmg")
                local width, height = draw.GetTextSize(text)
                -- draw.Text(500, 500 + startY, text)
                TextFade(startW - math.floor(width / 2), startH + startY, text, startColor, endColor)
                startY = startY + height
            end
        end
    end

    if menu.toggles.shoot_bombs_esp_enable then 
        draw.SetFont( tahoma )
        local bombs = entities.FindByClass( "CTFGenericBomb" )
        if #bombs == 0 then 
            bombs = entities.FindByClass( "CTFPumpkinBomb" )
        end
        for i, b in pairs(bombs) do
            if not b:IsDormant() then
                local pos = b:GetAbsOrigin()
                pos = client.WorldToScreen( pos )
                if pos then 
                    draw.Color(255,255,255,255)
                    local offset = 0
                    if menu.toggles.shoot_bombs_esp_name then
                        local string = "bomb"
                        local w, h = draw.GetTextSize(string)
                        draw.Text(pos[1]-f(w/2), pos[2]-f(h/2), string)
                        offset = offset + h
                    end
                    if menu.toggles.shoot_bombs_esp_dist then 
                        local dist = f(vector.Distance( localPlayer:GetAbsOrigin(), b:GetAbsOrigin()))
                        local string = string.format("[%s Hu]", dist)
                        local w, h = draw.GetTextSize(string)
                        draw.Text(pos[1]-f(w/2), pos[2]-f(h/2)+offset, string)
                    end
                end
            end
        end
    end
    ::continue::
end
callbacks.Register( "Draw", "awbtyngfuimhdj", NonMenuDraw )

local function dmgLogger(event)

    if (event:GetName() == 'player_hurt' ) and menu.toggles.dmg_logger then
  
        local localPlayer = entities.GetLocalPlayer();
        local victim = entities.GetByUserID(event:GetInt("userid"))
        local health = event:GetInt("health")
        local attacker = entities.GetByUserID(event:GetInt("attacker"))
        local damage = event:GetInt("damageamount")
  
        if (attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex()) then
            return
        end
  
        table.insert(logs, {player = victim:GetName(), dmg = damage, health = health, time = globals.RealTime(), r1 = math.random(1,5), r2 = math.random(1,5)})
        -- client.ChatPrintf( "\x078c75ff [spaghetti.vip]" .. "\x01 Hit " ..  "\x07d6b618" .. victim:GetName() .. " \x01for " .. "\x07d6b618" .. damage .. "\x01 HP. " .. "HP left " .. "\x07d6b618" .. health .. "\x01 HP")
    end
end

callbacks.Unregister("FireGameEvent", "asdawdaw")
callbacks.Register( "FireGameEvent", "asdawdaw", dmgLogger )

local function PositionAngles(source, dest)
    local function isNaN(x) return x ~= x end
    local M_RADPI = 180 / math.pi
    local delta = source - dest
    local pitch = math.atan(delta.z / delta:Length2D()) * M_RADPI
    local yaw = math.atan(delta.y / delta.x) * M_RADPI
    if delta.x >= 0 then
        yaw = yaw + 180
    end
    if isNaN(pitch) then pitch = 0 end
    if isNaN(yaw) then yaw = 0 end
    return EulerAngles(pitch, yaw, 0)
end

local function IsVisible(localPlayer, entity)
    local source = localPlayer:GetAbsOrigin() + localPlayer:GetPropVector( "localdata", "m_vecViewOffset[0]" );
    local destination = entity:GetAbsOrigin() + Vector3(0,0,15)
    local trace = engine.TraceLine( source, destination, CONTENTS_SOLID | CONTENTS_GRATE | CONTENTS_MONSTER );
    if (trace.entity ~= nil) then
        if trace.entity == entity then 
            return true 
        end
    end
    return false
end

local AimModeBefore1 = nil
local AimModeBefore2 = nil
local AimModeTick = 0

local function CreateMove(cmd)
    local lPlayer = entities.GetLocalPlayer()
    if menu.toggles.AA_spin_enable then 
        local add = menu.sliders.AA_spin_speed
        local function a(x)
            if x >= 180 then
                x = -180
            elseif x <= -180 then
                x = 180
            end
            return x
        end
        if menu.toggles.AA_spin_rand_speed and globals.RealTime() > delays.rand_spin + 0.2 then 
            menu.sliders.AA_spin_speed = math.random(1, 10)
            delays.rand_spin = globals.RealTime()
        end
        if menu.toggles.AA_spin_rand_invert and globals.RealTime() > delays.rand_invert + 0.2 then 
            menu.toggles.AA_spin_inverted = (math.random(0,1)==1)
            delays.rand_invert = globals.RealTime()
        end
        if menu.toggles.AA_spin_inverted then
            add = -add
        end
        gui.SetValue( "Anti Aim - Custom Yaw (real)", a(gui.GetValue( "Anti Aim - Custom Yaw (real)" ) + add))
    end

    if menu.toggles.smooth_on_spec then 
        gui.SetValue("disable aimbot when spectated", 0)
        local players = entities.FindByClass("CTFPlayer")
        local foundPlayer = false -- Flag to keep track of whether a player meets the conditions
        for i, p in pairs(players) do
            if (p:IsAlive() == false) and (p:IsDormant() == false) and not (IsFriend(p:GetIndex(), true)) then
                if p:GetPropEntity("m_hObserverTarget"):GetName() == steam.GetPlayerName(steam.GetSteamID()) then
                    if p:GetPropInt("m_iObserverMode") == 4 then 
                        foundPlayer = true -- Set the flag to true if a player meets the conditions
                        break -- No need to continue searching, we found a player
                    end
                end
            end
        end
        if foundPlayer then
            if not AimModeBefore1 and not AimModeBefore2 then
                AimModeBefore1 = gui.GetValue("aim method")
                AimModeBefore2 = gui.GetValue("aim method (projectile)")
            end
            gui.SetValue("aim method", "smooth")
            gui.SetValue("aim method (projectile)", "smooth")
            AimModeTick = globals.TickCount()
        else
            if AimModeBefore1 ~= nil and AimModeBefore2 ~= nil then
                gui.SetValue("aim method", tostring(AimModeBefore1))
                gui.SetValue("aim method (projectile)", tostring(AimModeBefore2))
                if AimModeTick < globals.TickCount()+2 then
                    AimModeBefore1 = nil
                    AimModeBefore2 = nil
                end
            end
        end
    end    

    if menu.toggles.leg_jitter and entities.GetLocalPlayer():EstimateAbsVelocity():Length() < menu.sliders.leg_jitter_value+1 then
        local value = menu.sliders.leg_jitter_value
        if (cmd.sidemove == 0) then
            if cmd.command_number % 2 == 0 then
                cmd:SetSideMove(value / 10)
            else
                cmd:SetSideMove(-value / 10)
            end
        elseif (cmd.forwardmove == 0) then
            if cmd.command_number % 2 == 0 then
                cmd:SetForwardMove(value / 10)
            else
                cmd:SetForwardMove(-value / 10)
            end
        end
    end

    if menu.toggles.shoot_bombs then 
        local bombs = entities.FindByClass( "CTFGenericBomb" )
        local isPumpkin = false
        if #bombs == 0 then 
            bombs = entities.FindByClass( "CTFPumpkinBomb" )
            isPumpkin = true
        end
        local safe_dist
        if isPumpkin then 
            safe_dist = 350
        else
            safe_dist = 300
        end
        for i, b in pairs(bombs) do
            if not b:IsDormant() and IsVisible(lPlayer, b) and (vector.Distance(lPlayer:GetAbsOrigin(), b:GetAbsOrigin()) < menu.sliders.shoot_bombs_dist) and (not menu.toggles.shoot_bombs_silent_preventDMG or (vector.Distance(lPlayer:GetAbsOrigin(), b:GetAbsOrigin()) > safe_dist)) and lPlayer:GetPropEntity( "m_hActiveWeapon" ) ~= lPlayer:GetEntityForLoadoutSlot( 2 ) then
                if menu.toggles.shoot_bombs_silent then
                    cmd:SetViewAngles( PositionAngles(lPlayer:GetAbsOrigin() + lPlayer:GetPropVector( "localdata", "m_vecViewOffset[0]" ), b:GetAbsOrigin()+Vector3(0,0,15)):Unpack())
                else
                    engine.SetViewAngles(PositionAngles(lPlayer:GetAbsOrigin() + lPlayer:GetPropVector( "localdata", "m_vecViewOffset[0]" ), b:GetAbsOrigin()+Vector3(0,0,15)))
                end
                cmd:SetButtons( cmd.buttons | IN_ATTACK )
            end
        end
    end
end
callbacks.Register( "CreateMove", "awfgtghydui", CreateMove )

local t = globals.TickCount()
client.Command("clear", true)
local function OnLoad()
    local lines = {"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠴⠤⠤⠴⠄⡄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⣠⠄⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠁⠃⠆⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⢀⡜⠁⠀⠀⠀⢠⡄⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠑⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⢈⠁⠀⠀⠠⣿⠿⡟⣀⡹⠆⡿⣃⣰⣆⣤⣀⠀⠀⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⣼⠀⠀⢀⣀⣀⣀⣀⡈⠁⠙⠁⠘⠃⠡⠽⡵⢚⠱⠂⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⢐⣢⣤⣵⡄⢀⠀⢀⢈⣉⠉⠉⠒⠤⠀⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⠉⠉⠁⠁⠈⠀⠸⢖⣿⣿⣷⠀⠀⢰⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⠃⠀⡄⠀⠈⠉⠀⠀⠀⢴⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⢈⣇⠀⠀⠀⠀⠀⠀⠀⢰⠉⠀⠀⠱⠀⠀⠀⠀⠀⢠⡄⠀⠀⠀⠀⠀⣀⠔⠒⢒⡩⠃⠀⠀⠀loaded godmode lua⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⣴⣿⣤⢀⠀⠀⠀⠀⠀⠈⠓⠒⠢⠔⠀⠀⠀⠀⠀⣶⠤⠄⠒⠒⠉⠁⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⡄⠤⠒⠈⠈⣿⣿⣽⣦⠀⢀⢀⠰⢰⣀⣲⣿⡐⣤⠀⠀⢠⡾⠃⠀⠀⠀⠀⠀⠀⠀⣀⡄⣠⣵⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠘⠏⢿⣿⡁⢐⠶⠈⣰⣿⣿⣿⣿⣷⢈⣣⢰⡞⠀⠀⠀⠀⠀⠀⢀⡴⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠈⢿⣿⣍⠀⠀⠸⣿⣿⣿⣿⠃⢈⣿⡎⠁⠀⠀⠀⠀⣠⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠈⢙⣿⣆⠀⠀⠈⠛⠛⢋⢰⡼⠁⠁⠀⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⣷⣧⣷⣤⡶⠎⠛⠁⠀⠀⠀⢀⡤⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠈⠁⠀⠀⠀⠀⠀⠠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀","⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"}
    local clr1 = {115, 119, 255}
    local clr2 = {224, 173, 199}
    if t < globals.TickCount() + 1 then
        for i = 1, #lines do
            local t = i / #lines
            local clr = {
                math.floor(clr1[1] + (clr2[1] - clr1[1]) * t),
                math.floor(clr1[2] + (clr2[2] - clr1[2]) * t),
                math.floor(clr1[3] + (clr2[3] - clr1[3]) * t)
            }
            printc(clr[1], clr[2], clr[3], 255, lines[i])
        end
        callbacks.Unregister( "CreateMove", "awjkudl9i0" )
    end
end
callbacks.Unregister( "CreateMove", "awjkudl9i0" )
callbacks.Register( "CreateMove", "awjkudl9i0", OnLoad )

table.insert(notifications, 1, {time = globals.CurTime(), text = "Loaded Lua!"})
