local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local EffectsNet = Net.ReferenceBridge("Effects")
local EffectNameIdentifier = Net.ReferenceIdentifier("EffectName")
local DataIdentifier = Net.ReferenceIdentifier("Data")

return function(Frameworks, EffectModules)
	EffectsNet:Connect(function(Info)
		local EffectName = Info[EffectNameIdentifier]
		local Data = Info[DataIdentifier]
		
		if EffectModules[EffectName] then
			EffectModules[EffectName](table.unpack(Data))
		end
	end)
end