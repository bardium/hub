--!strict

local function dictionaryToIndices(dictionary: { [any]: any }): { any }
	local indices = {}
	if type(dictionary) ~= "table" then
		return indices
	end
	for key in dictionary do
		table.insert(indices, key)
	end
	return indices
end

return dictionaryToIndices
