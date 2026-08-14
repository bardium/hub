--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getModelNameBySpeakerName =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/NPC/getModelNameBySpeakerName.luau`))()

local function onTeleportToPassiveNPC(
	speakerName: string,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> ()
)
	if type(speakerName) ~= "string" or speakerName == "" then
		return
	end

	local passiveNPCs = Workspace:FindFirstChild("PassiveNPCs")
	if not passiveNPCs then
		return
	end

	local npcModelName = getModelNameBySpeakerName(speakerName)
	if not npcModelName then
		return
	end
	local npc = passiveNPCs:FindFirstChild(npcModelName)
	if not (npc and npc:IsA("PVInstance")) then
		return
	end

	task.spawn(teleportTo, npc:GetPivot().Position)
end

return onTeleportToPassiveNPC
