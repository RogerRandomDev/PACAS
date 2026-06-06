extends RefCounted


func exampleHideShow(objects:Array,valid:bool=false,_additionalParam:Variant=null)->void:
	for object in objects:
		object.visible=valid

func exampleColorWhite(objects:Array,valid:bool=false,_additionalParam:Variant=null)->void:
	if not valid:return
	for object in objects:
		object.get_child(0).modulate=Color.WHITE
