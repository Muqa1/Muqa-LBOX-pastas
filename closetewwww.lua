local procent = 0.3 --you can change this value


local function CriticalHealth()

    if gamecoordinator.IsConnectedToMatchServer() then

        local players = entities.FindByClass("CTFPlayer")

        for i, p in ipairs( players ) do 
            
            Ratio = p:GetHealth() / p:GetMaxHealth()
            
            if (p:IsAlive()) and (Ratio <= procent) then 
                playerlist.SetPriority( p, 1 )
            else
                playerlist.SetPriority( p, 0 )
            end
        
        end
    
    end
end
callbacks.Register( "Draw", "CriticalHealth", CriticalHealth)