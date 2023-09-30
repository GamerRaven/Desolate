local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character
if not Character or not Character.Parent then
	Character = Player.CharacterAdded:Wait()
end

local Hum = Character:WaitForChild("Humanoid")
local Animator = Hum:FindFirstChildOfClass("Animator") or Hum

local AnimationValues = require(script:WaitForChild("AnimationValues"))
local Cache = script:WaitForChild("Cache")

local ContentProvider = game:GetService("ContentProvider")

local Animations = {}
local PlayingAnimations = {}

local _A = {}
_A.__index = _A

function _A.Init(Frameworks)
	local Utility = Frameworks.Utility
	
	local Preload = {}
	for Name, Id in pairs(AnimationValues) do
		local Animation = Instance.new("Animation")
		Animation.Name = Name
		Animation.AnimationId = Id
		Animation.Parent = Cache
		
		Animations[Name] = Animation
		
		task.spawn(function()
			ContentProvider:PreloadAsync({Animation})
		end)
	end
	
	Utility.CharacterUpdated:Connect(function(NewChar)
		Character = NewChar
		Hum = Character:WaitForChild("Humanoid")
		Animator = Hum:FindFirstChildOfClass("Animator") or Hum
	end)
end

function _A.Play(Name, TransitionTime)
	local Animation = Animations[Name]
	if Animation then else return end
	
	local AnimationTrack = Animator:LoadAnimation(Animation)
	PlayingAnimations[Name] = AnimationTrack
	AnimationTrack:Play(TransitionTime)
	
	AnimationTrack.Stopped:Connect(function()
		print("yea")
		PlayingAnimations[Name] = false
	end)

	return AnimationTrack
end

function _A.Stop(Name)
	local AnimationTrack = PlayingAnimations[Name]
	if AnimationTrack then else return end
	AnimationTrack:Stop()
end

return _A