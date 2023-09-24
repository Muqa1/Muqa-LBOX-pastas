local config = {

    tabs = {
        antiaim = true,
        visuals = false,
        misc = false,
        cfg = false,
    },

    antiaim = {

        random_pitch_down = false,
        random_pitch_up = false,

        custom_spin = false,
        custom_spin_invert = false,
        custom_spin_speed = 5,
        custom_spin_rand_speed = true,
        custom_spin_rand_invert = true,

        rotate_dynamic = false,
        rotate_dynamic_fake1 = 90,
        rotate_dynamic_fake2 = -90,
        rotate_dynamic_real1 = -90,
        rotate_dynamic_real2 = 90,
        rotate_dynamic_delay = 500,
        rotate_dynamic_switch = false,

        random_fakelag = false,
        fakelag_max = 22,
        fakelag_min = 15,

        leg_jitter = false,
        leg_jitter_amount = 20,

    },

    misc = {

        inf_respawn = false,

        spy_warning = false,
        spy_warning_yell = false,
        spy_warning_distance = 230,

        fine_shot_m8 = false,

        autostrafer = false,

    },

    visuals = {
        info = false,
        info_pos = {
            info_x = 600,
            info_y = 500,
            ratioX = 0,
            ratioY = 0,
        },

        crosshair_indicators = false,
        crosshair_indicators_info = {
            cheatName = "lmaobox",
        },

        aa_lines = false,
        aa_info = {
            boring_lines = false,
            size = 20
        },

        damage_logger = false,
        damage_logger_info = {
            damage_logger_movable = false,
            damage_logger_x = 700,
            damage_logger_y = 500,
            ratioX = 0,
            ratioY = 0,
        },
        

    }

}

local sW, sH = draw.GetScreenSize()
local tahoma_bold = draw.CreateFont( "tahoma", 12, 800, FONTFLAG_OUTLINE )
local tahoma = draw.CreateFont( "tahoma", 12, 400, FONTFLAG_OUTLINE )

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


local menuLoaded, ImMenu = pcall(require, "ImMenu")
assert(menuLoaded, "ImMenu not found, please install it!")
assert(ImMenu.GetVersion() >= 0.66, "ImMenu version is too old, please update it!")

local lastToggleTime = 0
local Lbox_Menu_Open = true
local function toggleMenu()
    local currentTime = globals.RealTime()
    if currentTime - lastToggleTime >= 0.1 then
        if Lbox_Menu_Open == false then
            Lbox_Menu_Open = true
        elseif Lbox_Menu_Open == true then
            Lbox_Menu_Open = false
        end
        lastToggleTime = currentTime
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

local function RGBRainbow(frequency) -- rainbow 
    local curtime = globals.CurTime() 
    local r,g,b
    r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
    g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
    b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)
    return r, g, b
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

local function MiscDraw()
    draw.SetFont( tahoma_bold )
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then goto continue end
    if config.antiaim.random_pitch_down then
        local wait = math.random(1, 10)
        if (globals.RealTime() > (delays.random_pitch_down + wait / 10)) then
            gui.SetValue( "Anti Aim - Pitch", math.random(2,3))
            delays.random_pitch_down = globals.RealTime()
        end
    end

    if config.antiaim.random_pitch_up then
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

    if config.antiaim.rotate_dynamic then 
        if (globals.RealTime() > (delays.rotate_dynamic_wait + config.antiaim.rotate_dynamic_delay / 1000)) then 
            if config.antiaim.rotate_dynamic_switch == false then 
                config.antiaim.rotate_dynamic_switch = true 
            else
                config.antiaim.rotate_dynamic_switch = false
            end
            delays.rotate_dynamic_wait = globals.RealTime()
        end

        if config.antiaim.rotate_dynamic_switch then 
            gui.SetValue("Anti aim - custom yaw (fake)", config.antiaim.rotate_dynamic_fake1)
            gui.SetValue("Anti aim - custom yaw (real)", config.antiaim.rotate_dynamic_real1)
        else
            gui.SetValue("Anti aim - custom yaw (fake)", config.antiaim.rotate_dynamic_fake2)
            gui.SetValue("Anti aim - custom yaw (real)", config.antiaim.rotate_dynamic_real2)
        end
    end

    if config.antiaim.random_fakelag then 
        local random_ticks = math.random(config.antiaim.fakelag_min, config.antiaim.fakelag_max)
        if globals.RealTime() > (delays.random_fakelag + (gui.GetValue("Fake lag value (ms)") / 1000) ) then
            random_ticks = random_ticks * 15
            gui.SetValue("Fake lag value (ms)", random_ticks)
            delays.random_fakelag = globals.RealTime()
        end
    end

    if config.misc.inf_respawn then 
        if not localPlayer:IsAlive() and (globals.RealTime() > (delays.respawnExtend + 2)) then 
            client.Command("extendfreeze", true)                                             
            delays.respawnExtend = globals.RealTime()                                             
        end
    end

    if config.misc.fine_shot_m8 then 
        if localPlayer:IsAlive() and (globals.RealTime() > (delays.fine_shot_m8 + 2)) then 
            client.Command( "voicemenu 2 6", true )                                            
            delays.fine_shot_m8 = globals.RealTime()                                             
        end
    end

    if config.misc.autostrafer then 
        if not (input.IsButtonDown( KEY_A ) or input.IsButtonDown( KEY_S ) or input.IsButtonDown( KEY_D ) or input.IsButtonDown( KEY_W )) then
            gui.SetValue("Auto strafe", "none")
        else
            gui.SetValue("Auto strafe", "directional")
        end
    end

    if config.misc.spy_warning then 
        local players = entities.FindByClass("CTFPlayer") 
        for i, spy in ipairs(players) do
            if spy:GetPropInt("m_iClass") == 8 then 
                local spy_pos = spy:GetAbsOrigin()
                local local_pos = localPlayer:GetAbsOrigin()
                local distance = vector.Distance(spy_pos, local_pos)
                if (distance < config.misc.spy_warning_distance) and spy:IsAlive() and spy:GetTeamNumber() ~= localPlayer:GetTeamNumber() and not spy:IsDormant() and IsVisible(spy, localPlayer) then
                    draw.Color(250, 85, 85, 255)
                    local length, height = draw.GetTextSize( "There Is A Spy Nearby!" )
                    draw.Text(math.floor((sW * 0.5) - (length * 0.5)), math.floor(sH * 0.6), "There Is A Spy Nearby!")
                    if config.misc.spy_warning_yell and (globals.RealTime() > (delays.spy_warning + 2.5)) then 
                        client.Command( "voicemenu 1 1", 1 )
                        delays.spy_warning = globals.RealTime()
                    end
                end
            end
        end
    end

    if config.visuals.info then 

        local info = {}

        local flr = math.floor

        local x, y = config.visuals.info_pos.info_x, config.visuals.info_pos.info_y
        local bW, bH = 150, 25 -- box width , box height

        local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2] -- mouse position

        if Lbox_Menu_Open and mX >= x and mX <= x + bW and mY >= y and mY <= y + bH then

            if not input.IsButtonDown(MOUSE_LEFT) then

                config.visuals.info_pos.ratioX = ((mX - x) / bW)
                config.visuals.info_pos.ratioY = ((mY - y) / bH)

            else
    
                config.visuals.info_pos.info_x = mX - flr(bW * config.visuals.info_pos.ratioX)
                config.visuals.info_pos.info_y = mY - flr(bH * config.visuals.info_pos.ratioY)

            end
        end
    

        draw.Color(40, 40, 40, 255)
        --draw.FilledRect(x, y, x + bW, y + bH)
        draw.FilledRectFade(x, y, x + bW, y + bH, 255, 0, false)
        
        draw.Color(140, 147, 255, 255)
        draw.Line(x, y, x + bW, y)
        --draw.OutlinedRect(x, y, x + bW, y + bH)

        draw.FilledRectFade(x, y, x+1, y + bH, 255, 0, false)
        draw.FilledRectFade(x+bW-1, y, x+bW, y + bH, 255, 0, false)

        --draw.FilledRectFade(x, y, x + bW, flr(y + bH/2), 0, 125, false)
        --draw.FilledRectFade(x, flr(y + bH/2), x + bW, y + bH, 125, 0, false)

        -- draw.Color(29, 189, 165, 255)
        -- draw.OutlinedRect(x, y, x + bW, y + bH)

        draw.Color(225, 225, 225, 255)
        local name = "Info Panel"
        local tW, tH = draw.GetTextSize(name) -- text width, text height
        -- draw.Text(flr(x+(bW/2)-(tW/2)), flr(y+(bH/2)-(tH/2)), name)
        -- local r1, g1, b1 = RGBRainbow(1)
        -- local r2, g2, b2 = RGBRainbow(1.5)
    
        -- local startColor = {r1, g1, b1,255} 
        -- local endColor = {r2, g2, b2,255}  

        local startColor = {255, 255, 255,255} 
        local endColor = {60, 60, 60,255}  
        
        ColorWaveTextEffect(flr(x+(bW/2)-(tW/2)), flr(y+(bH/2)-(tH/2)), name, startColor, endColor, -3)


        --[[ statuses start ]]--
        if gui.GetValue("fake lag") ~= 0 then 
            table.insert(info, {"Fake Lag: ".. flr((gui.GetValue("fake lag value (ms)") + 15) / 15).. " ticks", {35, 237, 255, 255}})
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

        local f = math.floor

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

    if config.visuals.crosshair_indicators then 

        local startW, startH = math.floor(sW / 2), math.floor(sH * 0.52)
        local r1, g1, b1 = LerpBetweenColors({50,50,50}, {255,255,255}, 3)
        local r2, g2, b2 = LerpBetweenColors({255,255,255}, {50,50,50}, 1)
        local startColor = {r1,g1,b1,255}
        local endColor = {r2,g2,b2,255}
        local cheatName = config.visuals.crosshair_indicators_info.cheatName
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

            --draw.FilledRect(pos)
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
            if wpn ~= nil then
                local critChance = wpn:GetCritChance()
                local dmgStats = wpn:GetWeaponDamageStats()
                local totalDmg = dmgStats["total"]
                local criticalDmg = dmgStats["critical"]
                local cmpCritChance = critChance + 0.1
                -- If we are allowed to crit
                if cmpCritChance > wpn:CalcObservedCritChance() then
                    -- draw.Text( 200, 510, "We can crit just fine!")
                else --Figure out how much damage we need
                    local requiredTotalDamage = (criticalDmg * (2.0 * cmpCritChance + 1.0)) / cmpCritChance / 3.0
                    local requiredDamage = requiredTotalDamage - totalDmg
                    -- draw.Color(232, 183, 49, 255)
                    -- local length, height = draw.GetTextSize( "Crit Ban: " .. math.floor(requiredDamage) )
                    -- draw.TextShadow(math.floor((sWidth / 2) - (length / 2)), math.floor(sHeight / 1.75), "Crit Ban: " .. math.floor(requiredDamage))
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

    end

    if config.visuals.aa_lines then 

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



        if config.visuals.aa_info.boring_lines then 
            draw.Color(255, 0, 0, 255)
            antiaimArrow(localPlayer:GetAbsOrigin(), yaws_fake[gui.GetValue("Anti aim - yaw (fake)")], config.visuals.aa_info.size)
            draw.Color(0, 255, 0, 255)
            antiaimArrow(localPlayer:GetAbsOrigin(), yaws_real[gui.GetValue("Anti aim - yaw (real)")], config.visuals.aa_info.size)
        else
            draw.Color(255, 0, 0, 255)
            antiaimCross(localPlayer:GetAbsOrigin(), yaws_fake[gui.GetValue("Anti aim - yaw (fake)")], config.visuals.aa_info.size)
            draw.Color(0, 255, 0, 255)
            antiaimCross(localPlayer:GetAbsOrigin(), yaws_real[gui.GetValue("Anti aim - yaw (real)")], config.visuals.aa_info.size)
        end

    end

    if config.visuals.damage_logger then 
        local startY = 0
        local currentTime = globals.RealTime()

        local startW, startH
        local x, y = config.visuals.damage_logger_info.damage_logger_x, config.visuals.damage_logger_info.damage_logger_y
        local bW, bH = 100, 20
        local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2] -- mouse position

        if not config.visuals.damage_logger_info.damage_logger_movable then
            startW, startH = math.floor(sW / 2), math.floor(sH * 0.6)
        else

            if Lbox_Menu_Open and mX >= x and mX <= x + bW and mY >= y and mY <= y + bH then

                if not input.IsButtonDown(MOUSE_LEFT) then
                    config.visuals.damage_logger_info.ratioX = ((mX - x) / bW)
                    config.visuals.damage_logger_info.ratioY = ((mY - y) / bH)
                else
                    config.visuals.damage_logger_info.damage_logger_x = mX - math.floor(bW * config.visuals.damage_logger_info.ratioX)
                    config.visuals.damage_logger_info.damage_logger_y = mY - math.floor(bH * config.visuals.damage_logger_info.ratioY)
                end
            end

            if Lbox_Menu_Open then 
                draw.Color(41, 41, 41, 225)
                draw.FilledRect(x, y, x + bW, y + bH)
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
    
    





    ::continue::


    if input.IsButtonPressed( KEY_END ) or input.IsButtonPressed( KEY_INSERT ) or input.IsButtonPressed( KEY_F11 ) then 
        toggleMenu()
    end

    if Lbox_Menu_Open then 
        ImMenu.Begin("Misc tools", true)

        ImMenu.BeginFrame(1)
        if ImMenu.Button("Antiaim") then 
            config.tabs.antiaim = true
            config.tabs.visuals = false
            config.tabs.misc = false
            config.tabs.cfg = false
        end
        if ImMenu.Button("Visuals") then 
            config.tabs.antiaim = false
            config.tabs.visuals = true
            config.tabs.misc = false
            config.tabs.cfg = false
        end
        if ImMenu.Button("Misc") then 
            config.tabs.antiaim = false
            config.tabs.visuals = false
            config.tabs.misc = true
            config.tabs.cfg = false
        end
        if ImMenu.Button("Config") then 
            config.tabs.antiaim = false
            config.tabs.visuals = false
            config.tabs.misc = false
            config.tabs.cfg = true
        end
        ImMenu.EndFrame()
    

        if config.tabs.antiaim then 
            ImMenu.BeginFrame(1)
            config.antiaim.random_pitch_down = ImMenu.Checkbox("Random Pitch Down", config.antiaim.random_pitch_down)
            config.antiaim.random_pitch_up = ImMenu.Checkbox("Random Pitch Up", config.antiaim.random_pitch_up)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            config.antiaim.rotate_dynamic = ImMenu.Checkbox("Rotate Dynamic", config.antiaim.rotate_dynamic)
            config.antiaim.custom_spin = ImMenu.Checkbox("Custom Spin (real yaw)", config.antiaim.custom_spin)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            config.antiaim.random_fakelag = ImMenu.Checkbox("Random Fakelag", config.antiaim.random_fakelag)
            config.antiaim.leg_jitter = ImMenu.Checkbox("Leg Jitter", config.antiaim.leg_jitter)
            ImMenu.EndFrame()

            if config.antiaim.rotate_dynamic then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("Rotate Dynamic Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.rotate_dynamic_delay = ImMenu.Slider("Delay (ms)", config.antiaim.rotate_dynamic_delay , 0, 5000)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.rotate_dynamic_fake1 = ImMenu.Slider("Fake Angle #1", config.antiaim.rotate_dynamic_fake1 , -180, 180)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.rotate_dynamic_real1 = ImMenu.Slider("Real Angle #1", config.antiaim.rotate_dynamic_real1 , -180, 180)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                ImMenu.Text(" ")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.rotate_dynamic_fake2 = ImMenu.Slider("Fake Angle #2", config.antiaim.rotate_dynamic_fake2 , -180, 180)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.rotate_dynamic_real2 = ImMenu.Slider("Real Angle #2", config.antiaim.rotate_dynamic_real2 , -180, 180)
                ImMenu.EndFrame()
            end

            if config.antiaim.custom_spin then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("Custom Spin Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.custom_spin_invert = ImMenu.Checkbox("Invert", config.antiaim.custom_spin_invert)
                config.antiaim.custom_spin_speed = ImMenu.Slider("Spin Speed", config.antiaim.custom_spin_speed , 1, 10)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.custom_spin_rand_speed = ImMenu.Checkbox("Random Speed", config.antiaim.custom_spin_rand_speed)
                config.antiaim.custom_spin_rand_invert = ImMenu.Checkbox("Random Invert", config.antiaim.custom_spin_rand_invert)
                ImMenu.EndFrame()
            end

            if config.antiaim.random_fakelag then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("Random Fakelag Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.fakelag_max = ImMenu.Slider("Random Fakelag Max", config.antiaim.fakelag_max , 1, 22)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.fakelag_min = ImMenu.Slider("Random Fakelag Min", config.antiaim.fakelag_min , 1, 22)
                ImMenu.EndFrame()
            end

            if config.antiaim.leg_jitter then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("Leg Jitter Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.leg_jitter_amount = ImMenu.Slider("Leg Jitter Amount", config.antiaim.leg_jitter_amount , 10, 60)
                ImMenu.EndFrame()
            end
        end


        if config.tabs.visuals then 
            ImMenu.BeginFrame(1)
            config.visuals.info = ImMenu.Checkbox("Info Panel", config.visuals.info)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            config.visuals.crosshair_indicators = ImMenu.Checkbox("Crosshair Indicators", config.visuals.crosshair_indicators)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            config.visuals.aa_lines = ImMenu.Checkbox("Antiaim Lines", config.visuals.aa_lines)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            config.visuals.damage_logger = ImMenu.Checkbox("Damage Logger", config.visuals.damage_logger)
            ImMenu.EndFrame()

            if config.visuals.damage_logger then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("DMG Logger Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.visuals.damage_logger_info.damage_logger_movable = ImMenu.Checkbox("Custom DMG Logger Pos", config.visuals.damage_logger_info.damage_logger_movable)
                ImMenu.EndFrame()
            end

            if config.visuals.aa_lines then  
                ImMenu.BeginFrame(1)
                ImMenu.Text("AA Lines Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.visuals.aa_info.boring_lines = ImMenu.Checkbox("Boring AA Lines", config.visuals.aa_info.boring_lines)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.visuals.aa_info.size = ImMenu.Slider("AA Line Size", config.visuals.aa_info.size , 1, 100)
                ImMenu.EndFrame()
            end

            if config.visuals.crosshair_indicators then
                ImMenu.BeginFrame(1)
                ImMenu.Text("Custom Cheat Name (must be over 1 character)")
                ImMenu.EndFrame() 
                ImMenu.BeginFrame(1)
                config.visuals.crosshair_indicators_info.cheatName = ImMenu.TextInput("Cheat Name", config.visuals.crosshair_indicators_info.cheatName)
                ImMenu.EndFrame()
            end
        end


        if config.tabs.misc then 
            ImMenu.BeginFrame(1)
            config.misc.inf_respawn = ImMenu.Checkbox("Infinite Respawn", config.misc.inf_respawn)
            config.misc.spy_warning = ImMenu.Checkbox("Spy Warning", config.misc.spy_warning)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            config.misc.fine_shot_m8 = ImMenu.Checkbox("Fine Shot M8", config.misc.fine_shot_m8)
            config.misc.autostrafer = ImMenu.Checkbox("Autostrafe Only WASD", config.misc.autostrafer)
            ImMenu.EndFrame()

            if config.misc.spy_warning then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("Spy Warning Settings")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.misc.spy_warning_yell = ImMenu.Checkbox("Call Out", config.misc.spy_warning_yell)
                config.misc.spy_warning_distance = ImMenu.Slider("Distance", config.misc.spy_warning_distance , 100, 1000)
                ImMenu.EndFrame()
            end
        end


        if config.tabs.cfg then 
            ImMenu.BeginFrame(1)
            if ImMenu.Button("Create/Save CFG") then
                CreateCFG( [[Misc Tools Lua]] , config )
                printc(255, 174, 0, 255, "Saved Lua Config")
            end

            if ImMenu.Button("Load CFG") then
                config = LoadCFG( [[Misc Tools Lua]] )
                printc(0, 255, 136, 255, "Loaded Lua Config")
            end

            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Dont load a config if you havent saved one.")
            ImMenu.EndFrame()
        end

        ImMenu.End()
    end
    
end


local function MiscCreateMove(cmd)


    if config.antiaim.custom_spin then 
        local add = config.antiaim.custom_spin_speed
        local function a(x)
            if x >= 180 then
                x = -180
            elseif x <= -180 then
                x = 180
            end
            return x
        end
        if config.antiaim.custom_spin_rand_speed and globals.RealTime() > delays.rand_spin + 0.2 then 
            config.antiaim.custom_spin_speed = math.random(1, 10)
            delays.rand_spin = globals.RealTime()
        end
        if config.antiaim.custom_spin_rand_invert and globals.RealTime() > delays.rand_invert + 0.2 then 
            config.antiaim.custom_spin_invert = (math.random(0,1)==1)
            delays.rand_invert = globals.RealTime()
        end
        if config.antiaim.custom_spin_invert then
            add = -add
        end
        gui.SetValue( "Anti Aim - Custom Yaw (real)", a(gui.GetValue( "Anti Aim - Custom Yaw (real)" ) + add))
    end


    if config.antiaim.leg_jitter then
        local value = config.antiaim.leg_jitter_amount 
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


end


local function dmgLogger(event)

    if (event:GetName() == 'player_hurt' ) and config.visuals.damage_logger then
  
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

callbacks.Unregister("Draw", "MiscDraw")
callbacks.Register( "Draw", "MiscDraw", MiscDraw )

callbacks.Unregister("CreateMove", "MiscCreateMove")
callbacks.Register( "CreateMove", "MiscCreateMove", MiscCreateMove )
