local color = { 0, 0, 0, 255} -- enter any RGBA color u want
--------------------------------------
local sW, sH = draw.GetScreenSize()
callbacks.Register( "Draw", function() 
    local localPlayer = entities.GetLocalPlayer()
    if localPlayer and localPlayer:InCond( 1 ) then 
        draw.Color( table.unpack(color) )
        draw.Line( sW / 2, 0, sW / 2, sH )
        draw.Line( 0, sH / 2, sW, sH / 2 )
    end
end)
