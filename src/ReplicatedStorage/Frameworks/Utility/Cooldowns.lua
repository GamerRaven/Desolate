--// Designed for local clients

local _C = {}
_C.__index = _C

local Cooldowns = {}

function _C.Cooldown(Name, Duration)
	Cooldowns[Name] = workspace:GetServerTimeNow() + Duration
end

function _C.Set(Name, EndTime)
	Cooldowns[Name] = EndTime
end

function _C.Check(Name)
	local TimeNow = workspace:GetServerTimeNow()
	local CurrentCooldown = Cooldowns[Name] or 0
	return TimeNow >= CurrentCooldown, CurrentCooldown
end

function _C.Remove(Name)
	Cooldowns[Name] = nil
end

return _C