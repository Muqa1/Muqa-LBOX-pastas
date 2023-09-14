local projectile_class_names = {
    [1] = "CTFProjectile_Rocket",
    [2] = "CTFGrenadePipebombProjectile",
    [3] = "CTFProjectile_SentryRocket",
    [4] = "CTFProjectile_Flare",
}

local function IsProjectileClose(lPlayer, projectile, min_distance)
    local p_dist = vector.Distance(lPlayer:GetAbsOrigin(), projectile:GetAbsOrigin())
    return p_dist < min_distance
end

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

local function IsVisible(startPos, endPos) -- for positions
    local trace = engine.TraceLine(startPos, endPos, 100679691)
    return trace.endpos == endPos
end

local startTick = nil

local function aDeadringer(cmd)
    local lPlayer = entities.GetLocalPlayer()
    local ping = entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[lPlayer:GetIndex() + 1]
    
    if lPlayer == nil then return end
    
    local shouldAttack2 = false -- Flag to determine if Attack2 should be pressed
    
    for i = 1, #projectile_class_names do -- projectiles
        local projectiles = entities.FindByClass(projectile_class_names[i])
        
        for _, p in pairs(projectiles) do 
            if p:GetTeamNumber() ~= lPlayer:GetTeamNumber() and not p:IsDormant() and IsProjectileClose(lPlayer, p, 250) then 
                local pred = p:GetAbsOrigin() + p:EstimateAbsVelocity() * (ping * 0.0005)
                
                if IsVisible(lPlayer:GetAbsOrigin() + Vector3(0, 0, 75), pred) then
                    local angles = PositionAngles(lPlayer:GetAbsOrigin() + Vector3(0, 0, 75), p:GetAbsOrigin())
                    
                    if not startTick then 
                        startTick = globals.TickCount()
                    end
                    
                    --engine.SetViewAngles(angles)
                    cmd:SetViewAngles(angles:Unpack())
                    
                    -- Check if enough ticks have passed before pressing Attack2
                    if globals.TickCount() > startTick then
                        shouldAttack2 = true
                    end
                else
                    startTick = nil
                end
            else
                startTick = nil
            end
        end
    end
    
    if shouldAttack2 then
        cmd:SetButtons(cmd.buttons | IN_ATTACK2)
    end
end

callbacks.Unregister("CreateMove", "aDeadringer")
callbacks.Register("CreateMove", "aDeadringer", aDeadringer)
