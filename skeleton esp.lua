-- preview: https://imgur.com/a/TS6HNpG
local boneIDs = {
    {1, 6},   -- head to pelvis
    {6, 5},   
    {5, 4}, 
    {4, 3}, 
    {3, 2},  -- head to pelvis

    {2, 13},  -- pelvis to left foot
    {13, 14}, 
    {14, 15}, -- pelvis to left foot

    {2, 16}, -- pelvis to right foot
    {16, 17}, 
    {17, 18}, -- pelvis to right foot

    {6, 10}, -- shoulder to right arm
    {10, 11},
    {11, 12}, -- shoulder to right arm

    {6, 7}, -- shoulder to left arm
    {7, 8},
    {8, 9} -- shoulder to left arm
}


callbacks.Register( "Draw", function ()
    local players = entities.FindByClass( "CTFPlayer" )
    for _,p in pairs(players) do 
        if p:IsAlive() and not p:IsDormant() and p:GetTeamNumber() ~= entities.GetLocalPlayer():GetTeamNumber() then 
            local player = p
            local hitboxes = player:GetHitboxes()
        
            for i = 1, #boneIDs do
                local startBoneID = boneIDs[i][1]
                local endBoneID = boneIDs[i][2]
        
                local startBone = hitboxes[startBoneID]
                local endBone = hitboxes[endBoneID]
        
                local startCenter = (startBone[1] + startBone[2]) * 0.5
                local endCenter = (endBone[1] + endBone[2]) * 0.5
        
                -- to screen space
                startCenter = client.WorldToScreen(startCenter)
                endCenter = client.WorldToScreen(endCenter)
        
                if (startCenter ~= nil and endCenter ~= nil) then
                    -- draw bone line
                    draw.Color(255, 255, 255, 255)
                    draw.Line(startCenter[1], startCenter[2], endCenter[1], endCenter[2])
                end
            end
        end
    end
end )

-- local font = draw.CreateFont( "tahoma", 12, 400, FONTFLAG_OUTLINE )
-- callbacks.Register( "Draw", function ()
--     draw.SetFont( font )
--     local player = entities.GetLocalPlayer()
--     local hitboxes = player:GetHitboxes()

--     for i = 1, #hitboxes do
--         local hitbox = hitboxes[i]
--         local min = hitbox[1]
--         local max = hitbox[2]
--         local center = (hitbox[1] + hitbox[2]) * 0.5

--         -- to screen space
--         min = client.WorldToScreen( min )
--         max = client.WorldToScreen( max )
--         center = client.WorldToScreen( center )

--         if (min ~= nil and max ~= nil) then
--             -- draw hitbox
--             draw.Color(255, 255, 255, 255)
--             -- draw.FilledRect( center[1] - 5, center[2] - 5, center[1] + 5, center[2] + 5 )
--             draw.Text( center[1], center[2], i )
--         end
--     end
-- end)
