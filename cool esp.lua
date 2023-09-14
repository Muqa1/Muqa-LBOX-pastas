local cfg = {
    red_team_color = {236,57,57,255},
    blue_team_color = {12,116,191,255},
}


--[[ dont touch anything from down here ]]--
local classes = {
    [1] = "Scout",
    [2] = "Sniper", 
    [3] = "Soldier",
    [4] = "Demoman",
    [5] = "Medic", 
    [6] = "Heavy",
    [7] = "Pyro",
    [8] = "Spy", 
    [9] = "Engineer",
}

local function getText(player)
    local playerConditions = {}
    table.insert(playerConditions, player:GetName())
    table.insert(playerConditions, classes[player:GetPropInt("m_iClass")])
    local health = player:GetHealth()
    local maxHealth = player:GetMaxHealth()
    local hString = tostring(health.. "/".. maxHealth.. "HP")
    table.insert(playerConditions, hString)
    return playerConditions
end

local function IsFriend(idx, inParty)
    if idx == client.GetLocalPlayerIndex() then return true end

    local playerInfo = client.GetPlayerInfo(idx)
    if steam.IsFriend(playerInfo.SteamID) then return true end
    if playerlist.GetPriority(playerInfo.UserID) < 0 then return true end

    if inParty then
        local partyMembers = party.GetMembers()
        if partyMembers == true then
            for _, member in ipairs(partyMembers) do
                if member == playerInfo.SteamID then return true end
            end
        end
    end

    return false
end

local font = draw.CreateFont( "TF2 Build", 12, 400, FONTFLAG_OUTLINE )

local function drawingAcoolESP()
    draw.SetFont( font )
    local lPlr = entities.GetLocalPlayer()
    if lPlr == nil or engine.IsGameUIVisible() then return end
    local enemy_only = (gui.GetValue( "Enemy only" ) == 1)
    local local_player = (gui.GetValue( "Local player" ) == 0)
    local players = entities.FindByClass( "CTFPlayer" )
    for i, p in pairs(players) do 
        local pTeam = p:GetTeamNumber()
        if (not enemy_only or pTeam ~= lPlr:GetTeamNumber()) and not p:IsDormant() and p:IsAlive() or IsFriend(p:GetIndex(), true) then

            if local_player and p == lPlr then goto continue end

            local padding = Vector3(0, 0, 6)

            local headPos = (p:GetAbsOrigin() + Vector3(0,0,75) + padding )
            local feetPos = p:GetAbsOrigin() - padding

            local headScreenPos = client.WorldToScreen(headPos)
            local feetScreenPos = client.WorldToScreen(feetPos)
            if not headScreenPos or not feetScreenPos then goto continue end

            local height = math.abs(headScreenPos[2] - feetScreenPos[2])
            local width = height * 0.6

            local x = math.floor(headScreenPos[1] - width * 0.5)
            local y = math.floor(headScreenPos[2])
            local w = math.floor(width)
            local h = math.floor(height)

            local espColor = {}

            if pTeam == 2 then 
                espColor = cfg.red_team_color
            elseif pTeam == 3 then 
                espColor = cfg.blue_team_color
            else
                espColor = {255,255,255,255}
            end
            
            if playerlist.GetPriority( p ) > 0 then 
                espColor = {255,255,0,255}
            elseif playerlist.GetPriority( p ) < 0 then 
                espColor = {18,172,100,255}
            end

            if IsFriend(p:GetIndex(), true) then 
                espColor = {18,172,100,255}
            end

            draw.Color( table.unpack(espColor) )

            local text = getText(p)

            local y_offset = 0

            local x_w = x + w + 5

            for index, condition in ipairs(text) do
                local drawColor = espColor

                local health = p:GetHealth()
                local maxHealth = p:GetMaxHealth()
                local hString = tostring(health.. "/".. maxHealth.. "HP")

                if condition == hString then
                    drawColor = { 0, 255, 0, 255 }
                end

                local width, length = draw.GetTextSize(condition)
                draw.Color(table.unpack(drawColor)) 
                draw.Text(x_w, y + y_offset, condition)
                y_offset = y_offset + length
            end


        end
        ::continue::
    end
end

callbacks.Unregister( "Draw", "Cool!" )
callbacks.Register( "Draw", "Cool!", drawingAcoolESP )
