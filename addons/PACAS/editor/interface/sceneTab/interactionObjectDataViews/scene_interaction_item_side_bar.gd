@tool
extends TabContainer


var activeSelection:PACASInteractionObject

func _ready() -> void:
	$"../../..".itemSelected.connect(updateSelected)

	%InteractionObjectGroupNameAddButton.pressed.connect(
		func():
			var groupName:String=%InteractionObjectGroupNameEdit.text
			%InteractionObjectGroupNameEdit.text=""
			if activeSelection==null:return
			if activeSelection.groups.has(groupName):return
			activeSelection.groups.push_back(groupName)
			updateGroupList()
	)
	%InteractionObjectGroupListEdit.item_mouse_selected.connect(
		func(position:Vector2,index:int):
			if activeSelection==null:return
			var selected :TreeItem= %InteractionObjectGroupListEdit.get_selected()
			if index==MOUSE_BUTTON_RIGHT:
				activeSelection.groups.erase(selected.get_text(0))
				updateGroupList.call_deferred()
	)
	
	%InteractionObjectPositionEdit.text_changed.connect(
		func(new_text:String):
			var splitValues:Array=new_text.split(",")
			if splitValues.size()!=2:return
			if not splitValues.all(func(v):return v.is_valid_float()):return
			var parsed:Vector2=Vector2(
				splitValues[0].to_float(),
				splitValues[1].to_float()
			)
			activeSelection.position=parsed
			$"../../..".get_node("Highlighter").updateHighlightPosition()
	)
	
	%InteractionObjectSizeEdit.text_changed.connect(
		func(new_text:String):
			var splitValues:Array=new_text.split(",")
			if splitValues.size()!=2:return
			if not splitValues.all(func(v):return v.is_valid_float()):return
			var parsed:Vector2=Vector2(
				splitValues[0].to_float(),
				splitValues[1].to_float()
			)
			activeSelection.size=parsed
			$"../../..".get_node("Highlighter").updateHighlightPosition()
	)
	
	%InteractionObjectLogicButton.pressed.connect(
		func():
			var popup :Window= load("res://addons/PACAS/editor/interface/InteractionLogicNodes/CallScriptLogicPopup.tscn").instantiate()
			popup.close_requested.connect(popup.queue_free)
			popup.loadContents(activeSelection.onClicked,activeSelection,"onClicked")
			add_child(popup)
			popup.popup()
	)

func updateSelected(item:PACASInteractionObject)->void:
	if activeSelection==item:return
	activeSelection=item
	updateGroupList()
	updateGeneralInfo()



func updateGroupList()->void:
	%InteractionObjectGroupListEdit.clear()
	if activeSelection==null:return
	var root:TreeItem=%InteractionObjectGroupListEdit.create_item()
	for group in activeSelection.groups:
		var child:TreeItem=root.create_child()
		child.set_text(0,group)


func updateGeneralInfo()->void:
	%InteractionObjectUniqueIDEdit.text=""
	%InteractionObjectPositionEdit.text=""
	%InteractionObjectSizeEdit.text=""
	if activeSelection==null:return
	%InteractionObjectUniqueIDEdit.text=activeSelection.uniqueID
	%InteractionObjectPositionEdit.text="%s,%s"%[
		str(snapped(activeSelection.position.x,0.001)),
		str(snapped(activeSelection.position.y,0.001))
	]
	%InteractionObjectSizeEdit.text="%s,%s"%[
		str(snapped(activeSelection.size.x,0.001)),
		str(snapped(activeSelection.size.y,0.001))
	]
	
