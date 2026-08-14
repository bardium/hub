--!strict

local function formatCommas(amount: number | string): string
	local minusSign, integerPart, fractionalPart
	minusSign, integerPart, fractionalPart = tostring(amount):match("([-]?)(%d+)([.]?%d*)")

	if not integerPart then
		return tostring(amount)
	end

	integerPart = integerPart:reverse():gsub("(%d%d%d)", "%1,")
	integerPart = integerPart:reverse():gsub("^,", "")

	return `{minusSign}{integerPart}{fractionalPart}`
end

return formatCommas
