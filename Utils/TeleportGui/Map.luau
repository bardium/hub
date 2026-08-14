--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

export type Item = {
	Id: number,
	Name: string,
	Value: number,
	Icon: string,
	Quantity: number?,
}

export type Dependencies = {
	Toggles: any,
	Options: any,
	teleportTo: (targetPosition: Vector3, checkForCollisions: boolean?, teleportMethod: string?) -> (),
	getMinimumHarvestableValueOption: () -> number,
	getHarvestableInstances: (minimumValue: number) -> { { Instance: PVInstance, Item: Item } },
	formatMoney: (amount: number) -> string,
}

export type Controller = {
	isActive: () -> boolean,
	onToggle: () -> (),
	onKeybindInput: (inputObject: InputObject, gameProcessedEvent: boolean) -> (),
	updatePlayerIcons: () -> (),
	updateHarvestableIcons: () -> (),
	setShowPlayerIcons: (value: boolean) -> (),
	setCensorOwnName: (value: boolean) -> (),
	setHideOwnPfp: (value: boolean) -> (),
	setShowHarvestables: (value: boolean) -> (),
	setImageTransparency: (value: number) -> (),
	teardown: () -> (),
}

return function(deps: Dependencies): Controller
	local player = Players.LocalPlayer

	local WORLD_GUI_CENTER = Vector3.new(-1287, 500, 48)
	local WORLD_GUI_SCALE = 2710 * 2
	local MAP_MIN_ZOOM = 1
	local MAP_MAX_ZOOM = 6
	local MAP_ZOOM_STEP = 0.15

	local moduleConnections = {} :: { RBXScriptConnection }

	local frontierTeleportGui = nil :: ScreenGui?
	local mapViewport = nil :: Frame?
	local mapImage = nil :: ImageLabel?
	local mapZoom = 1
	local mapPanPosition = Vector2.zero
	local mapDragging = false
	local lastDragMousePosition = Vector2.zero
	local mapPlayerIcons = {} :: { [Player]: Frame }
	local mapShowPlayerIcons = true
	local mapCensorOwnName = false
	local mapHideOwnPfp = false
	local mapHarvestableIcons = {} :: { [Instance]: Frame }
	local mapShowHarvestables = false
	local mapImageTransparency = 0.2

	local function isFrontierTeleportGuiActive(): boolean
		return frontierTeleportGui ~= nil and frontierTeleportGui.Enabled
	end

	local function getInputScreenPosition(inputObject: InputObject): Vector2
		local inputPos = inputObject.Position
		if inputPos and (typeof(inputPos) == "Vector2" or typeof(inputPos) == "Vector3") then
			return Vector2.new(inputPos.X, inputPos.Y)
		end
		local mouse = player:GetMouse()
		return Vector2.new(mouse.X, mouse.Y)
	end

	local function isPositionWithinMapViewport(screenPosition: Vector2): boolean
		if not mapViewport then
			return false
		end
		local viewportPosition = mapViewport.AbsolutePosition
		local viewportSize = mapViewport.AbsoluteSize
		return screenPosition.X >= viewportPosition.X
			and screenPosition.X <= viewportPosition.X + viewportSize.X
			and screenPosition.Y >= viewportPosition.Y
			and screenPosition.Y <= viewportPosition.Y + viewportSize.Y
	end

	local function onFrontierTeleportGuiClick(inputObject: InputObject)
		if
			not (
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			)
		then
			return
		end

		if not mapImage then
			return
		end

		local frameSize = mapImage.AbsoluteSize
		local framePosition = mapImage.AbsolutePosition
		local inputScreenPosition = getInputScreenPosition(inputObject)

		local relativeX = math.clamp((inputScreenPosition.X - framePosition.X) / frameSize.X, 0, 1)
		local relativeY = math.clamp((inputScreenPosition.Y - framePosition.Y) / frameSize.Y, 0, 1)

		local offsetX = (relativeX - 0.5) * WORLD_GUI_SCALE
		local offsetZ = (0.5 - relativeY) * WORLD_GUI_SCALE

		local worldZ = WORLD_GUI_CENTER.X + offsetX
		local worldX = WORLD_GUI_CENTER.Z + offsetZ
		local worldY = WORLD_GUI_CENTER.Y

		local targetPosition = Vector3.new(worldX, worldY, worldZ)
		deps.teleportTo(targetPosition, true, nil)
	end

	local function worldPositionToMapRelative(position: Vector3): (number, number)
		local relativeX = 0.5 + (position.Z - WORLD_GUI_CENTER.X) / WORLD_GUI_SCALE
		local relativeY = 0.5 - (position.X - WORLD_GUI_CENTER.Z) / WORLD_GUI_SCALE
		return relativeX, relativeY
	end

	local function clampMapPan(zoom: number, pan: Vector2): Vector2
		if not mapViewport then
			return pan
		end
		local viewportSize = mapViewport.AbsoluteSize
		local maxOffsetX = math.max(0, (viewportSize.X * zoom - viewportSize.X) / 2)
		local maxOffsetY = math.max(0, (viewportSize.Y * zoom - viewportSize.Y) / 2)
		return Vector2.new(math.clamp(pan.X, -maxOffsetX, maxOffsetX), math.clamp(pan.Y, -maxOffsetY, maxOffsetY))
	end

	local function updateMapTransform()
		if not mapImage then
			return
		end
		mapImage.Size = UDim2.fromScale(mapZoom, mapZoom)
		mapImage.Position = UDim2.new(0.5, mapPanPosition.X, 0.5, mapPanPosition.Y)
	end

	local function screenToViewportOffset(screenPosition: Vector2): Vector2
		if not mapViewport then
			return Vector2.zero
		end
		local viewportPosition = mapViewport.AbsolutePosition
		local viewportSize = mapViewport.AbsoluteSize
		return screenPosition - (viewportPosition + viewportSize / 2)
	end

	local function onMapZoom(wheelDelta: number, screenPosition: Vector2)
		if not (mapViewport and mapImage) then
			return
		end
		local viewportSize = mapViewport.AbsoluteSize
		if viewportSize.X <= 0 or viewportSize.Y <= 0 then
			return
		end

		local previousZoom = mapZoom
		local newZoom = math.clamp(previousZoom + wheelDelta * MAP_ZOOM_STEP, MAP_MIN_ZOOM, MAP_MAX_ZOOM)
		if newZoom == previousZoom then
			return
		end

		local mouseOffset = screenToViewportOffset(screenPosition)
		local relativeInImage = (mouseOffset - mapPanPosition) / (viewportSize * previousZoom)

		mapZoom = newZoom
		mapPanPosition = clampMapPan(mapZoom, mouseOffset - (relativeInImage * viewportSize * mapZoom))
		updateMapTransform()
	end

	local function createMapPlayerIcon(targetPlayer: Player): Frame
		local icon = Instance.new("Frame")
		icon.Name = `Icon_{targetPlayer.Name}`
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Size = UDim2.fromOffset(28, 28)
		icon.BackgroundTransparency = 1
		icon.ZIndex = 10

		local avatarImage = Instance.new("ImageLabel")
		avatarImage.Name = "Avatar"
		avatarImage.Size = UDim2.fromScale(1, 1)
		avatarImage.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		avatarImage.BorderSizePixel = 0
		avatarImage.Image = `rbxthumb://type=AvatarHeadShot&id={targetPlayer.UserId}&w=100&h=100`
		avatarImage.ZIndex = 10
		avatarImage.Parent = icon

		local avatarCorner = Instance.new("UICorner")
		avatarCorner.CornerRadius = UDim.new(1, 0)
		avatarCorner.Parent = avatarImage

		local avatarStroke = Instance.new("UIStroke")
		avatarStroke.Thickness = 2
		avatarStroke.Color = if targetPlayer == player
			then Color3.fromRGB(80, 220, 100)
			else Color3.fromRGB(220, 80, 80)
		avatarStroke.Parent = avatarImage

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.AnchorPoint = Vector2.new(0.5, 1)
		nameLabel.Position = UDim2.new(0.5, 0, 0, -2)
		nameLabel.Size = UDim2.fromOffset(120, 16)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = targetPlayer.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 12
		nameLabel.ZIndex = 10
		nameLabel.Parent = icon

		return icon
	end

	local function applyPlayerIconState(targetPlayer: Player, icon: Frame)
		local isLocalPlayer = targetPlayer == player

		local avatarImage = icon:FindFirstChild("Avatar")
		if avatarImage and avatarImage:IsA("ImageLabel") then
			avatarImage.Visible = not (isLocalPlayer and mapHideOwnPfp)
		end

		local nameLabel = icon:FindFirstChild("NameLabel")
		if nameLabel and nameLabel:IsA("TextLabel") then
			nameLabel.Text = if isLocalPlayer and mapCensorOwnName then "You" else targetPlayer.Name
		end
	end

	local function setMapShowPlayerIcons(value: boolean)
		mapShowPlayerIcons = value
		if not value then
			for _, icon in mapPlayerIcons do
				icon.Visible = false
			end
		end
	end

	local function setMapCensorOwnName(value: boolean)
		mapCensorOwnName = value
		local ownIcon = mapPlayerIcons[player]
		if ownIcon then
			applyPlayerIconState(player, ownIcon)
		end
	end

	local function setMapHideOwnPfp(value: boolean)
		mapHideOwnPfp = value
		local ownIcon = mapPlayerIcons[player]
		if ownIcon then
			applyPlayerIconState(player, ownIcon)
		end
	end

	local function updateMapPlayerIcons()
		if not (mapImage and mapImage.Parent) then
			return
		end

		if not mapShowPlayerIcons then
			for _, icon in mapPlayerIcons do
				icon.Visible = false
			end
			return
		end

		for _, otherPlayer in Players:GetPlayers() do
			local character = otherPlayer.Character
			local rootPart = if character then character:FindFirstChild("HumanoidRootPart") else nil
			if not (rootPart and rootPart:IsA("BasePart")) then
				continue
			end

			local icon = mapPlayerIcons[otherPlayer]
			if not icon then
				icon = createMapPlayerIcon(otherPlayer)
				icon.Parent = mapImage
				mapPlayerIcons[otherPlayer] = icon
			end

			local relativeX, relativeY = worldPositionToMapRelative(rootPart.Position)
			icon.Position = UDim2.fromScale(math.clamp(relativeX, 0, 1), math.clamp(relativeY, 0, 1))
			icon.Visible = relativeX >= -0.02 and relativeX <= 1.02 and relativeY >= -0.02 and relativeY <= 1.02
			applyPlayerIconState(otherPlayer, icon)
		end

		for otherPlayer, icon in mapPlayerIcons do
			if not (otherPlayer.Parent and otherPlayer.Character) then
				icon:Destroy()
				mapPlayerIcons[otherPlayer] = nil
			end
		end
	end

	local function createMapHarvestableIcon(item: Item): Frame
		local icon = Instance.new("Frame")
		icon.Name = `Harvestable_{item.Id}`
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Size = UDim2.fromOffset(22, 22)
		icon.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		icon.BackgroundTransparency = if item.Icon ~= "" then 0.2 else 1
		icon.BorderSizePixel = 0
		icon.ZIndex = 9

		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 4)
		iconCorner.Parent = icon

		if item.Icon ~= "" then
			local iconImage = Instance.new("ImageLabel")
			iconImage.Name = "Icon"
			iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
			iconImage.Position = UDim2.fromScale(0.5, 0.5)
			iconImage.Size = UDim2.fromScale(0.8, 0.8)
			iconImage.BackgroundTransparency = 1
			iconImage.Image = item.Icon
			iconImage.ZIndex = 9
			iconImage.Parent = icon
		else
			local marker = Instance.new("Frame")
			marker.Name = "Marker"
			marker.AnchorPoint = Vector2.new(0.5, 0.5)
			marker.Position = UDim2.fromScale(0.5, 0.5)
			marker.Size = UDim2.fromOffset(10, 10)
			marker.Rotation = 45
			marker.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
			marker.BorderSizePixel = 0
			marker.ZIndex = 9
			marker.Parent = icon
		end

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.AnchorPoint = Vector2.new(0.5, 1)
		nameLabel.Position = UDim2.new(0.5, 0, 0, -2)
		nameLabel.Size = UDim2.fromOffset(150, 16)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = `{item.Name} ({deps.formatMoney(item.Value)})`
		nameLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 11
		nameLabel.ZIndex = 9
		nameLabel.Parent = icon

		return icon
	end

	local function setMapShowHarvestables(value: boolean)
		mapShowHarvestables = value
		if not value then
			for _, icon in mapHarvestableIcons do
				icon:Destroy()
			end
			table.clear(mapHarvestableIcons)
		end
	end

	local function setMapImageTransparency(value: number)
		mapImageTransparency = math.clamp(value, 0, 100) / 100
		if mapImage then
			mapImage.ImageTransparency = mapImageTransparency
		end
	end

	local function updateMapHarvestableIcons()
		if not (mapImage and mapImage.Parent and mapShowHarvestables) then
			return
		end

		local minimumValue = deps.getMinimumHarvestableValueOption()
		local seenInstances = {} :: { [Instance]: boolean }

		for _, entry in deps.getHarvestableInstances(minimumValue) do
			local instance = entry.Instance
			seenInstances[instance] = true

			local icon = mapHarvestableIcons[instance]
			if not icon then
				icon = createMapHarvestableIcon(entry.Item)
				icon.Parent = mapImage
				mapHarvestableIcons[instance] = icon
			end

			local relativeX, relativeY = worldPositionToMapRelative(instance:GetPivot().Position)
			icon.Position = UDim2.fromScale(math.clamp(relativeX, 0, 1), math.clamp(relativeY, 0, 1))
			icon.Visible = relativeX >= -0.02 and relativeX <= 1.02 and relativeY >= -0.02 and relativeY <= 1.02
		end

		for instance, icon in mapHarvestableIcons do
			if not seenInstances[instance] then
				icon:Destroy()
				mapHarvestableIcons[instance] = nil
			end
		end
	end

	local function onMapUserInputBegan(inputObject: InputObject)
		if not isFrontierTeleportGuiActive() then
			return
		end
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton3 then
			return
		end
		local screenPosition = getInputScreenPosition(inputObject)
		if not isPositionWithinMapViewport(screenPosition) then
			return
		end
		mapDragging = true
		lastDragMousePosition = screenPosition
	end

	local function onMapUserInputChanged(inputObject: InputObject)
		if not isFrontierTeleportGuiActive() then
			return
		end

		if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
			local screenPosition = getInputScreenPosition(inputObject)
			if not isPositionWithinMapViewport(screenPosition) then
				return
			end
			onMapZoom(inputObject.Position.Z, screenPosition)
			return
		end

		if mapDragging and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			local screenPosition = getInputScreenPosition(inputObject)
			local delta = screenPosition - lastDragMousePosition
			lastDragMousePosition = screenPosition
			mapPanPosition = clampMapPan(mapZoom, mapPanPosition + delta)
			updateMapTransform()
		end
	end

	local function onMapUserInputEnded(inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton3 then
			mapDragging = false
		end
	end

	local function createFrontierTeleportGui()
		if frontierTeleportGui then
			frontierTeleportGui.Enabled = true
			return
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ScreenGui"
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = player:WaitForChild("PlayerGui")

		local viewport = Instance.new("Frame")
		viewport.Name = "MapViewport"
		viewport.BackgroundTransparency = 1
		viewport.ClipsDescendants = true
		viewport.AnchorPoint = Vector2.new(0.5, 0.5)
		viewport.Position = UDim2.fromScale(0.5, 0.5)
		viewport.Size = UDim2.fromScale(0.99, 0.99)
		viewport.Active = true

		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
		uIAspectRatioConstraint.Parent = viewport

		viewport.Parent = screenGui

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "MapImage"
		imageLabel.Image = "rbxassetid://118745157397327"
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageTransparency = mapImageTransparency
		imageLabel.BorderSizePixel = 0
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Active = true
		imageLabel.Selectable = true
		imageLabel.Parent = viewport

		table.insert(moduleConnections, imageLabel.InputBegan:Connect(onFrontierTeleportGuiClick))

		mapZoom = 1
		mapPanPosition = Vector2.zero
		mapViewport = viewport
		mapImage = imageLabel
		frontierTeleportGui = screenGui
	end

	local function destroyFrontierTeleportGui()
		if frontierTeleportGui then
			frontierTeleportGui.Enabled = false
		end
		mapDragging = false
	end

	local function onFrontierTeleportGuiToggle()
		if deps.Toggles.GuiFrontierTeleport and deps.Toggles.GuiFrontierTeleport.Value then
			createFrontierTeleportGui()
		else
			destroyFrontierTeleportGui()
		end
	end

	local function onFrontierTeleportGuiKeybindInput(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent or inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local keybindOption = deps.Options.GuiFrontierTeleportKeybind
		local keybindName = if keybindOption then keybindOption.Value else nil
		if type(keybindName) ~= "string" or keybindName == "" or keybindName == "None" then
			return
		end

		if inputObject.KeyCode ~= Enum.KeyCode[keybindName] then
			return
		end

		if deps.Toggles.GuiFrontierTeleport then
			deps.Toggles.GuiFrontierTeleport:SetValue(not deps.Toggles.GuiFrontierTeleport.Value)
		end
	end

	table.insert(moduleConnections, UserInputService.InputBegan:Connect(onMapUserInputBegan))
	table.insert(moduleConnections, UserInputService.InputChanged:Connect(onMapUserInputChanged))
	table.insert(moduleConnections, UserInputService.InputEnded:Connect(onMapUserInputEnded))
	table.insert(moduleConnections, UserInputService.InputBegan:Connect(onFrontierTeleportGuiKeybindInput))

	return {
		isActive = isFrontierTeleportGuiActive,
		onToggle = onFrontierTeleportGuiToggle,
		onKeybindInput = onFrontierTeleportGuiKeybindInput,
		updatePlayerIcons = updateMapPlayerIcons,
		updateHarvestableIcons = updateMapHarvestableIcons,
		setShowPlayerIcons = setMapShowPlayerIcons,
		setCensorOwnName = setMapCensorOwnName,
		setHideOwnPfp = setMapHideOwnPfp,
		setShowHarvestables = setMapShowHarvestables,
		setImageTransparency = setMapImageTransparency,
		teardown = function()
			for _, connection in moduleConnections do
				connection:Disconnect()
			end
			table.clear(moduleConnections)

			if frontierTeleportGui then
				frontierTeleportGui:Destroy()
				frontierTeleportGui = nil
			end
			mapViewport = nil
			mapImage = nil
			table.clear(mapPlayerIcons)
			table.clear(mapHarvestableIcons)
		end,
	}
end
