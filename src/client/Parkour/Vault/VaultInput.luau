local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local VaultWatcher = require(ReplicatedStorage.Modules.Parkour.Vault.VaultWatcher)

InputManager.addInput("Vault", {
	Keys = { Enum.KeyCode.Space },
	OnBegan = function()
		VaultWatcher:Fire()
	end,
})

return 0
