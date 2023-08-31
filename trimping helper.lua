local function TrimpHelper(cmd)
if (entities.GetLocalPlayer():InCond(17)) then
    gui.SetValue( "Auto Strafe", 0 )
    pitch, yaw, roll = cmd:GetViewAngles()
    if input.IsButtonDown( KEY_D ) then 
        cmd:SetViewAngles( pitch, yaw - 55, roll )
        cmd:SetButtons(cmd.buttons | IN_FORWARD)
        client.Command( "-moveright", 1 )
    else
        client.Command( "-moveright", 0 )
    end
    if input.IsButtonDown( KEY_A ) then 
        cmd:SetViewAngles( pitch, yaw + 55, roll )
        cmd:SetButtons(cmd.buttons | IN_FORWARD)
        client.Command( "-moveleft", 1 )
    else
        client.Command( "-moveleft", 0 )
    end
else 
    gui.SetValue( "Auto Strafe", 2 )
end
end
callbacks.Register( "CreateMove", "TrimpHelper", TrimpHelper )
