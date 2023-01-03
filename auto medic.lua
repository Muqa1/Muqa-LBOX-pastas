procent = 0.6 -- edit this value from 0.1 to 1 to change how low you must be to start the script (0.6 = 60% of your base health)

-------------------------
local LastExtenFreeze = 0 --pasted from someone, dont remember who tho
local function MedicCall()
    if gamecoordinator.IsConnectedToMatchServer() then -- just so it doesnt fill the console with "auto medic.lua:10: attempt to index a nil value (local 'LPlayer')" or sum like that

    local LPlayer = entities.GetLocalPlayer()

    CurrentRatio = LPlayer:GetHealth() / LPlayer:GetMaxHealth()

    if (CurrentRatio <= procent) and (globals.RealTime() > (LastExtenFreeze + 2)) then 
        client.Command( "voicemenu 0 0", true )
        LastExtenFreeze = globals.RealTime()
    end
    
end
end
callbacks.Register( "Draw", "MedicCall", MedicCall)