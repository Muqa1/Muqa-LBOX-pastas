local function Cvarr()

    if client.GetConVar( "sv_cheats" ) == 0 then 
        client.SetConVar( "sv_cheats", 1 )
        client.Command( "tf_always_deathanim 1", true )
    end

end

callbacks.Register( "Draw", "Cvarr", Cvarr )
