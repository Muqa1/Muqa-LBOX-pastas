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
local function GetHitboxPos(player, hitboxID)
    local hitbox = player:GetHitboxes()[hitboxID]
    if not hitbox then return nil end

    return (hitbox[1] + hitbox[2]) * 0.5
end
callbacks.Register( "CreateMove", function(cmd) 
    local lPlayer = entities.GetLocalPlayer()
    local weapon = lPlayer:GetPropEntity( "m_hActiveWeapon" )
    local players = entities.FindByClass( "CTFPlayer" )
    for i, p in pairs(players) do 
        if p:IsAlive() and not p:IsDormant() and p:GetTeamNumber() ~= lPlayer:GetTeamNumber() then
            if vector.Distance( lPlayer:GetAbsOrigin(), p:GetAbsOrigin() ) < 105 then 
                local ang = PositionAngles( lPlayer:GetAbsOrigin() + lPlayer:GetPropVector("localdata", "m_vecViewOffset[0]") , GetHitboxPos(p,4) )
                --engine.SetViewAngles( ang )
                cmd:SetViewAngles( ang:Unpack() )
            end
        end
    end 
    if weapon == lPlayer:GetEntityForLoadoutSlot( 2 ) then
        if weapon:GetPropInt("m_bReadyToBackstab") == 257 then 
            cmd:SetButtons( cmd.buttons | IN_ATTACK)
        end
    end
end)
