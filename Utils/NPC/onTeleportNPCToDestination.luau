--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local GroupId = (loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/GroupId.luau`))()
local PivotTableByGroupId =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/PivotTableByGroupId.luau`))()

local function onTeleportNPCToDestination(npcName: string, destination: string?, Library: any)
	local frontierPivotTable = PivotTableByGroupId[GroupId.Frontier]
	local nightmarePivotTable = PivotTableByGroupId[GroupId.Nightmare]
	local sellersPivotTable = PivotTableByGroupId[GroupId.Sellers]

	if not (type(npcName) == "string" and npcName ~= "") then
		return
	end

	local npcsFolder = Workspace:FindFirstChild("NPCS")
	if not npcsFolder then
		Library:Notify("NPCs folder not found", 3)
		return
	end
	local npc = Workspace:FindFirstChild(npcName) or npcsFolder:FindFirstChild(npcName)
	if not (npc and npc:IsA("PVInstance")) then
		Library:Notify(`NPC "{npcName}" not found`, 3)
		return
	end

	if not (type(destination) == "string" and destination ~= "") then
		npc:PivotTo(sellersPivotTable["Big Box"])
		return
	end

	local targetPlayer = Players:FindFirstChild(destination)
	local targetCharacter = if targetPlayer and targetPlayer:IsA("Player") then targetPlayer.Character else nil
	local humanoid = if targetCharacter then targetCharacter:FindFirstChildOfClass("Humanoid") else nil
	local rootPart = if humanoid then humanoid.RootPart else nil
	if targetPlayer and not rootPart then
		Library:Notify(`Player "{destination}" not found`, 3)
		return
	end

	local targetCFrame = if typeof(frontierPivotTable[destination]) == "CFrame"
		then frontierPivotTable[destination]
		else if typeof(nightmarePivotTable[destination]) == "CFrame"
			then nightmarePivotTable[destination]
			else if rootPart then rootPart:GetPivot() else nil
	if not targetCFrame then
		Library:Notify(`Location "{destination}" not found`, 3)
		return nil
	end

	npc:PivotTo(targetCFrame)
	return true
end

return onTeleportNPCToDestination
