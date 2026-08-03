extends Resource
class_name PACASInventoryModel

signal updated()

var contents:Array=[]
var stackSize:int=-1
var maxSlots:int=-1
var maxItems:int=-1


func addItem(item:PACASObjectDataModel)->void:
	var inventoryItem=convertToInventory(item)
	contents.push_back(inventoryItem)
	updated.emit()

func removeItem(item:PACASObjectDataModel,all:bool=true)->void:
	if all:
		contents=contents.filter(func(i):return not i.dataModel==item)
	else:
		var index = contents.find_custom(func(i):return i.dataModel==item)
		if index==-1:return
		if contents[index].inventoryInfo.get("count",1)==1:
			contents.erase(item)
		else:
			contents[index].inventoryInfo.set("count",
				contents[index].inventoryInfo.get("count",1)-1
			)
	
	updated.emit()

func addInventoryItem(item:PACASInventoryItem)->void:
	if contents.has(item):return
	contents.push_back(item)
	updated.emit()

func removeInventoryItem(item:PACASInventoryItem,all:bool=true)->void:
	if all:
		contents.erase(item)
	else:
		var index = contents.find(item)
		if index==-1:return
		if contents[index].inventoryInfo.get("count",1)==1:
			contents.erase(item)
		else:
			contents[index].inventoryInfo.set("count",
				contents[index].inventoryInfo.get("count",1)-1
			)
	updated.emit()

func convertToInventory(item:PACASObjectDataModel)->PACASInventoryItem:
	var inventoryItem = PACASInventoryItem.new()
	inventoryItem.dataModel=item
	#add special logic into here as needed
	
	return inventoryItem
