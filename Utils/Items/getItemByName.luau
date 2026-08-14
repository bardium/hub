--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

type Item = {
	Id: number,
	Name: string,
	Value: number,
	Icon: string,
	Quantity: number?,
}

local function getItemByName(itemName: string): Item?
	local itemInfo = ReplicatedStorage:FindFirstChild("ItemInfo")
	if not itemInfo then
		return nil
	end
	for _, folder in itemInfo:GetChildren() do
		local fullNameStringValue = folder:FindFirstChild("FullName")
		local otherItemName = if fullNameStringValue and fullNameStringValue:IsA("StringValue")
			then fullNameStringValue.Value
			else nil
		if not (itemName == otherItemName) then
			continue
		end

		local itemId = tonumber(folder.Name)
		local sellValueIntValue = if folder then folder:FindFirstChild("SellValue") else nil
		local sellValue = if sellValueIntValue and sellValueIntValue:IsA("IntValue")
			then sellValueIntValue.Value
			else nil
		local iconDecal = folder:FindFirstChild("Icon")
		local icon = if iconDecal and iconDecal:IsA("Decal") then iconDecal.Texture else ""

		if not (itemId and sellValue) then
			continue
		end

		return {
			Id = itemId,
			Name = itemName,
			Value = sellValue,
			Icon = icon,
		}
	end
	return nil
end

return getItemByName
