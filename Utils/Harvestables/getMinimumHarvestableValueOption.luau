--!strict

local function getMinimumHarvestableValueOption(Options: any): number
	local minimumValue = if Options.MinimumHarvestableValue and Options.MinimumHarvestableValue.Value
		then tonumber(Options.MinimumHarvestableValue.Value)
		else nil
	return if type(minimumValue) ~= "number" then 0 else minimumValue
end

return getMinimumHarvestableValueOption
