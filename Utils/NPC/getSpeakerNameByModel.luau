--!strict

local function getSpeakerNameByModel(npcModel: Instance): string
	local dialog1 = npcModel:FindFirstChild("Dialog1")
	local speakerName = if dialog1 then dialog1:FindFirstChild("SpeakerName") else nil
	if not speakerName then
		local dialogDefault = npcModel:FindFirstChild("Dialog_Default")
		speakerName = if dialogDefault then dialogDefault:FindFirstChild("SpeakerName") else nil
	end
	if not speakerName then
		local dialogIntro = npcModel:FindFirstChild("DialogIntro")
		speakerName = if dialogIntro then dialogIntro:FindFirstChild("SpeakerName") else nil
	end
	if not speakerName then
		local dialog = npcModel:FindFirstChild("Dialog")
		dialog1 = if dialog then dialog:FindFirstChild("Dialog1") else nil
		speakerName = if dialog1 then dialog1:FindFirstChild("SpeakerName") else nil
	end
	local speakerNameValue = if speakerName and speakerName:IsA("StringValue") then speakerName.Value else npcModel.Name
	return speakerNameValue
end

return getSpeakerNameByModel
