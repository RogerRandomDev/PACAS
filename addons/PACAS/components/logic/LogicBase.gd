@tool
extends Resource
class_name PACASLogicBase

@export_subgroup("Base")
## default to follow up with in logic.
@export var followUp:PACASLogicBase
## called when the response from executing is false, I.E. if a filter stops you, it runs this instead.
@export var alternateFollowUp:PACASLogicBase

func execute(iterationOwner:PACASInteractionObject)->bool:
	var runFollowup:bool=_executeInternal(iterationOwner)
	if followUp!=null and runFollowup:
		return followUp.execute(iterationOwner)
	if followUp!=null and not runFollowup:
		alternateFollowUp.execute(iterationOwner)
	return runFollowup

func _executeInternal(iterationOwner:PACASInteractionObject)->bool:
	return true
