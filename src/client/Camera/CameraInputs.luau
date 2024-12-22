local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraSubjectSwitcher = require(ReplicatedStorage.Modules.Camera.CameraSubjectSwitcher)
local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)

InputManager.addInput("ChangePersonView", {
	Keys = { Enum.KeyCode.V },
	OnEnded = function()
		CameraSubjectSwitcher.Signal:Fire()
	end,
})

return 0
