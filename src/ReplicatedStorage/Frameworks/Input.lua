local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local Modules = RS:WaitForChild("Modules")
local GoodSignal = require(Modules:WaitForChild("GoodSignal"))

local _I = {}
_I.__index = _I

local ActiveInputs = {}
local Cache = {}

function GetKeyFromEnum(Input)
	if not Cache[Input] then
		local Name = Input and tostring(Input):split('.')[3]
		Cache[Input] = Name
		return Name
	else
		return Cache[Input]
	end
end

function _I.New(Input, State_)
	local Name = GetKeyFromEnum(Input)
	local State = State_ ~= nil and State_ or true

	if ActiveInputs[Name] then else
		ActiveInputs[Name] = {}
	end
	
	print(ActiveInputs)
	
	table.insert(ActiveInputs[Name], setmetatable({
		Name = Name,
		State = State,
		TriggerEvent = GoodSignal.new()
	}, _I))
	
	local Index = #ActiveInputs[Name]
	print(Index)
	ActiveInputs[Name][Index]["Index"] = Index
	
	return ActiveInputs[Name][Index]
end

function _I:Destroy()
	local Name = self.Name
	local Index = self.Index
	
	self.TriggerEvent:Disconnect()
	
	ActiveInputs[Name][Index] = nil
	
	self = nil
end

function InputTrigger(State, Input, IsTyping)
	if IsTyping then return end

	local Name = GetKeyFromEnum(Input.KeyCode)
	Name = Name ~= "Unknown" and Name or GetKeyFromEnum(Input.UserInputType)

	local Functions = ActiveInputs[Name]
	if Functions then
		for _, Info in pairs(Functions) do
			local Event = Info.TriggerEvent
			
			local NeededState = Info.State
			if NeededState == "Both" then return Event:Fire(State) end
			if State == NeededState then
				Event:Fire()
			end
		end
	end
end

UIS.InputBegan:Connect(function(Input, IsTyping) InputTrigger(true, Input, IsTyping) end)
UIS.InputEnded:Connect(function(Input, IsTyping) InputTrigger(false, Input, IsTyping) end)
	
return _I