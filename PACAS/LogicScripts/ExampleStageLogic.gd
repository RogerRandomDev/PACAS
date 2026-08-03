extends RefCounted


func unlockDoor(owner:PACASInteractionObject,target:String="")->void:
	PACASInteractions.findByUUID(target).setTag("UNLOCKED",null,false)

func openCloseDoorTest(owner:PACASInteractionObject,target:String="")->void:
	var door=PACASInteractions.findByUUID(target)
	door.setTag(&"DoorOpen",
		null,door.checkForTag(&"DoorOpen")
	)
