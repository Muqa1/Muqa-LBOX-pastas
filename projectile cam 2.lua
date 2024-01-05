local camera_x_position = 5 -- edit these value to your liking
local camera_y_position = 300
local camera_width = 500
local camera_height = 300
----------------------------------
local projectilesTable = {}
local latestPos = nil
local latestProjAngles = nil
local originalPos = nil

local function PositionAngles(source, dest) -- straight from lnxLib, credits to him
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

local function LatestProj(cmd)
    local localPlayer = entities.GetLocalPlayer()
    if localPlayer == nil then return end
    local projectiles = entities.FindByClass("CTFGrenadePipebombProjectile")
    local hasLocalProjectiles = false
    for _, p in pairs(projectiles) do
        if not p:IsDormant() then
            local pos = p:GetAbsOrigin()
            local thrower = p:GetPropEntity("m_hThrower")
            if thrower and thrower == localPlayer and p:GetPropInt("m_iType") == 1 then
                hasLocalProjectiles = true
                local alreadyAdded = false
                for _, v in pairs(projectilesTable) do
                    if v[1] == p then
                        alreadyAdded = true
                        break
                    end
                end
                if not alreadyAdded then
                    local tick = globals.TickCount()
                    table.insert(projectilesTable, {p, tick})
                end
            end
        end
    end
    if not hasLocalProjectiles then
        projectilesTable = {}
    end
    local latestProj = nil
    local closestTick = math.huge
    for _, v in pairs(projectilesTable) do 
        local curTick = globals.TickCount()
        local tickDifference = curTick - v[2]
        
        if tickDifference < closestTick then
            closestTick = tickDifference
            latestProj = v[1]
        end
    end
    if latestProj then
        local predictedPos = latestProj:GetAbsOrigin() + latestProj:EstimateAbsVelocity()
        latestPos = latestProj:GetAbsOrigin() - (latestProj:EstimateAbsVelocity()*0.05); latestPos = latestPos + Vector3(0,0,5)
        latestProjAngles = PositionAngles(latestPos, predictedPos)
    else
        latestPos = nil
        latestProjAngles = nil
    end
end
callbacks.Register("CreateMove","ProjCamProj", LatestProj)

local cameraTexture = materials.CreateTextureRenderTarget( "camTexture", camera_width, camera_height )
local cameraMaterial = materials.Create( "camTexture", [[
    UnlitGeneric
    {
        $basetexture    "camTexture"
    }
]] )

callbacks.Register("PostRenderView", function(view)
    local localPlayer = entities.GetLocalPlayer()
    if localPlayer == nil then return end
    if latestPos and latestProjAngles and latestProjAngles.x < 90 and #projectilesTable ~= 0 then
        customView = view
        customView.origin = latestPos
        customView.angles = latestProjAngles
        render.Push3DView( customView, E_ClearFlags.VIEW_CLEAR_COLOR | E_ClearFlags.VIEW_CLEAR_DEPTH, cameraTexture )
        render.ViewDrawScene( true, true, customView )
        render.PopView()
        render.DrawScreenSpaceRectangle( cameraMaterial, camera_x_position, camera_y_position, camera_width, camera_height, 0, 0, camera_width, camera_height, camera_width, camera_height )
    else
        latestPos = nil
        latestProjAngles = nil
    end
end)
local font = draw.CreateFont( "Tahoma", 12, 800, FONTFLAG_OUTLINE )
callbacks.Register( "Draw", function() 
    if latestPos and latestProjAngles and latestProjAngles.x < 90 and #projectilesTable ~= 0 then
        draw.Color( 235, 64, 52, 255 )
        draw.OutlinedRect( camera_x_position, camera_y_position, camera_x_position + camera_width, camera_y_position + camera_height )
        draw.OutlinedRect( camera_x_position, camera_y_position - 20, camera_x_position + camera_width, camera_y_position )
        draw.Color( 130, 26, 17, 255 )
        draw.FilledRect( camera_x_position+1, camera_y_position - 19, camera_x_position + camera_width-1, camera_y_position-1 )
        draw.SetFont( font ); draw.Color(255,255,255,255)
        local w, h = draw.GetTextSize( "sticky camera" )
        draw.Text(camera_x_position + camera_width * 0.5 - (w*0.5), camera_y_position - 16, "sticky camera")
    end
end)
