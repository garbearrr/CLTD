------------------------------------------------------------------------

-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage");
--local LocalPlayer = game:GetService("Players").LocalPlayer;

------------------------------------------------------------------------

-- IMPORTS

local Config   	= workspace.GameSettings;
local CamBlock 	= workspace.Cam;
local CamGlass 	= workspace.CamBend;

local AR: Vector2 = Config:GetAttribute("AspectRatio");

------------------------------------------------------------------------

-- MODULES
local Constants = require(script.Parent.Constants);

------------------------------------------------------------------------

-- TYPES

------------------------------------------------------------------------

-- CONSTANTS

local MIN_NODE_RADIUS = 7;
local MAX_NODE_RADIUS = 100;

local GLASS_SIZE_X = 117.85/129;
local GLASS_SIZE_Y = 15;
local GLASS_SIZE_Z = 148.4/156;

local GLASS_POS_X = 0;
local GLASS_POS_Y = 6/63.437;
local GLASS_POS_Z = 0;

local ASPECT_RATIO = AR.X / AR.Y;

------------------------------------------------------------------------


-- DEFAULT OBJ

local Camera = {};

------------------------------------------------------------------------

-- CONSTRUCTOR

------------------------------------------------------------------------

-- METHODS

function Camera.init()
	local Cam = workspace.CurrentCamera;
	Cam.FieldOfView = Config:GetAttribute("VerticalCameraFOV");
	
	local Rad: number = Config:GetAttribute("DefaultNodeRadius");
	
	CamBlock.CFrame = CamBlock.CFrame + Vector3.new(0, Camera.getYValueForRadius(Rad), 0);

	Cam.CameraType = Enum.CameraType.Scriptable;
	Cam.CFrame = CamBlock.CFrame;
	Cam.Parent = CamBlock;

	local Width, Height = Camera.getCameraViewArea();
	CamGlass.Size = Vector3.new(Width * GLASS_SIZE_X, GLASS_SIZE_Y, Height * GLASS_SIZE_Z);
	CamGlass.CFrame = CFrame.new(GLASS_POS_X, GLASS_POS_Y * Cam.CFrame.Y, GLASS_POS_Z);
	CamGlass.Parent = CamBlock;
end

function Camera.getCamera(): Camera
	return workspace.CurrentCamera;
end

function Camera.getVerticalFov(): number
	return workspace.CurrentCamera.FieldOfView;
end

function Camera.getHorizontalFov(): number
	local Cam = workspace.CurrentCamera;
	
	local z = Cam.NearPlaneZ;
	local viewSize = Cam.ViewportSize;

	local r0, r1 = 
		Cam:ViewportPointToRay(viewSize.X*0, viewSize.Y/2, z), 
		Cam:ViewportPointToRay(viewSize.X*1, viewSize.Y/2, z);

	return math.deg(math.acos(r0.Direction.Unit:Dot(r1.Direction.Unit)));
end

function Camera.getAspectRatio(): number
	return ASPECT_RATIO;
end

function Camera.getCameraViewArea(): number & number
	local Y = workspace.CurrentCamera.CFrame.Position.Y;

	local Width  = Y / math.cos(math.rad(Camera.getVerticalFov() * (1 - math.fmod(ASPECT_RATIO, 1)) / 2)) * 2;
	local Height = Width / ASPECT_RATIO;

	return tonumber(string.format("%.2f", Width)), tonumber(string.format("%.2f", Height));
end

function Camera.getYValueForRadius(radius: number): number
	local rad = math.clamp(radius, MIN_NODE_RADIUS, MAX_NODE_RADIUS);
	local diameter = rad * 2;
	
	local NodeSize = Constants.NODE_SIZE;
	
	return diameter * NodeSize.X * math.cos(math.rad(Camera.getVerticalFov() * (1 - math.fmod(ASPECT_RATIO, 1)) / 2)) / 2;
end

function Camera.setVerticalFov(fov: number)
	workspace.CurrentCamera.FieldOfView = fov;
end

function Camera.setHorizontalFov(fov: number)
	local aspectRatio = Camera.getHorizontalFov() / Camera.getVerticalFov();

	workspace.CurrentCamera.FieldOfView = fov / aspectRatio;
end

function Camera.setCameraY(y: number)
	CamBlock.CFrame = CFrame.new(0, y, 0) * (CamBlock.CFrame - CamBlock.CFrame.Position);
	workspace.CurrentCamera.CFrame = CamBlock.CFrame;
	
	local Width, Height = Camera.getCameraViewArea();
	CamGlass.Size = Vector3.new(Width * GLASS_SIZE_X, GLASS_SIZE_Y, Height * GLASS_SIZE_Z);
	CamGlass.CFrame = CFrame.new(GLASS_POS_X, GLASS_POS_Y * workspace.CurrentCamera.CFrame.Y, GLASS_POS_Z);
end

------------------------------------------------------------------------

return Camera;
