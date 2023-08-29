local key = KEY_F

--------------------------
local projectilesTable = {} -- Table to store projectile information
local latestPos = nil
local originalPos = nil
function findClosestNumber(target, numbers)
    local closestNumber = numbers[1]
    local closestDifference = math.abs(target - closestNumber)
    for _, number in ipairs(numbers) do
        local difference = math.abs(target - number)
        if difference < closestDifference then
            closestNumber = number
            closestDifference = difference
        end
    end
    return closestNumber
end
callbacks.Register("CreateMove", function()
    local localPlayer = entities.GetLocalPlayer()
    if localPlayer == nil then
        return 
    end
    local projectiles = entities.FindByClass("CTFGrenadePipebombProjectile")
    local hasLocalProjectiles = false
    for _, p in pairs(projectiles) do
        if not p:IsDormant() then
            local pos = p:GetAbsOrigin()
            local w2s_pos = client.WorldToScreen(pos)
            if w2s_pos ~= nil then
                local launcher = p:GetPropEntity("m_hLauncher")
                if launcher:GetPropEntity("m_hOwnerEntity") == localPlayer then
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
        latestPos = latestProj:GetAbsOrigin() - Vector3(0,0,40)
    end
end)
callbacks.Register("PostPropUpdate", function()
    local localPlayer = entities.GetLocalPlayer()
    if input.IsButtonDown(key) then
        if not originalPos then
            originalPos = localPlayer:GetAbsOrigin()
        end
        if latestPos and #projectilesTable ~= 0 then
            localPlayer:SetPropVector(latestPos, "tfnonlocaldata", "m_vecOrigin")
        end
    elseif originalPos then
        localPlayer:SetPropVector(originalPos, "tfnonlocaldata", "m_vecOrigin")
        originalPos = nil
    end
end)
