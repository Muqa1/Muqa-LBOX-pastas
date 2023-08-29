local hitbox_id = 3 -- hitbox ids https://imgur.com/hzU3K27
local max_records = 1 -- max amount of tracers on screen
local disappear_time = 3 -- in how many seconds do you want the tracer to disappear

local tracer = true 
local hitbox_surrounding_box = true


-------------------------------
local hitPos = {}
local function PlayerHurtEvent(event)
    if (event:GetName() == 'player_hurt' ) then
        local localPlayer = entities.GetLocalPlayer();
        local victim = entities.GetByUserID(event:GetInt("userid"))
        local attacker = entities.GetByUserID(event:GetInt("attacker"))
        if (attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex()) then
            return
        end
        local startPos = localPlayer:GetAbsOrigin() + localPlayer:GetPropVector( "localdata", "m_vecViewOffset[0]" )
        local hitbox = victim:GetHitboxes()[hitbox_id]
        local endPos = (hitbox[1] + hitbox[2]) / 2
        local box = victim:HitboxSurroundingBox()
        table.insert(hitPos, 1, {startPos, endPos, box, globals.RealTime()})
    end
    if #hitPos > max_records then 
        table.remove(hitPos)
    end
end
callbacks.Register("FireGameEvent", "PlayerHurtEvent", PlayerHurtEvent)
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
end
local function PlayerHurtEventDraw()
    local currentTime = globals.RealTime()
    for i,v in pairs(hitPos) do 
        if currentTime - v[4] > disappear_time then
            table.remove(hitPos, i)
        else
            draw.Color( 255,255,255,255 )
            if tracer == true then 
                local startPos = v[1]
                local endPos = v[2]
                local w2s_startPos = client.WorldToScreen( startPos )
                local w2s_endPos = client.WorldToScreen( endPos )
                Draw3DBox(10, endPos)
                if w2s_startPos ~= nil and w2s_endPos ~= nil then 
                    draw.Line( w2s_startPos[1], w2s_startPos[2], w2s_endPos[1], w2s_endPos[2] )
                end
            end
            if hitbox_surrounding_box == true then 
                local hitboxes = v[3]
                local min = hitboxes[1]
                local max = hitboxes[2]
                local vertices = {
                    Vector3(min.x, min.y, min.z),
                    Vector3(min.x, max.y, min.z),
                    Vector3(max.x, max.y, min.z),
                    Vector3(max.x, min.y, min.z),
                    Vector3(min.x, min.y, max.z),
                    Vector3(min.x, max.y, max.z),
                    Vector3(max.x, max.y, max.z),
                    Vector3(max.x, min.y, max.z)
                }
                local screenVertices = {}
                for j, vertex in ipairs(vertices) do
                    local screenPos = client.WorldToScreen(vertex)
                    if screenPos ~= nil then
                        screenVertices[j] = {x = screenPos[1], y = screenPos[2]}
                    end
                end
                for j = 1, 4 do
                    local vertex1 = screenVertices[j]
                    local vertex2 = screenVertices[j % 4 + 1]
                    local vertex3 = screenVertices[j + 4]
                    local vertex4 = screenVertices[(j + 4) % 4 + 5]
                    if vertex1 ~= nil and vertex2 ~= nil and vertex3 ~= nil and vertex4 ~= nil then
                        draw.Line(vertex1.x, vertex1.y, vertex2.x, vertex2.y)
                        draw.Line(vertex3.x, vertex3.y, vertex4.x, vertex4.y)
                    end
                end
                for j = 1, 4 do
                    local vertex1 = screenVertices[j]
                    local vertex2 = screenVertices[j + 4]
                    if vertex1 ~= nil and vertex2 ~= nil then
                        draw.Line(vertex1.x, vertex1.y, vertex2.x, vertex2.y)
                    end
                end           
            end
        end
    end
end
callbacks.Register( "Draw", "PlayerHurtEventDraw", PlayerHurtEventDraw )
