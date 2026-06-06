@tool
extends PACASLogicBase
class_name PACASLogicCallMethod

##Unique ID to reference the given target to call the method on
@export var callMethod:StringName=&""


func _executeInternal(iterationOwner:PACASInteractionObject)->bool:
	if iterationOwner==null:return false
	var onNode=iterationOwner.call(callMethod)
	
	return true
