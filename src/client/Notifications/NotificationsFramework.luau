local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIAssets = ReplicatedStorage.Assets.UI

local Signal = require(ReplicatedStorage.Packages.Signal)

local notifySignal = Signal.new()

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

local NotifyUI = UIAssets.Notifier:Clone()
NotifyUI.Parent = PlayerGui

local labelsCache = {}
local tweensCache = {
	firstTween = {},
	lastTween = {},
}

local defaultColor = Color3.new(1, 1, 1)
local offset = UDim2.fromOffset(0, -15)

local firstTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local lastTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function setupLabel(label, properties)
	local color = properties.color or defaultColor
	local text = properties.text or ""
	local position = if properties.position then properties.position else UDim2.fromScale(0.5, 0.5)

	position += offset

	label.TextTransparency = 1
	label.TextStrokeTransparency = 1

	label.Text = text
	label.TextColor3 = color

	label.Position = position
	label.Visible = true
	label.Parent = NotifyUI
end

local function skipFirstTween(label)
	label.TextTransparency = 0
	label.TextStrokeTransparency = 0.5
end

local function runAnimation(label, category, index)
	local firstTween =
		TweenService:Create(label, firstTweenInfo, { Position = label.Position + offset, TextTransparency = 0, TextStrokeTransparency = 0.5 })

	tweensCache.firstTween[label] = firstTween

	firstTween:Play()
	firstTween.Completed:Wait()

	task.wait(0.6)

	local lastTween = TweenService:Create(
		label,
		lastTweenInfo,
		{ Position = label.Position - (UDim2.fromOffset(0, offset.Y.Offset * 4)), TextTransparency = 1, TextStrokeTransparency = 1 }
	)

	tweensCache.lastTween[label] = lastTween

	lastTween:Play()

	lastTween.Completed:Connect(function()
		labelsCache[category][index] = nil
		label:Destroy()

		firstTween:Destroy()
		lastTween:Destroy()
		tweensCache.firstTween[label] = nil
		tweensCache.lastTween[label] = nil
	end)
end

notifySignal:Connect(function(properties)
	local category = properties.category

	if not labelsCache[category] then labelsCache[category] = {} end

	local index = #labelsCache[category] + 1

	local newLabel = NotifyUI.Template:Clone()
	newLabel.Name = #labelsCache[category] + 1

	for i = 1, #labelsCache[category] do
		local label = labelsCache[category][i]

		if not label then continue end

		label.Position += UDim2.fromOffset(0, newLabel.AbsoluteSize.Y)

		if tweensCache.firstTween[label] then
			tweensCache.firstTween[label]:Cancel()
			skipFirstTween(label)
		end
	end

	table.insert(labelsCache[category], newLabel)

	setupLabel(newLabel, properties)
	runAnimation(newLabel, category, index)
end)

return notifySignal
