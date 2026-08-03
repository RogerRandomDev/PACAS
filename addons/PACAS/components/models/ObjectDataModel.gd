extends Resource
class_name PACASObjectDataModel
## Model used to store the individual data that is tracked between individual objects.

signal tagged(tag:String,value:Variant)

@export var name:StringName=&""
@export_file("*.png","*.svg") var texturePath:
	set(v):
		if v!=null and FileAccess.file_exists(v):
			texture=load(v)
		texturePath=v
var texture:Texture
@export_multiline var description:String=""
@export var tags:Dictionary={}
## ID of the group that owns the object for this data.
@export var groupOwnerID:StringName=&""

## adds a tag to the object. set [param removeNull] to false to allow the value to be null.
func addTag(tag:StringName,value:Variant=null)->void:
	if not tags.has(tag):
		tags[tag]=value
		PACASInteractions.modelTagged.emit(self,tag,value)
		tagged.emit(tag,value)

## sets a tag on the object. set [param removeNull] to false to allow the value to be null.
func setTag(tag:StringName,value:Variant=null,removeNull:bool=true)->void:
	tags[tag]=value
	if removeNull and value==null:tags.erase(tag)
	PACASInteractions.modelTagged.emit(self,tag,value)
	tagged.emit(tag,value)

## only checks and returns if a tag exists.
func checkForTag(tag:StringName)->bool:
	return tags.has(tag)
