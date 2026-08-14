--!strict

local Workspace = game:GetService("Workspace")

local random = Random.new()

local function onTeleportToEntrance(
	entranceName: string | { string },
	offsetMagnitude: number?,
	yOffset: number?,
	parent: Instance?,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> (),
	Library: any
)
	if not (type(entranceName) == "string" or type(entranceName) == "table") then
		return
	end

	local offset = if offsetMagnitude
		then random:NextUnitVector() * Vector3.new(offsetMagnitude, 0, offsetMagnitude)
		else Vector3.zero
	offset += Vector3.new(0, if yOffset then yOffset else 0, 0)

	parent = if parent then parent else Workspace
	if not parent then
		return
	end
	local entrance = if type(entranceName) == "string" then parent:FindFirstChild(entranceName) else nil
	if type(entranceName) == "table" then
		for _, name in entranceName do
			entrance = parent:FindFirstChild(name)
			if entrance and entrance:IsA("PVInstance") then
				break
			end
		end
	end
	if not entrance or not entrance:IsA("PVInstance") then
		Library:Notify(
			`"{if type(entranceName) == "string" then entranceName else entranceName[1]}" not found in {parent.Name}`,
			3
		)
		return
	end

	local targetPosition = entrance:GetPivot().Position + offset
	task.spawn(teleportTo, targetPosition)
end

return onTeleportToEntrance
