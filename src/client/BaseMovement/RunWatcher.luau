local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Signal = require(ReplicatedStorage.Packages.Signal)

local localPlayer = Players.LocalPlayer

local runInfo = TweenInfo.new(0.9, Enum.EasingStyle.Linear)
local idleInfo = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local updateSignal = Signal.new()

local function updateSpeed(humanoid)
	local vector = humanoid.MoveDirection

	if vector.Magnitude == 0 then
		TweenService:Create(humanoid, idleInfo, { WalkSpeed = MovementConfig.MinRunSpeed }):Play()
	else
		TweenService:Create(humanoid, runInfo, { WalkSpeed = MovementConfig.MaxRunSpeed }):Play()
	end
end

local function initCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 8

	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		updateSpeed(humanoid)
	end)
end

if localPlayer.Character then initCharacter(localPlayer.Character) end

localPlayer.CharacterAdded:Connect(initCharacter)

updateSignal:Connect(function()
	if not localPlayer.Character then return end

	local humanoid = localPlayer.Character:WaitForChild("Humanoid")

	if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

	updateSpeed(humanoid)
end)

return updateSignal
