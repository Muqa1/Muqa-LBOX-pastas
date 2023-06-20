local function flareJump( cmd )
    local player = entities.GetLocalPlayer( );

    if (player ~= nil or not player:IsAlive()) then
    end

    if input.IsButtonDown( KEY_V ) then

        local flags = player:GetPropInt( "m_fFlags" );

        local pitch, yaw, roll = cmd:GetViewAngles()

        if flags & FL_ONGROUND then
            cmd:SetButtons(cmd.buttons | IN_JUMP)
            cmd:SetButtons(cmd.buttons | IN_DUCK)
            cmd:SetButtons(cmd.buttons | IN_ATTACK)
            cmd:SetViewAngles( 89, yaw, roll )
        end
    end
end

callbacks.Register("CreateMove", "flareJump", flareJump)
