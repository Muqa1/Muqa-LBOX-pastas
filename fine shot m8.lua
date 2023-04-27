local wait = 0
local function VoicelineSpam()
    if (globals.RealTime() > (wait + 0.5)) then
        client.Command( "voicemenu 2 6", true )
        wait = globals.RealTime()
    end
end
callbacks.Register( "Draw", "VoicelineSpam", VoicelineSpam )
