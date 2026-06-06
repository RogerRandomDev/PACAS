@tool
extends Control


func _ready() -> void:
	$TabContainer.tab_changed.connect(
		func(tab:int):
			$TabContainer.get_child(tab).openTab()
	)
