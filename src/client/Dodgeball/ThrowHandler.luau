local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Signal = require(ReplicatedStorage.Packages.Signal)

local localPlayer = Players.LocalPlayer

local module = {}

module.Begin = Signal.new()
module.End = Signal.new()

local currentDistance = 0
local renderStepped

local function hasBall()
	return true
end

local function calculateArcVelocity(distance, gravity)
	local angle = math.rad(10)
	local speed = math.sqrt(gravity * distance / math.sin(2 * angle))
	local velocityX = speed * math.cos(angle)
	local velocityY = speed * math.sin(angle)
	return velocityX, velocityY
end

module.Begin:Connect(function()
	if not hasBall() then return end

	if renderStepped then renderStepped:Disconnect() end

	renderStepped = RunService.RenderStepped:Connect(function(dt)
		currentDistance += MovementConfig.ThrowDistancePerSecond ^ (dt / 2)
		print(currentDistance)
	end)
end)

module.End:Connect(function()
	if not hasBall() then return end

	local character = localPlayer.Character
	local ball = Instance.new("Part")
	ball.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
	ball.Parent = workspace
	ball.Massless = false
	ball.AssemblyLinearVelocity = Vector3.zero
	ball:SetAttribute("IsThrown", true)

	if not ball then return end

	if renderStepped then renderStepped:Disconnect() end

	local camera = workspace.CurrentCamera

	local gravity = workspace.Gravity
	local velocityX, velocityY = calculateArcVelocity(currentDistance, gravity)

	local viewport = camera.ViewportSize
	local vector = Vector2.new(viewport.X / 2, viewport.Y / 2)
	local throwDirection = camera:ScreenPointToRay(vector.X, vector.Y).Direction.Unit

	local velocity = (throwDirection * velocityX + Vector3.new(0, velocityY, 0)) * MovementConfig.ThrowForceBase

	ball:ApplyImpulse(velocity * ball:GetMass())

	currentDistance = 0
end)

return module
