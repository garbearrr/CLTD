------------------------------------------------------------------------

-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

------------------------------------------------------------------------

-- IMPORTS

local Scripts = ReplicatedStorage:WaitForChild("Scripts");
local Config   = workspace.GameSettings;
local CamBlock = workspace.Cam;
local Models = workspace.Models;
local NodeFolder = workspace.Nodes;

local Models = workspace.Models;
local Towers = workspace.Towers;
local Enemies = workspace.Enemies;

------------------------------------------------------------------------

-- MODULES

local FastCast     = require(Scripts.FastCastRedux);
local CameraModule = require(script:WaitForChild("Camera"));
local LightModule  = require(script:WaitForChild("Lights"));
local NodeManager  = require(script:WaitForChild("NodeManager"));
local Helper       = require(script:WaitForChild("Helpers"));
local Constants    = require(script:WaitForChild("Constants"));

local EnemyScript  = ReplicatedStorage:WaitForChild("LocalScripts").Enemy;

------------------------------------------------------------------------

-- TYPES

type HandlerType = {
	player   	: Player,
	caster   	: typeof(FastCast.new()),
	castBehavior	: typeof(FastCast.newBehavior()),
	cooldown		: boolean,
	mouse		: PlayerMouse,
	printHits	: boolean,
	path			: { Part },
	money		: number,
	moneyText	: TextLabel,
	buildMode	: boolean,
	targetModel	: Model,
	mouseDown	: boolean,
	wave			: number,
	enemies		: { Part },
	inWave		: boolean,
}

------------------------------------------------------------------------

-- CONSTANTS
local COOLDOWN_LENGTH = 0.1;
local RAY_VELOCITY = 5000;
local WAVE_COOLDOWN = 3;

local MODEL_TWEEN_INFO = TweenInfo.new(2, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, false, 0);
local OUTLINE_TWEEN_INFO = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0);
local PATH_OUTLINE_TWEEN = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0);

------------------------------------------------------------------------

-- DEFAULT OBJ

local Handler = {};
local metatable = {__index = Handler};

local Data = {};
------------------------------------------------------------------------

-- HELPER FUNCTIONS

local function OnRayHit(self, cast, result, velocity, bullet)
	if not self.buildMode then return end
	if not self.targetModel then return end
	
	local Hit = result.Instance;
	if(self.printHits) then print(Hit) end

	local IsOccupied = Hit:GetAttribute("Occupied");
	if(IsOccupied == nil or IsOccupied) then return end

	Helper.scaleModel(self.targetModel, Hit.Size.X / self.targetModel.PrimaryPart.Size.X);
	
	self.targetModel.Parent = Hit;
	self.targetModel:SetPrimaryPartCFrame(Hit.CFrame);
	self.targetModel.Model.CFrame = CFrame.new(self.targetModel.Model.Position) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0));
end

------------------------------------------------------------------------

-- CONSTRUCTOR

function Handler.new(LocalPlayer)
	local self: HandlerType = {};

	self.player   = LocalPlayer;
	self.caster   = FastCast.new();
	self.printHits= false;
	
	self.mouse    = LocalPlayer:GetMouse();
	self.mouse.TargetFilter = CamBlock;
	
	self.castBehavior = FastCast.newBehavior();
	self.castBehavior.AutoIgnoreContainer = false;
	self.castBehavior.RaycastParams = RaycastParams.new();
	self.castBehavior.RaycastParams.IgnoreWater = true;
	self.castBehavior.RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist;
	
	self.money = Constants.DEFAULT_CASH;
	
	self.buildMode = false;
	self.targetModel = nil;
	
	self.mouseDown = false;
	
	self.enemies = {};
	
	self.moneyText = LocalPlayer.PlayerGui:WaitForChild("Money"):WaitForChild("MoneyText");
	
	local mt = setmetatable(self, metatable);
	
	CameraModule.init();
	LightModule.turnOff();
	NodeManager.fillViewAreaWithNodes();
	
	NodeManager.drawBorder(true);
	local Borders = NodeManager.getAllBorderNodes();
	
	CamBlock.CamBend.Decal.Transparency = 1;
	
	task.wait(2);
	for i, Border in ipairs(Borders) do
		local Tween = TweenService:Create(Border:GetChildren()[1].Model, MODEL_TWEEN_INFO, {Transparency = 0});
		Tween:Play();
	end
	
	local OutlineTween = TweenService:Create(CamBlock.CamBend.Decal, OUTLINE_TWEEN_INFO, {Transparency = 0.9});
	OutlineTween:Play();
	
	task.wait(3);
	
	local Spawner = NodeManager.placeSpawner();
	local Home = NodeManager.placeHomeBase();
	
	local STween = TweenService:Create(Spawner:GetChildren()[1].Model, MODEL_TWEEN_INFO, {Transparency = 0});
	STween:Play();
	
	local HTween = TweenService:Create(Spawner:GetChildren()[1].Model, MODEL_TWEEN_INFO, {Transparency = 0});
	HTween:Play();
	
	task.wait(1);
	
	self.path = NodeManager.generatePath(true);
	self:updateRayFilter();
	
	for i, PathNode in ipairs(self.path) do
		local Tween = TweenService:Create(PathNode:GetChildren()[1].Model, PATH_OUTLINE_TWEEN, {Transparency = 0});
		Tween:Play();
		task.wait(0.07);
	end
	
	task.wait(3);
	
	self.caster.RayHit:Connect(function(cast, result, velocity, bullet)
		OnRayHit(self, cast, result, velocity, bullet);
	end);
	
	self.wave = 1;
	self.inWave = true;
	
	self:spawnEnemy();
	
	Data[LocalPlayer.UserId] = mt;
	
	return mt;
end

------------------------------------------------------------------------

-- METHODS
function Handler.getPlayerData(id: string)
	return Data[id];
end

function Handler:toggleLighting()
	if LightModule.areOn() then
		LightModule.turnOff();
	else
		LightModule.turnOn();
	end
end

function Handler:updateRayFilter()
	self.castBehavior.RaycastParams.FilterDescendantsInstances = NodeFolder:GetChildren();
end

function Handler:spawnEnemy()
	local AtSign = Enemies.AtSign:Clone();
	local NodeSize = Constants.NODE_SIZE;
	local ScriptClone = EnemyScript:Clone();
	
	Helper.scaleModel(AtSign, NodeSize.X / AtSign.PrimaryPart.Size.X);
	ScriptClone.Parent = AtSign.Model;
	
	local EnemyHandler = require(ScriptClone);
	EnemyHandler.init(self.path);
	
	table.insert(self.enemies, AtSign);
end

function Handler:towerBuy(Tower): boolean
	local Price = Tower:GetAttribute("Price");
	
	if self.money - Price < 0 then return false end
	
	self.money -= Price;
	
	self.targetModel = Tower:Clone();
	
	self.buildMode = true;
	
	return true;
end

function Handler:addCash()
	self.money += 2;
	self.moneyText.Text = self.money .. " Bytes";
end

function Handler:update(deltaTime)
	local origin     = CameraModule.getCamera().CFrame.Position;
	local direction = (self.mouse.Hit.p - origin).Unit;

	-- The third parameter is velocity which can be a number or Vec3
	self.caster:Fire(origin, direction, RAY_VELOCITY, self.castBehavior);
	
	if self.inWave and #self.enemies == 0 then
		self.inWave = false;
		self.wave += 1;
		
		task.delay(WAVE_COOLDOWN, function()
			for i = 1, self.wave do
				wait(1.5);
				self:spawnEnemy();
			end
			
			self.inWave = true;
		end);
	end
	
	if self.mouseDown and self.buildMode and self.targetModel ~= nil then
		local TempCloneHandler = require(self.targetModel.Model.Handler);
		self.buildMode = false;
		self.targetModel = nil;
		self.moneyText.Text = self.money .. " Bytes";
		TempCloneHandler.init();
	end
end

------------------------------------------------------------------------


return Handler;
