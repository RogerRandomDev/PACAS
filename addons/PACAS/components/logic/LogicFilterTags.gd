@tool
extends PACASLogicBase
class_name PACASLogicFilterTags

@export_group("Filter")
## Source to check tags on. I.E. UUID of a specific object in the world
@export var tagSource:StringName=&""
## An array of tags to either require, or block if had
@export var tags:PackedStringArray=[]
## If it is a white or blacklist
@export var isBlacklist:bool=false
## If all must be present for it to block/allow
@export var requireAll:bool=false
## If tags should use REGEX to check. [br]Begin any REGEX check with \ to prevent normal checks from being treated as REGEX.
@export var useREGEX:bool=false

func _executeInternal(iterationOwner:PACASInteractionObject)->bool:
	var checkTags:PACASObjectDataModel=null
	if tagSource==&"":
		if iterationOwner==null:return false
		checkTags=iterationOwner.dataModel
	else:
		checkTags=PACASInteractions.findByUUID(tagSource)
	var passedTests:bool=true
	if not useREGEX:
		if requireAll:passedTests=Array(tags).all(func(tag):return checkTags.tags.has(tag))
		else:passedTests=Array(tags).any(func(tag):return checkTags.tags.has(tag))
	else:
		
		if requireAll:passedTests=Array(tags).all(func(tag):
			var rgx:RegEx=RegEx.create_from_string(tag.trim_prefix("\\"))
			if not rgx.is_valid() or not tag.begins_with("\\"):return checkTags.tags.has(tag)
			return Array(checkTags.tags.keys()).any(func(cTag):return rgx.search(cTag)!=null)
		)
		else:passedTests=Array(tags).any(func(tag):
			var rgx:RegEx=RegEx.create_from_string(tag.trim_prefix("\\"))
			if not rgx.is_valid() or not tag.begins_with("\\"):return checkTags.tags.has(tag)
			return Array(checkTags.tags.keys()).any(func(cTag):return rgx.search(cTag)!=null)
		)
	
	if isBlacklist:return not passedTests
	return passedTests
