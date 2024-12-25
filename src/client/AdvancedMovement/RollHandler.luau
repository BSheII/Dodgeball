local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local ParkourAnimations = ReplicatedStorage.Assets.Animations.Parkour
local SoundsAssets = ReplicatedStorage.Assets.Sounds

local AnimationsManager = require(ReplicatedStorage.Modules.Animations.AnimationsManager)
local MovementConfig = require(ReplicatedStorage.Shared.MovementConfig)
local RollNotifier = require(ReplicatedStorage.Modules.Notifications.RollNotifier)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

local localPlayer = Players.LocalPlayer

local module = {}
module.LastRoll = 0

local renderStepped
local endedConnection
local lastMagnitude

local function calculateBoost(rollTime)
	return 55 + (35 - 55) * math.exp(-rollTime * 100)
end

local function initCharacter(character)
	if renderStepped then renderStepped:Disconnect() end

	character.Humanoid.Died:Connect(function()
		if not renderStepped then return end

		renderStepped:Disconnect()
		renderStepped = nil
	end)

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart

	renderStepped = RunService.RenderStepped:Connect(function()
		local currentDifference = os.clock() - module.LastRoll

		if currentDifference > MovementConfig.RollMaxSecondsTime then return end
		if humanoid.FloorMaterial == Enum.Material.Air then
			lastMagnitude = (rootPart.AssemblyLinearVelocity * Vector3.yAxis).Y
			return
		end
		if not lastMagnitude or lastMagnitude > MovementConfig.MinimumVelocityToRoll then return end

		character:SetAttribute("Rolling", true)

		module.LastRoll = 0

		if endedConnection then endedConnection:Disconnect() end

		local rollTrack = AnimationsManager.GetTrack(humanoid.Animator, ParkourAnimations.Roll)
		rollTrack:Play()
		rollTrack:AdjustSpeed(1.25)

		RollNotifier:Fire(currentDifference)

		local walkSpeed = calculateBoost(currentDifference)

		if currentDifference < 0.05 then
			SoundsAssets.GoodRoll:Play()
		else
			SoundsAssets.BadRoll:Play()
		end

		humanoid.WalkSpeed = walkSpeed

		endedConnection = rollTrack.Ended:Connect(function()
			character:SetAttribute("Rolling", false)
		end)
	end)
end

local function handleConnections()
	if localPlayer.Character then initCharacter(localPlayer.Character) end

	localPlayer.CharacterAdded:Connect(initCharacter)
end

module.Connection = Schedules["Boot"].job(handleConnections)

return module
