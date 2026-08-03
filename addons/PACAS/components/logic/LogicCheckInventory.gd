@tool
extends PACASLogicBase
class_name PACASLogicCheckInventory

@export var itemName:String=""
@export var exactName:bool=false
@export var checkTags:Dictionary={}


func _executeInternal(iterationOwner:PACASInteractionObject)->bool:
	var matchingNames:Array = PACASInteractions.inventoryHandler.searchInventoryByName(itemName,exactName)
	#ensure tags match now
	for tag in checkTags:
		matchingNames=matchingNames.filter(
			func(item):
				return item.dataModel.tags.has(tag) and (checkTags[tag]==null or item.dataModel.tags[tag]==checkTags[tag])
		)
	
	return matchingNames.size()!=0
	
