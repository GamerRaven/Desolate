local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local ToolEquip = Net.ReferenceBridge("ToolEquip")
local ToolUnequip = Net.ReferenceBridge("ToolUnequip")

local GunFire = Net.ReferenceBridge("GunFire")

local I_HitPosition = Net.ReferenceIdentifier("Gun_HitPosition")

return function(Frameworks, ToolName, Info)
	ToolEquip:InvokeServerAsync(ToolName)
	
	local Holdable = Info.Holdable
	
	local Camera = Frameworks.Camera
	local Input = Frameworks.Input
	local Utility = Frameworks.Utility
	local Cooldowns = Utility.Cooldowns
	
	Camera.ToggleEvent:Fire(true)
	
	local InputHandler = Input.New(Enum.UserInputType.MouseButton1, "Both")
	
	local function Fire()
		local ClientSuccess = Cooldowns.Check(ToolName) 
		if ClientSuccess == true then else return end

		local Direction, HitPosition, RaycastResult = Utility.GetHitPosition()
		local Success, EndTime = GunFire:InvokeServerAsync({
			[I_HitPosition] = HitPosition,
		})

		Cooldowns.Set(ToolName, EndTime) 
	end
	
	local Holding = false
	local HoldingConnection
	if Holdable then
		HoldingConnection = RunService.Stepped:Connect(function()
			if Holding then 
				Fire()
			end
		end)
	end
	
	InputHandler.TriggerEvent:Connect(function(State)
		if Holdable then
			Holding = State
		elseif State == true then
			Fire()
		end
	end)
	
	return function()
		if HoldingConnection then
			HoldingConnection:Disconnect()
		end
		
		ToolUnequip:Fire()
		InputHandler:Destroy()
		Camera.ToggleEvent:Fire(false)
	end
end