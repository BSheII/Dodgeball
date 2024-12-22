local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerAnimations = ReplicatedStorage.Assets.Animations.Player

local AnimationsManager = require(ReplicatedStorage.Modules.Animations.AnimationsManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)

local localPlayer = Players.LocalPlayer

RunService.RenderStepped:Connect(function()
	local character = localPlayer.Character

	if not character then return end
	if not character:FindFirstChild("Humanoid") then return end

	if character:FindFirstChild("Animate") then character.Animate.Enabled = false end

	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	local runAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Run)

	if not runAnimation.IsPlaying and humanoid.MoveDirection.Magnitude ~= 0 then runAnimation:Play(0.3) end
	if humanoid.MoveDirection.Magnitude == 0 then runAnimation:Stop(0.3) end

	local movementDirZ = humanoidRootPart.AssemblyLinearVelocity.Z / humanoid.WalkSpeed

	runAnimation:AdjustSpeed((humanoid.WalkSpeed / MovementConfig.MaxRunSpeed) * (if movementDirZ > 0.1 then -1 else 1))
end)

return 0
