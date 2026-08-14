--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local GroupId = (loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/GroupId.luau`))()
local PivotTableByGroupId =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/PivotTableByGroupId.luau`))()

local function onTeleportToLocation(
	locationName: string,
	groupId: GroupId.EnumType,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> (),
	Library: any
)
	if type(locationName) ~= "string" or locationName == "" then
		return
	end

	local pivotTable = PivotTableByGroupId[groupId]

	if pivotTable and typeof(pivotTable[locationName]) == "CFrame" then
		task.spawn(teleportTo, pivotTable[locationName].Position)
		return
	end

	Library:Notify(`Location "{locationName}" not found in {groupId}`, 3)
end

return onTeleportToLocation
