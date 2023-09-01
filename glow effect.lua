local maxValue = 10
local minValue = 2
local speed = 10 -- bigger number = slower effect
--------------------------------
local curValue = minValue
local increasing = true
local lastUpdateTime = globals.RealTime()
callbacks.Register("Draw", function()
    local currentTime = globals.RealTime()
    local deltaTime = currentTime - lastUpdateTime
    if deltaTime >= speed / 100 then
        lastUpdateTime = currentTime
        if increasing then 
            curValue = curValue + 1
        else
            curValue = curValue - 1
        end
        if curValue >= maxValue then
            curValue = maxValue
            increasing = false
        elseif curValue <= minValue then
            curValue = minValue
            increasing = true
        end
        gui.SetValue("Glow size", curValue)
    end
end)
