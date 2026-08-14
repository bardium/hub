--!strict

local Workspace = game:GetService("Workspace")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local getItemByName = (loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Items/getItemByName.luau`))()

local function onTeleportToHarvestable(
	harvestableName: string,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> (),
	Library: any
)
	if type(harvestableName) ~= "string" or harvestableName == "" then
		return
	end

	local targetChild = nil

	local spawners = Workspace:FindFirstChild("Spawners")
	if not spawners then
		return
	end
	local harvestable = getItemByName(harvestableName)
	if not harvestable then
		return
	end
	for _, folder in spawners:GetChildren() do
		for _, part in folder:GetChildren() do
			for _, collectible in part:GetChildren() do
				local info = collectible:FindFirstChild("Info")
				local itemIntValue = if info then info:FindFirstChild("Item") else nil
				local itemId = if itemIntValue and itemIntValue:IsA("IntValue") then itemIntValue.Value else nil
				if itemId and itemId == harvestable.Id then
					targetChild = collectible
					break
				end
			end
			if targetChild then
				break
			end
		end
		if targetChild then
			break
		end
	end

	if not (targetChild and targetChild:IsA("PVInstance")) then
		Library:Notify(`Harvestable "{harvestableName}" not found`, 3)
		return
	end

	local targetPosition = targetChild:GetPivot().Position
	task.spawn(teleportTo, targetPosition)
end

return onTeleportToHarvestable
