--!strict

export type EnumType =
	"Black Tower"
	| "Boathouse"
	| "Ice Spire"
	| "Starting House"
	| "The Red Ogre Inn"
	| "Topple Castle"
	| "Topple House"
	| "White Tower"

local Housing = {
	["Black Tower"] = "Black Tower" :: "Black Tower",
	["Boathouse"] = "Boathouse" :: "Boathouse",
	["Ice Spire"] = "Ice Spire" :: "Ice Spire",
	["Starting House"] = "Starting House" :: "Starting House",
	["The Red Ogre Inn"] = "The Red Ogre Inn" :: "The Red Ogre Inn",
	["Topple Castle"] = "Topple Castle" :: "Topple Castle",
	["Topple House"] = "Topple House" :: "Topple House",
	["White Tower"] = "White Tower" :: "White Tower",
}

return Housing
