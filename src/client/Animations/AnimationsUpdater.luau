local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerAnimations = ReplicatedStorage.Assets.Animations.Player
local ParkourAnimations = ReplicatedStorage.Assets.Animations.Parkour

local AnimationsManager = require(ReplicatedStorage.Modules.Animations.AnimationsManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

local localPlayer = Players.LocalPlayer
local animations = { fall = nil, jump = nil, vault = nil, swing = nil, slide = nil }

local renderStepped
local hasJumped = false
local jumping = false

local function playAnimation(animation)
	if animation.IsPlaying then return end

	animation:Play(0.3)
end

local function stopAnimations(...)
	for _, animation in { ... } do
		animation:Stop(0.3)
	end
end

local function handleAirborneState(humanoidState)
	if humanoidState == Enum.HumanoidStateType.Freefall or humanoidState == Enum.HumanoidStateType.Jumping then
		if hasJumped then
			playAnimation(animations.fall)
		elseif jumping then
			playAnimation(animations.jump)
			jumping = false
		end
	else
		stopAnimations(animations.fall, animations.jump)
	end
end

local function handleGroundedState()
	hasJumped = false
	stopAnimations(animations.jump, animations.fall, animations.vault, animations.swing)
end

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	animations.run = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Run)
	animations.jump = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Jump)
	animations.fall = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Fall)
	animations.vault = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Vault)
	animations.swing = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Swing)
	animations.slide = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Slide)

	humanoid.Died:Connect(function()
		if not renderStepped then return end

		renderStepped:Disconnect()
		renderStepped = nil
	end)

	humanoid.Jumping:Connect(function(isJumping)
		if not isJumping then return end

		jumping = true
	end)

	animations.jump.Ended:Connect(function()
		hasJumped = true
	end)

	renderStepped = RunService.RenderStepped:Connect(function()
		if character:FindFirstChild("Animate") then character.Animate.Enabled = false end

		local movementDirZ = humanoidRootPart.CFrame:VectorToObjectSpace(humanoidRootPart.AssemblyLinearVelocity).Z / humanoid.WalkSpeed

		animations.run:AdjustSpeed(((humanoid.WalkSpeed / MovementConfig.MaxRunSpeed) + 0.25) * (movementDirZ > 0.1 and -1 or 1))

		local floorMaterial = humanoid.FloorMaterial
		local humanoidState = humanoid:GetState()
		local directionMagnitude = humanoid.MoveDirection.Magnitude

		if directionMagnitude == 0 or floorMaterial == Enum.Material.Air then stopAnimations(animations.run, animations.slide) end

		if floorMaterial == Enum.Material.Air then
			handleAirborneState(humanoidState)
		else
			handleGroundedState()
		end

		if directionMagnitude ~= 0 and floorMaterial ~= Enum.Material.Air then
			if character:GetAttribute("Sliding") then
				playAnimation(animations.slide)
				stopAnimations(animations.run)
			else
				playAnimation(animations.run)
				stopAnimations(animations.slide)
			end
		end
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

return Schedules["Boot"].job(handleConnections)
