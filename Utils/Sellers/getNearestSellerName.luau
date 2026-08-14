--!strict

local Players = game:GetService("Players")

local Repository = "https://raw.githubusercontent.com/bardium/hub/main/"
local GroupId = (loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/GroupId.luau`))()
local PivotTableByGroupId =
	(loadstring :: any)((game :: any):HttpGet(`{Repository}Constants/Location/PivotTableByGroupId.luau`))()

local player = Players.LocalPlayer

local function getNearestSellerName(): string?
	local character = player.Character
	if not character then
		return nil
	end

	local characterPosition = character:GetPivot().Position
	local nearestSeller: string? = nil
	local nearestDistance = math.huge

	for sellerName, sellerCFrame in PivotTableByGroupId[GroupId.Seller] do
		if not (type(sellerName) == "string" and sellerCFrame and typeof(sellerCFrame) == "CFrame") then
			continue
		end
		local sellerPosition = sellerCFrame.Position
		local distance = (characterPosition - sellerPosition).Magnitude
		if distance >= nearestDistance then
			continue
		end
		nearestDistance = distance
		nearestSeller = sellerName
	end

	return nearestSeller
end

return getNearestSellerName
