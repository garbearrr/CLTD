
local function InhibitMovement(Player)
	-- Wait for character to load or movement will not be locked.
	Player.CharacterAdded:Wait();
	-- Movement changed from UserChoice to Scriptable.
	Player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable;
end

-- Run when a player is added to the game.
game.Players.PlayerAdded:Connect(InhibitMovement);
