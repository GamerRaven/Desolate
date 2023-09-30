local RS = game:GetService("ReplicatedStorage")

local Modules = RS:WaitForChild("Modules")
local GoodSignal = require(Modules:WaitForChild("GoodSignal"))

local Cooldowns = require(script:WaitForChild("Cooldowns"))

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character
if not Character or not Character.Parent then
	Character = Player.CharacterAdded:Wait()
end
local HumRP = Character:WaitForChild("HumanoidRootPart")

local Mouse = Player:GetMouse()
local CurrentCamera = workspace.CurrentCamera

local _U = {
	["GoodSignal"] = GoodSignal,
	["Cooldowns"] = Cooldowns,
}

function _U.Raycast(StartCFrame, Direction, IgnoreList)
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = IgnoreList

	local RaycastResult = workspace:Raycast(StartCFrame.Position, Direction, Params)
	local HitPosition = RaycastResult and RaycastResult.Position or StartCFrame.Position + Direction

	return Direction, HitPosition, RaycastResult
end

function _U.Init(Frameworks)
	local Camera = Frameworks.Camera
	
	function _U.GetHitPosition(IgnoreList)
		IgnoreList = IgnoreList or {Character}
		
		if Camera.FirstPerson then
			local StartCFrame = CurrentCamera.CFrame
			return _U.Raycast(StartCFrame, StartCFrame.LookVector * 1000, IgnoreList)
		else
			local StartCFrame = HumRP.CFrame
			local HitPos = Mouse.Hit
			local Direction = (HitPos.Position - StartCFrame.Position).unit
			
			return _U.Raycast(StartCFrame, Direction * 1000, IgnoreList)
		end
	end
end

return _U