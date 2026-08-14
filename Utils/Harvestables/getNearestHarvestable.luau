--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemById = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemById.luau`))()

local player = Players.LocalPlayer

local function getNearestHarvestable(minimumValue: number?): PVInstance?
	local character = player.Character
	if not character then
		return nil
	end

	local characterPosition = character:GetPivot().Position
	local minValue = if type(minimumValue) == "number" then minimumValue else 0

	local spawners = Workspace:FindFirstChild("Spawners")
	if not spawners then
		return nil
	end

	local nearestCollectible: PVInstance? = nil
	local nearestDistance = math.huge

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

				if not item or item.Value < minValue then
					continue
				end

				local collectiblePosition = collectible:GetPivot().Position
				local distance = (characterPosition - collectiblePosition).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					nearestCollectible = collectible
				end
			end
		end
	end

	return nearestCollectible
end

return getNearestHarvestable
