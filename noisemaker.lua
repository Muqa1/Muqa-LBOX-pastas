-- all pasted from lbox lua examples
local function damageLogger(event)
    if (event:GetName() == 'player_hurt' ) then
        local localPlayer = entities.GetLocalPlayer();
        local health = event:GetInt("health")
        local attacker = entities.GetByUserID(event:GetInt("attacker"))
        if (attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex()) then
            return
        end
        if health == 0 then
            local kv = [[ "use_action_slot_item_server" {} ]]
            engine.SendKeyValues( kv )
        end
    end
end
callbacks.Register("FireGameEvent", "exampledamageLogger", damageLogger)
