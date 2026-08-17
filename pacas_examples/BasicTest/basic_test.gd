extends Node2D


func _ready() -> void:
	PACASInteractions.updateStageStage.emit()
	

#test save/load
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.as_text()=="K":
		PACASInteractions.saveHandler.saveData()
	if event is InputEventKey and event.is_pressed() and event.as_text()=="L":
		PACASInteractions.saveHandler.loadData()
		get_tree().reload_current_scene()
