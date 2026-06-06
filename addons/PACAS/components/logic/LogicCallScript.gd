@tool
extends PACASLogicBase
class_name PACASLogicCallScript

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


func _executeInternal(iterationOwner:PACASInteractionObject)->bool:
	if _paramType==TYPE_NIL:
		if _scriptObj.get_method_argument_count(ScriptMethod)>0:_scriptObj.call(ScriptMethod,iterationOwner)
		else:_scriptObj.call(ScriptMethod)
	else:
		if _scriptObj.get_method_argument_count(ScriptMethod)>1:_scriptObj.call(ScriptMethod,iterationOwner,callParameter)
		else:_scriptObj.call(ScriptMethod,callParameter)
	
	return true



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
