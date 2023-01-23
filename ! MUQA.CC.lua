    version = 2.4

    watermark = false

    death_messages = {
        "WHAT HOW DID U KILL ME WHILE I WAS INVIS DUDE KICK THIS GUY PLS RN!!!!111!",
        "omgg guys he so obviouss kick himmmm",
        "THIS GUY JUST RESOLVED MY ANTIAIM, ONLY OTHER CHEATERS CAN DO THAT",
        "u killed me while i was using ULMERHOOK.XYZ? must be a cheater, kick",
        "Ok fr now what the flippin frick how did you see me????",
        "DUDEEEE KICK THIS DUDE ALREADY HE IS IN RIJINHACK.RU STEAM GROUP OBVIOUS HACKER",
        "doubletaping scout please kick him",
        "ok this dude has ulmerhook.xyz aswell if he killed me",
        "YOU WANNA HVH???? ULMERHOOK.XYZ WILL OWN YOU",
        "KILL ME ONCE MORE I WILL GO MGE AND OWN YOU!",
        "idk but i think this guy might be cheating",
        "he couldnt have killed me i was invisible and you cant see someone that is invisible because you cant see invisible players ",
        "DUDE I HAD UBER AND WAS INVISIBLE    HOW KILL???",
        "I GUESS POPUPWARE GOT A LUCKY MATH.RANDOM RESOLVE, NEW AA CFG LOADING",
        "kick please he killed while i was cloaked", 
        "i was not even on the same map as you? how you kill me?"
    }

    game_end = {
        "HAHAHAHA EZZ EZZZ SO EZZZZZZ SO BAAAAD SO EZZ",
        "GET ULMERHOOK TO ST0P LOSING N00BS",
        "THIS WAS SO EZZZZ",
        "L0L EZ",
        "NOT EVEN TRYING",
        "YALL GOT 0WNNED BY ulmerhook_bothosting_beta",
        "BUY ULMERHOOK.XYZ TO STOP LOSING N00BS",
        "this is mind boggling how easy this game is",
        "yall genuenly suck like stop sucking i guess",
        "Not even Se0wned can resolve this antiaim",
        "Dont feel bad about losing, cuz trannys always lose",
        "buy new acc != hvh win NN DOG",
        "ofc you lost with cracked nn cheat ULMERHOOK 0wnning",
        "EZIEsT W1N OF LIVETIME CANT LOSENN WITH ULMERHOOK.XYZ",
        "i should stop winning so much all the enemys will RAGE QUIT NN NNOOB  EZ EZE ZEZ ",
        "REMOVED FROM GAME BY SYSTEM I CALL IT RAGE QUIT EZ ZEZE ZEZZZZZZ",
        "DUAL INJECTED RIJNHACK.RU & ULMERHOOK.XYZ OFC I WON :cash:",
        "YOU SAY ITS FAKE LAG BUT YO'URE INTERNAT JUST TRASHH HHHHH",
        "GET NOVOLINE CLIENT TO STOP L0SSING"
    }

    local LastExtenFreeze = 0 
    local LastExtenFreeze84 = 0
    local LastExtenFreeze1 = 0 
    local LastExtenFreeze3 = 0
    local LastExtenFreeze99 = 0

local function Gunspy()

        
    --watermark 
    if watermark == true then
    color1 = math.random(0,255)
    color2 = math.random(0,255)
    color3 = math.random(0,255)
    transparency = math.random(0,255)
    draw.Color( color1, color2, color3, transparency )
    draw.FilledRect( 0, 0, 1920, 1080 )
    end
    --watermark

    --revolver
    if gamecoordinator.IsConnectedToMatchServer() then

        
        if globals.RealTime() > (LastExtenFreeze + 2) then 
        
        client.Command( "slot1", true )
        client.Command( "disguise 1 -1", true )
        --client.Command( "+voicerecord", true )
        LastExtenFreeze = globals.RealTime()
    end
    --revolver

    --health status 
if gamecoordinator.IsConnectedToMatchServer() then
    
        if globals.RealTime() > (LastExtenFreeze84 + 20) then 

        client.Command( "say_party ".. steam.GetPlayerName( steam.GetSteamID() ).. ":GetHealth() = ".. entities.GetLocalPlayer():GetHealth().. "/".. entities.GetLocalPlayer():GetMaxHealth(), true )
        LastExtenFreeze84 = globals.RealTime()
        end
    end
    --health status

    --auto deadringer
    local health = entities.GetLocalPlayer():GetHealth() / entities.GetLocalPlayer():GetMaxHealth()

    if (health <= 0.5) and (globals.RealTime() > (LastExtenFreeze1 + 0.5)) and (entities.GetLocalPlayer():IsAlive()) then
        
        gui.SetValue("Aim bot", 0 )
        gui.SetValue( "fake lag", 1 )
        client.Command( "voicemenu 0 0", true )
        client.Command( "+attack2", true )

        LastExtenFreeze1 = globals.RealTime()

    elseif (health >= 0.5) and (globals.RealTime() > (LastExtenFreeze1 + 0.5)) and (entities.GetLocalPlayer():IsAlive()) then
        
        gui.SetValue("Aim bot", 1 )
        gui.SetValue( "fake lag", 0 )
        warp.TriggerWarp()
        client.Command( "-attack2", true )
        SetButtons( MOUSE_FIRST + 1 )

        LastExtenFreeze1 = globals.RealTime()

    end
    --auto deadringer

    --game end
    
    if (gamerules.GetRoundState() == 8) and (globals.RealTime() > (LastExtenFreeze3 + 5)) then

        index = math.random(#game_end)

        client.Command( "say ".. game_end[index], true )
        LastExtenFreeze3 = globals.RealTime()
    end
    end
    --game end

    --noismakr
    client.Command( "voice_loopback 1", true )

    if gamecoordinator.IsConnectedToMatchServer() then
        if entities.GetLocalPlayer():IsAlive() then 
            gui.SetValue( "noisemaker spam", 0)
            else
                gui.SetValue( "noisemaker spam", 1)
        end
    
    end
    --noismakr

    --priority
    if gamecoordinator.IsConnectedToMatchServer() then

        local players = entities.FindByClass("CTFPlayer")
        local LastExtenFreeze75 = 0
        for i, p in ipairs( players ) do 
            
            if (playerlist.GetPriority( p ) >= 8) and (globals.RealTime() > (LastExtenFreeze75 + 120)) then 
            client.Command( "say_party ".. p:GetName().. "has priority set as ".. playerlist.GetPriority( p ), true )
            LastExtenFreeze75 = globals.RealTime()
            end
        
        end
    
    end
end
    --priority

    --on death
    local function onDeath(event)

    if (event:GetName() == 'player_death' ) then    

        local attacker = entities.GetByUserID(event:GetInt("attacker"))
        local localPlayer = entities.GetLocalPlayer();
        local victim = entities.GetByUserID(event:GetInt("userid"))

        index1 = math.random(#death_messages)

        if localPlayer:GetIndex() == victim:GetIndex() and localPlayer:GetIndex() ~= attacker:GetIndex() then
        client.Command( "-attack2", true )
        client.Command( "say ".. death_messages[index1].. " this ukrainians name is '".. attacker:GetName().. "'", true )
        client.Command( "say_party ".. steam.GetPlayerName( steam.GetSteamID() ).. ":GetHealthStatus() = Dead", true )
        --1% lua leak
        number = math.random(1,100)
        if number <= 99 then 
            client.Command("say ".. GetScriptName().. " ".. "IS THE BEST LUA FOR ULMERHOOK.XYZ!!1!")
        end
        --1% lua leak
        end
    end
    --on death

end
    
--callbacks
callbacks.Register( "Draw", "Gunspy", Gunspy)
callbacks.Register("FireGameEvent", "deathSayLua", onDeath)
--callbacks



startup_says = {
    (GetScriptName().. " HAS BEEN SUCERFULY LOADED!!! BE READY TO BE 0WNED DOGS version: ".. version),
    ("Feel The Power, Feel The Gamesense, Feel The Muqa.cc version: ".. version),
    ("ULMERHOOK SUCCEFULLY ENHANCED AND REINFORCED WITH ".. GetScriptName().. " VERSION: ".. version),
    (GetScriptName().. " Has been successfully loaded. Get Muqa.cc at https://grabify.link/O6INIY"),
    ("This party is now protected by UlmerHook.xyz and Muqa.cc lua version: ".. version),
    ("All of the trannies and bronies gonna rq when they see ".. steam.GetPlayerName( steam.GetSteamID() ).. " cuz MUQA.CC too powerful"),
    ("Get ready to be bored cuz UlmerHook.xyz is gonna carry now. message generated by MUQA.CC lua version: ".. version),
    ("ULMERHOOK, ULMERHOOK, NR1 CHEAT, U SO BAD BRO THAT I HAVE TO PEEK, EZ 1TAP NO BODYAIM ONLY WITH MUQA.CC"),
    ("Are u tired of 11 year old game? Well then u need to go to grabify.link/O6INIY and get the PREMIUM version of MUQA.CC today, the only way to have fun again :D")
}

index2 = math.random(#startup_says)

--on startup
engine.Notification( "ULMERHOOK PRIVATE GUNSPYBOT LUA (BETA)", "TAHNK YOU FOR CHOOSING ".. GetScriptName().. " ".. steam.GetPlayerName( steam.GetSteamID() ).. "\n \n WE ARE SO HAPPY TO RIP U OFF 500$ THAT U PAID US TO GET THIS PRIVATE LUA" )
client.Command( "say_party ".. startup_says[index2], true )
client.Command( "toggleconsole ", true )
engine.PlaySound( "vo/spy_item_unicorn_round_start03.mp3" )
print("==========================================================")
print("==========================================================")
printc(255, 0, 255, 255, "MUQA.CC")
printc(255, 255, 255, 255, "FEEL THE POWER OF UNLIMITED 0WNAGE")
printc(255, 255, 255, 100, "Version: ".. version)
print("==========================================================")
print("==========================================================")
 --on startup