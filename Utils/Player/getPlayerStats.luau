--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getInventory = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Player/getInventory.luau`))()
local getContainers = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Player/getContainers.luau`))()

local function getPlayerStats(
	targetPlayer: Player,
	getLocationFromPosition: (position: Vector3) -> string
): {
	Gold: number,
	Location: string,
	TotalArenaWins: number,
	UniqueArenaWins: number,
	Inventory: { [number]: { Value: number, Quantity: number } },
	Containers: { [number]: { [number]: { Value: number, Quantity: number } } },
	Effects: { Instance },
}
	local statsTable = {
		Gold = 0,
		Location = "Unknown",
		TotalArenaWins = 0,
		UniqueArenaWins = 0,
		Inventory = {},
		Containers = {},
		Effects = {},
	}
	local statsFolder = targetPlayer:FindFirstChild("Stats")
	if not statsFolder then
		return statsTable
	end

	local goldValue = statsFolder:FindFirstChild("Gold")
	local gold = if goldValue and goldValue:IsA("IntValue") then goldValue.Value else 0

	statsTable.Gold = gold

	local arenaWinsValue = statsFolder:FindFirstChild("Arena_Wins")
	local arenaWins = if arenaWinsValue and arenaWinsValue:IsA("IntValue") then arenaWinsValue.Value else 0

	statsTable.TotalArenaWins = arenaWins
	local uniqueArenaWinsInstance = statsFolder:FindFirstChild("Arena_PlayersDefeated")
	statsTable.UniqueArenaWins = if uniqueArenaWinsInstance then #uniqueArenaWinsInstance:GetChildren() else 0

	statsTable.Inventory = getInventory(targetPlayer)
	statsTable.Containers = getContainers(targetPlayer)

	local effectsFolder = targetPlayer:FindFirstChild("Effects")
	if effectsFolder then
		for _, effect in effectsFolder:GetChildren() do
			table.insert(statsTable.Effects, effect)
		end
	end
	local character = targetPlayer.Character
	if character then
		local position = character:GetPivot().Position
		statsTable.Location =
			`{getLocationFromPosition(position)} ({math.floor(position.X)}, {math.floor(position.Y)}, {math.floor(
				position.Z
			)})`
	else
		statsTable.Location = "Unknown"
	end

	return statsTable
end

return getPlayerStats
