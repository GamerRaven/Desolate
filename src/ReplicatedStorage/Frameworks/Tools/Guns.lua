local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local ToolEquip = Net.ReferenceBridge("ToolEquip")
local ToolUnequip = Net.ReferenceBridge("ToolUnequip")

local GunFire = Net.ReferenceBridge("GunFire")

local I_HitPosition = Net.ReferenceIdentifier("Gun_HitPosition")

return function(Frameworks, ToolName, Info)
	ToolEquip:InvokeServerAsync(ToolName)
	
	local Camera = Frameworks.Camera
	local Input = Frameworks.Input
	local Utility = Frameworks.Utility
	
	Camera.ToggleEvent:Fire(true)
	
	local InputHandler = Input.New(Enum.UserInputType.MouseButton1, "Both")
	InputHandler.TriggerEvent:Connect(function(State)
		local Direction, HitPosition, RaycastResult = Utility.GetHitPosition()
		GunFire:Fire({
			[I_HitPosition] = HitPosition,
		})
	end)
	
	return function()
		ToolUnequip:Fire()
		InputHandler:Destroy()
		Camera.ToggleEvent:Fire(false)
	end
end