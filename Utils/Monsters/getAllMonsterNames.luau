--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getAllMonsters = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Monsters/getAllMonsters.luau`))()

local function getAllMonsterNames(): { string }
	local monsterNames = {}
	for _, monster in getAllMonsters() do
		table.insert(monsterNames, monster.Name)
	end
	return monsterNames
end

return getAllMonsterNames
