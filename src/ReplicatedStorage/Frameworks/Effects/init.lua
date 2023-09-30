local _E = {}

local EffectEvents = script:WaitForChild("Events")
local EffectModules = {}

function _E.Init(Frameworks)
	local function LoopEffects(Folder)
		local LoopFolder = Folder or script:WaitForChild("Effects")
		for _, Module in pairs(LoopFolder:GetChildren()) do
			if Module:IsA("Folder") then LoopEffects(Module) end 
			if Module:IsA("ModuleScript") then else return end
			
			local RequiredModule = require(Module)
			if typeof(RequiredModule) == "table" then
				EffectModules[Module.Name] = {}
				
				for Name, Function in pairs(RequiredModule) do
					EffectModules[Module.Name][Name] = function(...)
						return Function(Frameworks, EffectModules, ...)
					end
				end
			else
				EffectModules[Module.Name] = function(...)
					return RequiredModule(Frameworks, EffectModules, ...)
				end
			end
		end
	end
	
	LoopEffects()
	
	for _, Module in pairs(EffectEvents:GetChildren()) do
		if Module:IsA("ModuleScript") then else return end
		require(Module)(Frameworks, EffectModules)
	end
	
	Frameworks["Effects"] = EffectModules
end

return _E