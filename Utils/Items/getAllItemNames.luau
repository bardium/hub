--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getAllItems = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getAllItems.luau`))()

local function getAllItemNames(): { string }
	local itemNames = {}

	for _, item in getAllItems() do
		table.insert(itemNames, item.Name)
	end
	return itemNames
end

return getAllItemNames
