local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local vaultSignal = Signal.new()

local localPlayer = Players.LocalPlayer

local overlapParams = OverlapParams.new()
overlapParams.FilterDescendantsInstances = { workspace.Platforms }
overlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function positionAtEdge(part, currentPosition)
	local currentY = currentPosition.Y
	local topY = part.Position.Y + (part.Size.Y / 2)

	print(math.abs(topY - currentY))

	return math.abs(topY - currentY) < 2
end

local function lookForEdge(character)
	local root = character.HumanoidRootPart

	local searchSize = root.Size + (character.Head.Size * Vector3.yAxis)
	local searchPosition = root.Position + root.CFrame.LookVector * 2

	local visualization = Instance.new("Part")
	visualization.CanCollide = false
	visualization.Anchored = true
	visualization.Position = searchPosition
	visualization.Size = searchSize
	visualization.Transparency = 0.5
	game.Debris:AddItem(visualization, 0.5)
	visualization.Parent = workspace

	local partsList = workspace:GetPartBoundsInBox(CFrame.new(searchPosition), searchSize)

	for _, part in partsList do
		if not positionAtEdge(part, character.Head.Position) then continue end

		break
	end
end

vaultSignal:Connect(function()
	local character = localPlayer.Character

	local edge = lookForEdge(character)

	if not edge then return end
end)

return vaultSignal
