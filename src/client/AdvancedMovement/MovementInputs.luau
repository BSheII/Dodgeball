local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BarSwingHandler = require(ReplicatedStorage.Modules.AdvancedMovement.BarSwingHandler)
local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local VaultHandler = require(ReplicatedStorage.Modules.AdvancedMovement.VaultHandler)

local localPlayer = Players.LocalPlayer

InputManager.addInput("CheckForMovementOnJump", {
	Keys = { Enum.KeyCode.Space },
	OnEnded = function()
		local character = localPlayer.Character

		if character:GetAttribute("Swinging") == true then return end

		BarSwingHandler.Signal:Fire()

		if character:GetAttribute("Swinging") == true then return end

		VaultHandler.Signal:Fire()
	end,
})

return 0
