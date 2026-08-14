--!strict

local function getStringFromEffects(effects: { Instance }): string
	local string = ""
	for _, effect in effects do
		local effectName = effect.Name
		string = string .. `{effectName}\n`
	end
	return if string == "" then "No effects" else string:sub(1, -2)
end

return getStringFromEffects
