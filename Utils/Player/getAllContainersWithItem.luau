--!strict

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function getAllContainersWithItem(itemId: number): { Instance }
	local containers = {} :: { Instance }
	local statsFolder = player:FindFirstChild("Stats")
	local containersFolder = if statsFolder then statsFolder:FindFirstChild("Containers") else nil
	if not containersFolder then
		return containers
	end
	for _, container in containersFolder:GetChildren() do
		for _, slot in container:GetChildren() do
			if slot:IsA("IntValue") and slot.Value == itemId and not table.find(containers, container) then
				table.insert(containers, container)
			end
		end
	end
	return containers
end

return getAllContainersWithItem
