local font = draw.CreateFont( "Tahoma", 16, 800, FONTFLAG_OUTLINE  )
local s_witdh , s_height = draw.GetScreenSize()

local function IsWallstuck()
    local flags = entities.GetLocalPlayer():GetPropInt( "m_fFlags" )

    if flags & FL_ONGROUND == 0 and entities.GetLocalPlayer():EstimateAbsVelocity():Length() == 6 then
        return true
    else
        return false
    end
end

local function Center(string)
    local screen_witdh , screen_height = draw.GetScreenSize()
    local text_x, text_y = draw.GetTextSize(string)
    return math.floor((screen_witdh / 2) - (text_x / 2))
end

local function Drawing()
    draw.SetFont( font )

    if IsWallstuck() == true and entities.GetLocalPlayer() ~= nil then
        draw.Color( 255, 255, 255, 255 )
        draw.Text(Center("Wallstuck"), math.floor(s_height / 1.8), "Wallstuck")
    end
end

callbacks.Register( "Draw", "Drawing", Drawing )
