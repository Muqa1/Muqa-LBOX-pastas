--[[
this file may contain a lot of pasted functions but this is just an archive for some functions that i think are useful/cool
]]

local function IsWallstuck()
    local flags = entities.GetLocalPlayer():GetPropInt( "m_fFlags" )

    if flags & FL_ONGROUND == 0 and entities.GetLocalPlayer():EstimateAbsVelocity():Length() == 6 then
        return true
    else
        return false
    end
end
----------------
local function Center(string)
    local screen_witdh , screen_height = draw.GetScreenSize()
    local text_x, text_y = draw.GetTextSize(string)
    return math.floor((screen_witdh / 2) - (text_x / 2))
end
-----------------
local function WalkTo(userCmd, localPlayer, destination) -- yeeted from lnx lib

    local function ComputeMove(userCmd, a, b)
        local diff = (b - a)
        if diff:Length() == 0 then return Vector3(0, 0, 0) end
    
        local x = diff.x
        local y = diff.y
        local vSilent = Vector3(x, y, 0)
    
        local ang = vSilent:Angles()
        local cPitch, cYaw, cRoll = userCmd:GetViewAngles()
        local yaw = math.rad(ang.y - cYaw)
        local pitch = math.rad(ang.x - cPitch)
        local move = Vector3(math.cos(yaw) * 450, -math.sin(yaw) * 450, -math.cos(pitch) * 450)
    
        return move
    end
    
    local localPos = localPlayer:GetAbsOrigin()
    local result = ComputeMove(userCmd, localPos, destination)

    userCmd:SetForwardMove(result.x)
    userCmd:SetSideMove(result.y)
end
----------------------
local function Draw3DBox(size, pos)
    local halfSize = size / 2
    local corners = {
        Vector3(-halfSize, -halfSize, -halfSize),
        Vector3(halfSize, -halfSize, -halfSize),
        Vector3(halfSize, halfSize, -halfSize),
        Vector3(-halfSize, halfSize, -halfSize),
        Vector3(-halfSize, -halfSize, halfSize),
        Vector3(halfSize, -halfSize, halfSize),
        Vector3(halfSize, halfSize, halfSize),
        Vector3(-halfSize, halfSize, halfSize)
    }

    local screenPositions = {}
    for _, cornerPos in ipairs(corners) do
        local worldPos = pos + cornerPos
        local screenPos = client.WorldToScreen(worldPos)
        if screenPos then
            table.insert(screenPositions, { x = screenPos[1], y = screenPos[2] })
        end
    end

    local linesToDraw = {
        {1, 2}, {2, 3}, {3, 4}, {4, 1},
        {5, 6}, {6, 7}, {7, 8}, {8, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }

    for _, line in ipairs(linesToDraw) do
        local p1, p2 = screenPositions[line[1]], screenPositions[line[2]]
        if p1 and p2 then
            draw.Line(p1.x, p1.y, p2.x, p2.y)
        end
    end

    -- for i, cornerPos in ipairs(screenPositions) do
    --     draw.Text(cornerPos.x, cornerPos.y, tostring(i))
    -- end
end
----------------
local lastToggleTime = 0
local function toggleFeature(feature) -- for toggling features
    local currentTime = globals.RealTime()
    if currentTime - lastToggleTime >= 0.1 then -- Add a 0.1 second cooldown period
        if gui.GetValue(feature) == 0 then
            gui.SetValue(feature, 1)
        elseif gui.GetValue(feature) == 1 then
            gui.SetValue(feature, 0)
        end
        lastToggleTime = currentTime
    end
end
---------------
local function RGBRainbow(frequency) -- rainbow 

    local curtime = globals.CurTime() 
    local r,g,b
    r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
    g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
    b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)
    
    return r, g, b
end
-------------------
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
----------------
local function draw_sphere(center, segments, radius)
    draw.Color( 255, 255, 255, 255 )
    local vertexBuffer = {}

    for i = 0, segments do
        local theta = math.pi * i / segments
        local sinTheta = math.sin(theta)
        local cosTheta = math.cos(theta)

        for j = 0, segments do
            local phi = 2 * math.pi * j / segments
            local sinPhi = math.sin(phi)
            local cosPhi = math.cos(phi)

            local x = center.x + radius * sinTheta * cosPhi
            local y = center.y + radius * sinTheta * sinPhi
            local z = center.z + radius * cosTheta

            vertexBuffer[#vertexBuffer + 1] = client.WorldToScreen(Vector3(x, y, z))
        end
    end

    for i = 0, segments - 1 do
        for j = 0, segments - 1 do
            local baseIndex = i * (segments + 1) + j + 1
            local nextIndex = baseIndex + 1
            local nextRowIndex = baseIndex + segments + 1

            local vertex1, vertex2, vertex3, vertex4 =
                vertexBuffer[baseIndex],
                vertexBuffer[nextIndex],
                vertexBuffer[nextRowIndex],
                vertexBuffer[nextRowIndex + 1]

            if vertex1 and vertex2 then
                draw.Line(vertex1[1], vertex1[2], vertex2[1], vertex2[2])
            end
            if vertex1 and vertex3 then
                draw.Line(vertex1[1], vertex1[2], vertex3[1], vertex3[2])
            end
            if vertex2 and vertex4 then
                draw.Line(vertex2[1], vertex2[2], vertex4[1], vertex4[2])
            end
        end
    end
end


local function draw_sphere(center, segments, radius) -- fixes weird lines but fucks fps
    draw.Color(255, 255, 255, 255)

    for i = 0, segments do
        local theta1 = math.pi * (i / segments)
        local theta2 = math.pi * ((i + 1) / segments)

        for j = 0, segments do
            local phi1 = 2 * math.pi * (j / segments)
            local phi2 = 2 * math.pi * ((j + 1) / segments)

            local vertex1 = center + Vector3(
                radius * math.sin(theta1) * math.cos(phi1),
                radius * math.sin(theta1) * math.sin(phi1),
                radius * math.cos(theta1)
            )
            local vertex2 = center + Vector3(
                radius * math.sin(theta1) * math.cos(phi2),
                radius * math.sin(theta1) * math.sin(phi2),
                radius * math.cos(theta1)
            )
            local vertex3 = center + Vector3(
                radius * math.sin(theta2) * math.cos(phi1),
                radius * math.sin(theta2) * math.sin(phi1),
                radius * math.cos(theta2)
            )

            local screen1 = client.WorldToScreen(vertex1)
            local screen2 = client.WorldToScreen(vertex2)
            local screen3 = client.WorldToScreen(vertex3)

            if screen1 and screen2 and screen3 then
                draw.Line(screen1[1], screen1[2], screen2[1], screen2[2])
                draw.Line(screen3[1], screen3[2], screen1[1], screen1[2])
            end
        end
    end
end
------------------------
local function L_line(start_pos, end_pos, secondary_line_size)
    if start_pos == nil or end_pos == nil then
        return
    end
    local direction = end_pos - start_pos
    local direction_length = direction:Length()
    if direction_length == 0 then
        return
    end
    local normalized_direction = direction / direction_length
    local perpendicular = Vector3(normalized_direction.y, -normalized_direction.x, 0) * secondary_line_size
    local w2s_start_pos = client.WorldToScreen(start_pos)
    local w2s_end_pos = client.WorldToScreen(end_pos)
    if w2s_start_pos == nil or w2s_end_pos == nil then
        return
    end
    draw.Line(w2s_start_pos[1], w2s_start_pos[2], w2s_end_pos[1], w2s_end_pos[2])
    local secondary_line_end_pos = start_pos + perpendicular
    local w2s_secondary_line_end_pos = client.WorldToScreen(secondary_line_end_pos)
    if w2s_secondary_line_end_pos ~= nil then
        local w2s_secondary_line_start_pos = w2s_start_pos
        draw.Line(w2s_secondary_line_start_pos[1], w2s_secondary_line_start_pos[2], w2s_secondary_line_end_pos[1], w2s_secondary_line_end_pos[2])
    end
end
-------------------
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
--------------------- 
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

-- CreateCFG("SEOwnedDE_lua_config", Menu)
-- Menu_config = LoadCFG("SEOwnedDE_lua_config")

------------------------
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

-- engine.SetViewAngles(PositionAngles(lPlayer:GetAbsOrigin() + lPlayer:GetPropVector( "localdata", "m_vecViewOffset[0]" ), p:GetAbsOrigin())) -- looks at their feet

----------------------------------
local function IsOnScreen(entity)
    local w2s = client.WorldToScreen(entity:GetAbsOrigin())
    if w2s ~= nil then
        if w2s[1] ~= nil and w2s[2] ~= nil then 
            return true 
        end
    end
    return false
end
