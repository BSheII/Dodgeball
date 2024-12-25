local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}
module.Begin = Signal.new()
module.End = Signal.new()
module.Sliding = false

local localPlayer = Players.LocalPlayer
local renderStepped

local lastYPosition
local bodyVelocity

local function applySlopeBasedVelocity(rootPart, currentY, dt)
	local velocityMagnitude = bodyVelocity.Velocity.Magnitude
	local assemblyVelocity = rootPart.AssemblyLinearVelocity
	local horizontalVelocity = Vector3.new(assemblyVelocity.X, 0, assemblyVelocity.Z)

	local maxSpeed = MovementConfig.SlideMaxSpeed
	local acceleration = MovementConfig.SlideAccelerationRate
	local deceleration = MovementConfig.SlideDecelerationRate

	if lastYPosition then
		local heightDifference = lastYPosition - currentY
		local slopeSteepness = math.clamp((heightDifference * 5) - 0.1, -1, 1)

		if velocityMagnitude == 0 then velocityMagnitude = horizontalVelocity.Magnitude end

		if slopeSteepness > 0 then
			velocityMagnitude = math.min(velocityMagnitude - (acceleration * dt * -slopeSteepness), maxSpeed)
		elseif slopeSteepness <= 0 then
			velocityMagnitude = math.max(velocityMagnitude + (deceleration * dt * slopeSteepness), 0)
		end
	end

	local velocityDirection = rootPart.CFrame.LookVector
	bodyVelocity.Velocity = velocityDirection * velocityMagnitude

	lastYPosition = currentY
end

local rayParams = RaycastParams.new()

local function slide(character, dt)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then return end

	rayParams.FilterDescendantsInstances = { workspace.CurrentMap }
	rayParams.FilterType = Enum.RaycastFilterType.Include

	local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -6, 0), rayParams)

	applySlopeBasedVelocity(rootPart, rootPart.Position.Y, dt)
	lastYPosition = rootPart.Position.Y

	if
		not raycastResult
		or not UserInputService:IsKeyDown(Enum.KeyCode.W)
		or character:GetAttribute("Rolling")
		or bodyVelocity.Velocity.Magnitude < MovementConfig.SlideMinSpeed
	then
		module.Sliding = false
		character:SetAttribute("Sliding", false)

		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end

		if renderStepped then
			renderStepped:Disconnect()
			renderStepped = nil
		end
		return
	end
end

module.Begin:Connect(function()
	if renderStepped then return end

	local character = localPlayer.Character
	if not character then character = localPlayer.CharacterAdded:Wait() end

	local rootPart = character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("Humanoid")

	if not bodyVelocity then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e6, 0, 1e6)
		bodyVelocity.P = 1000
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = rootPart
	end

	if bodyVelocity.Parent ~= rootPart then bodyVelocity.Parent = rootPart end

	module.Sliding = true
	character:SetAttribute("Sliding", true)

	lastYPosition = rootPart.Position.Y

	renderStepped = RunService.RenderStepped:Connect(function(dt)
		slide(character, dt)
	end)
end)

module.End:Connect(function()
	module.Sliding = false
end)

return module
