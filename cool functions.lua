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
    if not (start_pos and end_pos) then
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
    if not (w2s_start_pos and w2s_end_pos) then
        return
    end
    local secondary_line_end_pos = start_pos + perpendicular
    local w2s_secondary_line_end_pos = client.WorldToScreen(secondary_line_end_pos)
    if w2s_secondary_line_end_pos then
        draw.Line(w2s_start_pos[1], w2s_start_pos[2], w2s_end_pos[1], w2s_end_pos[2])
        draw.Line(w2s_start_pos[1], w2s_start_pos[2], w2s_secondary_line_end_pos[1], w2s_secondary_line_end_pos[2])
    end
end
-------------------
local function IsVisible(startPos, endPos) -- for positions
    local trace = engine.TraceLine( startPos, endPos, 100679691 )
    if trace.endpos == endPos then
        return true
    end
    return false
end

local function IsVisible(localPlayer, player) -- for players
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
--------------------------------
local function GetHitboxPos(player, hitboxID)
    local hitbox = player:GetHitboxes()[hitboxID]
    if not hitbox then return nil end

    return (hitbox[1] + hitbox[2]) * 0.5
end
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
-------------------------- 
local function Get2DBoundingBox(entity)
    local hitbox = entity:EntitySpaceHitboxSurroundingBox()
    local min = entity:GetAbsOrigin() + Vector3(hitbox[1].x, hitbox[1].y, hitbox[1].z)
    local max = entity:GetAbsOrigin() + Vector3(hitbox[2].x, hitbox[2].y, hitbox[2].z)
    local corners = {
        Vector3(min.x, min.y, min.z),
        Vector3(min.x, max.y, min.z),
        Vector3(max.x, max.y, min.z),
        Vector3(max.x, min.y, min.z),
        Vector3(max.x, max.y, max.z),
        Vector3(min.x, max.y, max.z),
        Vector3(min.x, min.y, max.z),
        Vector3(max.x, min.y, max.z)
    }
    local minX, minY, maxX, maxY = ScrW * 2, ScrH * 2, 0, 0
    for _, corner in pairs( corners ) do
        local onScreen = client.WorldToScreen( corner )
        if onScreen ~= nil then
            minX, minY = math.min( minX, onScreen[1] ), math.min( minY, onScreen[2] )
            maxX, maxY = math.max( maxX, onScreen[1] ), math.max( maxY, onScreen[2] )
        end
    end
    return minX, minY, maxX, maxY
end
-------------------- 
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
-------------------------- 
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
--------------------------- 
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
------------------------------- 
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
------------------------- 
local function antiaimCross(localplayer_pos, aa_angle, size)
    local vwA = engine.GetViewAngles()
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
            if d1 ~= nil and d2 ~= nil then
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
-------------------------------------
local function antiaimArrow(localplayer_pos, aa_angle, range)
    local vwA = engine.GetViewAngles()
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
------------------------------------
local function DrawCircle(centerX, centerY, radius, numSegments)
    local texture = draw.CreateTextureRGBA(string.char(0xff, 0xff, 0xff, 255, 0xff, 0xff, 0xff, 255, 0xff, 0xff, 0xff, 255, 0xff, 0xff, 0xff, 255), 2, 2)
    local vertices = {}
    local angleIncrement = 2 * math.pi / numSegments
    for i = 1, numSegments do
        local angle = i * angleIncrement
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)
        local u = (x - centerX) / (2 * radius) + 0.5
        local v = (y - centerY) / (2 * radius) + 0.5
        table.insert(vertices, {x, y, u, v})
    end
    local u = (vertices[1][1] - centerX) / (2 * radius) + 0.5
    local v = (vertices[1][2] - centerY) / (2 * radius) + 0.5
    table.insert(vertices, {vertices[1][1], vertices[1][2], u, v})
    draw.TexturedPolygon(texture, vertices, true)
end
--------------------------------------
local function RoundBox(x, y, w, h, radius)
    local texture = draw.CreateTextureRGBA(string.char(0xff, 0xff, 0xff, 255, 0xff, 0xff, 0xff, 255, 0xff, 0xff, 0xff, 255, 0xff, 0xff, 0xff, 255), 2, 2)
    local round = {}
    for i = 0, 3 do
        local _x = x + ((i < 2) and (w - radius) or radius)
        local _y = y + ((i % 3 == 0) and radius or (h - radius))
        local a = 90 * i
        for j = 0, 15 do
            local _a = math.rad(a + j * 6)
            local vertex_x = _x + radius * math.sin(_a)
            local vertex_y = _y - radius * math.cos(_a)
            table.insert(round, {vertex_x, vertex_y, 0.5, 0.5})
        end
    end
    draw.TexturedPolygon(texture, round, true)
end
------------------------------------
