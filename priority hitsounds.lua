local function f(event)
    local lPlr = entities.GetLocalPlayer()
    if (event:GetName()=="player_hurt") then
        local v=entities.GetByUserID(event:GetInt("userid"))
        local h=event:GetInt("health")
        local a=entities.GetByUserID(event:GetInt("attacker"))
        if (a==nil or lPlr:GetIndex()~=a:GetIndex()) then return end
        if playerlist.GetPriority(v)>0 then 
            if h==0 then 
                engine.PlaySound("replay/saved.wav") -- killsound
            else
                engine.PlaySound("replay/saved_take.wav") -- hitsound
            end
            client.Command( "tf_dingalingaling 0", true ) -- turning the hitsounds and killsounds off
        else
            client.Command( "tf_dingalingaling 1", true )
        end
    end
end
callbacks.Register("FireGameEvent", "Hello World!", f)
