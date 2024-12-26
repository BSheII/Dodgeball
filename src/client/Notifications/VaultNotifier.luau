local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationsFramework = require(ReplicatedStorage.Modules.Notifications.NotificationsFramework)
local Signal = require(ReplicatedStorage.Packages.Signal)

local notifySignal = Signal.new()

local startingPosition = UDim2.new(0.5, 0, 0.5, 30)
local color = Color3.new(0.439216, 1.000000, 0.513725)

local function math_round(n: number, scale: number?)
	return string.format("%." .. (typeof(scale) == "number" and scale or 2) .. "f", n)
end

notifySignal:Connect(function(vaultStuds)
	local text = `{math_round(vaultStuds, 2)} studs`

	NotificationsFramework:Fire { category = "Vault", text = text, color = color, position = startingPosition }
end)

return notifySignal
