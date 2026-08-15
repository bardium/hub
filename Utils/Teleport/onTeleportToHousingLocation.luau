--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local GroupId = (loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/GroupId.luau`))()
local onTeleportToLocation =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Teleport/onTeleportToLocation.luau`))()

local function onTeleportToHousingLocation(
	locationName: string,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> (),
	Library: any
)
	onTeleportToLocation(locationName, GroupId.Housing, teleportTo, Library)
end

return onTeleportToHousingLocation
