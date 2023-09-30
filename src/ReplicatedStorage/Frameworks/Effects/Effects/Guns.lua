local TweenService = game:GetService("TweenService")

local Blood_ = script:WaitForChild("Blood")

local function GetRandRot()
	return math.random(-360,360)
end

local Functions = {}

function Functions.Hit(Frameworks, EffectModules, Character)
	local HumRP = Character:WaitForChild("HumanoidRootPart")
	for i = 1, math.random(3,7), 1 do
		local BloodPart = Blood_:Clone()
		BloodPart.Position = HumRP.Position

		local x = math.random(-15,15)
		local y = math.random(15,30)
		local z = math.random(-15,15)

		local Rotation = Vector3.new(GetRandRot(), GetRandRot(), GetRandRot())
		BloodPart.Rotation = Rotation

		BloodPart.Velocity = Vector3.new(x,y,z)
		EffectModules.Utility.Parenting(BloodPart)

		task.delay(2, function()
			BloodPart:Destroy()
		end)
	end
end

function Functions.FireLight(Frameworks, EffectModules, FirePoint)
	local LightLifeTime = 0.3

	local FirePart = FirePoint:Clone()
	FirePart:ClearAllChildren()
	FirePart.Position = FirePoint.Position
	FirePart.Anchored = true
	EffectModules.Utility.Parenting(FirePart)

	local PointLight = Instance.new("PointLight")
	PointLight.Brightness = 2
	PointLight.Color = Color3.fromRGB(255, 231, 94)
	PointLight.Range = 25
	PointLight.Parent = FirePart

	local SurfaceLight = Instance.new("SurfaceLight")
	SurfaceLight.Brightness = 50
	SurfaceLight.Color = Color3.fromRGB(255, 231, 94)
	SurfaceLight.Range = 15
	SurfaceLight.Face = "Back"
	SurfaceLight.Parent = FirePart

	TweenService:Create(PointLight, TweenInfo.new(LightLifeTime), {Brightness = 0}):Play()
	TweenService:Create(SurfaceLight, TweenInfo.new(LightLifeTime), {Brightness = 1}):Play()

	task.delay(LightLifeTime, function()
		FirePart:Destroy()
	end)

	return FirePart
end

function Functions.Fire(Frameworks, EffectModules, FirePoint, FireSound)
	local Sounds = Frameworks.Sounds

	local GunEquip = Sounds.Get(FireSound, FirePoint):Play()
	
	Functions.FireLight(Frameworks, EffectModules, FirePoint) 
end

return function(Frameworks, EffectModules, Type, ...)
	if Functions[Type] then
		return Functions[Type](Frameworks, EffectModules, ...)
	end
end