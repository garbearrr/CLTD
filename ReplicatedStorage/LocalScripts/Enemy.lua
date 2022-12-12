local Model: MeshPart = script.Parent;
local Group = Model.Parent;
local Particles: ParticleEmitter = Model.ParticleEmitter;

local RunService	 = game:GetService("RunService");
local Player = game:GetService("Players").LocalPlayer;
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Scripts = ReplicatedStorage:WaitForChild("Scripts");
local Handler = require(Scripts:WaitForChild("Handler"));

local Enemy = {
	Damage		= Group:GetAttribute("Damage"),
	Health		= Group:GetAttribute("Health"),
	Speed		= Group:GetAttribute("Speed"),
	Path			= nil,
	Pos			= 1,
	Connection	= nil,
	Cooldown		= true,
};

local BLANK_TIME = 0.5;

local function update(dt)
	if Enemy.Cooldown then return end
	if Enemy.Pos - 1 == #Enemy.Path then return Enemy.destroy(false) end --Damage Base
	
	Model.Transparency = 1;
	Enemy.Cooldown = true;
	
	task.delay(BLANK_TIME, function()
		Enemy.Pos += 1;

		local Target = Enemy.Path[Enemy.Pos];
		Group:SetPrimaryPartCFrame(Target.CFrame);
		Group.Parent = Target;
		
		Model.Transparency = 0;

		task.delay(Enemy.Speed, function()
			Enemy.Cooldown = false;
		end);
	end);
end

function Enemy.init(path)
	Enemy.Path = path;
	
	Group.Parent = path[1];
	Group:SetPrimaryPartCFrame(path[1].CFrame);
	Group.Model.CFrame = CFrame.new(Group.Model.Position) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
	
	task.delay(Enemy.Speed, function()
		Enemy.Cooldown = false;
	end);
	
	Enemy.Connection = RunService.RenderStepped:Connect(update);
end

function Enemy.hit(damage)
	Enemy.Health -= damage;
	if(Enemy.Health <= 0) then
		Enemy.destroy(true);
	end
end

function Enemy.destroy(addCash: boolean)
	Particles:Emit(10);
	
	Enemy.Connection:Disconnect();
	Group:Destroy();
	
	local Data: typeof(Handler.new()) = Handler.getPlayerData(Player.UserId);
	if not Data then return end
	
	table.remove(Data.enemies, 1);
	
	if addCash then
		Data:addCash();
	end
end

return Enemy;
