local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local viewableParts = {
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local function FirstPerson(character)
	for _, part in character:GetDescendants() do
		if not part:IsA("BasePart") then continue end
		if not table.find(viewableParts, part.Name) then
			part.LocalTransparencyModifier = 1
			continue
		end

		part.LocalTransparencyModifier = 0.5
		part.CanCollide = false
	end
end

local function ThirdPerson(character)
	for _, part in character:GetDescendants() do
		if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then continue end

		part.LocalTransparencyModifier = 0
		part.CanCollide = false
	end
end

RunService.RenderStepped:Connect(function()
	local character = localPlayer.Character

	if not character then return end

	if (character.Head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 1 then
		FirstPerson(character)
	else
		ThirdPerson(character)
	end
end)

return 0
