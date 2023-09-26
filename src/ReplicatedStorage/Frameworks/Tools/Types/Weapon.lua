local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

return function(Frameworks, ToolName, Info)
	local Input = Frameworks.Input
	local InputHandler = Input.New(Enum.UserInputType.MouseButton1, "Both")
	InputHandler.TriggerEvent:Connect(function(State)
		
	end)
	
	return function()
		InputHandler:Destroy()
	end
end