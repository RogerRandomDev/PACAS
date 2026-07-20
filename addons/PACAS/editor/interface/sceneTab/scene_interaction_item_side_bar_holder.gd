@tool
extends Control


func _ready() -> void:
	$"../..".itemSelected.connect(updateShownSelection)

func updateShownSelection(selectedItem:PACASInteractionObject)->void:
	if selectedItem == null:
		return
	var objectSubset:String = selectedItem.get_script().get_global_name()
	var sceneName:String= "DATAVIEW_%s.tscn"%objectSubset
	var fullPath:String="res://addons/PACAS/editor/interface/sceneTab/interactionObjectDataViews/%s"%sceneName
	if not FileAccess.file_exists(fullPath):return
	get_child(0).queue_free()
	var newSideView=load(fullPath).instantiate()
	add_child(newSideView)
	newSideView.updateSelected(selectedItem)
	move_child(newSideView,0)
