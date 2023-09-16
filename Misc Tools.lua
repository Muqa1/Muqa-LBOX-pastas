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

        inf_repawn = false,

        spy_warning = false,
        spy_warning_yell = false,
        spy_warning_distance = 230,

    },

    visuals = {
        info = true,
        info_pos = {
            info_x = 10,
            info_y = 500,
        },

    }

}

local sW, sH = draw.GetScreenSize()
local font = draw.CreateFont( "tahoma", 12, 800, FONTFLAG_OUTLINE )

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

local delays = {
    random_pitch_down = 0,
    random_pitch_up = 0,
    random_fakelag = 0,
    respawnExtend = 0,
    spy_warning = 0,
    rotate_dynamic_wait = 0,
}

local function MiscDraw()
    draw.SetFont( font )
    local localPlayer = entities.GetLocalPlayer()
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

    if config.misc.inf_repawn then 
        if (localPlayer:IsAlive() == false) and (globals.RealTime() > (delays.respawnExtend + 2)) then 
            client.Command("extendfreeze", true)                                             
            delays.respawnExtend = globals.RealTime()                                             
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
        local bW, bH = 100, 25 -- box width , box height

        local mX, mY = input.GetMousePos()[1], input.GetMousePos()[2] -- mouse position

        if input.IsButtonDown(MOUSE_LEFT) and Lbox_Menu_Open and -- is the cursor inside the box?
            mX >= x and mX <= x + bW and
            mY >= y and mY <= y + bH then
            config.visuals.info_pos.info_x = mX - flr(bW/2)
            config.visuals.info_pos.info_y = mY - flr(bH/2)
        end

        draw.Color(35, 51, 66, 225)
        draw.FilledRect(x, y, x + bW, y + bH)

        draw.Color(29, 189, 165, 255)
        draw.OutlinedRect(x, y, x + bW, y + bH)

        draw.Color(225, 225, 225, 255)
        local name = "Info Panel"
        local tW, tH = draw.GetTextSize(name) -- text width, text height
        draw.Text(flr(x+(bW/2)-(tW/2)), flr(y+(bH/2)-(tH/2)), name)


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
            table.insert(info, {"Yaw Offset: ".. GetOffset().. "°", {255, 184, 184, 255}})
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
            draw.Color( table.unpack(v[2]) )
            draw.Text(x + 1, y + bH + 1 + startY, v[1])
            startY = startY + h
        end

    end








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
                config.antiaim.rotate_dynamic_fake2 = ImMenu.Slider("Fake Angle #2", config.antiaim.rotate_dynamic_fake2 , -180, 180)
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                config.antiaim.rotate_dynamic_real1 = ImMenu.Slider("Real Angle #1", config.antiaim.rotate_dynamic_real1 , -180, 180)
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
        end


        if config.tabs.misc then 
            ImMenu.BeginFrame(1)
            config.misc.inf_repawn = ImMenu.Checkbox("Infinite Respawn", config.misc.inf_repawn)
            config.misc.spy_warning = ImMenu.Checkbox("Spy Warning", config.misc.spy_warning)
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
            end

            if ImMenu.Button("Load CFG") then
                config = LoadCFG( [[Misc Tools Lua]] )
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
        if not config.antiaim.custom_spin_invert then
        
            gui.SetValue( "Anti Aim - Custom Yaw (real)", gui.GetValue( "Anti Aim - Custom Yaw (real)" ) + config.antiaim.custom_spin_speed)

            if (gui.GetValue( "Anti Aim - Custom Yaw (real)") >= 170) then 
                gui.SetValue( "Anti Aim - Custom Yaw (real)", -180)
            end
        else
            gui.SetValue( "Anti Aim - Custom Yaw (real)", gui.GetValue( "Anti Aim - Custom Yaw (real)" ) - config.antiaim.custom_spin_speed)
  
            if (gui.GetValue( "Anti Aim - Custom Yaw (real)") <= -170) then 
                gui.SetValue( "Anti Aim - Custom Yaw (real)", 180)
            end
        end
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

callbacks.Unregister("Draw", "MiscDraw")
callbacks.Register( "Draw", "MiscDraw", MiscDraw )

callbacks.Unregister("CreateMove", "MiscCreateMove")
callbacks.Register( "CreateMove", "MiscCreateMove", MiscCreateMove )
