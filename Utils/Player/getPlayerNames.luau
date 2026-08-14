--!strict

local Players = game:GetService("Players")

local function getPlayerNames(): { string }
	local playerList = {}
	for _, otherPlayer in Players:GetPlayers() do
		table.insert(playerList, otherPlayer.Name)
	end
	return playerList
end

return getPlayerNames
