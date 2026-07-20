@tool
extends Node


func _ready() -> void:
	
	%SceneInteractionObjectListTree.item_selected.connect(itemSelected
	)

func itemSelected()->void:
	var selected:TreeItem = %SceneInteractionObjectListTree.get_selected()
	
	var interactionObject:PACASInteractionObject = selected.get_meta("Object",null)
	%SelectionHighlightRect.set_meta("Object",interactionObject)
	if interactionObject==null:return
	get_parent().itemSelected.emit(interactionObject)
	%SelectionHighlightRect.show()
	%SelectionHighlightRect.position=interactionObject.global_position
	%SelectionHighlightRect.size=interactionObject.size

func updateHighlightPosition()->void:
	var interactionObject:PACASInteractionObject = %SelectionHighlightRect.get_meta("Object",null)
	%SelectionHighlightRect.hide()
	if interactionObject==null:return
	%SelectionHighlightRect.show()
	%SelectionHighlightRect.position=interactionObject.global_position
	%SelectionHighlightRect.size=interactionObject.size
