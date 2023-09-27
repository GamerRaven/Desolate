local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local GunFire = Net.ReferenceBridge("GunFire")

local _GS = {}

local Resources
local Utility

function _GS.Init(Resources_)
	Resources = Resources_
	Utility = Resources.Utility
end

function _GS.Setup(Player, Tool_, Config)
	local Character = Player.Character
	local RightArm = Character:WaitForChild("Right Arm")
	local Hum = Character:WaitForChild("Humanoid")
	local HumRP = Character:WaitForChild("HumanoidRootPart")
	
	Hum.Animator:LoadAnimation(script:WaitForChild("Animation")):Play()
	
	Hum:UnequipTools()
	
	local Tool = Tool_:Clone()
	local Handle = Tool.Handle
	Tool.Parent = Character
	
	local Weld = Utility.Weld(RightArm, Handle)
	
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if RightGrip then
		RightGrip:Destroy()
	end
	
	return {
		["Unequipped"] = function()
			Tool:Destroy()
			Weld:Destroy()
		end,
	}
end
	
return _GS