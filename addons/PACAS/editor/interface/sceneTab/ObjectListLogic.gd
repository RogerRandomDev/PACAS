@tool
extends Node


func _ready() -> void:
	
	%SceneInteractionObjectListTree.item_selected.connect(itemSelected
	)

func itemSelected()->void:
	var selected:TreeItem = %SceneInteractionObjectListTree.get_selected()
	var interactionObject:PACASInteractionObject = selected.get_meta("Object",null)
	if interactionObject==null:return
	%SelectionHighlightRect.show()
	%SelectionHighlightRect.position=interactionObject.global_position
	%SelectionHighlightRect.size=interactionObject.size
	
