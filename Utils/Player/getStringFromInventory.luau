--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemById = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemById.luau`))()
local formatCommas = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Format/formatCommas.luau`))()

local function getStringFromInventory(
	inventory: { [number]: { Value: number, Quantity: number } },
	itemValue: boolean?
): string
	local string = ""
	for _, inventoryItem in inventory do
		local item = getItemById(inventoryItem.Value)
		if not item then
			continue
		end
		if itemValue then
			string = string .. `{formatCommas(inventoryItem.Quantity)}x {item.Name} - {formatCommas(item.Value)}\n`
		else
			string = string .. `{formatCommas(inventoryItem.Quantity)}x {item.Name}\n`
		end
	end
	return if string == "" then "Empty" else string:sub(1, -2)
end

return getStringFromInventory
