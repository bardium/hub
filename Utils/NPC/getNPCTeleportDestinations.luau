--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local GroupId = (loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/GroupId.luau`))()
local PivotTableByGroupId =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/PivotTableByGroupId.luau`))()
local dictionaryToIndices =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Common/dictionaryToIndices.luau`))()
local getPlayerNames = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Player/getPlayerNames.luau`))()

local function getNPCTeleportDestinations(): { string }
	local destinations = {}

	local players = getPlayerNames()
	for _, playerName in players do
		table.insert(destinations, playerName)
	end

	local frontierLocationNames = dictionaryToIndices(PivotTableByGroupId[GroupId.Frontier])
	for _, frontierLocationName in frontierLocationNames do
		table.insert(destinations, frontierLocationName)
	end

	local nightmareLocationNames = dictionaryToIndices(PivotTableByGroupId[GroupId.Nightmare])
	for _, nightmareLocationName in nightmareLocationNames do
		table.insert(destinations, nightmareLocationName)
	end

	return destinations
end

return getNPCTeleportDestinations
