local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

local localPlayer = Players.LocalPlayer

local renderStepped

local function isRunning()
	return UserInputService:IsKeyDown(Enum.KeyCode.W)
end

local function adjustJumpPower(humanoid, dt)
	local currentPower = humanoid.JumpPower
	local targetPower = if isRunning() then MovementConfig.MaxJumpPower else MovementConfig.MinJumpPower
	local rate = if currentPower < targetPower then MovementConfig.AccelerationRate else MovementConfig.DecelerationRate

	if humanoid.MoveDirection.Magnitude == 0 then
		humanoid.JumpPower = MovementConfig.MinJumpPower
	else
		humanoid.JumpPower = currentPower + math.clamp(targetPower - currentPower, -rate * dt, rate * dt)
	end
end

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	character.Humanoid.Died:Connect(function()
		renderStepped:Disconnect()
		renderStepped = nil
	end)

	local humanoid = character.Humanoid

	renderStepped = RunService.RenderStepped:Connect(function(dt)
		adjustJumpPower(humanoid, dt)
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

return Schedules["Boot"].job(handleConnections)
