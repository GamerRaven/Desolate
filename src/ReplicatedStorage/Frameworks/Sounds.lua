local ContentProvider = game:GetService("ContentProvider")

local SoundsFolder = script:WaitForChild("Sounds")

local SoundsCache = {}

local _S = {}

function _S.Init()
	for _, Sound in pairs(SoundsFolder:GetChildren()) do
		SoundsCache[Sound.Name] = Sound
	end
	
	for _, Sound in pairs(SoundsCache) do
		ContentProvider:PreloadAsync({Sound})
	end
end

function _S.New(SoundName, Parent)
	if SoundsCache[SoundName] then
		local Sound = SoundsCache[SoundName]:Clone()
		Sound.Parent = Parent
		
		return Sound
	end
end

function _S.Get(SoundName, Parent)
	if Parent then else return {Play = function() end} end
	return Parent:FindFirstChild(SoundName) or _S.New(SoundName, Parent)
end

return _S
