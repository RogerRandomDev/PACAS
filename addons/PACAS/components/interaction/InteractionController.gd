@tool
extends Node
class_name PACASInteractionController
## an autoload for the logic in PACAS for interactions.

signal ObjectInteracted(interactionType:InteractionTypes,object:PACASInteractionObject)
signal modelTagged(dataModel:PACASObjectDataModel,tag:String,value:Variant)
signal updateStageStage()


enum InteractionTypes{
	LeftClick,
	RightClick,
	Hover,
	Unhover,
	DragLeft,#left mouse button drag
	DragRight,#right mouse button drag
	DragRelease,#released mouse button after entering drag
}
## tracker to know what UUID corresponds to what object in the world
var ObjectUUIDS:Dictionary={}

var dataModel:PACASObjectDataModel=PACASObjectDataModel.new()

#defaults
var PACASDefaults:PACASDefaultsDataModel=load("res://addons/PACAS/PACASDefaults.tres")


func _ready() -> void:
	ObjectUUIDS["__GLOBAL__"]=self


func findByUUID(uuid:StringName)->Variant:
	return ObjectUUIDS.get(uuid)

func loadInteractiveObject(object:PACASInteractionObject)->void:
	if ObjectUUIDS.has(object.uniqueID):
		object.dataModel=ObjectUUIDS.get(object.uniqueID)
	else:
		ObjectUUIDS.set(object.uniqueID,object.dataModel)
