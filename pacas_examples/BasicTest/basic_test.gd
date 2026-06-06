extends Node2D


func _ready() -> void:
	PACASInteractions.updateStageStage.emit()
