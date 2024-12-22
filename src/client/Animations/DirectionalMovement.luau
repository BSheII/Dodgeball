local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

local function calculate(dT, plr, HRP, Humanoid, Torso)
	local movementDir = HRP.CFrame:VectorToObjectSpace(HRP.AssemblyLinearVelocity)

	if plr:GetAttribute("CharacterBusy") == true then movementDir = Vector3.zero end

	movementDir = Vector3.new(movementDir.X / Humanoid.WalkSpeed, 0, movementDir.Z / Humanoid.WalkSpeed)

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

	Torso["Right Hip"].C0 = Torso["Right Hip"].C0:Lerp(rightHip, lerpTime)
	Torso["Left Hip"].C0 = Torso["Left Hip"].C0:Lerp(leftHip, lerpTime)
	HRP.RootJoint.C0 = HRP.RootJoint.C0:Lerp(root, lerpTime)

	if not TiltCFrames[plr] then TiltCFrames[plr] = CFrame.new() end

	local MoveDirection = HRP.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
	TiltCFrames[plr] = TiltCFrames[plr]:Lerp(
		CFrame.Angles(math.rad(-MoveDirection.Z) * maxBodyTilting, math.rad(-MoveDirection.X) * maxBodyTilting, 0),
		0.2 * (1 / (dT * 60))
	)

	HRP.RootJoint.C0 = RootC0 * TiltCFrames[plr]
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

localPlayer.CharacterAdded:Connect(setupVariables)

RunService.RenderStepped:Connect(function(dT)
	for _, plr in Players:GetPlayers() do
		if not plr.Character then continue end
		if table.find(PlayersTable, plr) then continue end

		table.insert(PlayersTable, plr)
	end

	for _, plr in PlayersTable do
		if not plr or not plr.Character then table.remove(PlayersTable, plr) end

		local character = plr.Character

		if not character:FindFirstChild("HumanoidRootPart") then continue end
		if not RightHipC0 then setupVariables(localPlayer.Character) end

		calculate(dT, plr, character.HumanoidRootPart, character.Humanoid, character.Torso)
	end
end)

return 0
