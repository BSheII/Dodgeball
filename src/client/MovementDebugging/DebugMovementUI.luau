local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VaultHandler = require(ReplicatedStorage.Modules.AdvancedMovement.VaultHandler)

local UIAssets = ReplicatedStorage.Assets.UI

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

local DebugUI = UIAssets.DebugMovementValues:Clone()
DebugUI.Parent = PlayerGui

local function GetDebugMovementValues()
	local character = localPlayer.Character

	if not character then return end
	if not character:FindFirstChild("HumanoidRootPart") then return end

	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	local assemblyVelocity = humanoidRootPart.AssemblyLinearVelocity

	local values = {}

	values["Velocity (Horizontal)"] = string.format("%.2f", (assemblyVelocity * (Vector3.xAxis + Vector3.zAxis)).Magnitude)
	values["Velocity (Vertical)"] = string.format("%.2f", (assemblyVelocity * Vector3.yAxis).Y)
	values["Running speed"] = math.round(humanoid.WalkSpeed)
	values["Jump power"] = math.round(humanoid.JumpPower)
	values["Studs"] = string.format("%.2f", VaultHandler.VaultStuds)
	values["Boost"] = string.format("%.2f", VaultHandler.VaultBoost)

	return values
end

RunService.RenderStepped:Connect(function()
	local values = GetDebugMovementValues()

	if not values then return end

	for UI, value in values do
		if not DebugUI:FindFirstChild(UI) then continue end

		DebugUI[UI].Text = `{UI}: {value}`
	end
end)

return 0
