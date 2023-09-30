local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local Modules = RS:WaitForChild("Modules")
local FastCast = require(Modules:WaitForChild("FastCastRedux"))

local GunFire = Net.ReferenceBridge("GunFire")
local I_HitPosition = Net.ReferenceIdentifier("Gun_HitPosition")

local DefaultConfig = require(script:WaitForChild("DefaultConfig"))

local BulletParts = script:WaitForChild("Bullets")

local CosmeticBulletsFolder = workspace:FindFirstChild("CosmeticBulletsFolder") or Instance.new("Folder", workspace)
CosmeticBulletsFolder.Name = "CosmeticBulletsFolder"

local RNG = Random.new()
local TAU = math.pi * 2	

local _GS = {}
local PlayersEquipped = {}

local Resources
local Cooldowns
local Utility

function _GS.Init(Resources_)
	Resources = Resources_
	Utility = Resources.Utility
	Cooldowns = Utility.Cooldowns
end

local function GetConfig(Config_)
	local NewTable = {}
	for Index, Value in pairs(DefaultConfig) do
		NewTable[Index] = Config_[Index] or Value
	end
	return NewTable
end

function SetupCaster(Player, Config)
	local Damage = Config.Damage
	
	local Caster = FastCast.new()
	
	local CosmeticBullet = BulletParts:FindFirstChild(Config.Bullet) or BulletParts:WaitForChild("DefaultTracer")
	
	local function OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
		local HitPart = raycastResult.Instance
		local HitPoint = raycastResult.Position
		local Normal = raycastResult.Normal
		if HitPart ~= nil and HitPart.Parent ~= nil then 
			local Humanoid = HitPart.Parent:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid:TakeDamage(Damage)
			end
		end
	end

	local function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
		if cosmeticBulletObject == nil then return end
		local bulletLength = cosmeticBulletObject.Size.Z / 2
		local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
		local newCFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
		cosmeticBulletObject.CFrame = newCFrame
	end

	local function OnRayTerminated(cast)
		local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
		if cosmeticBullet ~= nil then
			cosmeticBullet:Destroy()
		end
	end

	Caster.RayHit:Connect(OnRayHit)
	Caster.LengthChanged:Connect(OnRayUpdated)
	Caster.CastTerminating:Connect(OnRayTerminated)
	
	return Caster
end

function Fire(Player, Info, HitPosition)
	local Tool = Info.Tool
	local Handle = Tool:WaitForChild("Handle")
	local FirePoint = Tool:FindFirstChild("FirePoint") or Handle:FindFirstChild("FirePoint") or Handle
	local FirePos = FirePoint:IsA("Attachment") and FirePoint.WorldPosition or FirePoint.Position
	
	local Caster = Info.Caster
	
	local Config = Info.Config
	local Speed = Config.Speed
	local MaxDistance = Config.MaxDistance
	local Acceleration = Config.Acceleration
	
	local MinSpread = Config.MinSpread
	local MaxSpread = Config.MaxSpread
	
	local CosmeticBullet = BulletParts:FindFirstChild(Config.Bullet) or BulletParts:WaitForChild("DefaultTracer")
	
	local Character = Player.Character
	local HumRP = Character:WaitForChild("HumanoidRootPart")
	
	local CastParams = RaycastParams.new()
	CastParams.IgnoreWater = true
	CastParams.FilterType = Enum.RaycastFilterType.Exclude
	CastParams.FilterDescendantsInstances = {Character}
	
	local CastBehavior = FastCast.newBehavior()
	CastBehavior.RaycastParams = CastParams
	CastBehavior.MaxDistance = MaxDistance
	CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default
	
	CastBehavior.CosmeticBulletTemplate = CosmeticBullet
	CastBehavior.CosmeticBulletContainer = CosmeticBulletsFolder
	CastBehavior.Acceleration = Acceleration
	CastBehavior.AutoIgnoreContainer = true
	
	local Direction = (HitPosition - FirePos).Unit
	local DirectionalCF = CFrame.new(Vector3.new(), Direction)
	Direction = (DirectionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(MinSpread, MaxSpread)), 0, 0)).LookVector

	local ModifiedBulletSpeed = (Direction * Speed)
	
	Caster:Fire(FirePos, Direction, ModifiedBulletSpeed, CastBehavior)
end

function _GS.Setup(Player, Tool_, Config_)
	local CooldownHandler = Cooldowns.Get(Player)
	
	local Config = GetConfig(Config_)
	
	local Character = Player.Character
	local RightArm = Character:WaitForChild("Right Arm")
	local Hum = Character:WaitForChild("Humanoid")
	local HumRP = Character:WaitForChild("HumanoidRootPart")
	
	Hum:UnequipTools()
	
	local Tool = Tool_:Clone()
	local Handle = Tool.Handle
	Tool.Parent = Character
	
	local Weld = Utility.Weld(RightArm, Handle)
	
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if RightGrip then
		RightGrip:Destroy()
	end
	
	local Caster = SetupCaster(Player, Config)
	
	PlayersEquipped[Player] = {
		Tool = Tool,
		Config = Config,
		
		Caster = Caster,
		CooldownHandler = CooldownHandler,
	}
	
	return {
		["Unequipped"] = function()
			Tool:Destroy()
			Weld:Destroy()

			PlayersEquipped[Player] = nil
		end,
	}
end

GunFire.OnServerInvoke = function(Player, Content)
	local Info = PlayersEquipped[Player]
	if Info then else return end
		
	local HitPosition = Content[I_HitPosition]
	if HitPosition and (typeof(HitPosition) == "Vector3") then else return end
	
	local Tool = Info.Tool
	
	local CooldownHandler = Info.CooldownHandler
	local Success, EndTime = CooldownHandler:Check(Tool)	
	if Success then else return Success, EndTime end
	
	local Config = Info.Config
	local Cooldown = Config.Cooldown
	
	CooldownHandler:Set(Tool, Cooldown)
	
	local Amount = Config.BulletsPerShot
	for i = 1, Amount do
		Fire(Player, Info, HitPosition)
	end
	
	return Success, EndTime
end
	
return _GS