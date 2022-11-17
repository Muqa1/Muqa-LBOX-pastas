local function Draw_aa()
gui.SetValue("Anti Aim - Custom Yaw (Real)", math.random(-180, 180 ))
gui.SetValue("Anti Aim - Custom Yaw (Fake)", math.random(-180, 180 ))
gui.SetValue("Anti Aim - Custom Pitch (Real)", math.random(-90, 90 ))
end

callbacks.Register( "Draw", "Draw_aa", Draw_aa )
