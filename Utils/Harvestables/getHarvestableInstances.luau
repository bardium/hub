--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemById = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemById.luau`))()

export type Item = {
	Id: number,
	Name: string,
	Value: number,
	Icon: string,
	Quantity: number?,
}

local function getHarvestableInstances(minimumValue: number): { { Instance: PVInstance, Item: Item } }
	local instances = {}

	local spawners = Workspace:FindFirstChild("Spawners")
	if not spawners then
		return instances
	end

	for _, folder in spawners:GetChildren() do
		for _, part in folder:GetChildren() do
			for _, collectible in part:GetChildren() do
				if not collectible:IsA("PVInstance") then
					continue
				end

				local info = collectible:FindFirstChild("Info")
				local itemIntValue = if info then info:FindFirstChild("Item") else nil
				local itemId = if itemIntValue and itemIntValue:IsA("IntValue") then itemIntValue.Value else nil
				local item = if itemId then getItemById(itemId) else nil
				if not item or item.Value < minimumValue then
					continue
				end

				table.insert(instances, { Instance = collectible, Item = item })
			end
		end
	end

	return instances
end

return getHarvestableInstances
