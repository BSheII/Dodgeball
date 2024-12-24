local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Schedules = require(ReplicatedStorage.Shared.Schedules)
local Signal = require(ReplicatedStorage.Packages.Signal)

local localPlayer = Players.LocalPlayer

local renderStepped

local camera = workspace.CurrentCamera
local cameraOffset = Vector3.new(2, 0.5, 5)
local yOffset = cameraOffset * Vector3.yAxis
local xzOffset = CFrame.new(cameraOffset * (Vector3.xAxis + Vector3.zAxis))

local initCameraCFrame = camera.CFrame

local module = {}
module.Signal = Signal.new()
module.FirstPerson = false

module.Signal:Connect(function()
	module.FirstPerson = not module.FirstPerson
end)

RunService:BindToRenderStep("Reset Camera", Enum.RenderPriority.First.Value, function()
	camera.CFrame = initCameraCFrame
end)

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	character.Humanoid.Died:Connect(function()
		if not renderStepped then return end

		renderStepped:Disconnect()
		renderStepped = nil
	end)

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart

	renderStepped = RunService.RenderStepped:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		initCameraCFrame = camera.CFrame

		if module.FirstPerson == true then
			humanoid.CameraOffset = Vector3.zero
			humanoid.AutoRotate = true

			camera.CFrame = initCameraCFrame * CFrame.new(0, 0, 0.2)
		else
			camera.CFrame = initCameraCFrame * xzOffset

			humanoid.CameraOffset = yOffset
			humanoid.AutoRotate = false
		end

		local _, y, _ = camera.CFrame:ToEulerAnglesYXZ()
		local rootCFrame = CFrame.Angles(0, y, 0)
		rootPart.CFrame = rootCFrame + rootPart.Position
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

Schedules["Boot"].job(handleConnections)

return module
