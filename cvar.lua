local function cvar()

    if client.GetConVar( "sv_cheats" ) == 0 then 
        client.SetConVar( "sv_cheats", 1 )
        client.SetConVar( "tf_always_deathanim", 1 )
    end

end

callbacks.Register( "Draw", "cvar", cvar )