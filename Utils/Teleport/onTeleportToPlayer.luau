--!strict

local function onTeleportToPlayer(
	targetPlayer: Player?,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> ()
)
	if not targetPlayer then
		return
	end

	local targetCharacter = targetPlayer.Character
	local targetPosition = if targetCharacter then targetCharacter:GetPivot().Position else nil
	if not targetPosition then
		return
	end

	task.spawn(teleportTo, targetPosition)
end

return onTeleportToPlayer
