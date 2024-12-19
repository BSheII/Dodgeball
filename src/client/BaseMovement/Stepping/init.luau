local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SoundAssets = ReplicatedStorage.Assets.Sounds

local SteppingSounds = require(script.SteppingSounds)

local checkedAnimations = {}

local function step(character)
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if not humanoidRootPart:FindFirstChild("StepSound") then
		local stepSound = SoundAssets.StepSound:Clone()
		stepSound.Parent = humanoidRootPart
	end

	local FloorMaterial = humanoid.FloorMaterial

	local stepSound = SteppingSounds[FloorMaterial] or SteppingSounds.SmoothPlastic

	humanoidRootPart.StepSound.SoundId = stepSound.id
	humanoidRootPart.StepSound.Volume = stepSound.volume
	humanoidRootPart.StepSound.PlaybackSpeed = stepSound.speed

	humanoidRootPart.StepSound:Play()
	task.wait(0.05)
	humanoidRootPart.StepSound:Stop()
end

RunService.RenderStepped:Connect(function()
	for _, player in Players:GetPlayers() do
		local character = player.Character

		if not character then return end
		if not character:FindFirstChild("Humanoid") then return end

		local humanoid = character.Humanoid
		local animator = humanoid.Animator

		for _, track in animator:GetPlayingAnimationTracks() do
			if table.find(checkedAnimations, track) then continue end

			local hadStepMarker = false

			local endedConnection
			local markerReachedConnection

			markerReachedConnection = track:GetMarkerReachedSignal("Step"):Connect(function()
				hadStepMarker = true

				step(character)
			end)

			endedConnection = track.Ended:Connect(function()
				if not hadStepMarker then markerReachedConnection:Disconnect() end

				endedConnection:Disconnect()
			end)

			table.insert(checkedAnimations, track)
		end
	end
end)

return 0
