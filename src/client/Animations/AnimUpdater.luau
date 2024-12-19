local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AnimationAssets = ReplicatedStorage.Assets.Animations

local AnimationManager = require(ReplicatedStorage.Shared.AnimationManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)

local localPlayer = Players.LocalPlayer

local steppedConnection
local animations = { Walk = nil, Idle = nil, Run = nil, Jump = nil, FreeFall = nil }

local maxRunSpeed = MovementConfig.MaxRunSpeed

local states = {
	[Enum.HumanoidStateType.Running] = function(humanoid)
		local moving = humanoid.MoveDirection.Magnitude > 0

		animations.FreeFall:Stop(0.2)

		if humanoid.WalkSpeed >= maxRunSpeed / 1.5 and moving then
			animations.Walk:Stop(0.2)
			animations.Run:AdjustSpeed(maxRunSpeed / humanoid.WalkSpeed)

			if animations.Run.IsPlaying then return end

			animations.Run:Play(0.2)
		elseif moving then
			animations.Run:Stop(0.2)

			if animations.Walk.IsPlaying then return end

			animations.Walk:Play(0.2)
		elseif not moving then
			animations.Run:Stop(0.2)
			animations.Walk:Stop(0.2)

			if animations.Idle.IsPlaying then return end

			animations.Idle:Play(0.2)
		end
	end,
	[Enum.HumanoidStateType.Jumping] = function(_)
		if animations.Jump.IsPlaying then return end

		animations.Jump:Play(0.2)
	end,

	[Enum.HumanoidStateType.Freefall] = function(_)
		animations.Jump:Stop(0.2)

		if animations.FreeFall.IsPlaying then return end

		animations.FreeFall:Play(0.2)
	end,
}

local function initCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid.Animator

	animations = {}

	animations.Walk = AnimationManager.GetTrack(animator, AnimationAssets.Player.Walk)
	animations.Run = AnimationManager.GetTrack(animator, AnimationAssets.Player.Run)
	animations.Idle = AnimationManager.GetTrack(animator, AnimationAssets.Player.Idle)
	animations.Jump = AnimationManager.GetTrack(animator, AnimationAssets.Player.Jump)
	animations.FreeFall = AnimationManager.GetTrack(animator, AnimationAssets.Player.FreeFall)

	if steppedConnection then steppedConnection:Disconnect() end

	steppedConnection = RunService.RenderStepped:Connect(function()
		local humanoidState = humanoid:GetState()

		if not states[humanoidState] then return end

		states[humanoidState](humanoid)
	end)
end

if localPlayer.Character then initCharacter(localPlayer.Character) end

localPlayer.CharacterAdded:Connect(initCharacter)

return 0
