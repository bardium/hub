--!strict

local function getContainers(
	targetPlayer: Player
): { [number]: { [number]: { Value: number, Quantity: number } } }
	local containers = {} :: { [number]: { [number]: { Value: number, Quantity: number } } }
	local statsFolder = targetPlayer:FindFirstChild("Stats")
	local containersFolder = if statsFolder then statsFolder:FindFirstChild("Containers") else nil
	if not containersFolder then
		return containers
	end

	for _, folder in containersFolder:GetChildren() do
		local folderNumericKey = tonumber(folder.Name:match("%d+"))
		if not folderNumericKey then
			continue
		end
		containers[folderNumericKey] = {} :: { [number]: { Value: number, Quantity: number } }
		for _, child in folder:GetChildren() do
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
			containers[folderNumericKey][numericKey] = {
				Value = value,
				Quantity = quantity,
			}
		end
	end

	return containers
end

return getContainers
