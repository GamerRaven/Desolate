local RS = game:GetService("ReplicatedStorage")
local Modules = RS:WaitForChild("Modules")

local ToolsInfo = require(Modules:WaitForChild("ToolsInfo"))
local ToolTypes = script

local _T = {}

local Frameworks

function _T.Init(Frameworks_)
	Frameworks = Frameworks_
end

local Equipping = false

function _T.Equip(ToolName)
	local Info = ToolsInfo[ToolName]
	if Info then else return end
	
	if Equipping then Equipping(Frameworks) Equipping = false return end
	
	local Type = Info.Type or "Guns"
	local Module = ToolTypes:FindFirstChild(Type)
	if Module then else return end
	
	Equipping =	require(Module)(Frameworks, ToolName, Info)
end

return _T