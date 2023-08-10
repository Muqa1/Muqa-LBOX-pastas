local s_width, s_height = draw.GetScreenSize()
local tahoma = draw.CreateFont( "Tahoma", 12, 400, FONTFLAG_OUTLINE )
callbacks.Register( "Draw", function()
    if not engine.IsGameUIVisible() and entities.GetLocalPlayer():InCond(81) then
        draw.SetFont( tahoma )
        draw.Color(255,255,255,255)
        local width, height = draw.GetTextSize( "Blast Jumping" )
        draw.Text(math.floor(s_width / 2 - (width / 2)), math.floor(s_height / 1.9), "Blast Jumping" )
    end
end)
