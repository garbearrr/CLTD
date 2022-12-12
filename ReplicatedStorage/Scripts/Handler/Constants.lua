
local Config = workspace.GameSettings;
local NS = Config:GetAttribute("NodeRatio");

local Constants = {
	NODE_SIZE = {X = tonumber(string.format("%.3f", NS.X)), Y = tonumber(string.format("%.3f", NS.Y))};
	DEFAULT_CASH = 4
}

return Constants;
