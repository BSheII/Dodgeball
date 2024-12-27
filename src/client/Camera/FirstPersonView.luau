local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CameraSubjectSwitcher = require(ReplicatedStorage.Modules.Camera.CameraSubjectSwitcher)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

local localPlayer = Players.LocalPlayer

local viewableParts = {
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local noCollideParts = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local renderStepped

local function FirstPerson(character)
	for _, part in character:GetDescendants() do
		if not part:IsA("BasePart") then continue end
		if not table.find(viewableParts, part.Name) then
			part.LocalTransparencyModifier = 1
			continue
		end

		part.LocalTransparencyModifier = 0
	end
end

local function ThirdPerson(character)
	for _, part in character:GetDescendants() do
		if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then continue end

		part.LocalTransparencyModifier = 0
	end
end

local function setCanCollide(character) -- TODO: Change this to somewhere else
	for _, partName in noCollideParts do
		if not character:FindFirstChild(partName) then continue end

		character[partName].CanCollide = false
	end
end

local function setMouseIcon() -- TODO: Change this to somewhere else as well (oh I know this is gonna pile up)
	UserInputService.MouseIcon = "rbxassetid://15722065980"
end

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	setCanCollide(character)
	setMouseIcon()

	character.Humanoid.Died:Connect(function()
		if not renderStepped then return end

		renderStepped:Disconnect()
		renderStepped = nil
	end)

	renderStepped = RunService.RenderStepped:Connect(function()
		if CameraSubjectSwitcher.FirstPerson == true then
			FirstPerson(character)
		else
			ThirdPerson(character)
		end
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

return Schedules["Boot"].job(handleConnections)
