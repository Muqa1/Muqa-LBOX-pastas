local key = KEY_F

--------------------------
local projectilesTable = {}
local latestPos = nil
local originalPos = nil
local TurnMovementOff = false
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
        latestPos = latestProj:GetAbsOrigin() - Vector3(0,0,50)
    else
        latestPos = nil
    end
    if TurnMovementOff then 
        cmd:SetButtons(cmd.buttons & (~IN_ATTACK))
        cmd:SetForwardMove(0)
        cmd:SetSideMove(0)
        cmd:SetUpMove(0)
    end
end
local function PropUpdate()
    local localPlayer = entities.GetLocalPlayer()
    if localPlayer == nil then return end
    if input.IsButtonDown(key) then
        if not originalPos and #projectilesTable ~= 0 then
            originalPos = localPlayer:GetAbsOrigin()
            client.Command( "r_drawviewmodel 0", 1 )
            TurnMovementOff = true
        end
        if latestPos and #projectilesTable ~= 0 then
            localPlayer:SetPropVector(latestPos, "tfnonlocaldata", "m_vecOrigin")
        end
        if gui.GetValue( "Thirdperson") then 
            gui.SetValue( "Thirdperson", 0 )
        end
    elseif originalPos then
        localPlayer:SetPropVector(originalPos, "tfnonlocaldata", "m_vecOrigin")
        originalPos = nil
        client.Command( "r_drawviewmodel 1", 1 )
        TurnMovementOff = false
    end
end
callbacks.Register("CreateMove","ProjCamProj", LatestProj)
callbacks.Register("PostPropUpdate","ProjCamProp", PropUpdate)
