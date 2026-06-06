@tool
extends Node
class_name PACASStageState
## node for declaring what objects are available/exist in a given state for a stage.
## state is done using [PACASLogicBase] and its extensions



@export var stageStateName:StringName=&""
@export_multiline var description:String=""
@export var stateLogic:PACASLogicBase
@export var onGroups:PackedStringArray
@export_group("Script")
##File path to the script we are using
@export_file("*.gd") var ScriptFile:String:
	set(v):
		if v == &"":return
		var file=load(v)
		if file==null or not file.new() is RefCounted:return
		ScriptFile=v
		if v!=&"":
			_scriptObj=file.new()
		notify_property_list_changed()
var _scriptObj:RefCounted
##Selection from the script file
var ScriptMethod:StringName=&""
##Parameter for the script to call with
var callParameter:Variant
var _paramType:int:
	set(v):
		_paramType=v
		notify_property_list_changed()

func _ready()->void:
	if Engine.is_editor_hint():return
	#makes the child run after it's parent.
	if get_parent() is PACASStageState:await get_parent().ready
	PACASInteractions.updateStageStage.connect(updateState)

#should probably make this more versatile but for now, this will do.
#like, some states dont hide objects, they update their image/locations
func updateState()->void:
	var works = stateLogic.execute(null)
	var allNodes:Dictionary={}
	for group in onGroups:
		var nodes=get_tree().get_nodes_in_group(group)
		for node in nodes:
			allNodes[node]=null
	if _scriptObj!=null:
		_scriptObj.call(ScriptMethod,allNodes.keys(),works,callParameter)



func _get_property_list() -> Array[Dictionary]:
	var arr:Array[Dictionary]=[]
	if _scriptObj!=null:
		#filter out the default methods, only the custom ones are available
		var default_methods=RefCounted.new().get_method_list().map(func(m):return m.name)
		var methods=_scriptObj.get_method_list().map(func(m):return m.name)
		methods=methods.filter(func(m):return not default_methods.has(m) and not m.begins_with("@"))
		arr.append({
				"name": "ScriptMethod",
				"type": TYPE_STRING_NAME,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(methods),
			})
	# the param type for the call parameter to use
	var typeList:PackedStringArray=[]
	while typeList.size()<TYPE_MAX:
		var type=type_string(typeList.size())
		if type==null:break
		typeList.push_back(type)
	arr.append({
		"name": "_paramType",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(typeList),
	})
	arr.append({
		"name": "callParameter",
		"type": _paramType,
	})
	
	return arr
