--!strict

local Players = game:GetService("Players")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getInventory = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Player/getInventory.luau`))()

local player = Players.LocalPlayer

local function getInventoryEmptySlot(): boolean
	local amount = 0
	for _, inventoryItem in getInventory(player) do
		if inventoryItem.Quantity > 0 then
			amount += 1
		end
	end
	return amount < 20
end

return getInventoryEmptySlot
