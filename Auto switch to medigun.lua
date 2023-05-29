local wait = 0
local function SwitchToMedigun()
    local lPlayer = entities.GetLocalPlayer()
    if lPlayer == nil then 
        return 
    end
    if not lPlayer:GetPropEntity( "m_hActiveWeapon" ):IsMedigun() and (globals.RealTime() > (wait + 0.5)) then -- cooldown between each command sent so u dont get kicked by the server
        client.Command( "slot2", true )
        wait = globals.RealTime()
    end
end
callbacks.Register( "Draw", "SwitchToMedigun", SwitchToMedigun )
