local RS = game:GetService("ReplicatedStorage")
local Net = require(RS:WaitForChild("Net"))

local EffectsNet = Net.ReferenceBridge("Effects")
local EffectNameIdentifier = Net.ReferenceIdentifier("EffectName")
local DataIdentifier = Net.ReferenceIdentifier("Data")

local function Effect(Player, EffectName, ...)
	EffectsNet:Fire(Player, {
		[EffectNameIdentifier] = EffectName,
		[DataIdentifier] = {...},
	})
end

return {
	Effect = function(Player, ...)
		Effect(Player, ...)
	end,
	
	EffectAll = function(...)
		Effect(Net.AllPlayers(), ...)
	end,
	
	EffectExcept = function(Players, ...)
		Effect(Net.PlayersExcept(Players), ...)
	end,
}