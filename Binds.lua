local font = draw.CreateFont( "Consolas", 16, 200 )

local function Binds()
    local FLvalue = gui.GetValue( "Fake Lag Value (ms)" ) +15
    local DTticks = warp.GetChargedTicks() 
    local Fake_latency = gui.GetValue( "Fake Latency Value (ms)" )
    
    draw.Color( 20, 20, 20, 200 ) --box
    draw.FilledRect(0,500, 160, 600)

    
    draw.SetFont( font ) --the text Binds on the top
    draw.Color( 255, 0, 125, 255)
    draw.Text( 9, 502, "Binds" )

    draw.Color( 255, 255, 255, 255) -- antiaim status
    draw.Text( 10, 520, "Anti Aim" )
    if gui.GetValue( "Anti Aim" ) == 1 then
        draw.Color( 0, 200, 0, 255)
        draw.Text( 80, 520, "ON" )
    else
        draw.Color( 200, 0, 0, 255)
        draw.Text( 80, 520, "OFF" )
    end

    draw.Color( 255, 255, 255, 255) -- fakelag status
    draw.Text( 9, 540, "Fake Lag" )
    if gui.GetValue( "Fake Lag" ) == 1 then
        draw.Color( 0, 200, 0, 255)
        draw.Text( 79, 540, "ON" )
        draw.Text( 99, 540, FLvalue )
    else
        draw.Color( 200, 0, 0, 255)
        draw.Text( 79, 540, "OFF" )
    end

    draw.Color( 255, 255, 255, 255) -- Doubletap ticks
    draw.Text( 9, 560, "Double Tap Ticks" )
    if DTticks >= 1 then
        draw.Color( 0, 200, 0, 255)
        draw.Text( 140, 560, DTticks +1) 
    else
        draw.Color( 200, 0, 0, 255)
        draw.Text( 140, 560, DTticks )
    end
    
    draw.Color( 255, 255, 255, 255) -- fake latency 
    draw.Text( 9, 580, "Fake Latency" )
    if gui.GetValue( "Fake Latency" ) >= 1 then 
        draw.Color( 0, 200, 0, 255)
        draw.Text( 110, 580, Fake_latency / 1000 )
    else
    draw.Color( 200, 0, 0, 255)
    draw.Text( 110, 580, "OFF" )
    end

end

callbacks.Register( "Draw", Binds )