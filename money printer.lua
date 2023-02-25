wait = 0

local function money_printer()
if (entities.GetLocalPlayer():IsAlive() == false) and (globals.RealTime() > (wait + 0.1)) then 
    client.Command("td_buyback", true )
    wait = globals.RealTime()
end

if entities.GetLocalPlayer():IsAlive() == true then 
    callbacks.Unregister( "Draw", "money_printer" )
    print("Unloading the script because the player is alive and glitch wont work")
end

end

callbacks.Register( "Draw", "money_printer", money_printer )
