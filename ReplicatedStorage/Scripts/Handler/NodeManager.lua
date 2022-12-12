------------------------------------------------------------------------

-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage");

------------------------------------------------------------------------

-- IMPORTS

local DefaultNode = workspace.DefaultNode;
local NodeFolder = workspace.Nodes;

local Models = workspace.Models;

local SpawnerModel = Models.Spawn;
local HomeModel    = Models.Home;

local TopRightCorner 	= Models.TopRightCorner;
local TopLeftCorner  	= Models.TopLeftCorner;
local TopHorizBar    	= Models.TopHorizontalBar;
local BottomRightCorner	= Models.BottomRightCorner;
local BottomLeftCorner	= Models.BottomLeftCorner;
local BottomHorizBar		= Models.BottomHorizontalBar;
local VerticalBar		= Models.VerticalBar;

local PathModel = Models.Path;

local VertPath		= Models.VertPath;
local HorizPath		= Models.HorizPath;
local UpRightPath	= Models.UpRightPath;
local RightUpPath	= Models.RightUpPath;
local UpLeftPath		= Models.UpLeftPath;
local LeftUpPath		= Models.LeftUpPath;

local SpawnerPath	= Models.SpawnPath;
local HomePath		= Models.HomePath;

local Corners = { TopLeftCorner, TopRightCorner, BottomLeftCorner, BottomRightCorner };

------------------------------------------------------------------------

-- MODULES

local CameraModule 	= require(script.Parent.Camera);
local Helper			= require(script.Parent.Helpers);
local Constants		= require(script.Parent.Constants);

------------------------------------------------------------------------

-- TYPES

------------------------------------------------------------------------

-- CONSTANTS

local MIN_JUMP_RATIO = 5;
local MAX_JUMP_RATIO = 4;

------------------------------------------------------------------------

-- DEFAULT OBJ

local NodeManager = {};

------------------------------------------------------------------------

-- HELPER FUNCTIONS

------------------------------------------------------------------------

-- CONSTRUCTOR

------------------------------------------------------------------------

-- METHODS

function NodeManager.getNode(x: number, y: number): Part
	return NodeFolder:FindFirstChild(x .. " " .. y);
end

function NodeManager.getAllNodes(): { Part }
	return NodeFolder:GetChildren();
end

function NodeManager.getAllUnoccupiedNodes(): { Part } 
	local Nodes = NodeFolder:GetChildren();
	local Unoccupied = {};

	for i, child in ipairs(Nodes) do
		local isOccupied = child:GetAttribute("Occupied");
		local isSpawner  = child:GetAttribute("Spawner");
		local isHome     = child:GetAttribute("Home");
		local isPath     = child:GetAttribute("Path");
		
		if isOccupied ~= nil and isOccupied then continue end
		if isSpawner ~= nil and isSpawner then continue end
		if isHome ~= nil and isHome then continue end
		if isPath ~= nil and isPath then continue end
		
		table.insert(Unoccupied, child);
	end
	
	return Unoccupied;
end

function NodeManager.getAllBorderNodes(): { Part }
	local Nodes = NodeFolder:GetChildren();
	local Borders = {};

	for i, child in ipairs(Nodes) do
		local isBorder = child:GetAttribute("Border");

		if isBorder ~= nil and isBorder == true then
			table.insert(Borders, child);
		end
	end

	return Borders;
end

function NodeManager.getSpawner(): { Part }
	local Nodes = NodeFolder:GetChildren();

	for i, child in ipairs(Nodes) do
		local isSpawner = child:GetAttribute("Spawner");
		if isSpawner ~= nil and isSpawner then return child end
	end
	
	return nil;
end

function NodeManager.getHomeBase(): { Part }
	local Nodes = NodeFolder:GetChildren();

	for i, child in ipairs(Nodes) do
		local isHome = child:GetAttribute("Home");
		if isHome ~= nil and isHome then return child end
	end

	return nil;
end

function NodeManager.getNodesAcross(): number
	local Width, Height = CameraModule.getCameraViewArea();
	
	return math.floor(Width / Constants.NODE_SIZE.X + 0.5);
end

function NodeManager.getNodesTall(): number
	local Width, Height = CameraModule.getCameraViewArea();
	
	return math.floor(Height / Constants.NODE_SIZE.Y + 0.5);
end

function NodeManager.getTotalNodes(): number
	return NodeManager.getNodesTall() * NodeManager.getNodesAcross();
end

function NodeManager.setNodeColor(color: Color3, node: Part)
	if not node then return end
	
	node.Color = color;
end

function NodeManager.getNodesWithRadius(center_x: number, center_y: number, radius: number): { Part }
	local Points = {};

	for x = center_x - radius, center_x + radius do
		-- add the top and bottom coordinates to the list
		table.insert(Points, NodeManager.getNode(x, center_y - radius));
		table.insert(Points, NodeManager.getNode(x, center_y + radius));
	end

	-- iterate over the y values on the top and bottom edges of the square
	for y = center_y - radius + 1, center_y + radius - 1 do
		-- add the left and right coordinates to the list
		table.insert(Points, NodeManager.getNode(center_x - radius, y));
		table.insert(Points, NodeManager.getNode(center_x + radius, y));
	end
	
	return Points;
end

function NodeManager.nodeHasEnemy(node: Part): boolean
	if not node then return false end
	
	for i, child in ipairs(node:GetChildren()) do
		if child.Name == "AtSign" then return true end
	end
	
	return false;
end

function NodeManager.fillViewAreaWithNodes()
	NodeManager.clearNodes();
	
	local Width, Height = CameraModule.getCameraViewArea();

	local StartX = -Width / 2;
	local StartZ = -Height / 2;

	local NodesAcross = NodeManager.getNodesAcross();
	local NodesTall   = NodeManager.getNodesTall()
	local TotalNodes  = NodesAcross * NodesTall;

	local x = 0; local z = 0;
	for i = 0, TotalNodes - 1 do
		local CurXPos = StartX + Constants.NODE_SIZE.X * x;
		local CurZPos = StartZ + Constants.NODE_SIZE.Y * z;

		local NodeClone = DefaultNode:Clone();
		NodeClone.Parent = NodeFolder;
		NodeClone.Size = Vector3.new(Constants.NODE_SIZE.X, 0.001, Constants.NODE_SIZE.Y);
		NodeClone.CFrame = CFrame.new(CurXPos + Constants.NODE_SIZE.X / 2, 0.001, CurZPos + Constants.NODE_SIZE.Y / 2);
		NodeClone.Name = x .. " " .. z;

		x += 1;

		if(x == NodesAcross) then
			x = 0;
			z += 1;
		end
	end
end

function NodeManager.clearNodes()
	local Nodes = NodeFolder:GetChildren();

	for i, child in ipairs(Nodes) do
		child:Destroy();
	end
end

function NodeManager.drawBorder(transparent: boolean)
	local Nodes = NodeFolder:GetChildren();
	
	local NodesAcross = NodeManager.getNodesAcross();
	local NodesTall   = NodeManager.getNodesTall();

	for i, child in ipairs(Nodes) do
		local Name = child.Name;

		if Helper.strStarts(Name, "0") or Helper.strStarts(Name, (NodesAcross - 1) .. "") then
			local VerticalBarClone = VerticalBar:Clone();
			Helper.scaleModel(VerticalBarClone, child.Size.X / VerticalBarClone.PrimaryPart.Size.X);
			VerticalBarClone.Parent = child;
			VerticalBarClone:SetPrimaryPartCFrame(child.CFrame);
			VerticalBarClone.Model.CFrame = CFrame.new(VerticalBarClone.Model.Position) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0));
			if transparent ~= nil then VerticalBarClone.Model.Transparency = 1 end
			child:SetAttribute("Occupied", true);
			child:SetAttribute("Border", true);
		end

		if Helper.strEnds(Name, " 0") then
			local TopBarClone = TopHorizBar:Clone();
			Helper.scaleModel(TopBarClone, child.Size.X / TopBarClone.PrimaryPart.Size.X);
			TopBarClone.Parent = child;
			TopBarClone:SetPrimaryPartCFrame(child.CFrame);
			TopBarClone.Model.CFrame = CFrame.new(TopBarClone.Model.Position) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0));
			if transparent ~= nil then TopBarClone.Model.Transparency = 1 end
			child:SetAttribute("Occupied", true);
			child:SetAttribute("Border", true);
		end

		if  Helper.strEnds(Name, (NodesTall - 1) .. "") then
			local BottomBarClone = BottomHorizBar:Clone();
			Helper.scaleModel(BottomBarClone, child.Size.X / BottomBarClone.PrimaryPart.Size.X);
			BottomBarClone.Parent = child;
			BottomBarClone:SetPrimaryPartCFrame(child.CFrame);
			BottomBarClone.Model.CFrame = CFrame.new(BottomBarClone.Model.Position) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0));
			if transparent ~= nil then BottomBarClone.Model.Transparency = 1 end
			child:SetAttribute("Occupied", true);
			child:SetAttribute("Border", true);
		end
	end

	local TopLeft  		= NodeFolder:FindFirstChild("0 0");
	local TopRight 		= NodeFolder:FindFirstChild((NodesAcross - 1) .. " 0");
	local BottomLeft		= NodeFolder:FindFirstChild("0 " .. (NodesTall - 1));
	local BottomRight	= NodeFolder:FindFirstChild((NodesAcross - 1) .. " " .. (NodesTall - 1));

	local Arr = { TopLeft, TopRight, BottomLeft, BottomRight };

	for i, Corner in ipairs(Arr) do
		for g, child in ipairs(Corner:GetChildren()) do child:Destroy() end

		local CornerClone = Corners[i]:Clone();
		Helper.scaleModel(CornerClone, Corner.Size.X / CornerClone.PrimaryPart.Size.X);
		CornerClone.Parent = Corner;
		CornerClone:SetPrimaryPartCFrame(Corner.CFrame);
		if(Helper.strStarts(Corners[i].Name, "Bottom")) then
			CornerClone.Model.CFrame = CFrame.new(CornerClone.Model.Position) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
		else
			CornerClone.Model.CFrame = CFrame.new(CornerClone.Model.Position) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0));
		end
		if transparent ~= nil then CornerClone.Model.Transparency = 1 end
		Corner:SetAttribute("Occupied", true);
		Corner:SetAttribute("Border", true);
	end
end

-- Returns spawner parent node.
function NodeManager.placeSpawner(transparent: boolean): Part
	local SpawnerY = NodeManager.getNodesTall() - 2;
	local SpawnerX;

	local ValidAcross = NodeManager.getNodesAcross() - 8;
	local LastX = NodeManager.getNodesAcross() - 4;

	local HomeNode = NodeManager.getHomeBase();
	if HomeNode ~= nil then
		local HomeX = Helper.strSplit(HomeNode.Name, " ")[1];
		local MidWay = math.floor(ValidAcross / 2 + 0.5);
		
		if tonumber(HomeX) == MidWay then SpawnerX = math.random(4, LastX)
		elseif tonumber(HomeX) < MidWay then SpawnerX = math.random(MidWay, LastX)
		else HomeX = math.random(4, MidWay) end
	else
		SpawnerX = math.random(4, LastX);
	end

	local TargetNode = NodeManager.getNode(SpawnerX, SpawnerY);
	if not TargetNode then
		print("Target node for spawner placement not found! X: " .. SpawnerX .. " Y: " .. SpawnerY);
		return nil;
	end
	
	TargetNode:SetAttribute("Spawner", true);
	
	local Spawner = SpawnerModel:Clone();
	Spawner.Parent = TargetNode;
	
	Helper.scaleModel(Spawner, TargetNode.Size.X / Spawner.PrimaryPart.Size.X);
	
	Spawner:SetPrimaryPartCFrame(TargetNode.CFrame);
	Spawner.Model.CFrame = CFrame.new(Spawner.Model.Position) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
	
	if transparent ~= nil and transparent == true then Spawner.Model.Transparency = 1 end
	
	NodeManager.getNode(SpawnerX-1, SpawnerY):SetAttribute("Occupied", true);
	NodeManager.getNode(SpawnerX+1, SpawnerY):SetAttribute("Occupied", true);
	
	return TargetNode;
end

-- Returns home parent node.
function NodeManager.placeHomeBase(transparent: boolean): Part
	local HomeX;
	local HomeY = 1;
	
	local ValidAcross = NodeManager.getNodesAcross() - 8;
	local LastX = NodeManager.getNodesAcross() - 4;
	
	local SpawnerNode = NodeManager.getSpawner();
	if SpawnerNode ~= nil then
		local SpawnerX = Helper.strSplit(SpawnerNode.Name, " ")[1];
		local MidWay = math.floor(ValidAcross / 2 + 0.5);
		
		if tonumber(SpawnerX) == MidWay then HomeX = math.random(4, LastX)
		elseif tonumber(SpawnerX) < MidWay then HomeX = math.random(MidWay, LastX)
		else HomeX = math.random(4, MidWay) end
	else
		HomeX = math.random(4, LastX);
	end

	local TargetNode = NodeManager.getNode(HomeX, HomeY);
	if not TargetNode then
		print("Target node for home placement not found! X: " .. HomeX .. " Y: " .. HomeY);
		return nil;
	end

	TargetNode:SetAttribute("Home", true);

	local Home = HomeModel:Clone();
	Home.Parent = TargetNode;

	Helper.scaleModel(Home, TargetNode.Size.X / Home.PrimaryPart.Size.X);

	Home:SetPrimaryPartCFrame(TargetNode.CFrame);
	Home.Model.CFrame = CFrame.new(Home.Model.Position) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
	
	if transparent ~= nil and transparent == true then Home.Model.Transparency = 1 end

	NodeManager.getNode(HomeX-1, HomeY):SetAttribute("Occupied", true);
	NodeManager.getNode(HomeX+1, HomeY):SetAttribute("Occupied", true);

	return TargetNode;
end

function NodeManager.generatePath(transparent: boolean): { Part }
	local Spawner = NodeManager.getSpawner();
	local Home = NodeManager.getHomeBase();
	
	local Path = {};
	
	if not Spawner or not Home then
		print("A path cannot be generated without a spawner and home base.");
		return;
	end
	
	local NodesTall = NodeManager.getNodesTall();
	local NodesAcross = NodeManager.getNodesAcross();
	
	local LowerXLimit = 4;
	local UpperXLimit = NodesAcross - 4;
	
	local LowerYLimit = 1;
	local UpperYLimit = NodesTall - 1;
	
	local MinJump = math.floor(NodesTall / MIN_JUMP_RATIO + 0.5);
	local MaxJump = math.floor(NodesTall / MAX_JUMP_RATIO + 0.5);
	
	local SpawnerSplit = Helper.strSplit(Spawner.Name, " ");
	local HomeSplit = Helper.strSplit(Home.Name, " ");
	
	local SpawnerX = tonumber(SpawnerSplit[1]); local SpawnerY = tonumber(SpawnerSplit[2]);
	local HomeX = tonumber(HomeSplit[1]); local HomeY = tonumber(HomeSplit[2]);
	
	local CurrentX = tonumber(SpawnerSplit[1]); local CurrentY = tonumber(SpawnerSplit[2]);

	local CurrentQuadrant = SpawnerX < NodesAcross / 2 and 2 or 1;
	
	local CurrentTargetX = SpawnerX;
	local CurrentTargetY = UpperYLimit - math.random(MinJump, MaxJump);
	
	local LastPlacedNode = nil;
	local Going = "up";
	local First = true;
	
	while CurrentX ~= HomeX or CurrentY ~= HomeY do
		
		while CurrentX ~= CurrentTargetX or CurrentY ~= CurrentTargetY do
			
			local OriginalX = CurrentX; local OriginalY = CurrentY;
			local NextGoing = nil;

			local Rand = math.random(1, 3);
			if Rand == 1 and CurrentX > CurrentTargetX and CurrentX - 1 >= LowerXLimit then
				CurrentX -= 1; -- move left
				NextGoing = "left";
			elseif Rand == 2 and CurrentX < CurrentTargetX and CurrentX + 1 <= UpperXLimit then
				CurrentX += 1; -- move right
				NextGoing = "right";
			elseif Rand == 3 and CurrentY > CurrentTargetY and CurrentY - 1 >= LowerYLimit and CurrentX == CurrentTargetX then
				CurrentY -= 1; -- move up only if x matches
				NextGoing = "up";
			end

			local Node = NodeManager.getNode(CurrentX, CurrentY);

			if Node:GetAttribute("Path") then 
				CurrentX = OriginalX; CurrentY = OriginalY;
			elseif NextGoing then
				local ModelToUse = nil;
				
				if LastPlacedNode and NextGoing == "up" then
					if Going == "up" then ModelToUse = VertPath
					elseif Going == "left" then ModelToUse = LeftUpPath
					else ModelToUse = RightUpPath end
				elseif LastPlacedNode and NextGoing == "left" then
					if Going == "up" then ModelToUse = UpLeftPath
					else ModelToUse = HorizPath end
				elseif LastPlacedNode and NextGoing == "right" then
					if Going == "up" then ModelToUse = UpRightPath
					else ModelToUse = HorizPath end
				end
				
				if ModelToUse then
					local PathClone = ModelToUse:Clone();
					Helper.scaleModel(PathClone, LastPlacedNode.Size.X / PathClone.PrimaryPart.Size.X);
					PathClone.Parent = LastPlacedNode;
					PathClone:SetPrimaryPartCFrame(LastPlacedNode.CFrame);
					PathClone.Model.CFrame = CFrame.new(PathClone.Model.Position) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
					
					if transparent ~= nil and transparent == true then PathClone.Model.Transparency = 1 end
					
					LastPlacedNode:SetAttribute("Occupied", true);
					LastPlacedNode:SetAttribute("Path", true);
					
					table.insert(Path, LastPlacedNode);
				end
				
				LastPlacedNode = Node;
				Going = NextGoing;
			end
		end
		
		if CurrentQuadrant == 1 then
			CurrentQuadrant = 2;
			CurrentTargetX = math.random(LowerXLimit, math.floor(NodesAcross / math.random(3, 5)));
		else
			CurrentQuadrant = 1;
			CurrentTargetX = math.random(math.floor(NodesAcross / math.random(3, 5)), UpperXLimit);
		end
		
		CurrentTargetY -= math.random(MinJump, MaxJump);
		
		if CurrentTargetY <= HomeY then 
			CurrentTargetY = HomeY;
			CurrentTargetX = HomeX;
		end
	end
	
	local SPath = SpawnerPath:Clone();
	Helper.scaleModel(SPath, Spawner.Size.X / SPath.PrimaryPart.Size.X);
	SPath.Parent = Spawner;
	SPath:SetPrimaryPartCFrame(Spawner.CFrame);
	SPath.Model.CFrame = CFrame.new(SPath.Model.Position) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
	
	local HPath = HomePath:Clone();
	Helper.scaleModel(HPath, Home.Size.X / HPath.PrimaryPart.Size.X);
	HPath.Parent = Home;
	HPath:SetPrimaryPartCFrame(Home.CFrame);
	HPath.Model.CFrame = CFrame.new(HPath.Model.Position) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
	
	return Path;
end

------------------------------------------------------------------------

return NodeManager;