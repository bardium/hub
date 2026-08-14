--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemById = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemById.luau`))()

local function getHarvestables(minimumValue: number?): { string }
	local harvestableList = {}
	local seenNames = {}

	minimumValue = if type(minimumValue) ~= "number" then 0 else minimumValue
	if type(minimumValue) ~= "number" then
		return harvestableList
	end

	local spawners = Workspace:FindFirstChild("Spawners")
	if not spawners then
		return harvestableList
	end

	for _, folder in spawners:GetChildren() do
		for _, part in folder:GetChildren() do
			for _, collectible in part:GetChildren() do
				local info = collectible:FindFirstChild("Info")
				local itemIntValue = if info then info:FindFirstChild("Item") else nil
				local itemId = if itemIntValue and itemIntValue:IsA("IntValue") then itemIntValue.Value else nil
				local item = if itemId then getItemById(itemId) else nil
				if item and item.Value >= minimumValue and not seenNames[item.Id] then
					table.insert(harvestableList, item.Name)
					seenNames[item.Id] = true
				end
			end
		end
	end

	return harvestableList
end

return getHarvestables
