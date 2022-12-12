local ReplicatedStorage 	 	= game:GetService("ReplicatedStorage");
local Player			   	  	= game:GetService("Players").LocalPlayer;
local ContextActionSerivce 	= game:GetService("ContextActionService");
local RunService				= game:GetService("RunService");
local StarterGui				= game:GetService("StarterGui");

local Scripts = ReplicatedStorage:WaitForChild("Scripts");
local Handler = require(Scripts:WaitForChild("Handler"));
local Module = Handler.new(Player, workspace.CurrentCamera);

local PlayerGui = Player:WaitForChild("PlayerGui");
local DebugGui = PlayerGui:WaitForChild("Debug");

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);

local function DebugMode(actionName, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		DebugGui.Enabled = not DebugGui.Enabled;
	end
	return Enum.ContextActionResult.Pass;
end

local function LeftMouseClick(actionName, inputState, inputObject)
	Module.mouseDown = inputState == Enum.UserInputState.Begin;
	
	return Enum.ContextActionResult.Pass;
end

ContextActionSerivce:BindAction("DebugMode", DebugMode, false, Enum.KeyCode.D);
ContextActionSerivce:BindAction("LeftClick", LeftMouseClick, false, Enum.UserInputType.MouseButton1);

local function update(dt)
	Module:update(dt);
end

RunService.RenderStepped:Connect(update);