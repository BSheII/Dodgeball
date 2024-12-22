local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Signal = require(ReplicatedStorage.Packages.Signal)

local localPlayer = Players.LocalPlayer

local module = {}
module.Signal = Signal.new()
module.FirstPerson = false

module.Signal:Connect(function()
	module.FirstPerson = not module.FirstPerson
end)

RunService.RenderStepped:Connect(function(dt)
	local camera = workspace.CurrentCamera

	camera.CameraType = Enum.CameraType.Scriptable

	local character = localPlayer.Character

	if not character then return end
	if not character:FindFirstChild("HumanoidRootPart") then return end

	local root = character.HumanoidRootPart

	character.Humanoid.AutoRotate = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	local mouseDelta = UserInputService:GetMouseDelta().X

	character.HumanoidRootPart.CFrame *= CFrame.Angles(0, -mouseDelta * dt, 0)

	if module.FirstPerson then
		camera.CFrame = CFrame.lookAlong(root.Position + root.CFrame.UpVector, root.CFrame.LookVector)
	else
		local offset = (root.CFrame.LookVector * -7) + (root.CFrame.UpVector * 2) + (root.CFrame.RightVector * 2)
		camera.CFrame = CFrame.lookAlong(root.Position + offset, root.CFrame.LookVector)
	end
end)

return module
