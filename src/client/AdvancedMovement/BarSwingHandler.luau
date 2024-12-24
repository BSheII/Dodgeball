local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ParkourAnimations = ReplicatedStorage.Assets.Animations.Parkour

local AnimationsManager = require(ReplicatedStorage.Modules.Animations.AnimationsManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}
module.Signal = Signal.new()
module.VaultStuds = 0
module.VaultBoost = 0

local localPlayer = Players.LocalPlayer
local debounce = false

local overlapParams = OverlapParams.new()
overlapParams.FilterDescendantsInstances = { workspace.CurrentMap }
overlapParams.FilterType = Enum.RaycastFilterType.Include

local swingTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function getHeightDifference(part, currentPosition)
	local currentY = currentPosition.Y
	local topY = part.Position.Y + (part.Size.Y / 2)

	return math.abs(topY - currentY)
end

local function _visualize(size, cframe)
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = cframe
	part.Transparency = 0.3
	part.Anchored = true
	part.Color = Color3.new(0, 0.5, 0.5)
	part.CanCollide = false
	part.Parent = workspace

	game.Debris:AddItem(part, 2)
end

local function lookForBar(character)
	local root = character.HumanoidRootPart
	local lkVector = root.CFrame.LookVector

	local searchSize = (((root.Size / 2) + character.Head.Size) * Vector3.yAxis) + Vector3.new(0.2, 0.5, 2)

	local startingPosition = root.Position + Vector3.new(0, (root.Size.Y / 2), 0)
	local searchCFrame = CFrame.lookAt(startingPosition + (lkVector * 1.5), startingPosition)

	--_visualize(searchSize, searchCFrame)

	local partsList = workspace:GetPartBoundsInBox(searchCFrame, searchSize, overlapParams)

	for _, part in partsList do
		local heightDifference = getHeightDifference(part, character.Head.Position)

		if heightDifference >= 2 or not part:GetAttribute("SwingBar") then continue end

		return part
	end

	return
end

module.Signal:Connect(function()
	local character = localPlayer.Character

	if debounce == true then return end

	debounce = true

	task.delay(MovementConfig.VaultCooldown, function()
		debounce = false
	end)

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart

	local swingAnimation = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Swing)

	local bar = lookForBar(character)

	if not bar then return end

	character:SetAttribute("Swinging", true)

	swingAnimation:Play(0.1)

	local root = character.HumanoidRootPart
	local lkVector = root.CFrame.LookVector

	local position = root.Position + Vector3.new(0, (root.Size.Y / 2), 0) + (lkVector * 1.5)

	local tween = TweenService:Create(rootPart, swingTweenInfo, { Position = Vector3.new(position.X, bar.Position.Y - 2.5, position.Z) })

	tween:Play()
	tween.Completed:Wait()

	rootPart.AssemblyLinearVelocity = (rootPart.CFrame.LookVector * MovementConfig.SwingVelocity) + Vector3.new(0, 5, 0)
	humanoid.WalkSpeed = MovementConfig.SwingWalkSpeed

	character:SetAttribute("Swinging", false)

	return true
end)

return module
