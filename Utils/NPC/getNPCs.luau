--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getSpeakerNameByModel =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/NPC/getSpeakerNameByModel.luau`))()

local function getNPCs(folderName: "NPCS" | "PassiveNPCs"): { string }
	local npcList = {}
	local seenNames = {}

	local npcsFolder = Workspace:FindFirstChild(folderName)
	if not npcsFolder then
		return npcList
	end

	for _, npcModel in npcsFolder:GetChildren() do
		if not (npcModel:IsA("Model") and not seenNames[getSpeakerNameByModel(npcModel)]) then
			continue
		end
		table.insert(npcList, getSpeakerNameByModel(npcModel))
		seenNames[getSpeakerNameByModel(npcModel)] = true
	end
	if folderName == "NPCS" then
		local circusNPC = Workspace:FindFirstChild("CircusNPC")
		if circusNPC and circusNPC:IsA("Model") then
			table.insert(npcList, circusNPC.Name)
			seenNames[circusNPC.Name] = true
		end
	end
	return npcList
end

return getNPCs
