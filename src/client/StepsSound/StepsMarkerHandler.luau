local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SoundAssets = ReplicatedStorage.Assets.Sounds

local SteppingSounds = require(ReplicatedStorage.Modules.StepsSound.SteppingSounds)

local checkedAnimations = {}

local function step(character)
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	local FloorMaterial = humanoid.FloorMaterial

	local stepSound = SteppingSounds[FloorMaterial] or SteppingSounds.SmoothPlastic

	local StepSoundInstance = SoundAssets.StepSound:Clone()

	StepSoundInstance.SoundId = stepSound.id
	StepSoundInstance.Volume = stepSound.volume
	StepSoundInstance.PlaybackSpeed = stepSound.speed

	StepSoundInstance.Parent = humanoidRootPart

	StepSoundInstance:Play()
	task.wait(0.25)
	StepSoundInstance:Destroy()
end

RunService.RenderStepped:Connect(function()
	for _, player in Players:GetPlayers() do
		local character = player.Character

		if not character then return end
		if not character:FindFirstChild("Humanoid") then return end

		character.HumanoidRootPart.Running.Volume = 0

		local humanoid = character.Humanoid
		local animator = humanoid.Animator

		for _, track in animator:GetPlayingAnimationTracks() do
			if table.find(checkedAnimations, track) then continue end

			local hadStepMarker = false

			local endedConnection
			local markerReachedConnection

			markerReachedConnection = track:GetMarkerReachedSignal("step"):Connect(function()
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
