local config = {
    melee_distance = 350,
    AutoQueue = true,
    stop_aiming_after_precent = 0.75,
    random_wpn_switch = true,
    look_at_walking_dir = true,
}

local function WalkTo(userCmd, localPlayer, destination)

    local function ComputeMove(userCmd, a, b)
        local diff = (b - a)
        if diff:Length() == 0 then return Vector3(0, 0, 0) end
    
        local x = diff.x
        local y = diff.y
        local vSilent = Vector3(x, y, 0)
    
        local ang = vSilent:Angles()
        local cPitch, cYaw, cRoll = userCmd:GetViewAngles()
        local yaw = math.rad(ang.y - cYaw)
        local pitch = math.rad(ang.x - cPitch)
        local move = Vector3(math.cos(yaw) * 450, -math.sin(yaw) * 450, -math.cos(pitch) * 450)
    
        return move
    end
    
    local localPos = localPlayer:GetAbsOrigin()
    local result = ComputeMove(userCmd, localPos, destination)

    userCmd:SetForwardMove(result.x)
    userCmd:SetSideMove(result.y)
end

local function IsVisible(player, localPlayer)
    local me = localPlayer
    local source = me:GetAbsOrigin() + me:GetPropVector( "localdata", "m_vecViewOffset[0]" );
    local destination = player:GetAbsOrigin() + Vector3(0,0,75)
    local trace = engine.TraceLine( source, destination, CONTENTS_SOLID | CONTENTS_GRATE | CONTENTS_MONSTER );
    if (trace.entity ~= nil) then
        if trace.entity == player then 
            return true 
        end
    end
    return false
end

local function PositionAngles(source, dest)
    local function isNaN(x) return x ~= x end
    local M_RADPI = 180 / math.pi
    local delta = source - dest
    local pitch = math.atan(delta.z / delta:Length2D()) * M_RADPI
    local yaw = math.atan(delta.y / delta.x) * M_RADPI
    if delta.x >= 0 then
        yaw = yaw + 180
    end
    if isNaN(pitch) then pitch = 0 end
    if isNaN(yaw) then yaw = 0 end
    return EulerAngles(pitch, yaw, 0)
end

local function IsKeyboardInputActive()
    if input.IsButtonDown( KEY_W ) or 
    input.IsButtonDown( KEY_A ) or 
    input.IsButtonDown( KEY_S ) or 
    input.IsButtonDown( KEY_D ) then 
        return true
    end
    return false
end

local wait = 0
local wait2 = 0
local wait3 = 0
local targetPlayer = nil

local foundValidTarget = false
local priority_player = false 
local prioritized_player = nil 

callbacks.Register("CreateMove", function(cmd)
    if entities.GetLocalPlayer() == nil then return end
    local lPlayer = entities.GetLocalPlayer()
    local players = entities.FindByClass("CTFPlayer")
    
    for _, p in pairs(players) do
        if p:IsAlive() and not p:IsDormant() and p:GetTeamNumber() ~= lPlayer:GetTeamNumber() and not p:InCond(4) and not p:InCond(5) then
            local p_pos = p:GetAbsOrigin()
            local l_pos = lPlayer:GetAbsOrigin()
            local dist = vector.Distance(p_pos, l_pos)
            
            if dist < config.melee_distance and IsVisible(p, lPlayer) then
                foundValidTarget = true
                targetPlayer = p
                
                if globals.RealTime() > wait then
                    client.Command("slot3", 1)
                    wait = globals.RealTime() + 0.3 
                end
                engine.SetViewAngles(PositionAngles(lPlayer:GetAbsOrigin() + lPlayer:GetPropVector("localdata", "m_vecViewOffset[0]"), p_pos + Vector3(0, 0, 40)))
                if targetPlayer and foundValidTarget then
                    WalkTo(cmd, lPlayer, targetPlayer:GetAbsOrigin())
                    gui.SetValue("follow bot", 0)
                end
            else
                foundValidTarget = false
                targetPlayer = nil
                gui.SetValue("follow bot", "all players")
            end
    
            if playerlist.GetPriority(p) > 0 and IsVisible(p, lPlayer) == true then
                priority_player = true 
                prioritized_player = p  
            end
        end
    end
    
    if prioritized_player and not IsVisible(prioritized_player, lPlayer) then
        priority_player = false
    end
    
    if not foundValidTarget and globals.RealTime() > wait then
        client.Command("slot1", 1)
        wait = globals.RealTime() + 0.3 
        targetPlayer = nil
    end

    if lPlayer:InCond(1) and lPlayer:GetPropEntity("m_hActiveWeapon"):GetPropFloat("SniperRifleLocalData", "m_flChargedDamage") > 150 * config.stop_aiming_after_precent then -- wait for full charge which is 150
        cmd:SetButtons( cmd.buttons | IN_ATTACK2)
    end

    if (lPlayer:GetPropEntity("m_hActiveWeapon") == lPlayer:GetEntityForLoadoutSlot(LOADOUT_POSITION_PRIMARY) 
        or lPlayer:GetPropEntity("m_hActiveWeapon") == lPlayer:GetEntityForLoadoutSlot(LOADOUT_POSITION_SECONDARY)) then 
            if not priority_player then
                if gui.GetValue("Aim method") ~= "smooth" then
                    gui.SetValue("Aim method", "smooth")
                end
                if gui.GetValue( "Aim position" ) ~= "head" then 
                    gui.SetValue("Aim position", "head")
                end
                if gui.GetValue("Fake latency") ~= 0 then
                    gui.SetValue("fake latency", 0)
                end
            else
                if gui.GetValue("Aim method") ~= "plain" then
                    gui.SetValue("Aim method", "plain")
                end
                if gui.GetValue( "Aim position" ) ~= "hit scan" then 
                    gui.SetValue("Aim position", "hit scan")
                end
            end
    end
    if lPlayer:GetPropEntity("m_hActiveWeapon") == lPlayer:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE) then
        if gui.GetValue("Aim method") ~= "plain" then
            gui.SetValue("Aim method", "plain")
        end
        if gui.GetValue("fake latency") == 0 then
            gui.SetValue("fake latency", 1)
        end
        cmd:SetButtons(cmd.buttons | IN_ATTACK)
    else
        if gui.GetValue("fake latency") == 1 then
            gui.SetValue("fake latency", 0)
        end
    end

    if gui.GetValue("Fake latency") == 1 then 
        if gui.GetValue("ping reducer") == 0 then
            gui.SetValue("ping reducer", 1)
        end
    else
        if gui.GetValue("ping reducer") == 1 then
            gui.SetValue("ping reducer", 0)
        end
    end


    if config.random_wpn_switch and not priority_player == true and not lPlayer:InCond(1) then 
        local random = math.random(10, 20)
        if globals.RealTime() > wait2 + random then
            client.Command("slot2", 1)
            wait2 = globals.RealTime()
        end
    end
    
    if config.look_at_walking_dir and not lPlayer:InCond(1) and not foundValidTarget and not IsKeyboardInputActive() then 
        local random = math.random(1, 9) * 0.5
        local pred_pos = vector.Add( lPlayer:GetAbsOrigin(), lPlayer:EstimateAbsVelocity() ) + Vector3(0,0,60)
        if globals.RealTime() > wait3 then -- wait3 + random
            if lPlayer:EstimateAbsVelocity():Length() >= 50 then 
                local angles = PositionAngles(lPlayer:GetAbsOrigin() + lPlayer:GetPropVector( "localdata", "m_vecViewOffset[0]" ), pred_pos)
                engine.SetViewAngles( EulerAngles(7, angles.y, 0))
            end
            wait3 = globals.RealTime()
        end
    end

end)

local s_width, s_height = draw.GetScreenSize()
local font = draw.CreateFont( "TF2 build", 15, 400, FONTFLAG_OUTLINE )
callbacks.Register( "Draw", function() 
    draw.SetFont(font)
    if targetPlayer ~= nil then 
        draw.Color( 255, 120, 102, 255 )
        local width = draw.GetTextSize( "Targeted player: ".. targetPlayer:GetName() )
        draw.Text( math.floor(s_width * 0.5 - (width * 0.5)), math.floor(s_height * 0.6), "Targeted player: ".. targetPlayer:GetName())
    end
end)






local lastTime = 0
local casualQueue = party.GetAllMatchGroups()["Casual"]

local function Draw_AutoQueue()
    if not config.AutoQueue or gamecoordinator.HasLiveMatch() or gamecoordinator.IsConnectedToMatchServer() or gamecoordinator.GetNumMatchInvites() > 0 then
        return
    end

    if globals.RealTime() - lastTime < 4 then
        return
    end

    lastTime = globals.RealTime()
    if #party.GetQueuedMatchGroups() == 0 and not party.IsInStandbyQueue() and party.CanQueueForMatchGroup(casualQueue) == true then
        party.QueueUp(casualQueue)
    end
end

callbacks.Unregister("Draw", "Draw_AutoQueue")
callbacks.Register("Draw", "Draw_AutoQueue", Draw_AutoQueue)
