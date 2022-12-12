local Model: MeshPart = script.Parent;
local Group: Model = Model.Parent;
local Projectile = Group.Projectile;
local ProjectilePoint = Model.ProjectileOrigin;

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService	 = game:GetService("RunService");
local TweenService = game:GetService("TweenService");

local Scripts = ReplicatedStorage:WaitForChild("Scripts");
local Handler = Scripts:WaitForChild("Handler");

local NodeManager = require(Handler.NodeManager);
local Constants   = require(Handler.Constants);
local Helper      = require(Handler.Helpers);

local Tower = {
	Damage		= Group:GetAttribute("Damage"),
	FireRate		= Group:GetAttribute("FireRate"),
	ProjVelo		= Group:GetAttribute("ProjectileVelocity"),
	Range		= Group:GetAttribute("Range"),
	Price		= Group:GetAttribute("Price"),
	Connection	= nil,
	Cooldown		= false
};

local ProjTweenInfo = TweenInfo.new(
	Tower.ProjVelo, -- Time animating
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- Repitions
	false, -- Reverse post tween?
	0 -- Delay time
);

local function fire(EnemyNode)
	if EnemyNode == nil then return end
	
	local Enemy = EnemyNode.AtSign;
	local EnemyData = require(Enemy.Model.Enemy);
	
	local ProjectileClone = Projectile:Clone();
	Projectile.Transparency = 1;
	
	local Goal = {
		Position = Enemy.PrimaryPart.Position
	};
	
	local Tween = TweenService:Create(ProjectileClone, ProjTweenInfo, Goal);
	Tween:Play();
	
	task.delay(Tower.ProjVelo, function()
		Projectile.Transparency = 0;
		ProjectileClone:Destroy();
		EnemyData.hit(Tower.Damage);
	end);
end

local function update(dt)
	if Tower.Cooldown then return end
	
	local N = Group.Parent;
	local Split = Helper.strSplit(N.Name, " ");
	local X = tonumber(Split[1]); local Y = tonumber(Split[2]);
	
	local NodesAround = NodeManager.getNodesWithRadius(X, Y, Tower.Range);
	
	local EnemyTower = nil;
	
	for i, Node in ipairs(NodesAround) do
		local HasEnemy = NodeManager.nodeHasEnemy(Node);
		
		if HasEnemy then
			EnemyTower = Node;
			break;
		end
	end
	
	Tower.Cooldown = true;
	
	fire(EnemyTower);
	
	task.delay(Tower.FireRate, function()
		Tower.Cooldown = false;
	end);
end

Tower.init = function()
	Tower.Connection = RunService.RenderStepped:Connect(update);
end

return Tower;
