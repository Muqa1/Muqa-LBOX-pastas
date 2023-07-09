local Proj_name = true
local Proj_dist = true
local Proj_box = true
--======================================================================================================================--
local font = draw.CreateFont( "Tahoma", 12, 800, FONTFLAG_OUTLINE  )
local function proj_esp()
    if entities.GetLocalPlayer() ~= nil then
        draw.SetFont( font )
        draw.Color( 255, 255, 255, 255 )
        local stickyies = entities.FindByClass("CTFGrenadePipebombProjectile")
        for i, sticky in pairs(stickyies) do 
            local sticky_screen = client.WorldToScreen( sticky:GetAbsOrigin() )
            if sticky_screen ~= nil and sticky:GetTeamNumber() ~= entities.GetLocalPlayer():GetTeamNumber() then 
                if Proj_box == true then
                draw.OutlinedRect( sticky_screen[1] - 5, sticky_screen[2] - 5, sticky_screen[1] + 5, sticky_screen[2] + 5 )
                end
                if Proj_name == true then
                local sticky_length, sticky_height = draw.GetTextSize("Sticky")
                draw.Text( sticky_screen[1] - math.floor(sticky_length / 2), sticky_screen[2] - 20, "Sticky" )
                end
                if Proj_dist == true then
                local sticky_dist = vector.Distance( entities.GetLocalPlayer():GetAbsOrigin(), sticky:GetAbsOrigin() )
                sticky_dist = math.floor(sticky_dist)
                local sticky_dist_length, sticky_dist_height = draw.GetTextSize("[".. sticky_dist.. "Hu]")
                draw.Text( sticky_screen[1] - math.floor(sticky_dist_length / 2), sticky_screen[2] + 10, "[".. sticky_dist.. "Hu]" )
                end
            end
        end
        local rockets = entities.FindByClass("CTFProjectile_Rocket")
        for i, rocket in pairs(rockets) do 
            local rocket_screen = client.WorldToScreen( rocket:GetAbsOrigin() )
            if rocket_screen ~= nil and rocket:GetTeamNumber() ~= entities.GetLocalPlayer():GetTeamNumber() then 
                if Proj_box == true then
                draw.OutlinedRect( rocket_screen[1] - 5, rocket_screen[2] - 5, rocket_screen[1] + 5, rocket_screen[2] + 5 )
                end
                if Proj_name == true then
                local rocket_length, rocket_height = draw.GetTextSize("Rocket")
                draw.Text( rocket_screen[1] - math.floor(rocket_length / 2), rocket_screen[2] - 20, "Rocket" )
                end
                if Proj_dist == true then
                local rocket_dist = vector.Distance( entities.GetLocalPlayer():GetAbsOrigin(), rocket:GetAbsOrigin() )
                rocket_dist = math.floor(rocket_dist)
                local rocket_dist_length, rocket_dist_height = draw.GetTextSize("[".. rocket_dist.. "Hu]")
                draw.Text( rocket_screen[1] - math.floor(rocket_dist_length / 2), rocket_screen[2] + 10, "[".. rocket_dist.. "Hu]" )
                end
            end
        end
    end
end
callbacks.Register( "Draw", "proj_esp", proj_esp )
