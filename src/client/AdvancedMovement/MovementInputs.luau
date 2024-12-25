local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BarSwingHandler = require(ReplicatedStorage.Modules.AdvancedMovement.BarSwingHandler)
local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local RollHandler = require(ReplicatedStorage.Modules.AdvancedMovement.RollHandler)
local SlideHandler = require(ReplicatedStorage.Modules.AdvancedMovement.SlideHandler)
local VaultHandler = require(ReplicatedStorage.Modules.AdvancedMovement.VaultHandler)

local localPlayer = Players.LocalPlayer

InputManager.addInput("CheckForMovementOnJump", {
	Keys = { Enum.KeyCode.Space },
	OnEnded = function()
		local character = localPlayer.Character

		if character:GetAttribute("Swinging") == true then return Enum.ContextActionResult.Sink end

		BarSwingHandler.Signal:Fire()

		if character:GetAttribute("Swinging") == true then return Enum.ContextActionResult.Sink end

		local didVault = VaultHandler.Signal:Fire()

		if didVault then return Enum.ContextActionResult.Sink end

		return Enum.ContextActionResult.Pass
	end,
})

InputManager.addInput("CheckForSlideAndRoll", {
	Keys = { Enum.KeyCode.C },
	OnBegan = function()
		local character = localPlayer.Character

		if character.Humanoid.FloorMaterial == Enum.Material.Air then RollHandler.LastRoll = os.clock() end

		SlideHandler.Begin:Fire()
	end,
	OnEnded = function()
		SlideHandler.End:Fire()
	end,
})

return 0
