local Resources = {}

for _, Module in pairs(script:GetChildren()) do
	if Module:IsA("ModuleScript") then
		Resources[Module.Name] = require(Module)
	end
end

for _, Module in pairs(Resources) do
	if type(Module) == "table" and (Module["Init"]) then
		task.spawn(function() Module.Init(Resources) end)
	end
end

return Resources