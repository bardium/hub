--!strict

local function getInventory(targetPlayer: Player): { [number]: { Value: number, Quantity: number } }
	local inventory = {} :: { [number]: { Value: number, Quantity: number } }
	local inventoryFolder = targetPlayer:FindFirstChild("Inventory")
	if not inventoryFolder then
		return inventory
	end

	for _, child in inventoryFolder:GetChildren() do
		local value = if child:IsA("IntValue") then child.Value else nil
		if type(value) ~= "number" or value == 0 then
			continue
		end

		local quantityChild = child:FindFirstChild("Quantity")
		local quantity = if quantityChild and quantityChild:IsA("IntValue") then quantityChild.Value else 0
		local numericKey = tonumber(child.Name:match("%d+"))
		if not numericKey then
			continue
		end
		inventory[numericKey] = {
			Value = value,
			Quantity = quantity,
		}
	end

	return inventory
end

return getInventory
