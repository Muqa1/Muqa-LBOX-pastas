procent = 0.6 -- edit this value from 0.1 to 1 to change how low you must be to start the script (0.6 = 60% of your base health)

-------------------------
local LastExtenFreeze = 0 
local function MedicCall()
    if client.IsFreeTrialAccount() == true then
        print("Cant run ".. GetScriptName().. " because you have a free to play account.")
        callbacks.Unregister( "Draw", "MedicCall", MedicCall )
    end

    if gamecoordinator.IsConnectedToMatchServer() then 

    local LPlayer = entities.GetLocalPlayer()

    CurrentRatio = LPlayer:GetHealth() / LPlayer:GetMaxHealth()

    if (CurrentRatio <= procent) and (globals.RealTime() > (LastExtenFreeze + 2)) then 
        client.Command( "voicemenu 0 0", true )
        LastExtenFreeze = globals.RealTime()
    end
    
end
end
callbacks.Register( "Draw", "MedicCall", MedicCall)
