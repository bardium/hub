--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local function getAllMonsters(): { Instance }
	local monsters = {}

	local npcsFolder = Workspace:FindFirstChild("NPCS")
	if npcsFolder then
		for _, monster in npcsFolder:GetChildren() do
			table.insert(monsters, monster)
		end
	end

	local guttermouthContainer = Workspace:FindFirstChild("Guttermouth")
	local guttermouthRooms = {
		if guttermouthContainer then guttermouthContainer:FindFirstChild("GuttermouthRoom1") else nil,
		if guttermouthContainer then guttermouthContainer:FindFirstChild("GuttermouthRoom2") else nil,
		if guttermouthContainer then guttermouthContainer:FindFirstChild("GuttermouthRoom3") else nil,
		if guttermouthContainer then guttermouthContainer:FindFirstChild("GuttermouthRoom4") else nil,
	}
	for _, roomFolder in guttermouthRooms do
		local roomMonstersFolder = if roomFolder then roomFolder:FindFirstChild("Monsters") else nil
		if not roomMonstersFolder then
			continue
		end
		for _, monster in roomMonstersFolder:GetChildren() do
			table.insert(monsters, monster)
		end
	end

	local spawnables = ReplicatedStorage:FindFirstChild("Spawnables")
	local monstersFolder = if spawnables then spawnables:FindFirstChild("Monsters") else nil
	if monstersFolder then
		for _, monster in monstersFolder:GetChildren() do
			table.insert(monsters, monster)
		end
	end

	return monsters
end

return getAllMonsters
