extends Node
class_name PACASInventoryBaseMiddleware



var inventory:PACASInventoryModel=PACASInventoryModel.new()

func loadInventory()->void:
	#load contents into inventory/set up special info for it
	#I.E. loading a save
	pass

func searchInventoryByName(item:String,exact:bool=false):
	item=item.to_lower()
	if exact:
		return inventory.contents.filter(func(i):return i.dataModel.name.to_lower() == item)
	return inventory.contents.filter(func(i):return i.dataModel.name.to_lower().contains(item))

func searchInventoryByTag(tag:String):
	return inventory.contents.filter(func(i):return i.dataModel.tags.has(tag))

func searchInventoryByItem(item:PACASObjectDataModel,exact:bool=false):
	if exact:
		#should do custom so as long as the data matches it also counts
		return inventory.contents.filter(func(i):return i.dataModel == item)
	return inventory.contents.filter(func(i):return i.dataModel.name == item.name)

func addItemToInventory(item:PACASObjectDataModel):
	inventory.addItem(item)

func removeItemFromInventory(item:PACASObjectDataModel,all:bool=true):
	inventory.removeItem(item,all)

func addInventoryItemToInventory(item:PACASInventoryItem):
	inventory.addInventoryItem(item)

func removeInventoryItemToInventory(item:PACASInventoryItem,all:bool=true):
	inventory.removeInventoryItem(item,all)

func getInventory()->PACASInventoryModel:
	return inventory
