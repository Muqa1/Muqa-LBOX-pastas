--[[
    author: Muqa 
    credits to LNX for helping me figure out how to set the color for the fog
]]

local settings = {
    
    tabs = {
        fog = true,
        cfg = false,
    },

    enabled = true,
    density = 35,

    color_r = 136,
    color_g = 142,
    color_b = 172,

    fogStart = -7000, 
    fogEnd = 15000,
    farz = 0,
}
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

callbacks.Register( "Draw", function() 
    local fC = entities.FindByClass( "CFogController" )
    for _, f in pairs(fC) do
        if settings.enabled then 
            f:SetPropInt(1, "m_fog.enable")
        else
            f:SetPropInt(0, "m_fog.enable")
        end
        f:SetPropFloat(settings.density / 100, "m_fog.maxdensity")
        local rgb = (settings.color_r) | (settings.color_g << 8) | settings.color_b << 16
        f:SetPropInt(rgb , "m_fog.colorPrimary")
        f:SetPropFloat(settings.fogStart, "m_fog.start")
        f:SetPropFloat(settings.fogEnd, "m_fog.end")
        f:SetPropFloat(settings.farz, "m_fog.farz")
    end

    if input.IsButtonPressed( KEY_END ) or input.IsButtonPressed( KEY_INSERT ) or input.IsButtonPressed( KEY_F11 ) then 
        toggleMenu()
    end

    if Lbox_Menu_Open then 
        ImMenu.Begin("Fog Modulation", true)

        ImMenu.BeginFrame(1)

        if ImMenu.Button("Fog") then 
            settings.tabs.fog = true
            settings.tabs.cfg = false
        end
        if ImMenu.Button("Config") then 
            settings.tabs.fog = false
            settings.tabs.cfg = true
        end

        ImMenu.EndFrame()

        if settings.tabs.fog then

            ImMenu.BeginFrame(1)
            settings.enabled = ImMenu.Checkbox("Enable", settings.enabled)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.density = ImMenu.Slider("Fog Density", settings.density , 0, 100)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.color_r = ImMenu.Slider("Color R", settings.color_r , 0, 255)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.color_g = ImMenu.Slider("Color G", settings.color_g , 0, 255)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.color_b = ImMenu.Slider("Color B", settings.color_b , 0, 255)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.fogStart = ImMenu.Slider("Fog Start", settings.fogStart , -10000, 30000)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.fogEnd = ImMenu.Slider("Fog End", settings.fogEnd , -10000, 30000)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            settings.farz = ImMenu.Slider("Farz", settings.farz , 0, 5000)
            ImMenu.EndFrame()

        end
        if settings.tabs.cfg then 

            ImMenu.BeginFrame(1)

            if ImMenu.Button("Create/Save CFG") then
                CreateCFG( [[Fog modulation lua]] , settings )
            end

            if ImMenu.Button("Load CFG") then
                settings = LoadCFG( [[Fog modulation lua]] )
            end

            ImMenu.EndFrame()

            ImMenu.BeginFrame(1)
            ImMenu.Text("Dont load a config if you havent saved one.")
            ImMenu.EndFrame()

        end
        ImMenu.End()
    end
end)
