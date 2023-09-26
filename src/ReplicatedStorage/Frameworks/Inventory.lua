local _I = {}

local Frameworks
local Input
local Tools

local Keycodes = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Zero"
}

local CurrentEquiped

local MainInventory = {
	"Pistol"
}

function _I.Init(Frameworks_)
	Frameworks = Frameworks_
	Input = Frameworks.Input
	Tools = Frameworks.Tools
	
	for Index, Keycode in pairs(Keycodes) do
		local InputHandler = Input.New(Enum.KeyCode[Keycode], true)
		InputHandler.TriggerEvent:Connect(function()
			local ToolName = MainInventory[Index]
			if ToolName then
				Tools.Equip(ToolName)								
			end
		end)
	end
end
	
return _I