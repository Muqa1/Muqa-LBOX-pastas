local Menu = { -- the config table

    colors = { 
        -- Local = {},
        friend = {0,255,0},
        enemy = {255,255,255},
        teammate = {0, 130, 22},
        uber = {255,0,255},
        over_heal = {71, 166, 255},
        priority ={255,255,0},
        cheater = {255,0,0},
        supplies = {255,255,255},
    },

    tabs = {
        global = true, 
        world = false, 
        players = false, 
        buildings = false,
        colors = false,
        config = false,
    },

    global_tab = {
        active = true,
        memory = true,
        max_distance = 2500,
        fonts = {"Tahoma", "Tahoma Bold", "Verdana", "Consolas", "Arial", "TF2 Build"},
        selected_font = 1,
        tracer_pos = {
            from = {"Top", "Center", "Bottom"},
            selected_from = 1, -- 1 is top, 2 is center and so on
            to = {"Top", "Center", "Bottom"},
            selected_to = 1,
        },
    },

    world_tab = {
        active = false,
        alpha = 5,
        health_and_ammospin = 10,
        ignore = {
            -- health_packs = false, -- i didnt find a way to differentiate them
            -- ammo_packs = false, 
            supplies = false,
            enemy_projectiles = false,
            teammate_projectiles = true, 
            -- halloween_gifts = false, -- these are not done yet
            -- mvm_money = false
        },
        draw = {
            name = true, 
            box = false, 
            tracer = false
        },
    },

    players_tab = {
        active = true,
        alpha = 10,
        ignore = {
            friends = false,
            enemies = false,
            teammates = true,
            invisible = false
        },
        draw = {
            text_pos = {"Normal", "Top Left", "Bottom Left", "Right Top", "Left Top", "Center", "Bottom Center", "Top Center"},
            selected_text_pos = 1,
            name = true,
            class = false,
            health = true, 
            health_bar = true, 
            uber = true,
            uber_bar = true,
            box = true,
            skeleton = false,
            tracer = false,
            conds = true,
            bars_thickness = 2,
            box_cornered = false,
            box_outlined = true,
            health_bar_pos = {"Left", "Bottom"},
            selected_health_bar_pos = 1,
            uber_bar_pos = {"Left", "Bottom"},
            selected_uber_bar_pos = 1,
            bars_static_bacrkound = false,
        },
    },

    buildings_tab = {
        active = false,
        alpha = 10,
        ignore = {
            teammates = true,
            enemies = false,
        },
        draw = {
            name = true,
            health = false, 
            health_bar = true,
            level = false,
            level_bar = false,
            box = false,
            tracer = false,
            conds = false,
            sentry_range = false,
            sentry_range_segments = 20,
        }
    },
    
    colors_tab = {
        colors = {"Friend", "Enemy", "Teammate", "Uber", "Over Heal", "Priority", "Cheater", "Supplies"},
        selected_color = 1,
    }
}

local wait = 0
local memoryUsage = 0

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

local fonts = {
    [1] = draw.CreateFont( "Tahoma", 12, 400, FONTFLAG_OUTLINE),
    [2] = draw.CreateFont( "Tahoma", 12, 800, FONTFLAG_OUTLINE),
    [3] = draw.CreateFont( "Verdana", 14, 400, FONTFLAG_OUTLINE),
    [4] = draw.CreateFont( "Consolas", 12, 400, FONTFLAG_OUTLINE),
    [5] = draw.CreateFont( "Arial", 14, 400, FONTFLAG_OUTLINE),
    [6] = draw.CreateFont( "TF2 Build", 12, 400, FONTFLAG_OUTLINE)
}

local s_width, s_height = draw.GetScreenSize()

local function calculateTracerPositions(x, y, w, height)
    local from_pos = {(s_width / 2), 0}
    local to_pos = {(math.floor(x + w / 2)), 0}

    if Menu.global_tab.tracer_pos.selected_from == 2 then
        from_pos[2] = s_height / 2
    elseif Menu.global_tab.tracer_pos.selected_from == 3 then
        from_pos[2] = s_height
    end

    if Menu.global_tab.tracer_pos.selected_to == 1 then
        to_pos[2] = y
    elseif Menu.global_tab.tracer_pos.selected_to == 2 then
        to_pos[2] = y + math.floor(height / 2)
    elseif Menu.global_tab.tracer_pos.selected_to == 3 then
        to_pos[2] = y + height
    end

    return from_pos, to_pos
end

local function ColorCalculator(index) -- best name
    local colors = {
        [1] = Menu.colors.friend,
        [2] = Menu.colors.enemy,
        [3] = Menu.colors.teammate,
        [4] = Menu.colors.uber,
        [5] = Menu.colors.over_heal,
        [6] = Menu.colors.priority,
        [7] = Menu.colors.cheater,
        [8] = Menu.colors.supplies,
    }
    return colors[index]
end

local projectiles = {
    "CTFStunBall",
    "CTFBall_Ornament",
    "CTFProjectile_Cleaver",
    "CTFProjectile_JarMilk",
    "CTFProjectile_Rocket",
    "CTFProjectile_EnergyBall",
    "CTFProjectile_EnergyRing",
    "CTFProjectile_BallOfFire",
    "CTFProjectile_Flare",
    "CTFGrenadePipebombProjectile",
    "CTFProjectile_Arrow",
    "CTFProjectile_MechanicalArmOrb",
    "CTFProjectile_HealingBolt",
    "CTFProjectile_Jar",
    "CTFProjectile_JarGas",
    "CTFProjectile_SentryRocket"
}

local projectile_names = {
    ["CTFStunBall"] = "Ball",
    ["CTFBall_Ornament"] = "Ornament",
    ["CTFProjectile_Cleaver"] = "Cleaver",
    ["CTFProjectile_JarMilk"] = "Milk",
    ["CTFProjectile_Rocket"] = "Rocket",
    ["CTFProjectile_SentryRocket"] = "Rocket",
    ["CTFProjectile_EnergyBall"] = "Energy Ball",
    ["CTFProjectile_EnergyRing"] = "Energy Ring",
    ["CTFProjectile_BallOfFire"] = "Fire",
    ["CTFProjectile_Flare"] = "Flare",
    ["CTFGrenadePipebombProjectile"] = "Sticky",
    ["CTFProjectile_Arrow"] = "Arrow",
    ["CTFProjectile_MechanicalArmOrb"] = "Orb",
    ["CTFProjectile_HealingBolt"] = "Healing Arrow",
    ["CTFProjectile_Jar"] = "Jarate",
    ["CTFProjectile_JarGas"] = "Gas Passer"
}

local boneIDs = {
    {1, 6},   -- head to pelvis
    {6, 5},   
    {5, 4}, 
    {4, 3}, 
    {3, 2},  -- head to pelvis

    {2, 13},  -- pelvis to left foot
    {13, 14}, 
    {14, 15}, -- pelvis to left foot

    {2, 16}, -- pelvis to right foot
    {16, 17}, 
    {17, 18}, -- pelvis to right foot

    {6, 10}, -- shoulder to right arm
    {10, 11},
    {11, 12}, -- shoulder to right arm

    {6, 7}, -- shoulder to left arm
    {7, 8},
    {8, 9} -- shoulder to left arm
}

local classes = {
    [1] = "Scout",
    [2] = "Sniper", 
    [3] = "Soldier",
    [4] = "Demoman",
    [5] = "Medic", 
    [6] = "Heavy",
    [7] = "Pyro",
    [8] = "Spy", 
    [9] = "Engineer",
}

local building_names = {
    ["CObjectSentrygun"] = "Sentry",
    ["CObjectTeleporter"] = "Teleporter",
    ["CObjectDispenser"] = "Dispenser",
}

local conditions_names = {
    [1] = "*ZOOMED*",
    [3] = "*DISGUISED*",
    [4] = "*CLOAKED*",
    [5] = "*UBER*",
    [7] = "*TAUNT*",

    [11] = "*CRITS*", -- ape
    [33] = "*CRITS*",
    [34] = "*CRITS*",
    [35] = "*CRITS*",
    [37] = "*CRITS*",
    [38] = "*CRITS*",
    [39] = "*CRITS*",
    [40] = "*CRITS*",
    [44] = "*CRITS*",
    [56] = "*CRITS*",
    [78] = "*MINI CRITS*",
    [105] = "*CRITS*",

    [22] = "*BRUNING*",
    [24] = "*JARATE*",
    [25] = "*BLEEDING*",
    [27] = "*MILK*",
    [32] = "*SPEED BOOST*",
    [36] = "*HYPE*",
    [58] = "*BULLET RES (UBER)*",
    [59] = "*BLAST RES (UBER)*",
    [60] = "*FIRE RES (UBER)*",
    [61] = "*BULLET RES*",
    [62] = "*BLAST RES*",
    [63] = "*FIRE RES*",
    [81] = "*BLAST JUMPING*",
    [123] = "*GAS*",
}
local function building_conds(building)
    local buildingConditions = {}
    if Menu.buildings_tab.draw.health then
        local health = building:GetHealth()
        table.insert(buildingConditions, health)
    end
    if Menu.buildings_tab.draw.level then
        local level = building:GetPropInt("m_iUpgradeLevel")
        table.insert(buildingConditions, level)
    end
    -- if Menu.buildings_tab.draw.conds then
    --     if building:InCond(50) then 
    --         table.insert(buildingConditions, "SAPPED")
    --     end
    -- end
    return buildingConditions
end

local function getConditions(player)
    local playerConditions = {}
    if Menu.players_tab.draw.class then 
        table.insert(playerConditions, classes[player:GetPropInt("m_iClass")])
    end
    if Menu.players_tab.draw.health then
        local health = player:GetHealth()
        local maxHealth = player:GetMaxHealth()
        table.insert(playerConditions, health)
    end
    if Menu.players_tab.draw.uber then
        if player:GetPropInt("m_iClass") == 5 then
            local medigun = player:GetEntityForLoadoutSlot( 1 )
            local uber = medigun:GetPropFloat("LocalTFWeaponMedigunData","m_flChargeLevel")
            local TextPercentage = uber * 100
            local UberPercentage = math.floor(TextPercentage)
            table.insert(playerConditions, UberPercentage.. "%")
        end
    end
    if Menu.players_tab.draw.conds then
        for conditionInt, conditionName in pairs(conditions_names) do
            if player:InCond(conditionInt) then
                table.insert(playerConditions, conditionName)
            end
        end
    end
    return playerConditions
end

local function isInTable(name, table)
    for _, value in ipairs(table) do
        if value == name then
            return true
        end
    end
    return false
end

local function distance_check(entity, local_player)
    if vector.Distance( entity:GetAbsOrigin(), local_player:GetAbsOrigin()) > Menu.global_tab.max_distance then 
        return false 
    end 
    return true
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

local function draw_circle(pos, segments, radius)
    local angleIncrement = 360 / segments
    local vertices = {}
    for i = 1, segments do
        local angle = math.rad(i * angleIncrement)
        local x = pos.x + math.cos(angle) * radius
        local y = pos.y + math.sin(angle) * radius
        local z = pos.z
        vertices[i] = client.WorldToScreen(Vector3(x, y, z))
    end    
    for i = 1, segments do
        local j = i + 1
        if j > segments then j = 1 end
        local vertex1, vertex2 = vertices[i], vertices[j]     
        if vertex1 and vertex2 then
            draw.Line(vertex1[1], vertex1[2], vertex2[1], vertex2[2])
        end
    end
end

local function Get2DBoundingBox(entity)
    local hitbox = entity:HitboxSurroundingBox()
    local corners = {
        Vector3(hitbox[1].x, hitbox[1].y, hitbox[1].z),
        Vector3(hitbox[1].x, hitbox[2].y, hitbox[1].z),
        Vector3(hitbox[2].x, hitbox[2].y, hitbox[1].z),
        Vector3(hitbox[2].x, hitbox[1].y, hitbox[1].z),
        Vector3(hitbox[2].x, hitbox[2].y, hitbox[2].z),
        Vector3(hitbox[1].x, hitbox[2].y, hitbox[2].z),
        Vector3(hitbox[1].x, hitbox[1].y, hitbox[2].z),
        Vector3(hitbox[2].x, hitbox[1].y, hitbox[2].z)
    }
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for _, corner in pairs(corners) do
        local onScreen = client.WorldToScreen(corner)
        if onScreen then
            minX, minY = math.min(minX, onScreen[1]), math.min(minY, onScreen[2])
            maxX, maxY = math.max(maxX, onScreen[1]), math.max(maxY, onScreen[2])
        else
            return false
        end
    end
    return minX, minY, maxX, maxY
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
        printc( 255, 183, 0, 255, "["..os.date("%H:%M:%S").."] Saved to ".. tostring(fullPath))
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
            printc( 0, 255, 140, 255, "["..os.date("%H:%M:%S").."] Loaded from ".. tostring(fullPath))
            return chunk()
        else
            print("Error loading configuration:", err)
        end
    end
end


callbacks.Register( "Draw", "Muqas esp", function()

    if input.IsButtonPressed( KEY_END ) or input.IsButtonPressed( KEY_INSERT ) or input.IsButtonPressed( KEY_F11 ) then 
        toggleMenu()
    end

    if Lbox_Menu_Open == true and ImMenu.Begin("Custom lua esp for lmaobox by Muqa", true) then -- managing the menu

        ImMenu.BeginFrame(1) -- tabs

        if ImMenu.Button("Global") then 
            Menu.tabs.global = true
            Menu.tabs.world = false
            Menu.tabs.players = false
            Menu.tabs.buildings = false
            Menu.tabs.colors = false
            Menu.tabs.config = false
        end

        if ImMenu.Button("World") then
            Menu.tabs.global = false
            Menu.tabs.world = true
            Menu.tabs.players = false
            Menu.tabs.buildings = false
            Menu.tabs.colors = false
            Menu.tabs.config = false
        end

        if ImMenu.Button("Players") then
            Menu.tabs.global = false
            Menu.tabs.world = false
            Menu.tabs.players = true
            Menu.tabs.buildings = false
            Menu.tabs.colors = false
            Menu.tabs.config = false
        end

        if ImMenu.Button("Buildings") then
            Menu.tabs.global = false
            Menu.tabs.world = false
            Menu.tabs.players = false
            Menu.tabs.buildings = true
            Menu.tabs.colors = false
            Menu.tabs.config = false
        end

        if ImMenu.Button("Colors") then
            Menu.tabs.global = false
            Menu.tabs.world = false
            Menu.tabs.players = false
            Menu.tabs.buildings = false 
            Menu.tabs.colors = true
            Menu.tabs.config = false
        end

        if ImMenu.Button("Config") then
            Menu.tabs.global = false
            Menu.tabs.world = false
            Menu.tabs.players = false
            Menu.tabs.buildings = false
            Menu.tabs.colors = false
            Menu.tabs.config = true
        end

        ImMenu.EndFrame()

        if Menu.tabs.global then 
            ImMenu.BeginFrame(1)
            ImMenu.Text("The menu keys are INSERT, END and F11")
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.global_tab.active = ImMenu.Checkbox("Active", Menu.global_tab.active)
            Menu.global_tab.memory = ImMenu.Checkbox("Show Memory Usage", Menu.global_tab.memory)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.global_tab.max_distance = ImMenu.Slider("Max Distance", Menu.global_tab.max_distance , 100, 6000)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Esp Font")
            Menu.global_tab.selected_font = ImMenu.Option(Menu.global_tab.selected_font, Menu.global_tab.fonts)
            ImMenu.EndFrame()
            
            ImMenu.BeginFrame(1)
            ImMenu.Text("Tracer From")
            Menu.global_tab.tracer_pos.selected_from = ImMenu.Option(Menu.global_tab.tracer_pos.selected_from, Menu.global_tab.tracer_pos.from)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Tracer To")
            Menu.global_tab.tracer_pos.selected_to = ImMenu.Option(Menu.global_tab.tracer_pos.selected_to, Menu.global_tab.tracer_pos.to)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            if ImMenu.Button("Unload Script") then
                callbacks.Unregister( "Draw", "Muqas esp" )
            end
            ImMenu.EndFrame()
        end

        if Menu.tabs.world then 
            ImMenu.BeginFrame(1)
            Menu.world_tab.active = ImMenu.Checkbox("Active", Menu.world_tab.active)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.world_tab.alpha = ImMenu.Slider("Alpha", Menu.world_tab.alpha , 0, 10)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.world_tab.health_and_ammospin = ImMenu.Slider("Health And Ammopack Spin", Menu.world_tab.health_and_ammospin , 0, 100)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Ignore List")
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            Menu.world_tab.ignore.supplies = ImMenu.Checkbox("Supplies", Menu.world_tab.ignore.supplies)
            Menu.world_tab.ignore.enemy_projectiles = ImMenu.Checkbox("Enemy Projectiles", Menu.world_tab.ignore.enemy_projectiles)
            Menu.world_tab.ignore.teammate_projectiles = ImMenu.Checkbox("Teammate Projectiles", Menu.world_tab.ignore.teammate_projectiles)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Draw List")
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            Menu.world_tab.draw.name = ImMenu.Checkbox("Name", Menu.world_tab.draw.name)
            Menu.world_tab.draw.box = ImMenu.Checkbox("Box", Menu.world_tab.draw.box)
            Menu.world_tab.draw.tracer = ImMenu.Checkbox("Tracer", Menu.world_tab.draw.tracer)
            ImMenu.EndFrame()
        end

        if Menu.tabs.players then 
            ImMenu.BeginFrame(1)
            Menu.players_tab.active =  ImMenu.Checkbox("Active", Menu.players_tab.active)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.players_tab.alpha = ImMenu.Slider("Alpha", Menu.players_tab.alpha , 0, 10)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Ignore List")
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.players_tab.ignore.friends =  ImMenu.Checkbox("Friends", Menu.players_tab.ignore.friends)
            Menu.players_tab.ignore.enemies =  ImMenu.Checkbox("Enemies", Menu.players_tab.ignore.enemies)
            Menu.players_tab.ignore.teammates =  ImMenu.Checkbox("Teammates", Menu.players_tab.ignore.teammates)
            Menu.players_tab.ignore.invisible =  ImMenu.Checkbox("Invisible", Menu.players_tab.ignore.invisible)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Draw List")
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Text Position")
            Menu.players_tab.draw.selected_text_pos = ImMenu.Option(Menu.players_tab.draw.selected_text_pos, Menu.players_tab.draw.text_pos)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.players_tab.draw.name =  ImMenu.Checkbox("Name", Menu.players_tab.draw.name)
            Menu.players_tab.draw.class =  ImMenu.Checkbox("Class", Menu.players_tab.draw.class)
            Menu.players_tab.draw.health =  ImMenu.Checkbox("Health", Menu.players_tab.draw.health)
            Menu.players_tab.draw.health_bar =  ImMenu.Checkbox("Health Bar", Menu.players_tab.draw.health_bar)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.players_tab.draw.uber =  ImMenu.Checkbox("Uber", Menu.players_tab.draw.uber)
            Menu.players_tab.draw.uber_bar =  ImMenu.Checkbox("Uber Bar", Menu.players_tab.draw.uber_bar)
            Menu.players_tab.draw.box =  ImMenu.Checkbox("Box", Menu.players_tab.draw.box)
            Menu.players_tab.draw.tracer =  ImMenu.Checkbox("Tracer", Menu.players_tab.draw.tracer)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.players_tab.draw.conds =  ImMenu.Checkbox("Conditions", Menu.players_tab.draw.conds)
            Menu.players_tab.draw.skeleton =  ImMenu.Checkbox("Skeleton", Menu.players_tab.draw.skeleton)
            ImMenu.EndFrame()

            if Menu.players_tab.draw.box then 
                ImMenu.BeginFrame(1)
                ImMenu.Text("Box Options")
                ImMenu.EndFrame()
                ImMenu.BeginFrame(1)
                Menu.players_tab.draw.box_cornered =  ImMenu.Checkbox("Cornered Box", Menu.players_tab.draw.box_cornered)
                Menu.players_tab.draw.box_outlined = ImMenu.Checkbox("Box Outline", Menu.players_tab.draw.box_outlined)
                ImMenu.EndFrame()
            end

            if Menu.players_tab.draw.health_bar or Menu.players_tab.draw.uber_bar then 

                ImMenu.BeginFrame(1)
                ImMenu.Text("Health & Uber Bar Options")
                ImMenu.EndFrame()

                if Menu.players_tab.draw.health_bar then 
                    ImMenu.BeginFrame(1)
                    ImMenu.Text("Health Bar Position")
                    Menu.players_tab.draw.selected_health_bar_pos = ImMenu.Option(Menu.players_tab.draw.selected_health_bar_pos, Menu.players_tab.draw.health_bar_pos)
                    ImMenu.EndFrame()    
                end

                if Menu.players_tab.draw.uber_bar then 
                    ImMenu.BeginFrame(1)
                    ImMenu.Text("Uber Bar Position")
                    Menu.players_tab.draw.selected_uber_bar_pos = ImMenu.Option(Menu.players_tab.draw.selected_uber_bar_pos, Menu.players_tab.draw.uber_bar_pos)
                    ImMenu.EndFrame()    
                end

                ImMenu.BeginFrame(1)
                Menu.players_tab.draw.bars_thickness = ImMenu.Slider("Health & Uber Bar Thickness", Menu.players_tab.draw.bars_thickness , 1, 10)
                ImMenu.EndFrame()

                ImMenu.BeginFrame(1)
                Menu.players_tab.draw.bars_static_bacrkound = ImMenu.Checkbox("Health & Uber Bar Static Backround", Menu.players_tab.draw.bars_static_bacrkound)
                ImMenu.EndFrame()
            end
        end

        if Menu.tabs.buildings then 
            ImMenu.BeginFrame(1)
            Menu.buildings_tab.active =  ImMenu.Checkbox("Active", Menu.buildings_tab.active)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.buildings_tab.alpha = ImMenu.Slider("Alpha", Menu.buildings_tab.alpha , 0, 10)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Ignore List")
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.buildings_tab.ignore.enemies = ImMenu.Checkbox("Enemies", Menu.buildings_tab.ignore.enemies)
            Menu.buildings_tab.ignore.teammates = ImMenu.Checkbox("Teammates", Menu.buildings_tab.ignore.teammates)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Draw List")
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.buildings_tab.draw.name =  ImMenu.Checkbox("Name", Menu.buildings_tab.draw.name)
            Menu.buildings_tab.draw.health =  ImMenu.Checkbox("Health", Menu.buildings_tab.draw.health)
            Menu.buildings_tab.draw.health_bar =  ImMenu.Checkbox("Health Bar", Menu.buildings_tab.draw.health_bar)
            Menu.buildings_tab.draw.level =  ImMenu.Checkbox("Level", Menu.buildings_tab.draw.level)
            Menu.buildings_tab.draw.level_bar =  ImMenu.Checkbox("Level Bar", Menu.buildings_tab.draw.level_bar)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            Menu.buildings_tab.draw.box =  ImMenu.Checkbox("Box", Menu.buildings_tab.draw.box)
            Menu.buildings_tab.draw.tracer =  ImMenu.Checkbox("Tracer", Menu.buildings_tab.draw.tracer)
            Menu.buildings_tab.draw.conds =  ImMenu.Checkbox("Conditions", Menu.buildings_tab.draw.conds)
            Menu.buildings_tab.draw.sentry_range =  ImMenu.Checkbox("Sentry Range", Menu.buildings_tab.draw.sentry_range)
            ImMenu.EndFrame()
            if Menu.buildings_tab.draw.sentry_range then 
                ImMenu.BeginFrame(1)
                Menu.buildings_tab.draw.sentry_range_segments = ImMenu.Slider("Sentry Range Cricle Segments", Menu.buildings_tab.draw.sentry_range_segments , 3, 50)
                ImMenu.EndFrame()
            end
        end

        if Menu.tabs.colors then
            ImMenu.BeginFrame(1)
            ImMenu.Text("Sorry for no color picker")
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Selected Color")
            Menu.colors_tab.selected_color = ImMenu.Option(Menu.colors_tab.selected_color, Menu.colors_tab.colors)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ColorCalculator(Menu.colors_tab.selected_color)[1] = ImMenu.Slider("Red", ColorCalculator(Menu.colors_tab.selected_color)[1] , 0, 255)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            ColorCalculator(Menu.colors_tab.selected_color)[2] = ImMenu.Slider("Green", ColorCalculator(Menu.colors_tab.selected_color)[2] , 0, 255)
            ImMenu.EndFrame()
            ImMenu.BeginFrame(1)
            ColorCalculator(Menu.colors_tab.selected_color)[3] = ImMenu.Slider("Blue", ColorCalculator(Menu.colors_tab.selected_color)[3] , 0, 255)
            ImMenu.EndFrame()
        end

        if Menu.tabs.config then 
            ImMenu.BeginFrame(1)
            if ImMenu.Button("Create/Save CFG") then
                CreateCFG( [[Muqas lua esp config]] , Menu )
            end

            if ImMenu.Button("Load CFG") then
                Menu = LoadCFG( [[Muqas lua esp config]] )
            end

            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Dont load a config if you havent saved one.")
            ImMenu.EndFrame()
        end

        ImMenu.End()
    end

    --=====================--
    -- starting drawing esp 
    draw.SetFont( fonts[Menu.global_tab.selected_font] )
    local localPlayer = entities.GetLocalPlayer()
    if Menu.global_tab.active and not engine.IsGameUIVisible() then
        if Menu.global_tab.memory then 
            local function getMemoryUsage()
                local mem = collectgarbage("count") / 1024
                return mem
            end
            if globals.RealTime() > (wait + 1) then
                memoryUsage = getMemoryUsage()
                wait = globals.RealTime()
            end
            local roundedMemoryUsage = string.format("%.2f", memoryUsage)
            draw.Color(255, 255, 255, 255)
            draw.Text(10, math.floor(s_height * 0.2), "Memory usage: " .. roundedMemoryUsage .. " MB")
        end
        if Menu.world_tab.active then 
            local function draw_world_esp(entity_name)
                local entities = entities.FindByClass( entity_name ) 
                for i,entity in pairs(entities) do 
                    if not entity:IsDormant() and distance_check(entity, localPlayer) then
                        local entity_class = entity:GetClass()
                        local name
                        local colorWorld = nil

                        if entity_class == "CBaseAnimating" or entity_class == "CTFAmmoPack" then 
                            name = "Supplies"
                            colorWorld = Menu.colors.supplies
                            if entity:GetPropFloat("m_flPlaybackRate") ~= Menu.world_tab.health_and_ammospin then
                                entity:SetPropFloat( Menu.world_tab.health_and_ammospin, "m_flPlaybackRate" )
                            end
                        end

                        if isInTable(entity_class, projectiles) == true then 
                            name = projectile_names[entity_class]
                            local localTeam = localPlayer:GetTeamNumber()
                            local enemyTeam = entity:GetTeamNumber()
                            if enemyTeam ~= localTeam then 
                                colorWorld = Menu.colors.enemy
                            else
                                colorWorld = Menu.colors.teammate
                            end
                            if Menu.world_tab.ignore.enemy_projectiles and not Menu.world_tab.ignore.teammate_projectiles then 
                                if enemyTeam ~= localTeam then
                                    goto projectile_esp_continue
                                end
                            end
                            if Menu.world_tab.ignore.teammate_projectiles and not Menu.world_tab.ignore.enemy_projectiles then 
                                if enemyTeam == localTeam  then
                                    goto projectile_esp_continue
                                end
                            end
                        end

                        local x,y,x2,y2 = Get2DBoundingBox(entity)
                        if not x or not y or not x2 or not y2 then goto projectile_esp_continue end
                        local h, w = y2 - y, x2 - x

                        local alpha = math.floor(255 * (Menu.world_tab.alpha / 10))

                        draw.Color(colorWorld[1], colorWorld[2], colorWorld[3], alpha)

                        if Menu.world_tab.draw.tracer then 
                            draw.Color(colorWorld[1],colorWorld[2],colorWorld[3],alpha)
                            local from_pos, to_pos = calculateTracerPositions(x, y, w, height)
                            draw.Line( from_pos[1], from_pos[2], to_pos[1], to_pos[2] )
                        end
                        if Menu.world_tab.draw.name then 
                            local width , height = draw.GetTextSize( name )
                            draw.Text( math.floor(x + w / 2 - (width / 2)), y - height, name )
                        end
                        if Menu.world_tab.draw.box then 
                            if entity_class == "CTFAmmoPack" then -- looks retarded on dropped ammo
                                goto projectile_esp_continue
                            end
                            draw.OutlinedRect(x, y, x + w, y + h)
                            draw.Color(0,0,0, alpha)
                            draw.OutlinedRect(x - 1, y - 1, x + w + 1, y + h + 1)
                        end
                        ::projectile_esp_continue::
                    end
                end
            end
            if not Menu.world_tab.ignore.supplies then
                draw_world_esp("CBaseAnimating")
                draw_world_esp("CTFAmmoPack")
            end
            if not Menu.world_tab.ignore.enemy_projectiles or not Menu.world_tab.ignore.teammate_projectiles then 
                for i, projectile in ipairs(projectiles) do 
                    draw_world_esp(projectile)
                end
            end
        end


        if Menu.players_tab.active then 
            local players = entities.FindByClass( "CTFPlayer" )
            for i,p in pairs(players) do 
                if p:IsAlive() and not p:IsDormant() and distance_check(p, localPlayer) and p ~= localPlayer then 
                    local pIndex = p:GetIndex()
                    local localTeam = localPlayer:GetTeamNumber()
                    local enemyTeam = p:GetTeamNumber()
                    local espColor = nil


                    if Menu.players_tab.ignore.friends and IsFriend(pIndex, true) then
                        goto esp_continue
                    end
                    
                    if Menu.players_tab.ignore.teammates and enemyTeam == localTeam then 
                        if IsFriend(pIndex, true) and not Menu.players_tab.ignore.friends then 
                            goto friends_vip_ignore_check_bypass -- was ignoring friends when ignoring teammates
                        end
                        goto esp_continue
                    end
                    
                    if Menu.players_tab.ignore.enemies and enemyTeam ~= localTeam then 
                        goto esp_continue
                    end
                    
                    if Menu.players_tab.ignore.invisible and p:InCond(4) then 
                        if IsFriend(pIndex, true) and not Menu.players_tab.ignore.friends then 
                            goto friends_vip_ignore_check_bypass
                        end
                        goto esp_continue
                    end
                    
                    ::friends_vip_ignore_check_bypass::

                    if enemyTeam ~= localTeam then 
                        espColor = Menu.colors.enemy
                    else
                        espColor = Menu.colors.teammate
                    end
                    if playerlist.GetPriority( p ) == 10 then 
                        espColor = Menu.colors.cheater
                    elseif playerlist.GetPriority( p ) > 0 then
                        espColor = Menu.colors.priority
                    end
                    if IsFriend(pIndex, true) then 
                        espColor = Menu.colors.friend
                    end


                    local x,y,x2,y2 = Get2DBoundingBox(p)
                    if not x or not y or not x2 or not y2 then goto esp_continue end
                    local h, w = y2 - y, x2 - x

                    local alpha = math.floor(255 * (Menu.players_tab.alpha / 10))

                    local text_pos_table = {}

                    draw.Color(espColor[1], espColor[2], espColor[3],alpha)

                    if Menu.players_tab.draw.name then 
                        if Menu.players_tab.draw.selected_text_pos ~= 1 then 
                            table.insert(text_pos_table, {p:GetName(), {espColor[1], espColor[2], espColor[3],alpha} })
                        else
                            local name_width = draw.GetTextSize(p:GetName())
                            draw.Text(math.floor(x + w / 2 - (name_width / 2)), y - 15, p:GetName())
                        end
                    end

                    if Menu.players_tab.draw.box then 
                        if not Menu.players_tab.draw.box_cornered then
                            draw.OutlinedRect(x, y, x + w, y + h)
                            if Menu.players_tab.draw.box_outlined then
                                draw.Color(0,0,0,alpha)
                                draw.OutlinedRect(x - 1, y - 1, x + w + 1, y + h + 1)
                                draw.OutlinedRect(x + 1, y + 1, x + w - 1, y + h - 1)
                            end
                        else
                            draw.Line( x, y, math.min( x + 5, x2 ), y )
                            draw.Line( x, y, x, math.min( y + 5, y2 ) )
                            --
                            draw.Line( x2, y, math.max( x2 - 5, x ), y )
                            draw.Line( x2, y, x2, math.min( y + 5, y2 ) )
                            --
                            draw.Line( x, y2, math.min( x + 5, x2 ), y2 )
                            draw.Line( x, y2, x, math.max( y2 - 5, y ) )
                            --
                            draw.Line( x2, y2, math.max( x2 - 5, x ), y2 )
                            draw.Line( x2, y2, x2, math.max( y2 - 5, y ) )
                        end
                    end

                    local health = nil -- saving these cuz i use these variables in the health text color
                    local maxHealth = nil
                    local percentageHealth = nil

                    if Menu.players_tab.draw.health_bar then 
                        health = p:GetHealth()
                        maxHealth = p:GetMaxHealth()
                        percentageHealth = math.floor(health / maxHealth * 100)
                        local healthBarSize = nil
                        local maxHealthBarSize = nil

                        local health_bar_pos = nil
                        local health_bar_backround_pos = nil

                        if Menu.players_tab.draw.selected_health_bar_pos == 1 then -- left
                            healthBarSize = math.floor(h * (health / maxHealth))
                            maxHealthBarSize = math.floor(h)
                            if percentageHealth > 100 then 
                                healthBarSize = maxHealthBarSize
                            end
                            health_bar_pos = {x - (4 + Menu.players_tab.draw.bars_thickness), (y + h) - healthBarSize, x - 4, (y + h)}
                            if not Menu.players_tab.draw.bars_static_bacrkound then
                                health_bar_backround_pos = {health_bar_pos[1] - 1, health_bar_pos[2] - 1, health_bar_pos[3] + 1, health_bar_pos[4] + 1}
                            else
                                health_bar_backround_pos = {x - (5 + Menu.players_tab.draw.bars_thickness), y - 1, x - 3, (y + h) + 1}
                            end
                        end

                        if Menu.players_tab.draw.selected_health_bar_pos == 2 then -- down
                            healthBarSize = math.floor(w * (health / maxHealth))
                            maxHealthBarSize = math.floor(w)
                            if percentageHealth > 100 then 
                                healthBarSize = maxHealthBarSize
                            end
                            health_bar_pos = {x + 1, y + h + 3, x - 1 + healthBarSize, y + h + 3 + Menu.players_tab.draw.bars_thickness}

                            if not Menu.players_tab.draw.bars_static_bacrkound then
                                health_bar_backround_pos = {health_bar_pos[1] - 1, health_bar_pos[2] - 1, health_bar_pos[3] + 1, health_bar_pos[4] + 1}
                            else
                                health_bar_backround_pos = {x, y + h + 2, x + w, y + h + 4 + Menu.players_tab.draw.bars_thickness}
                            end
                        end

                        draw.Color(0,0,0,alpha)
                        draw.FilledRect(health_bar_backround_pos[1], health_bar_backround_pos[2], health_bar_backround_pos[3], health_bar_backround_pos[4]) -- backround

                        if percentageHealth < 101 then
                            draw.Color(255 - math.floor(health / maxHealth * 255), math.floor(health / maxHealth * 255), 0, alpha)
                        elseif p:InCond(5) then 
                            healthBarSize = maxHealthBarSize
                            draw.Color(Menu.colors.uber[1], Menu.colors.uber[2], Menu.colors.uber[3], alpha)
                        elseif percentageHealth > 100 then 
                            draw.Color(Menu.colors.over_heal[1],Menu.colors.over_heal[2],Menu.colors.over_heal[3], alpha)
                        end

                        draw.FilledRect(health_bar_pos[1], health_bar_pos[2], health_bar_pos[3], health_bar_pos[4]) -- healthbar
                        draw.Color(espColor[1],espColor[2],espColor[3],alpha)
                    end

                    local medigun = nil -- same story as for the health
                    local uber = nil

                    if Menu.players_tab.draw.uber_bar then 
                        if p:GetPropInt("m_iClass") == 5 then
                            medigun = p:GetEntityForLoadoutSlot( 1 )
                            uber = medigun:GetPropFloat("LocalTFWeaponMedigunData","m_flChargeLevel")
                            local percentageUber = math.floor((uber / 1) * 100)
                            local uberBarSize = math.floor(w * (uber / 1))
    
                            local uber_bar_pos = nil
                            local uber_bar_backround_pos = nil

                            if Menu.players_tab.draw.selected_uber_bar_pos == 2 then -- down
                                uber_bar_pos = {x + 1, y + h + 3, x - 1 + uberBarSize, y + h + 3 + Menu.players_tab.draw.bars_thickness}
                                if not Menu.players_tab.draw.bars_static_bacrkound then
                                    uber_bar_backround_pos = {uber_bar_pos[1] - 1, uber_bar_pos[2] - 1, uber_bar_pos[3] + 1, uber_bar_pos[4] + 1}
                                else
                                    uber_bar_backround_pos = {x, y + h + 2, x + w, y + h + 4 + Menu.players_tab.draw.bars_thickness}
                                end
                            end

                            if Menu.players_tab.draw.selected_uber_bar_pos == 1 then -- left
                                uber_bar_pos = {x - (4 + Menu.players_tab.draw.bars_thickness), (y + h) - uberBarSize, x - 4, (y + h)}
                                if not Menu.players_tab.draw.bars_static_bacrkound then
                                    uber_bar_backround_pos = {uber_bar_pos[1] - 1, uber_bar_pos[2] - 1, uber_bar_pos[3] + 1, uber_bar_pos[4] + 1}
                                else
                                    uber_bar_backround_pos = {x - (5 + Menu.players_tab.draw.bars_thickness), y - 1, x - 3, (y + h) + 1}
                                end
                            end

                            if Menu.players_tab.draw.health_bar and Menu.players_tab.draw.selected_health_bar_pos == 2 and Menu.players_tab.draw.selected_uber_bar_pos == 2 then 
                                uber_bar_pos = {uber_bar_pos[1], uber_bar_pos[2] + 4 + Menu.players_tab.draw.bars_thickness, uber_bar_pos[3], uber_bar_pos[4] + 4 + Menu.players_tab.draw.bars_thickness}
                                uber_bar_backround_pos = {uber_bar_backround_pos[1], uber_bar_backround_pos[2] + 4 + Menu.players_tab.draw.bars_thickness, uber_bar_backround_pos[3], uber_bar_backround_pos[4] + 4 + Menu.players_tab.draw.bars_thickness}
                            end

                            if Menu.players_tab.draw.health_bar and Menu.players_tab.draw.selected_health_bar_pos == 1 and Menu.players_tab.draw.selected_uber_bar_pos == 1 then 
                                uber_bar_pos = {uber_bar_pos[1] - 4 - Menu.players_tab.draw.bars_thickness, uber_bar_pos[2], uber_bar_pos[3] - 4 - Menu.players_tab.draw.bars_thickness, uber_bar_pos[4]}
                                uber_bar_backround_pos = {uber_bar_backround_pos[1] - 4 - Menu.players_tab.draw.bars_thickness, uber_bar_backround_pos[2], uber_bar_backround_pos[3] - 4 - Menu.players_tab.draw.bars_thickness, uber_bar_backround_pos[4]}
                            end

                            if percentageUber ~= 0 then
                                draw.Color(0,0,0,alpha)
                                draw.FilledRect(uber_bar_backround_pos[1], uber_bar_backround_pos[2], uber_bar_backround_pos[3], uber_bar_backround_pos[4]) -- backround 
                                draw.Color(Menu.colors.uber[1], Menu.colors.uber[2], Menu.colors.uber[3],alpha)
                                draw.FilledRect(uber_bar_pos[1], uber_bar_pos[2], uber_bar_pos[3], uber_bar_pos[4]) -- uber bar
                            end
                        end
                    end

                    draw.Color(espColor[1], espColor[2], espColor[3],alpha)

                    if Menu.players_tab.draw.tracer then 
                        local from_pos, to_pos = calculateTracerPositions(x, y, w, height)
                        draw.Line( from_pos[1], from_pos[2], to_pos[1], to_pos[2] )
                    end

                    if Menu.players_tab.draw.skeleton then 
                        local hitboxes = p:GetHitboxes()
                        for i = 1, #boneIDs do
                            local startBoneID = boneIDs[i][1]
                            local endBoneID = boneIDs[i][2]
                            local startBone = hitboxes[startBoneID]
                            local endBone = hitboxes[endBoneID]
                            local startCenter = (startBone[1] + startBone[2]) * 0.5
                            local endCenter = (endBone[1] + endBone[2]) * 0.5
                            startCenter = client.WorldToScreen(startCenter)
                            endCenter = client.WorldToScreen(endCenter)
                            if (startCenter ~= nil and endCenter ~= nil) then
                                draw.Line(startCenter[1], startCenter[2], endCenter[1], endCenter[2])
                            end
                        end
                    end

                    if Menu.players_tab.draw.conds or Menu.players_tab.draw.health or Menu.players_tab.draw.uber or Menu.players_tab.draw.class or Menu.players_tab.draw.selected_text_pos ~= 1 then -- idk the text positions dont work without ths if function
                        local y_offset = 0
                        local playerConditions = getConditions(p)
    
                        if #playerConditions > 0 then
                        local x_w_5 = x + w + 5 -- the conds start position X
                        for index, condition in ipairs(playerConditions) do
                            local drawColor = { 0, 255, 179, alpha }

                            if condition == classes[p:GetPropInt("m_iClass")] then
                                drawColor = { 255, 255, 255, alpha }
                            end
            
                            if p:GetPropInt("m_iClass") == 5 then
                                if uber == nil then
                                    medigun = p:GetEntityForLoadoutSlot(1)
                                    uber = medigun:GetPropFloat("LocalTFWeaponMedigunData", "m_flChargeLevel")
                                end
                                local UberPercentage = math.floor(uber * 100)
                
                                if condition == tostring(UberPercentage.. "%") then
                                    drawColor = { 255, 0, 255, alpha }  
                                end
                            end

                            if health == nil then
                                health = p:GetHealth()
                                maxHealth = p:GetMaxHealth()
                                percentageHealth = math.floor(health / maxHealth * 100)
                            end
                                
                            if condition == health then
                                if percentageHealth > 100 then
                                    drawColor = { 0, 255, 0, alpha } 
                                else
                                    drawColor = { 255 - math.floor(health / maxHealth * 255), math.floor(health / maxHealth * 255), 0, alpha } 
                                end
                            end

                            if Menu.players_tab.draw.selected_text_pos == 1 then
                                local width, length = draw.GetTextSize(condition)
                                draw.Color(table.unpack(drawColor)) 
                                draw.Text(x_w_5, y + y_offset, condition)
                                y_offset = y_offset + length
                            else
                                table.insert(text_pos_table, {condition, drawColor})
                            end
                        end
                    end

                    if Menu.players_tab.draw.selected_text_pos ~= 1 then 
                        local y_offset = 0
                        for i, text in ipairs(text_pos_table) do 
                            draw.Color(text[2][1],text[2][2],text[2][3],alpha)
                            local width, length = draw.GetTextSize(text[1])
                            local text_positions = {
                                [2] = {x, y - 15 - y_offset},
                                [3] = {x, y + h + 15 + y_offset},
                                [4] = {x + w + 5, y + y_offset},
                                [5] = {x - 5 - width, y + y_offset},
                                [6] = {math.floor(x + (w / 2) - (width / 2)), math.floor(y + (h / 2) + y_offset)},
                                [7] = {math.floor(x + (w / 2) - (width / 2)), y + h + 10 + y_offset},
                                [8] = {math.floor(x + (w / 2) - (width / 2)), y - 15 - y_offset}
                            }
                            local text_position = text_positions[Menu.players_tab.draw.selected_text_pos]
                            draw.Text(text_position[1], text_position[2], text[1])
                            y_offset = y_offset + length
                        end
                    end
                end
                ::esp_continue::
                end
            end 
        end

        if Menu.buildings_tab.active then 
            local function draw_building_esp(entity_name) 
                local buildings = entities.FindByClass( entity_name )
                for i,b in pairs(buildings) do 
                    if not b:IsDormant() and distance_check(b, localPlayer) then
                        local localTeam = localPlayer:GetTeamNumber()
                        local enemyTeam = b:GetTeamNumber()
    
    
                        if Menu.buildings_tab.ignore.enemies and enemyTeam ~= localTeam then -- ignoring
                            goto buildings_continue
                        end
                        if Menu.buildings_tab.ignore.teammates and enemyTeam == localTeam then 
                            goto buildings_continue
                        end

                        local name
                        
                        local x,y,x2,y2 = Get2DBoundingBox(b)
                        if not x or not y or not x2 or not y2 then goto buildings_continue end
                        local h, w = y2 - y, x2 - x

                        local alpha = math.floor(255 * (Menu.buildings_tab.alpha / 10))

                        local colorBuildings = nil
                        if enemyTeam ~= localTeam then
                            colorBuildings = Menu.colors.enemy
                        end
                        if enemyTeam == localTeam then
                            colorBuildings = Menu.colors.teammate
                        end
                            
                        draw.Color(colorBuildings[1], colorBuildings[2], colorBuildings[3],alpha)

                        if Menu.buildings_tab.draw.box then 
                            draw.OutlinedRect(x, y, x + w, y + h)
                            draw.Color(0,0,0, alpha)
                            draw.OutlinedRect(x - 1, y - 1, x + w + 1, y + h + 1)
                        end
                        if Menu.buildings_tab.draw.name then  
                            name = building_names[b:GetClass()]
                            draw.Color(colorBuildings[1], colorBuildings[2], colorBuildings[3],alpha)
                            local width , height = draw.GetTextSize( name )
                            draw.Text( math.floor(x + w / 2 - (width / 2)), y - height, name )
                        end
                        if Menu.buildings_tab.draw.tracer then 
                            draw.Color(colorBuildings[1], colorBuildings[2], colorBuildings[3],alpha)
                            local from_pos, to_pos = calculateTracerPositions(x, y, w, height)
                            draw.Line( from_pos[1], from_pos[2], to_pos[1], to_pos[2] )
                        end
                        if Menu.buildings_tab.draw.health_bar then 
                            local health = b:GetHealth()
                            local maxHealth = b:GetMaxHealth()
                            local percentageHealth = math.floor(health / maxHealth * 100)
                            local healthBarSize = math.floor(h * (health / maxHealth))
                            local maxHealthBarSize = math.floor(h)

                            if percentageHealth > 100 then 
                                healthBarSize = maxHealthBarSize
                            end

                            draw.Color(0,0,0,alpha)
                            draw.FilledRect(x - 7, (y + h) - healthBarSize - 1, x - 3, (y + h) + 1 ) -- backround

                            if percentageHealth < 101 then
                                draw.Color(255 - math.floor(health / maxHealth * 255), math.floor(health / maxHealth * 255), 0, alpha)
                            elseif p:InCond(5) then 
                                healthBarSize = maxHealthBarSize
                                draw.Color(Menu.colors.uber[1], Menu.colors.uber[2], Menu.colors.uber[3], alpha)
                            elseif percentageHealth > 100 then 
                                draw.Color(Menu.colors.over_heal[1],Menu.colors.over_heal[2],Menu.colors.over_heal[3], alpha)
                            end
                            draw.FilledRect(x - 6, (y + h) - healthBarSize, x - 4, (y + h) ) -- healthbar
                            draw.Color(colorBuildings[1], colorBuildings[2], colorBuildings[3],alpha)
                        end
                        if Menu.buildings_tab.draw.level_bar then 
                            local level = b:GetPropInt("m_iUpgradeLevel")
                            local maxLevel = 3
                            local percentageLevel = math.floor(level / maxLevel * 100)
                            local levelBarSize = math.floor(w * (level / maxLevel))
                            draw.Color(0,0,0,alpha)
                            draw.FilledRect(x, y + h + 2, x - 1 + levelBarSize + 1, y + h + 6)
                            draw.Color(200, 200, 200,alpha)
                            draw.FilledRect(x + 1, y + h + 3, x - 1 + levelBarSize, y + h + 5)
                        end
                        if Menu.buildings_tab.draw.conds or Menu.buildings_tab.draw.health or Menu.buildings_tab.draw.level then 
                            local y_offset = 0
                            local buildingConditions = building_conds(b)
    
                            if #buildingConditions > 0 then
                                local x_w_5 = x + w + 5
                                for index, condition in ipairs(buildingConditions) do
                                    local drawColor = { 0, 255, 179, alpha }

                                    local level = b:GetPropInt("m_iUpgradeLevel")
                
                                    if condition == level then
                                        drawColor = { 255, 255, 255, alpha }  
                                    end
                                

                                    local health = b:GetHealth()
                                    local maxHealth = b:GetMaxHealth()
                                    local percentageHealth = math.floor(health / maxHealth * 100)
                                
                                    if condition == health then
                                        if percentageHealth > 100 then
                                            drawColor = { 0, 255, 0, alpha } 
                                        else
                                            drawColor = { 255 - math.floor(health / maxHealth * 255), math.floor(health / maxHealth * 255), 0, alpha } 
                                        end
                                    end
            
                                    local width, length = draw.GetTextSize(condition)
                                    draw.Color(table.unpack(drawColor)) 
                                    draw.Text(x_w_5, y + y_offset, condition)
                                    y_offset = y_offset + length
                                end
                            end
                        end
                        if Menu.buildings_tab.draw.sentry_range and b:GetClass() == "CObjectSentrygun" then 
                            draw.Color(colorBuildings[1], colorBuildings[2], colorBuildings[3],alpha)
                            draw_circle(b:GetAbsOrigin(),Menu.buildings_tab.draw.sentry_range_segments,1100)
                        end
                        ::buildings_continue::
                    end
                end
            end
            draw_building_esp("CObjectSentrygun")
            draw_building_esp("CObjectDispenser")
            draw_building_esp("CObjectTeleporter")
        end

    end

end)

callbacks.Register( "Unload", function() 
    local entities = entities.FindByClass( "CBaseAnimating" )
    for i, entity in pairs(entities) do 
        entity:SetPropFloat( 1, "m_flPlaybackRate" )
    end
end)
