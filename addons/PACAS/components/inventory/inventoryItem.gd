extends Resource
class_name PACASInventoryItem

var dataModel:PACASObjectDataModel
var inventoryInfo:Dictionary={}

func getPacked()->String:
	return dataModel.getPacked(inventoryInfo)

static func getUnpacked(packed:String)->PACASInventoryItem:
	var unpackedString = JSON.parse_string(packed)
	var unpackedObject=PACASInventoryItem.new()
	unpackedObject.dataModel=PACASObjectDataModel.getUnpackedFromArray(unpackedString)
	unpackedObject.inventoryInfo=unpackedString[-1]
	return unpackedObject
	
