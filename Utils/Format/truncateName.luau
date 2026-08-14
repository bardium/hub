--!strict

local function truncateName(name: string, maxLength: number): string
	if #name <= maxLength then
		return name
	end
	local truncated = name:sub(1, maxLength - 3)
	if truncated:sub(-1) == " " then
		truncated = truncated:sub(1, -2)
	end
	return truncated .. "..."
end

return truncateName
