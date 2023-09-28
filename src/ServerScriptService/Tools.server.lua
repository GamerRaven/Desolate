local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Modules = RS:WaitForChild("Modules")

local ToolsInfo = require(Modules:WaitForChild("ToolsInfo"))
local ToolTypes = ServerStorage:WaitForChild("Tools")

local ToolsResources = require(ToolTypes:WaitForChild("Resources"))

local Net = require(RS:WaitForChild("Net"))
local ToolEquip = Net.ReferenceBridge("ToolEquip")
local ToolUnequip = Net.ReferenceBridge("ToolUnequip")

local GunFire = Net.ReferenceBridge("GunFire")

local PlayersEquip = {}

ToolEquip.OnServerInvoke = function(Player, ToolName)
	--// Check Inventory
	
	local Info = ToolsInfo[ToolName]
	if Info then else return end

	local Type = Info.Type
	local TypeFolder = ToolTypes:FindFirstChild(Type)
	if TypeFolder then else return end

	local ToolModule = TypeFolder:FindFirstChild(ToolName)
	if ToolModule then else return end
	
	PlayersEquip[Player] = require(ToolModule)(ToolsResources, Player) or {}
	
	return PlayersEquip[Player].ClientData
end

ToolUnequip:Connect(function(Player)
	local Info = PlayersEquip[Player]
	if Info then
		Info.Unequipped()
	end
	
	PlayersEquip[Player] = nil
end)

Players.PlayerRemoving:Connect(function(Player)
	if PlayersEquip[Player] then
		PlayersEquip[Player].Unequipped(Player)
		PlayersEquip[Player] = nil
	end
end)