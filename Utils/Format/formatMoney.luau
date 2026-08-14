--!strict

local function formatMoney(amount: number): string
	if amount < 1000 then
		return tostring(amount)
	elseif amount < 1000000 then
		local thousands = amount / 1000
		if thousands % 1 == 0 then
			return `{math.floor(thousands)}k`
		else
			local rounded = math.floor(thousands * 10) / 10
			return `{rounded}k`
		end
	else
		local millions = amount / 1000000
		if millions % 1 == 0 then
			return `{math.floor(millions)}m`
		else
			local rounded = math.floor(millions * 10) / 10
			return `{rounded}m`
		end
	end
end

return formatMoney
