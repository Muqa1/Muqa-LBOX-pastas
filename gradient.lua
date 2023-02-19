local function DrawGradient(x1, y1, x2, y2, r1, g1, b1, a1, r2, g2, b2, a2, steps)

local startColor = {r=r1, g=g1, b=b1, a=a1} 
local endColor = {r=r2, g=g2, b=b2, a=a2} 

local numSteps = steps

local rStep = (endColor.r - startColor.r) / numSteps
local gStep = (endColor.g - startColor.g) / numSteps
local bStep = (endColor.b - startColor.b) / numSteps
local aStep = (endColor.a - startColor.a) / numSteps

local gradient = {}

for i = 1, numSteps do
  local color = {
    r = startColor.r + rStep * i,
    g = startColor.g + gStep * i,
    b = startColor.b + bStep * i,
    a = startColor.a + aStep * i
  }
  table.insert(gradient, color)
end
    
for i = x1, x2 do 
  local colorIndex = math.floor((i / x2) * numSteps) + 1 
  local color = gradient[colorIndex] 
  if color then 
    draw.Color(math.floor(color.r), math.floor(color.g), math.floor(color.b), math.floor(color.a)) 
    draw.Line(i, y1, i, y2) 
  end
end
end

-- example of drawing the gradient
local function drawing()

    DrawGradient(0, 0, 1920, 1080, 255, 255, 255, 255, 0, 0, 0, 0, 1000)

end
callbacks.Register( "Draw", "drawing", drawing )