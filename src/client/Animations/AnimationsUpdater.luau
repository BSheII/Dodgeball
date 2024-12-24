local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerAnimations = ReplicatedStorage.Assets.Animations.Player
local ParkourAnimations = ReplicatedStorage.Assets.Animations.Parkour

local AnimationsManager = require(ReplicatedStorage.Modules.Animations.AnimationsManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

local localPlayer = Players.LocalPlayer

local renderStepped
local hasJumped = false

local function playAnimation(animation)
	if animation.IsPlaying then return end

	animation:Play(0.3)
end

local function stopAnimations(...)
	for _, animation in { ... } do
		animation:Stop(0.3)
	end
end

local function handleAirborneState(humanoidState, jumpAnimation, fallAnimation)
	if humanoidState == Enum.HumanoidStateType.Freefall or humanoidState == Enum.HumanoidStateType.Jumping then
		if hasJumped then
			playAnimation(fallAnimation)
		else
			playAnimation(jumpAnimation)
		end
	else
		stopAnimations(fallAnimation, jumpAnimation)
	end
end

local function handleGroundedState(jumpAnimation, fallAnimation, vaultAnimation, swingAnimation)
	hasJumped = false
	stopAnimations(jumpAnimation, fallAnimation, vaultAnimation, swingAnimation)
end

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	humanoid.Died:Connect(function()
		if not renderStepped then return end

		renderStepped:Disconnect()
		renderStepped = nil
	end)

	local runAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Run)
	local jumpAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Jump)
	local fallAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Fall)
	local vaultAnimation = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Vault)
	local swingAnimation = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Swing)

	renderStepped = RunService.RenderStepped:Connect(function()
		if character:FindFirstChild("Animate") then character.Animate.Enabled = false end

		local movementDirZ = humanoidRootPart.CFrame:VectorToObjectSpace(humanoidRootPart.AssemblyLinearVelocity).Z / humanoid.WalkSpeed

		runAnimation:AdjustSpeed(((humanoid.WalkSpeed / MovementConfig.MaxRunSpeed) + 0.25) * (movementDirZ > 0.1 and -1 or 1))

		local floorMaterial = humanoid.FloorMaterial
		local humanoidState = humanoid:GetState()
		local directionMagnitude = humanoid.MoveDirection.Magnitude

		if directionMagnitude == 0 or floorMaterial == Enum.Material.Air then runAnimation:Stop(0.3) end

		if floorMaterial == Enum.Material.Air then
			handleAirborneState(humanoidState, jumpAnimation, fallAnimation)
		else
			handleGroundedState(jumpAnimation, fallAnimation, vaultAnimation, swingAnimation)
		end

		if directionMagnitude ~= 0 and floorMaterial ~= Enum.Material.Air then playAnimation(runAnimation) end
	end)

	jumpAnimation.Ended:Connect(function()
		hasJumped = true
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

return Schedules["Boot"].job(handleConnections)
