Binds = true -- put as false if you dont want the aa keybinds
Colorss = {
    right_arrow = {255, 0, 0, 255},
    left_arrow = {0, 255, 0, 255},
    back_arrow = {0, 0, 255, 255}
}

local function arrows()

    if gui.GetValue( "Anti aim" ) == 1 then
        
      --- arrows      
        if (gui.GetValue( "Anti Aim - Custom Yaw (Real)") == -90) or (gui.GetValue( "Anti Aim - Yaw (Real)") == "right") then -- right arrow
        draw.Color(table.unpack(Colorss.right_arrow))
        draw.Line( 1000, 550, 1000, 530 )
        draw.Line( 1000, 550, 1020, 540 )
        draw.Line( 1000, 530, 1020, 540 )
        end
    

    if (gui.GetValue( "Anti Aim - Custom Yaw (Real)") == 90) or (gui.GetValue( "Anti Aim - Yaw (Real)") == "left") then -- left arrow
        draw.Color(table.unpack(Colorss.left_arrow))
        draw.Line( 920, 550, 920, 530 )
        draw.Line( 920, 550, 900, 540 )
        draw.Line( 920, 530, 900, 540 )
    end

    if (gui.GetValue( "Anti Aim - Custom Yaw (Real)") == -180) or (gui.GetValue( "Anti Aim - Custom Yaw (Real)") == 180) or (gui.GetValue( "Anti Aim - Yaw (Real)") == "back") then -- down arrow
        draw.Color(table.unpack(Colorss.back_arrow))
        draw.Line( 950, 570, 970, 570 )
        draw.Line( 950, 570, 960, 590 )
        draw.Line( 970, 570, 960, 590 )
    end
    --- arrows
    --- binds
    if (Binds == true) and (input.IsButtonPressed( KEY_C)) then -- right antiaim bind
        gui.SetValue( "Anti Aim - Yaw (Real)", "right" )
    end

    if (Binds == true) and (input.IsButtonPressed( KEY_Z)) then -- left antiaim bind
        gui.SetValue( "Anti Aim - Yaw (Real)", "left" )
    end

    if (Binds == true) and (input.IsButtonPressed( KEY_X)) then -- back antiaim bind
        gui.SetValue( "Anti Aim - Yaw (Real)", "back" )
    end
    --- binds
end
end
callbacks.Register( "Draw", "arrows", arrows)

