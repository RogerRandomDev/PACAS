@tool
extends EditorPlugin

const PACASScreen=preload("res://addons/PACAS/editor/PACASEditorInterface.tscn")
var PACASScreenInstance

func _enter_tree() -> void:
	add_autoload_singleton("PACASInteractions","res://addons/PACAS/components/interaction/InteractionController.gd")
	#load the editor screen
	#PACASScreenInstance=PACASScreen.instantiate()
	#EditorInterface.get_editor_main_screen().add_child(PACASScreenInstance)
	_make_visible(false)


func _exit_tree() -> void:
	remove_autoload_singleton("PACASInteractions")
	pass


func _has_main_screen() -> bool:return false

func _make_visible(visible: bool) -> void:
	#PACASScreenInstance.visible=visible
	pass

func _get_plugin_name() -> String:return "PACAS"
