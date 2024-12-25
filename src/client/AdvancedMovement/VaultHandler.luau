local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local yMultiplier = 0.7
local xzMuliplier = 1.05

local overlapParams = OverlapParams.new()
overlapParams.FilterDescendantsInstances = { workspace.CurrentMap }
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function calculateBoost(heightDifference, assemblyMass)
	local result = heightDifference * assemblyMass
	return result * yMultiplier
end

local function getHeightDifference(part, character)
	local topY = part.Position.Y + (part.Size.Y / 2)
	local currentY = character.HumanoidRootPart.Position.Y

	return math.abs(topY - currentY)
end

local function _visualize(size, cframe)
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = cframe
	part.Transparency = 0.3
	part.Anchored = true
	part.Color = Color3.new(0.5, 0, 0.5)
	part.CanCollide = false
	part.Parent = workspace

	game.Debris:AddItem(part, 2)
end

local function _visualizeEdge(part)
	if not part then return end

	local highlight = Instance.new("Highlight")
	highlight.Parent = part

	game.Debris:AddItem(highlight, 1)
end

local function lookForEdge(character)
	local root = character.HumanoidRootPart
	local lkVector = root.CFrame.LookVector

	local searchSize = ((root.Size + character.Head.Size) * Vector3.yAxis) + Vector3.new(0.2, 0.5, 3)

	local startingPosition = root.Position + (root.CFrame.UpVector / 2)
	local searchCFrame = CFrame.lookAt(startingPosition + (lkVector * 2), startingPosition)

	--_visualize(searchSize, searchCFrame)

	local partsList = workspace:GetPartBoundsInBox(searchCFrame, searchSize, overlapParams)
	local actualParts = {}

	for _, part in partsList do
		local heightDifference = getHeightDifference(part, character)

		if heightDifference < 2.5 then table.insert(actualParts, part) end
	end

	local chosenPart = nil

	for _, part in actualParts do
		local partY = part.Position.Y
		local currentY = chosenPart and chosenPart.Position.Y

		if (currentY and partY > currentY) or not currentY then chosenPart = part end
	end

	--_visualizeEdge(chosenPart)

	return chosenPart
end

module.Signal:Connect(function()
	local character = localPlayer.Character

	if debounce == true then return end

	debounce = true

	task.delay(MovementConfig.VaultCooldown, function()
		debounce = false
	end)

	local edge = lookForEdge(character)

	if not edge then return end

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart

	local vaultAnimation = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Vault)

	local heightDifference = getHeightDifference(edge, character)
	local assemblyMass = rootPart.AssemblyMass
	local assemblyVelocity = rootPart.AssemblyLinearVelocity

	if heightDifference > MovementConfig.MaxVaultStuds then heightDifference = MovementConfig.MaxVaultStuds end

	local boost = calculateBoost(heightDifference, assemblyMass)

	vaultAnimation:Play(0.1)

	module.VaultStuds = heightDifference
	module.VaultBoost = boost

	rootPart.AssemblyLinearVelocity = Vector3.new(assemblyVelocity.X * xzMuliplier, 25 + boost, assemblyVelocity.Z * xzMuliplier)
	humanoid.WalkSpeed = MovementConfig.MaxRunSpeed + 6

	return true
end)

return module
