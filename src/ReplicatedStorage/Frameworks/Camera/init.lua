local _C = {}
_C.__index = _C;

-- [[ Variables ]]:

--// Services and requires
local Players = game:GetService("Players");
local WorkspaceService = game:GetService("Workspace");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
local Maid = require(script.Utils:WaitForChild("Maid"));
local Spring = require(script.Utils:WaitForChild("Spring"));

--// Instances
local LocalPlayer = Players.LocalPlayer;

--// Bindables
local ToggleEvent = script:WaitForChild("Toggle");
local EditConfig = script:WaitForChild("EditConfig");

_C.ToggleEvent = ToggleEvent
_C.EditConfig = EditConfig
_C.FirstPerson = false

--// Configuration
local config = {
	["CHARACTER_SMOOTH_ROTATION"]   = true,                       --// If your character should rotate smoothly or not
	["MANUALLY_TOGGLEABLE"]         = true,                       --// If the OTS an be toggled manually by player
	["CHARACTER_ROTATION_SPEED"]    = 7,                          --// How quickly character rotates smoothly
	["TRANSITION_SPRING_DAMPER"]    = 0.8,                        --// Camera transition spring damper, test it out to see what works for you
	["CAMERA_TRANSITION_IN_SPEED"]  = 20,                         --// How quickly locked camera moves to offset position
	["CAMERA_TRANSITION_OUT_SPEED"] = 25,                         --// How quickly locked camera moves back from offset position
	["LOCKED_CAMERA_OFFSET"]        = Vector3.new(1.75, 0.25, 0), --// Locked camera offset
	--["LOCKED_MOUSE_ICON"]           =                             --// Locked mouse icon
	--	"rbxasset://textures/MouseLockedCursor.png",
}

local ENABLED = false;

--// Setup
local maid = Maid.new();

-- [[ Functions ]]:

--// Setup smooth OTS on client (Run once and on a LocalScript)
function _C:InitMethod()
	local managerMaid = Maid.new();
	
	if LocalPlayer.Character then
		self:CharacterAdded();
	end

	managerMaid:GiveTask(LocalPlayer.CharacterAdded:Connect(function()
		self:CharacterAdded();
	end));
end;

--// Character added event function
function _C:CharacterAdded()
	local self = setmetatable({}, _C);
	--// Instances
	self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
	self.RootPart = self.Character:WaitForChild("HumanoidRootPart");
	self.Humanoid = self.Character:WaitForChild("Humanoid");
	self.Head = self.Character:WaitForChild("Head");
	--// Other
	self.Camera = WorkspaceService.CurrentCamera;
	--// Setup
	self.connectionsMaid = Maid.new();
	self.camOffsetSpring = Spring.new(Vector3.new(0, 0, 0));
	self.camOffsetSpring.Damper = config.TRANSITION_SPRING_DAMPER;
	
	--// Update camera offset
	self.connectionsMaid:GiveTask(RunService.RenderStepped:Connect(function()
		if self.Head.LocalTransparencyModifier > 0.6 then _C.FirstPerson = true return end;
		
		local camCF = self.Camera.CoordinateFrame;
		local distance = (self.Head.Position - camCF.p).magnitude;
		
		_C.FirstPerson = false
		
		--// Camera offset
		if (distance > 1) then	
			self.Camera.CFrame = (self.Camera.CFrame * CFrame.new(self.camOffsetSpring.Position)); 
			
			if (ENABLED) and (UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter) then
				self:SetMouseState(ENABLED);
			end;
		end;
	end));
	
	--// Bindables
	self.connectionsMaid:GiveTask(ToggleEvent.Event:Connect(function(toggle: boolean)
		if (self.Humanoid and self.Humanoid.Health ~= 0) then
			self:ToggleOTS(toggle);
		end;
	end));
	
	self.connectionsMaid:GiveTask(EditConfig.Event:Connect(function(toChange, value)
		if config[toChange] ~= nil then
			config[toChange] = value;
		end;
	end));
	
	--// On death
	self.connectionsMaid:GiveTask(self.Humanoid.Died:Connect(function()
		self:CharacterDiedOrRemoved();
		return;
	end));
	
	--// On character removing
	self.connectionsMaid:GiveTask(LocalPlayer.CharacterRemoving:Connect(function()
		self:CharacterDiedOrRemoved();
		return;
	end));

	return self;
end;

--// Stop upon character death or removal
function _C:CharacterDiedOrRemoved()
	self:ToggleOTS(false);
	
	if self.connectionsMaid ~= nil then
		self.connectionsMaid:Destroy();
	end;
	
	maid:DoCleaning();
end;

--// Return enabled state
function _C:IsEnabled(): boolean
	return ENABLED;
end;

--// Set Enum.MouseBehavior to LockCenter or Default depending on enabled
function _C:SetMouseState(enable : boolean)
	UserInputService.MouseBehavior = (enable and Enum.MouseBehavior.LockCenter) or (Enum.MouseBehavior.Default);
end;

--// Change mouse icon depending on enabled
function _C:SetMouseIcon(enable : boolean)
	UserInputService.MouseIcon = (enable and config.LOCKED_MOUSE_ICON :: string) or "";
end;

--// Tween locked camera offset position
function _C:TransitionLockOffset(enable : boolean)
	if (enable) then
		self.camOffsetSpring.Speed = config.CAMERA_TRANSITION_IN_SPEED;
		self.camOffsetSpring.Target = config.LOCKED_CAMERA_OFFSET;
	else
		self.camOffsetSpring.Speed = config.CAMERA_TRANSITION_OUT_SPEED;
		self.camOffsetSpring.Target = Vector3.new(0, 0, 0);
	end;
end;

--// Toggle
function _C:ToggleOTS(enable : boolean)
	assert(typeof(enable) == typeof(false), "Enable value is not a boolean.");
	ENABLED = enable;

	self:SetMouseState(ENABLED);
	self:SetMouseIcon(ENABLED);
	self:TransitionLockOffset(ENABLED);
	
	--// Start
	if (ENABLED) then
		maid:GiveTask(RunService.RenderStepped:Connect(function(delta)
			if (self.Humanoid and self.RootPart) then 
				self.Humanoid.AutoRotate = not ENABLED;
			end;
			
			--// Rotate character
			if (ENABLED) then
				if not (self.Humanoid.Sit) and (config.CHARACTER_SMOOTH_ROTATION) then
					local x, y, z = self.Camera.CFrame:ToOrientation();
					self.RootPart.CFrame = self.RootPart.CFrame:Lerp(CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0), delta * 5 * config.CHARACTER_ROTATION_SPEED);
				elseif not (self.Humanoid.Sit) then
					local x, y, z = self.Camera.CFrame:ToOrientation();
					self.RootPart.CFrame = CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0);
				end;
			end;
			
			--// Stop
			if not (ENABLED) then 
				maid:Destroy() end;
		end));
	end;
	
	return self;
end;

return _C;