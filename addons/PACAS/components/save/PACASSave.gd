extends RefCounted
class_name PACASSaveBase



func saveData(saveTo:String="user://save.dat")->void:
	var objects = getPACASObjects()
	var inventory = getInventoryObjects()
	var saveFile = FileAccess.open(saveTo,FileAccess.WRITE)
	saveFile.store_var(
		{"Main":objects,"Inventory":inventory},true
	)
	saveFile.close()

func loadData(loadFrom:String="user://save.dat")->void:
	var saveFile = FileAccess.open(loadFrom,FileAccess.READ)
	var data = saveFile.get_var(true)
	saveFile.close()
	for object in data["Main"]:
		PACASInteractions.ObjectUUIDS[object]=data["Main"][object]
	for object in data["Inventory"]:
		PACASInteractions.inventoryHandler.inventory.contents.push_back(data["Inventory"][object])

func getPACASObjects()->Dictionary:
	var saveFormat:Dictionary={}
	for object in PACASInteractions.ObjectUUIDS:
		saveFormat[object]=PACASInteractions.ObjectUUIDS[object]
		
	return saveFormat

func getInventoryObjects()->Array:
	var saveFormat:Array=[]
	for object in PACASInteractions.inventoryHandler.inventory.contents:
		saveFormat.push_back(object)
		
	return saveFormat
