	local ToolsInfo = require(script:WaitForChild("Info"))
local ToolTypes = script:WaitForChild("Types")

local _T = {}

local Frameworks

function _T.Init(Frameworks_)
	Frameworks = Frameworks_
end

function _T.Equip(ToolName)
	local Info = ToolsInfo[ToolName]
	if Info then else return end
	
	local Type = Info.Type or "Weapon"
	local Module = ToolTypes:FindFirstChild(Type)
	if Module then else return end
	
	local RequiredModule = require(Module)
	RequiredModule(Frameworks, ToolName, Info)
end

return _T