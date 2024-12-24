local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

type InputTable = {
	Keys: { Enum.KeyCode | Enum.UserInputType },
	OnBegan: (() -> ())?,
	OnEnded: (() -> ())?,
	HoldingRequirements: { Enum.KeyCode | Enum.UserInputType },
	TouchButton: boolean,
}

type Module = {
	addInput: (string, InputTable) -> (),
	addAction: (string, () -> ()) -> (),
}

local inputs: { [string]: InputTable } = {}

local inputFunctions: { [Enum.UserInputState]: ((() -> ())?, (() -> ())?) -> () } = {
	[Enum.UserInputState.Begin] = function(onBegan: (() -> ())?)
		if onBegan then onBegan() end
	end,

	[Enum.UserInputState.End] = function(_, onEnded: (() -> ())?)
		if onEnded then onEnded() end
	end,
}

local module = {} :: Module

function module.addInput(inputName: string, inputTable: InputTable)
	if not inputName or not inputTable.Keys then
		warn("Couldn't make Input: No input name or keys")
		return
	end
	if not inputTable.OnBegan and not inputTable.OnEnded then return end
	inputTable.HoldingRequirements = inputTable.HoldingRequirements or {}
	inputTable.TouchButton = inputTable.TouchButton or false
	inputs[inputName] = inputTable
end

local function setupInput(input: InputTable, name: string)
	ContextActionService:BindAction(name, function(_, state: Enum.UserInputState)
		for _, key in input.HoldingRequirements do
			if not UserInputService:IsKeyDown(key) then return Enum.ContextActionResult.Pass end
		end
		if inputFunctions[state] then inputFunctions[state](input.OnBegan, input.OnEnded) end

		return Enum.ContextActionResult.Pass
	end, input.TouchButton, unpack(input.Keys))
end

local function init()
	for name, input in inputs do
		setupInput(input, name)
	end

	local inputMt = {
		__newindex = function(t: any, i: string, v: InputTable)
			setupInput(v, i)
			rawset(t, i, v)
		end,
	}
	setmetatable(inputs, inputMt)
end

init()

return module
