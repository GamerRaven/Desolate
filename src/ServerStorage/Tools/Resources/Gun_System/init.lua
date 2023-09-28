local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local GunFire = Net.ReferenceBridge("GunFire")
	
local I_HitPosition = Net.ReferenceIdentifier("Gun_HitPosition")

local DefaultConfig = require(script:WaitForChild("DefaultConfig"))

local _GS = {}
local PlayersEquipped = {}

local Resources
local Utility

function _GS.Init(Resources_)
	Resources = Resources_
	Utility = Resources.Utility
end

local function GetConfig(Config_)
	local NewTable = {}
	for Index, Value in pairs(DefaultConfig) do
		NewTable[Index] = Config_[Index] or Value
	end
	return NewTable
end

function _GS.Setup(Player, Tool_, Config_)
	local Config = GetConfig(Config_)
	
	local Character = Player.Character
	local RightArm = Character:WaitForChild("Right Arm")
	local Hum = Character:WaitForChild("Humanoid")
	local HumRP = Character:WaitForChild("HumanoidRootPart")
	
	local Animation = Hum.Animator:LoadAnimation(script:WaitForChild("Animation"))
	Animation:Play()
	
	Hum:UnequipTools()
	
	local Tool = Tool_:Clone()
	local Handle = Tool.Handle
	Tool.Parent = Character
	
	local Weld = Utility.Weld(RightArm, Handle)
	
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if RightGrip then
		RightGrip:Destroy()
	end
	
	PlayersEquipped[Player] = {
		Tool = Tool,
		Config = Config,
	}
	
	return {
		["Unequipped"] = function()
			Tool:Destroy()
			Weld:Destroy()
			Animation:Stop()
			
			PlayersEquipped[Player] = nil
		end,
	}
end

GunFire:Connect(function(Player, Content)
	local Info = PlayersEquipped[Player]
	if Info then else return end
		
	local HitPosition = Content[I_HitPosition]
	if HitPosition and (typeof(HitPosition) == "Vector3") then else return end
	
	print(HitPosition)
end)
	
return _GS