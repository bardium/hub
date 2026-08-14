--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

type Item = {
	Id: number,
	Name: string,
	Value: number,
	Icon: string,
	Quantity: number?,
}

local function getItemById(itemId: number): Item?
	local itemInfo = ReplicatedStorage:FindFirstChild("ItemInfo")
	local folder = if itemInfo then itemInfo:FindFirstChild(`{itemId}`) else nil
	local fullNameStringValue = if folder then folder:FindFirstChild("FullName") else nil
	local itemName = if fullNameStringValue and fullNameStringValue:IsA("StringValue")
		then fullNameStringValue.Value
		else nil
	local sellValueIntValue = if folder then folder:FindFirstChild("SellValue") else nil
	local sellValue = if sellValueIntValue and sellValueIntValue:IsA("IntValue") then sellValueIntValue.Value else nil
	local iconDecal = if folder then folder:FindFirstChild("Icon") else nil
	local icon = if iconDecal and iconDecal:IsA("Decal") then iconDecal.Texture else ""

	if not (itemName and sellValue) then
		return nil
	end

	return {
		Id = itemId,
		Name = itemName,
		Value = sellValue,
		Icon = icon,
	}
end

return getItemById
