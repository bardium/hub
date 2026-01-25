--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getSpeakerNameByModel = (loadstring :: any)(
	(game :: any):HttpGet(`{Repository}Utils/NPC/getSpeakerNameByModel.luau`)
)()

local function getModelNameBySpeakerName(speakerName: string): string?
	local npcsFolder = Workspace:FindFirstChild("NPCS")
	local passiveNPCsFolder = Workspace:FindFirstChild("PassiveNPCs")
	if not (npcsFolder and passiveNPCsFolder) then
		return nil
	end
	for _, npcModel in passiveNPCsFolder:GetChildren() do
		if getSpeakerNameByModel(npcModel) == speakerName then
			return npcModel.Name
		end
	end
	for _, npcModel in npcsFolder:GetChildren() do
		if getSpeakerNameByModel(npcModel) == speakerName then
			return npcModel.Name
		end
	end
	return nil
end

return getModelNameBySpeakerName
