--!strict

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local GroupId = (loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/GroupId.luau`))()
local PivotTableByGroupId =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/PivotTableByGroupId.luau`))()
local getNearestSellerName =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Utils/Sellers/getNearestSellerName.luau`))()

local function onTeleportToSeller(
	sellerName: string,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> ()
)
	if type(sellerName) ~= "string" or sellerName == "" then
		return
	end

	local targetCFrame: CFrame? = nil

	if sellerName == "Nearest To Character" then
		local nearestSeller = getNearestSellerName()
		if nearestSeller then
			targetCFrame = PivotTableByGroupId[GroupId.Seller][nearestSeller]
		end
	else
		targetCFrame = PivotTableByGroupId[GroupId.Seller][sellerName]
	end

	if not targetCFrame then
		return
	end

	task.spawn(teleportTo, targetCFrame.Position)
end

return onTeleportToSeller
