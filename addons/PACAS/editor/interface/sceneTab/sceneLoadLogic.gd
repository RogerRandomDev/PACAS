@tool
extends Node


func _ready() -> void:
	get_parent().sceneLoaded.connect(onSceneLoaded)

func onSceneLoaded(scene:Node)->void:
	var interactionObjects:Array=getInteractionObjects(scene)
	%SelectionHighlightRect.hide()
	loadObjectList(interactionObjects)

func getInteractionObjects(scene:Node)->Array:
	var objects:Array=[]
	if scene.has_node("InteractionObjects"):
		var interactionObjectHolder:Node=scene.get_node("InteractionObjects")
		objects=iterateGetInteractionObjects(interactionObjectHolder)
	else:
		objects=iterateGetInteractionObjects(scene)
	return objects


func iterateGetInteractionObjects(iterator:Node)->Array:
	var arr:Array=[]
	for child in iterator.get_children():arr.append_array(iterateGetInteractionObjects(child))
	if iterator is PACASInteractionObject:
		arr.push_back(iterator)
	
	return arr

func loadObjectList(objects:Array)->void:
	%SceneInteractionObjectListTree.clear()
	var root:TreeItem=%SceneInteractionObjectListTree.create_item()
	for interactionObject in objects:
		var objectItem:TreeItem = root.create_child()
		objectItem.set_text(0,interactionObject.uniqueID)
		objectItem.set_meta("Object",interactionObject)
