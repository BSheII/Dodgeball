local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)

local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local maxRunSpeed = MovementConfig.MaxRunSpeed
local minRunSpeed = MovementConfig.MinRunSpeed

local maxRunSpeedFOV = 85
local minRunSpeedFOV = 60
local increment = 60 -- Just the base FOV basically (when at minRunSpeedFOV)

local function calculateFOV(walkSpeed)
	local m = (maxRunSpeedFOV - minRunSpeedFOV) / (maxRunSpeed - minRunSpeed)
	local y = m * (walkSpeed - minRunSpeed) + increment

	return y
end

local function Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

RunService.RenderStepped:Connect(function(dt)
	local character = localPlayer.Character

	if not character then return end
	if not character:FindFirstChild("Humanoid") then return end

	local humanoid = character.Humanoid

	currentCamera.FieldOfView = Lerp(currentCamera.FieldOfView, calculateFOV(humanoid.WalkSpeed), dt)
end)

return 0
