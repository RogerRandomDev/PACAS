extends Resource
class_name PACASDefaultsDataModel

@export_group("InteractionDefaults")
## Left click
@export var onClickedDefault:PACASLogicBase
## Right click
@export var onAlternateClickedDefault:PACASLogicBase
@export var onHoveredDefault:PACASLogicBase

@export_group("FileDefaults")
@export var rootFolder:StringName=&"res://"
@export var scenesFolder:StringName=&"res://"
@export var texturesFolder:StringName=&"res://"
@export var stageStateFolder:StringName=&"res://"
@export var logicScriptsFolder:StringName=&"res://"
@export_group("Inventory")
@export_file("*.gd") var inventoryHandler="res://addons/PACAS/components/inventory/inventoryHandlerBase.gd"
