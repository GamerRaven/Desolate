local Players = game:GetService("Players")

local _C = {}
_C.__index = _C

local PlayersCooldown = {}

function _C.Get(Player)
	return PlayersCooldown[Player]
end

function _C:Set(Name, Duration)
	local Player = self.Player
	self.Cooldowns[Name] = workspace:GetServerTimeNow() + Duration
end

function _C:Check(Name)
	local TimeNow = workspace:GetServerTimeNow()
	local CurrentCooldown = self.Cooldowns[Name] or 0
	return TimeNow >= CurrentCooldown, CurrentCooldown
end

Players.PlayerAdded:Connect(function(Player)
	PlayersCooldown[Player] = setmetatable({
		Player = Player,
		Cooldowns = {}
	}, _C)
end)

Players.PlayerRemoving:Connect(function(Player)
	PlayersCooldown[Player] = nil
end)

return _C