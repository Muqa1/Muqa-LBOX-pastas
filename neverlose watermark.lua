Colors = {
    main_Color = {255, 255, 255, 255},
    big_text_fade1_color = {9, 93, 137, 255},
    big_text_fade2_color = {30, 183, 229, 255},
    background_Color = { 32, 39, 50, 255}
}

font = draw.CreateFont( "Museo Sans Cryl 900", 24, 800 )
font1 = draw.CreateFont( "Museo Sans Cryl 900", 19,500 )

local function wmark()
    if engine.IsGameUIVisible() == false then
--
    draw.Color(table.unpack(Colors.background_Color)) -- main box
    draw.FilledRect( 1500, 25, 1875, 50 )  
-- 
    draw.SetFont( font )--neverlose text
    draw.Color(table.unpack(Colors.big_text_fade1_color))
    draw.Text( 1503, 23, "LMAOBOX.NET" )
    draw.Color(table.unpack(Colors.big_text_fade2_color))
    draw.Text( 1504, 24, "LMAOBOX.NET" )
    draw.Color(table.unpack(Colors.main_Color))
    draw.Text( 1505, 25, "LMAOBOX.NET" )
--
    local current_fps = 0 --fps
    if globals.FrameCount() then
        current_fps = math.floor(1 / globals.FrameTime())
    end
    draw.Color(table.unpack(Colors.main_Color))
    draw.SetFont( font1 ) 
    draw.Text( 1655, 27, "| ".. current_fps.. " fps" )
--
    if clientstate.GetClientSignonState() == 6 then --ping pasted from XJN2 https://lmaobox.net/forum/v/discussion/22007/skeet-gamesense-styled-watermark/p1
        ping = entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[entities.GetLocalPlayer():GetIndex()] 
    else
        ping = "-"
    end
    draw.Color(table.unpack(Colors.main_Color))
    draw.Text( 1725, 27, "| ".. (ping * 2).. " ms" )
--  
    draw.Color(table.unpack(Colors.main_Color)) --clock pasted from XJN2 https://lmaobox.net/forum/v/discussion/22007/skeet-gamesense-styled-watermark/p1
    draw.Text( 1790, 27, "| ".. os.date("%I:%M %p") ) 
--
end
end

callbacks.Register( "Draw", "wmark", wmark)
