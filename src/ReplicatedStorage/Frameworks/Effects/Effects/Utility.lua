local Functions = {}

local EffectsFolder = workspace:FindFirstChild("Effects") or Instance.new("Folder")
EffectsFolder.Name = "Effects"
EffectsFolder.Parent = workspace

function Functions.Weld(_, _, a, b)
	local w = Instance.new("Weld")
	w.Part0 = a
	w.Part1 = b
	w.C0 = a.CFrame:inverse() * b.CFrame
	w.Parent = a
	return w
end

function Functions.Parenting(_, _, part)
	if part then
		part.Parent = EffectsFolder
	else
		return EffectsFolder
	end
end

function Functions.Draw(_, _, p, vec_1, vec_2)
	local m = (vec_1 - vec_2).Magnitude
	p.Size = Vector3.new(p.Size.X, p.Size.Y, m)
	p.CFrame = CFrame.new(
		vec_1:Lerp(vec_2, 0.5),
		vec_2
	)
	return p
end

return Functions