local dist = 200 -- how close the projectile needs to be for deadringer to be pulled out (hammer units)
local health = 0.3 -- how low you need to be while bleeding or burning for deadringer to be pulled out (in this case 30% of the maximum health)
----------------------
-- dont touch anything from down here if u dont know what ur doing
local projectile_class_names = {
    [1] = "CTFProjectile_Rocket",
    [2] = "CTFGrenadePipebombProjectile",
    [3] = "CTFProjectile_Arrow",
    [4] = "CTFProjectile_SentryRocket"
}
local function IsProjectileClose(lPlayer, projectile, min_distance)
    local p_dist = vector.Distance( lPlayer:GetAbsOrigin(), projectile:GetAbsOrigin() )
    if p_dist < min_distance then 
        return true
    end
    return false
end
local function aDeadringer(cmd)
    local lPlayer = entities.GetLocalPlayer()
    if (lPlayer == nil) or (lPlayer:GetPropInt("m_iClass") ~= 8) or (lPlayer:GetPropInt("m_Shared", "m_bFeignDeathReady") == 1) then return end
    for i = 1, #projectile_class_names do -- projectiles
        local projectiles = entities.FindByClass( projectile_class_names[i] )
        for _,p in pairs(projectiles) do 
            if p:GetTeamNumber() ~= lPlayer:GetTeamNumber() and not p:IsDormant() and IsProjectileClose(lPlayer, p, dist) then
                cmd:SetButtons( cmd.buttons | IN_ATTACK2)
            end
        end
    end
    if (lPlayer:InCond(22) or lPlayer:InCond(25)) and ((lPlayer:GetHealth() / lPlayer:GetMaxHealth()) < health) then -- bleeding and burning
        cmd:SetButtons( cmd.buttons | IN_ATTACK2)
    end
end
callbacks.Unregister( "CreateMove", "aDeadringer" )
callbacks.Register( "CreateMove", "aDeadringer", aDeadringer )
