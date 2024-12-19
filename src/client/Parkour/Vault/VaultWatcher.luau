local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationAssets = ReplicatedStorage.Assets.Animations

local AnimationManager = require(ReplicatedStorage.Shared.AnimationManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Signal = require(ReplicatedStorage.Packages.Signal)

local localPlayer = Players.LocalPlayer

local vaultSignal = Signal.new()
local vaultCooldown = false

local function calculateBoost(heightDiff)
	local boost = MovementConfig.VaultBoostBase
	boost += heightDiff

	if boost + MovementConfig.PerfectVaultForgiveness >= MovementConfig.PerfectVault then boost = MovementConfig.PerfectVault end

	return boost
end

local function isEdge(pos, instance)
	if math.abs(pos.Y - (instance.Position.Y + (instance.Size.Y / 2))) > MovementConfig.MaxPartSizeToPosDifference then return false end

	return true
end

local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true

local function findLedge(character)
	local humanoidRootPart = character.HumanoidRootPart
	local head = character.Head

	local initCFrame = CFrame.new(head.Position)
	local initSize = Vector3.new(1, 2, 1)

	local direction = humanoidRootPart.CFrame.LookVector
	local distance = MovementConfig.MaxVaultReachDistance

	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local cast = workspace:Blockcast(initCFrame, initSize, direction * distance)

	if cast then
		local instance = cast.Instance

		if isEdge(cast.Position, instance) then return -(head.Position.Y - (instance.Position.Y + (instance.Size.Y / 2))) end

		return
	end

	return
end

vaultSignal:Connect(function()
	if vaultCooldown == true then return end

	local character = localPlayer.Character
	local humanoidRootPart = character.HumanoidRootPart

	local heightDifference = findLedge(character)

	if heightDifference then
		vaultCooldown = true

		task.delay(MovementConfig.VaultCooldown, function()
			vaultCooldown = false
		end)

		local boost = calculateBoost(heightDifference)

		local vaultTrack = AnimationManager.GetTrack(character.Humanoid.Animator, AnimationAssets.Parkour.Vault)
		vaultTrack:Play(0.2)

		humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.CFrame.UpVector * (60 * (boost / 2))
	end
end)

return vaultSignal
