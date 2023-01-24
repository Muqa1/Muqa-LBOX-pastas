local function Cvarr()

        client.SetConVar( "sv_cheats", 1 )
        client.Command( "tf_always_deathanim 1", true )

end

callbacks.Register( "Draw", "Cvarr", Cvarr )
