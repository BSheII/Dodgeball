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

local function adjustWalkSpeed(character, dt)
	local humanoid = character.Humanoid

	if character:GetAttribute("Sliding") == true then return end

	local currentSpeed = humanoid.WalkSpeed
	local targetSpeed = if isRunning() then MovementConfig.MaxRunSpeed else MovementConfig.MinRunSpeed
	local rate = if currentSpeed < targetSpeed then MovementConfig.AccelerationRate else MovementConfig.DecelerationRate

	if humanoid.MoveDirection.Magnitude == 0 then
		humanoid.WalkSpeed = MovementConfig.MinRunSpeed
	else
		humanoid.WalkSpeed = currentSpeed + math.clamp(targetSpeed - currentSpeed, -rate * dt, rate * dt)
	end
end

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	character.Humanoid.Died:Connect(function()
		if not renderStepped then return end

		renderStepped:Disconnect()
		renderStepped = nil
	end)

	renderStepped = RunService.RenderStepped:Connect(function(dt)
		adjustWalkSpeed(character, dt)
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

return Schedules["Boot"].job(handleConnections)
