local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)

local localPlayer = Players.LocalPlayer

local function isRunning()
	return UserInputService:IsKeyDown(Enum.KeyCode.W)
end

local function adjustWalkSpeed(humanoid, dt)
	local currentSpeed = humanoid.WalkSpeed
	local targetSpeed = if isRunning() then MovementConfig.MaxRunSpeed else MovementConfig.MinRunSpeed
	local rate = if currentSpeed < targetSpeed then MovementConfig.AccelerationRate else MovementConfig.DecelerationRate

	if humanoid.MoveDirection.Magnitude == 0 then
		humanoid.WalkSpeed = MovementConfig.MinRunSpeed
	else
		humanoid.WalkSpeed = currentSpeed + math.clamp(targetSpeed - currentSpeed, -rate * dt, rate * dt)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local character = localPlayer.Character

	if not character then return end
	if not character:FindFirstChild("Humanoid") then return end

	adjustWalkSpeed(character.Humanoid, dt)
end)

return 0
