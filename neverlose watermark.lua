-- Credit for LNX00 for the options from https://lmaobox.net/forum/v/discussion/22631/release-simple-dt-bar

local options = {
    X = 0.88,
    Y = 0.03,
    Size = 10,
    Colors = {
    main_Color = {255, 255, 255, 255},
    big_text_fade1_color = {9, 93, 137, 255},
    big_text_fade2_color = {30, 183, 229, 255},
    background_Color = { 32, 39, 50, 255}
    }
}

font = draw.CreateFont( "Museo Sans Cryl 900", 24, 800 )
font1 = draw.CreateFont( "Museo Sans Cryl 900", 19,500 )

local function wmark()
    if engine.IsGameUIVisible() == false then

    local boxWidth = 37.5 * options.Size
    local boxHeight = math.floor(2.5 * options.Size)

    local sWidth, sHeight = draw.GetScreenSize()

    local xPos = math.floor(sWidth * options.X - boxWidth * 0.5)
    local yPos = math.floor(sHeight * options.Y - boxHeight * 0.5)
--
    draw.Color(table.unpack(Colors.background_Color)) -- main box
    draw.FilledRect(xPos, yPos, xPos + boxWidth, yPos + boxHeight)  
-- 
    draw.SetFont( font )--neverlose text
    draw.Color(table.unpack(Colors.big_text_fade1_color))
    draw.Text( xPos + 3, yPos - 2, "LMAOBOX.NET" )
    draw.Color(table.unpack(Colors.big_text_fade2_color))
    draw.Text( xPos + 4, yPos - 1, "LMAOBOX.NET" )
    draw.Color(table.unpack(Colors.main_Color))
    draw.Text(xPos + 5, yPos, "LMAOBOX.NET" )
--
    local current_fps = 0 --fps
    if globals.FrameCount() then
        current_fps = math.floor(1 / globals.FrameTime())
    end
    draw.Color(table.unpack(Colors.main_Color))
    draw.SetFont( font1 ) 
    draw.Text( xPos + 155, yPos + 2, "| ".. current_fps.. " fps" )
--
    if clientstate.GetClientSignonState() == 6 then --ping pasted from XJN2 https://lmaobox.net/forum/v/discussion/22007/skeet-gamesense-styled-watermark/p1
        ping = entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[entities.GetLocalPlayer():GetIndex()] 
    else
        ping = "-"
    end
    draw.Color(table.unpack(Colors.main_Color))
    draw.Text( xPos + 225, yPos + 2, "| ".. ping.. " ms" )
--  
    draw.Color(table.unpack(Colors.main_Color)) --clock pasted from XJN2 https://lmaobox.net/forum/v/discussion/22007/skeet-gamesense-styled-watermark/p1
    draw.Text( xPos + 290, yPos + 2, "| ".. os.date("%I:%M %p") ) 
--
end
end

callbacks.Register( "Draw", "wmark", wmark)
