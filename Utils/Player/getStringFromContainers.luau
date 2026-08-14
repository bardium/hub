--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemById = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemById.luau`))()
local formatCommas = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Format/formatCommas.luau`))()

local function getStringFromContainers(
	containers: { [number]: { [number]: { Value: number, Quantity: number } } },
	containerIndex: number?
): string
	local string = ""
	if containerIndex then
		if not containers[containerIndex] then
			return "Empty"
		end
		for _, inventoryItem in containers[containerIndex] do
			local item = getItemById(inventoryItem.Value)
			if not item then
				continue
			end
			string = string .. `{formatCommas(inventoryItem.Quantity)}x {item.Name}\n`
		end
	else
		for _, container in containers do
			for _, inventoryItem in container do
				local item = getItemById(inventoryItem.Value)
				if not item then
					continue
				end
				string = string .. `{formatCommas(inventoryItem.Quantity)}x {item.Name}\n`
			end
		end
	end
	return if string == "" then "Empty" else string:sub(1, -2)
end

return getStringFromContainers
