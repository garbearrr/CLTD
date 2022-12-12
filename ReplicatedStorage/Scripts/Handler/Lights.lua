------------------------------------------------------------------------

-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Lighting = game:GetService("Lighting");

------------------------------------------------------------------------

-- IMPORTS

local CamLighting = workspace.CamBend.SurfaceLight;

------------------------------------------------------------------------

-- MODULES

------------------------------------------------------------------------

-- TYPES

------------------------------------------------------------------------

-- CONSTANTS

------------------------------------------------------------------------

-- DEFAULT OBJ

local Lights = {};

------------------------------------------------------------------------

-- CONSTRUCTOR

------------------------------------------------------------------------

-- METHODS

function Lights.turnOn()
	Lighting.Brightness = 3;
	Lighting.EnvironmentDiffuseScale = 1;
	Lighting.EnvironmentSpecularScale = 1;
end

function Lights.turnOff()
	Lighting.Brightness = 0;
	Lighting.EnvironmentDiffuseScale = 0;
	Lighting.EnvironmentSpecularScale = 0;
end

function Lights.areOn(): boolean
	return Lighting.Brightness > 0;
end

function Lights.getCameraLight(): SurfaceLight
	return CamLighting;
end

------------------------------------------------------------------------

return Lights;