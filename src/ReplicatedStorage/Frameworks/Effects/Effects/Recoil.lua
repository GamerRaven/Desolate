local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local Modules = RS:WaitForChild("Modules")
local Spring = require(Modules:WaitForChild("Spring"))

local Camera = workspace.CurrentCamera

local SpringSettings = {
	["Normal"] = {2, 11, 30, 0, 10, 0}
}

local Springs = {}

RunService.RenderStepped:Connect(function(DeltaTime)
	for _, Spring in pairs(Springs) do
		local Vertical = Spring[1].Offset
		local Horizontal = Spring[2].Offset
		
		local CameraCFrame = Camera.CFrame
		Camera.CFrame = CameraCFrame:Lerp(CameraCFrame * CFrame.Angles(math.rad(Vertical), math.rad(Horizontal), 0), 0.1)
	end
end)

return function(Frameworks, Effects, Vertical, Horizontal, SpringSetting)
	local SettingName = SpringSetting or "Normal"
	local Setting = SpringSettings[SettingName]
	local RecoilSpring = Springs[SettingName]
	if RecoilSpring then else
		Springs[SettingName] = {Spring.new(table.unpack(Setting)), Spring.new(table.unpack(Setting))}
		RecoilSpring = Springs[SettingName]
	end
	
	RecoilSpring[1]:AddOffset(Vertical) 
	RecoilSpring[2]:AddOffset(Horizontal) 
end