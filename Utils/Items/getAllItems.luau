--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemById = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemById.luau`))()

type Item = {
	Id: number,
	Name: string,
	Value: number,
	Icon: string,
	Quantity: number?,
}

local function getAllItems(): { Item }
	local items = {}

	local itemInfo = ReplicatedStorage:FindFirstChild("ItemInfo")
	if not itemInfo then
		return items
	end

	for _, child in itemInfo:GetChildren() do
		local itemId = tonumber(child.Name)
		local item = if itemId then getItemById(itemId) else nil
		if item and item.Name ~= "" then
			table.insert(items, item)
		end
	end
	return items
end

return getAllItems
