--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local onTeleportNPCToDestination =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/NPC/onTeleportNPCToDestination.luau`))()

local function onTeleportToNPC(
	npcName: string,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> (),
	Library: any,
	Toggles: any,
	Options: any
)
	if type(npcName) ~= "string" or npcName == "" then
		return
	end

	local npcsFolder = Workspace:FindFirstChild("NPCS")
	if not npcsFolder then
		Library:Notify("NPCs folder not found", 3)
		return
	end
	local npc = Workspace:FindFirstChild(npcName) or npcsFolder:FindFirstChild(npcName)
	if not (npc and npc:IsA("Model")) then
		Library:Notify(`NPC "{npcName}" not found`, 3)
		return
	end

	local targetPosition = npc:GetPivot().Position

	task.spawn(teleportTo, targetPosition)
	task.delay(10, function()
		if Toggles.TeleportNPC and Toggles.TeleportNPC.Value then
			local destination = if Options.TeleportNPCDestination and Options.TeleportNPCDestination.Value
				then Options.TeleportNPCDestination.Value
				else nil
			onTeleportNPCToDestination(npcName, destination, Library)
		end
	end)
end

return onTeleportToNPC
