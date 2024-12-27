local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local ThrowHandler = require(ReplicatedStorage.Modules.Dodgeball.ThrowHandler)

InputManager.addInput("ThrowBall", {
	Keys = { Enum.UserInputType.MouseButton1 },
	OnBegan = function()
		ThrowHandler.Begin:Fire()
	end,
	OnEnded = function()
		ThrowHandler.End:Fire()
	end,
})

return 0
