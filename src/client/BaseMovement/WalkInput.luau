local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local RunWatcher = require(ReplicatedStorage.Modules.BaseMovement.RunWatcher)

local maxRunSpeed = MovementConfig.MaxRunSpeed
local minRunSpeed = MovementConfig.MinRunSpeed

InputManager.addInput("Walk", {
	Keys = { Enum.KeyCode.LeftControl },
	OnBegan = function()
		MovementConfig.MaxRunSpeed = minRunSpeed
		RunWatcher:Fire()
	end,
	OnEnded = function()
		MovementConfig.MaxRunSpeed = maxRunSpeed
		RunWatcher:Fire()
	end,
})

return 0
