local Frameworks = {}

local Priority = {
	[1] = "Utility",
	[2] = "Camera",
	[3] = "Input",
	[4] = "Inventory",
	[5] = "Tools",
	[6] = "Effects" -- Always have effects set to last
}

for _, Module in pairs(script:GetChildren()) do
	if Module:IsA("ModuleScript") then else continue end
	Frameworks[Module.Name] = require(Module)
end

local function RunFramework(Framework)
	if Framework then else return end
	if type(Framework) == "table" then
		if (Framework["Init"]) then
			task.spawn(function() Framework.Init(Frameworks) end)
		elseif (Framework["InitMethod"]) then
			task.spawn(function() Framework:InitMethod(Frameworks) end)
		end
	end
end
	
for _, Name in pairs(Priority) do
	RunFramework(Frameworks[Name])
end

for Name, Framework in pairs(Frameworks) do
	if table.find(Priority, Name) then continue end
	RunFramework(Framework)
end

return Frameworks