local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local Schedules = require(ReplicatedStorage.Shared.Schedules)

local localPlayer = Players.LocalPlayer

local RangeOfMotion = 30
local RangeOfMotionTorso = 90 - RangeOfMotion
local RangeOfMotionXZ = RangeOfMotion / 140
local LerpSpeed = 0.03
local maxBodyTilting = 11

RangeOfMotion = math.rad(RangeOfMotion)
RangeOfMotionTorso = math.rad(RangeOfMotionTorso)

local PlayersTable = {}
local TiltCFrames = {}

local RootC0
local RightHipC0
local LeftHipC0

local function calculate(dT, character)
	local rootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid
	local torso = character.Torso

	local movementDir = rootPart.CFrame:VectorToObjectSpace(rootPart.AssemblyLinearVelocity)

	if character:GetAttribute("CharacterBusy") == true then movementDir = Vector3.zero end

	movementDir = Vector3.new(movementDir.X / humanoid.WalkSpeed, 0, movementDir.Z / humanoid.WalkSpeed)

	local x = (movementDir.X * (RangeOfMotion - (math.abs(movementDir.Z) * (RangeOfMotion / 2))))
	local xTorso = (movementDir.X * (RangeOfMotionTorso - (math.abs(movementDir.Z) * (RangeOfMotion / 2))))
	local xXZ = (movementDir.X * (RangeOfMotionXZ - (math.abs(movementDir.Z) * (RangeOfMotion / 2))))

	if movementDir.Z > 0.1 then
		x *= -1
		xTorso *= -1
		xXZ *= -1
		maxBodyTilting = 19
	else
		maxBodyTilting = 11
	end

	local rightHip = RightHipC0 * CFrame.new(-xXZ, 0, -math.abs(xXZ) + math.abs(-xXZ)) * CFrame.Angles(0, -x, 0)
	local leftHip = LeftHipC0 * CFrame.new(-xXZ, 0, -math.abs(-xXZ) + math.abs(-xXZ)) * CFrame.Angles(0, -x, 0)
	local root = RootC0 * CFrame.Angles(0, 0, -xTorso)

	local lerpTime = 1 - LerpSpeed * dT

	torso["Right Hip"].C0 = torso["Right Hip"].C0:Lerp(rightHip, lerpTime)
	torso["Left Hip"].C0 = torso["Left Hip"].C0:Lerp(leftHip, lerpTime)
	rootPart.RootJoint.C0 = rootPart.RootJoint.C0:Lerp(root, lerpTime)

	if not TiltCFrames[character] then TiltCFrames[character] = CFrame.new() end

	local MoveDirection = rootPart.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
	TiltCFrames[character] = TiltCFrames[character]:Lerp(
		CFrame.Angles(math.rad(-MoveDirection.Z) * maxBodyTilting, math.rad(-MoveDirection.X) * maxBodyTilting, 0),
		0.2 * (1 / (dT * 60))
	)

	rootPart.RootJoint.C0 = RootC0 * TiltCFrames[character]
end

local function setupVariables(character)
	if not character then return end
	if not character:FindFirstChild("HumanoidRootPart") then return end

	local humanoidRootPart = character.HumanoidRootPart
	local torso = character.Torso

	RootC0 = humanoidRootPart.RootJoint.C0
	RightHipC0 = torso["Right Hip"].C0
	LeftHipC0 = torso["Left Hip"].C0
end

RunService.RenderStepped:Connect(function(dT)
	for _, player in PlayersTable do
		if not player or not player.Character then continue end

		local character = player.Character

		if not character:FindFirstChild("HumanoidRootPart") then continue end
		if not RightHipC0 then setupVariables(localPlayer.Character) end

		calculate(dT, character)
	end
end)

local function initPlayer(player)
	table.insert(PlayersTable, player)

	player.CharacterRemoving:Connect(function(character)
		if not TiltCFrames[character] then return end

		TiltCFrames[character] = nil
	end)
end

local function handleConnections()
	if localPlayer.Character then setupVariables(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(setupVariables)

	for _, player in Players:GetPlayers() do
		initPlayer(player)
	end

	Players.PlayerAdded:Connect(initPlayer)

	Players.PlayerRemoving:Connect(function(player)
		local i = table.find(PlayersTable, player)

		if not i then return end

		table.remove(PlayersTable, i)
	end)
end

return Schedules["Boot"].job(handleConnections)
