local function DEG2RAD(x) return x * math.pi / 180 end
local function isNaN(x) return x ~= x end
local function IsOnScreen(entity)
    local w2s = client.WorldToScreen(entity:GetAbsOrigin())
    if w2s ~= nil then
        if w2s[1] ~= nil and w2s[2] ~= nil then 
            return true 
        end
    end
    return false
end

local ScrW, ScrH = draw.GetScreenSize()
local font = draw.CreateFont("Tahoma", 12, 400, FONTFLAG_OUTLINE)

callbacks.Register("Draw", "yes", function()
    local lPlayer = entities.GetLocalPlayer()
    if lPlayer == nil then return end

    local real_angle = engine.GetViewAngles()
    local yaw = DEG2RAD(real_angle.y)
    draw.SetFont(font)

    for _, p in pairs(entities.FindByClass("CTFPlayer")) do
        if not p:IsDormant() and p:IsAlive() and p:GetTeamNumber() ~= lPlayer:GetTeamNumber() then
            local positionDiff = lPlayer:GetAbsOrigin() - p:GetAbsOrigin()
            local x = math.cos(yaw) * positionDiff.y - math.sin(yaw) * positionDiff.x
            local y = math.cos(yaw) * positionDiff.x + math.sin(yaw) * positionDiff.y
            local len = math.sqrt(x * x + y * y)

            x = x / len
            y = y / len

            local pos1 = ScrW / 2 + x * 200
            local pos2 = ScrH / 2 + y * 200

            if not isNaN(pos1) and not isNaN(pos2) and not IsOnScreen(p) then
                pos1 = math.floor(pos1)
                pos2 = math.floor(pos2)

                local name_width, name_height = draw.GetTextSize(p:GetName())
                local health_width, health_height = draw.GetTextSize(p:GetHealth())
                local distance = vector.Distance( lPlayer:GetAbsOrigin(), p:GetAbsOrigin() )
                local alpha = math.floor(math.max(0, 255 - (distance * 0.05)))

                draw.Color(255, 255, 255, alpha)
                draw.Text(pos1 - math.floor(name_width / 2), pos2, p:GetName())
                draw.Color(0, 255, 0, alpha)
                draw.Text(pos1 - math.floor(health_width / 2), pos2 + name_height, p:GetHealth())
            end
        end
    end
end)
