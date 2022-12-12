local Helpers = {};

function Helpers.strStarts(str: string, start: string): boolean
	return str:sub(1, #start) == start;
end

function Helpers.strEnds(str: string, ending: string): boolean
	return ending == "" or str:sub(-#ending) == ending;
end

function Helpers.strSplit(s: string, delimiter: string): {string}
	local result = {};

	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end

	return result;
end

function Helpers.scaleModel(model: Model, scale: number): Model
	local primary = model.PrimaryPart;
	local primaryCf = primary.CFrame;

	for _,v in pairs(model:GetDescendants()) do
		if (v:IsA("BasePart")) then
			v.Size = (v.Size * scale);
			if (v ~= primary) then
				v.CFrame = (primaryCf + (primaryCf:inverse() * v.Position * scale));
			end
		end
	end

	return model;
end

return Helpers;
