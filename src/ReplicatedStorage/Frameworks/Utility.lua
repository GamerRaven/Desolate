local RS = game:GetService("ReplicatedStorage")

local Modules = RS:WaitForChild("Modules")
local GoodSignal = require(Modules:WaitForChild("GoodSignal"))

local _U = {
	["GoodSignal"] = GoodSignal
}



return _U