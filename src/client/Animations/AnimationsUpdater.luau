local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerAnimations = ReplicatedStorage.Assets.Animations.Player

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

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	humanoid.Died:Connect(function()
		renderStepped:Disconnect()
		renderStepped = nil
	end)

	local runAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Run)
	local jumpAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Jump)
	local fallAnimation = AnimationsManager.GetTrack(humanoid.Animator, PlayerAnimations.Fall)

	renderStepped = RunService.RenderStepped:Connect(function()
		if character:FindFirstChild("Animate") then character.Animate.Enabled = false end

		local movementDirZ = humanoidRootPart.CFrame:VectorToObjectSpace(humanoidRootPart.AssemblyLinearVelocity).Z / humanoid.WalkSpeed

		runAnimation:AdjustSpeed((humanoid.WalkSpeed / MovementConfig.MaxRunSpeed) * (if movementDirZ > 0.1 then -1 else 1))

		local floorMaterial = humanoid.FloorMaterial
		local directionMagnitude = humanoid.MoveDirection.Magnitude

		if directionMagnitude == 0 or floorMaterial == Enum.Material.Air then runAnimation:Stop(0.3) end

		if floorMaterial ~= Enum.Material.Air then
			hasJumped = false

			jumpAnimation:Stop(0.3)
			fallAnimation:Stop(0.3)
		else
			if hasJumped then
				if not jumpAnimation.IsPlaying then playAnimation(fallAnimation) end
			else
				if not fallAnimation.IsPlaying then
					playAnimation(jumpAnimation)
					hasJumped = true
				end
			end
		end

		if directionMagnitude ~= 0 and floorMaterial ~= Enum.Material.Air then playAnimation(runAnimation) end
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

return Schedules["Boot"].job(handleConnections)
