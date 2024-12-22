local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local VaultHandler = require(ReplicatedStorage.Modules.AdvancedMovement.VaultHandler)

InputManager.addInput("Vault", {
	Keys = { Enum.KeyCode.Space },
	OnEnded = function()
		VaultHandler:Fire()
	end,
})

return 0
