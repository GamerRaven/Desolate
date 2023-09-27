local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local ToolEquip = Net.ReferenceBridge("ToolEquip")
local GunFire = Net.ReferenceBridge("GunFire")

return function(Frameworks, ToolName, Info)
	ToolEquip:InvokeServerAsync(ToolName)
	
	local Input = Frameworks.Input
	local InputHandler = Input.New(Enum.UserInputType.MouseButton1, "Both")
	InputHandler.TriggerEvent:Connect(function(State)
		
	end)
	
	return function()
		InputHandler:Destroy()
	end
end