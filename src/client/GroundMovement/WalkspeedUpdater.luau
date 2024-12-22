local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

local targetSpeed = 32
local accelerationTime = 0.65
local deaccelerationTime = 0.2

local function adjustWalkSpeed(humanoid, dt)
	local currentSpeed = humanoid.WalkSpeed
	local speedDiff = targetSpeed - currentSpeed

	if not UserInputService:IsKeyDown(Enum.KeyCode.W) then return end

	local lerpAlpha = (speedDiff > 0 and dt / accelerationTime or dt / deaccelerationTime)
	humanoid.WalkSpeed = currentSpeed + speedDiff * math.clamp(lerpAlpha, 0, 1)
end

RunService.RenderStepped:Connect(function(dt)
	local character = localPlayer.Character

	if not character then return end
	if not character:FindFirstChild("Humanoid") then return end

	adjustWalkSpeed(character.Humanoid, dt)
end)

return 0
