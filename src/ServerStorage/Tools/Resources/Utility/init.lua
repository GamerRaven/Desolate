local _U = {}

--// Weld
function _U.Weld(a, b, setCframe)
	setCframe = setCframe == nil and true or setCframe

	local w = Instance.new("Motor6D")
	w.Part0 = a
	w.Part1 = b
	if setCframe then
		w.C0 = a.CFrame:inverse() * b.CFrame
	end
	w.Parent = a

	return w
end

_U.Cooldowns = require(script:WaitForChild("Cooldowns"))
_U.Effects = require(script:WaitForChild("Effects"))

return _U