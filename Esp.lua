--[[
author: Muqa | https://github.com/Muqa1

credits to:
LNX | https://lmaobox.net/forum/v/discussion/23106/simple-box-esp-and-health-bar  and some functions from lnxLib
@George3779 on telegram | uber level
]]

local max_distance = 3000 -- hammer units
local show_local_player = false -- can be buggy
--==--
local box = true
local box_color = {255, 255, 255}

local box_outline = true -- box needs to be on
local box_outline_color = {0, 0, 0}

local box_fill = false -- doesnt work with dormant fadeout yet | box needs to be on
local box_fill_color = {255, 255, 255, 25}
--==--
local tracers = false 
local tracers_color = {255,255,255}
--==--
local health_bar = true
local health_bar_backround = {0, 0, 0}

local health_bar_colour_mode = "static" -- use option "static" for a custom color | other option is "health_based" to have a health based color 
local health_bar_static_color = {0, 255, 0}
local health_bar_overheal_color = {54, 159, 245}
local health_bar_uber_color = {166, 71, 255}

local health_bar_text = false -- only works if custom health bar is true
local health_bar_text_color = {255, 255, 255}
--==--
local uber_bar = true 
local uber_bar_color = {105, 187, 255}
local uber_bar_backround_color = {0, 0, 0}

local uber_bar_text = false -- uber bar needs to be on
local uber_bar_text_color = {255, 255, 255}
--==-- 
local name = true
local name_color = {255,255,255}

local tags = true -- name needs to be on | in party or friend = FRIEND tag | 1 - 9 priority = PRIORITY tag | 10 priority = CHEATER tag
local friend_tag_color = {0,255,0}
local cheater_tag_color = {255,0,0}
local priority_tag_color = {255,255,0}
local dormant_tag_color = {150,150,150}
--==--
local conditions = true
local conditions_color = {0, 255, 191}
--==--
local draw_dormant_players = false -- it ist far esp but it just fades out dormant players
local dormant_duration = 5 -- duration in seconds for players to fade out

--==============================--
-- dont touch anything from down here, unless u know what ur doing
local tahoma = draw.CreateFont("Tahoma", 12, 400, FONTFLAG_OUTLINE)
local tahoma_bold = draw.CreateFont("Tahoma", 12, 800, FONTFLAG_OUTLINE)
local s_width, s_height = draw.GetScreenSize()
local dormant_fade_speed = 255 / dormant_duration
local dormant_start_times = {}
local conditions_names = {
    [1] = "zoomed",
    [3] = "disguised",
    [4] = "invis",
    [5] = "uber",
    [7] = "taunt",

    [11] = "crits",
    [33] = "crits",
    [34] = "crits",
    [35] = "crits",
    [37] = "crits",
    [38] = "crits",
    [39] = "crits",
    [40] = "crits",
    [44] = "crits",
    [56] = "crits",
    [78] = "mini crits",
    [105] = "crits",

    [22] = "burning",
    [24] = "jarate",
    [25] = "bleeding",
    [27] = "milk",
    [32] = "speed boost",
    [36] = "hype",
    [58] = "bullet res",
    [59] = "blast res",
    [60] = "fire res",
    [81] = "blast jumping",
    [123] = "gas",
}
local function getConditions(player)
    local playerConditions = {}
    local hasOverheal = false
    for conditionInt, conditionName in pairs(conditions_names) do
        if player:InCond(conditionInt) then
            table.insert(playerConditions, conditionName)
        end
    end
    local overhealAmount = player:GetHealth() - player:GetMaxHealth()
    if overhealAmount > 0 and math.floor((player:GetHealth() / player:GetMaxHealth() * 100)) > 100 then
        table.insert(playerConditions, "+" .. overhealAmount .. "hp")
        hasOverheal = true
    end
    return playerConditions
end

local function IsFriend(idx, inParty)
    if idx == client.GetLocalPlayerIndex() and show_local_player then return true end

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

local function Drawing_Esp()
    if engine.IsGameUIVisible() then dormant_start_times = {} return end
    
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then return end
    local localPlayerIndex = localPlayer:GetIndex()
    local localPlayerTeam = localPlayer:GetTeamNumber()
    local players = entities.FindByClass("CTFPlayer")

    for _, entity in pairs(entities.FindByClass("CTFPlayer")) do
        local entityIndex = entity:GetIndex()
        if entity:IsAlive() and entity:GetTeamNumber() ~= localPlayerTeam
                and vector.Distance(localPlayer:GetAbsOrigin(), entity:GetAbsOrigin()) < max_distance
                or IsFriend(entityIndex, true) then

            local padding = Vector3(0, 0, 6)

            local headPos = (entity:GetAbsOrigin() + entity:GetPropVector("localdata", "m_vecViewOffset[0]")) + padding 
            local feetPos = entity:GetAbsOrigin() - padding

            local headScreenPos = client.WorldToScreen(headPos)
            local feetScreenPos = client.WorldToScreen(feetPos)
            if headScreenPos ~=nil and feetScreenPos ~= nil then

                local height = math.abs(headScreenPos[2] - feetScreenPos[2])
                local width = height * 0.6

                local x = math.floor(headScreenPos[1] - width * 0.5)
                local y = math.floor(headScreenPos[2])
                local w = math.floor(width)
                local h = math.floor(height)

                local alpha = 255
                if entity:IsDormant() then
                   
                    local start_time = dormant_start_times[entity:GetIndex()] or globals.RealTime()
                    dormant_start_times[entity:GetIndex()] = start_time
        
                    local dormant_time = globals.RealTime() - start_time
                    alpha = math.floor(math.max(255 - dormant_time * dormant_fade_speed, 0))
                else
                    dormant_start_times[entity:GetIndex()] = nil  
                end

                if not draw_dormant_players and entity:IsDormant() then
                    goto continue
                end

                if tracers then 
                    draw.Color(tracers_color[1], tracers_color[2], tracers_color[3], alpha)
                    draw.Line( math.floor(s_width / 2), s_height, feetScreenPos[1], feetScreenPos[2] )
                end

                if name then
                    draw.SetFont(tahoma_bold)
                    local playerName = entity:GetName()
                    local width, height = draw.GetTextSize(playerName)
                    local tagOffset = 0
                    local textColor = name_color
                    local tagText, tagColor
                    if tags then
                        if IsFriend(entity:GetIndex(), true) then
                            tagText = "FRIEND"
                            tagColor = friend_tag_color
                        elseif playerlist.GetPriority(entity) == 10 then
                            tagText = "CHEATER"
                            tagColor = cheater_tag_color
                        elseif playerlist.GetPriority(entity) >= 1 then
                            tagText = "PRIORITY"
                            tagColor = priority_tag_color
                        end
                        if tagText then
                            local tagWidth, tagHeight = draw.GetTextSize(tagText)
                            draw.Color(tagColor[1], tagColor[2], tagColor[3], alpha)
                            draw.Text(math.floor(x + w / 2 - (tagWidth / 2)), y - height * 2 - tagOffset, tagText)
                            tagOffset = tagOffset + tagHeight
                        end
                        if entity:IsDormant() then
                            local dormantWidth, dormantHeight = draw.GetTextSize("DORMANT")
                            draw.Color(dormant_tag_color[1], dormant_tag_color[2], dormant_tag_color[3], alpha)
                            draw.Text(math.floor(x + w / 2 - (dormantWidth / 2)), y - height * 2 - tagOffset, "DORMANT")
                        end
                    end
                    draw.Color(textColor[1], textColor[2], textColor[3], alpha)
                    draw.Text(math.floor(x + w / 2 - (width / 2)), y - height, playerName)
                end
                
                draw.SetFont(tahoma)

                local y_offset = 0
                if conditions then
                    local playerConditions = getConditions(entity)
                    if #playerConditions > 0 then
                        draw.Color(conditions_color[1], conditions_color[2], conditions_color[3], alpha)
                        local x_w_5 = x + w + 5
                        for index, condition in ipairs(playerConditions) do
                            local width, length = draw.GetTextSize(condition)
                            draw.Text(x_w_5, y + y_offset, condition) 
                            y_offset = y_offset + length 
                        end
                    end
                end                      

                if box then
                    draw.Color(box_color[1], box_color[2], box_color[3], alpha)
                    draw.OutlinedRect(x, y, x + w, y + h)
                    if box_outline then 
                        draw.Color(box_outline_color[1], box_outline_color[2], box_outline_color[3], alpha)
                        draw.OutlinedRect(x - 1, y - 1, x + w + 1, y + h + 1) -- outer outline
                        draw.OutlinedRect(x + 1, y + 1, x + w - 1, y + h - 1) -- inner outline
                    end
                    if box_fill then
                        draw.Color(box_fill_color[1], box_fill_color[2], box_fill_color[3], box_fill_color[4])
                        draw.FilledRect(x + 1, y + 1, x + w - 1, y + h - 1)
                    end 
                end
        
                if health_bar then
                    local health = entity:GetHealth()
                    local maxHealth = entity:GetMaxHealth()
                    local percentageHealth = math.floor(health / maxHealth * 100)
                    local healthBarSize = math.floor(h * (health / maxHealth))
                    local maxHealthBarSize = math.floor(h)

                    draw.Color(health_bar_backround[1], health_bar_backround[2], health_bar_backround[3], alpha)
                    draw.FilledRect(x - 7, y - 1, x - 3, (y + h) + 1 ) -- health bar backround

                    if health_bar_colour_mode == "health_based" and percentageHealth < 101 then
                        draw.Color(255 - math.floor(health / maxHealth * 255), math.floor(health / maxHealth * 255), 0, alpha)
                    elseif health_bar_colour_mode == "static" and percentageHealth < 101 then
                        draw.Color(health_bar_static_color[1], health_bar_static_color[2], health_bar_static_color[3], alpha)
                    elseif entity:InCond(5) then 
                        healthBarSize = maxHealthBarSize
                        draw.Color(health_bar_uber_color[1], health_bar_uber_color[2], health_bar_uber_color[3], alpha)
                    elseif percentageHealth > 100 then 
                        healthBarSize = maxHealthBarSize
                        draw.Color(health_bar_overheal_color[1], health_bar_overheal_color[2], health_bar_overheal_color[3], alpha)
                    end

                    draw.FilledRect(x - 6, (y + h) - healthBarSize, x - 4, (y + h) ) -- health bar
        
                    if health_bar_text and health_bar and percentageHealth < 100 then
                        draw.Color(health_bar_text_color[1], health_bar_text_color[2], health_bar_text_color[3], alpha)
                        local width, height = draw.GetTextSize(health)
                        draw.Text(math.floor(x - 5 - width / 2), (y + h) - healthBarSize - 5 , health )
                    end
                end      
                
                if uber_bar then
                    if entity:GetPropInt("m_iClass") == 5 then
                        local medigun = entity:GetEntityForLoadoutSlot( 1 )
                        local uber = medigun:GetPropFloat("LocalTFWeaponMedigunData","m_flChargeLevel")
                        local maxUber = 1.0
                        local percentageUber = math.floor(uber / maxUber * 100)
                        local uberBarSize = math.floor(h * (uber / maxUber))

                        draw.Color(uber_bar_backround_color[1], uber_bar_backround_color[2], uber_bar_backround_color[3], alpha)
                        draw.FilledRect(x - 13, y - 1, x - 9, (y + h) + 1 ) -- uber bar backround
                        draw.Color(uber_bar_color[1], uber_bar_color[2], uber_bar_color[3], alpha)
                        draw.FilledRect(x - 12, (y + h) - uberBarSize, x - 10, (y + h) ) -- uber bar

                        if uber_bar_text then 
                            local TextPercentage = uber * 100
                            local UberPercentage = math.floor(TextPercentage)
                            local width, height = draw.GetTextSize(UberPercentage)
                            if UberPercentage ~= 0 then
                                draw.Color(uber_bar_text_color[1], uber_bar_text_color[2], uber_bar_text_color[3], alpha)
                                draw.Text(math.floor(x - 11 - width / 2), (y + h) - uberBarSize - 5 , UberPercentage )
                            end
                        end
                    end
                end 
                ::continue::
            end
        end
    end
end
callbacks.Unregister("Draw", "muqa_ESP")
callbacks.Register("Draw", "muqa_ESP", Drawing_Esp)
