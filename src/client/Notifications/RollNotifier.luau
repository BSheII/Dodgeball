local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationsFramework = require(ReplicatedStorage.Modules.Notifications.NotificationsFramework)
local Signal = require(ReplicatedStorage.Packages.Signal)

local notifySignal = Signal.new()

local startingPosition = UDim2.new(0.5, 0, 0.5, 40)
local color = Color3.new(0.439216, 0.870588, 1.000000)

local function math_round(n: number, scale: number?)
	return string.format("%." .. (typeof(scale) == "number" and scale or 2) .. "f", n)
end

notifySignal:Connect(function(seconds)
	local text = `{math_round(seconds * 1000, 2)} ms`

	NotificationsFramework:Fire { category = "Roll", text = text, color = color, position = startingPosition }
end)

return notifySignal
