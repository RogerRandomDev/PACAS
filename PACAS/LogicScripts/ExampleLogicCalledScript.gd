extends RefCounted


func test(owner:PACASInteractionObject)->void:
	print("Owner: %s\nTriggered the ExampleLogicCalledScript method (test)"%owner)



func testFilterNotTagged(owner:PACASInteractionObject)->void:
	print("Owner: %s\nTriggered the ExampleLogicCalledScript method (testFilterNotTagged)"%owner)

func testFilter(owner:PACASInteractionObject)->void:
	print("Owner: %s\nTriggered the ExampleLogicCalledScript method (testFilter)"%owner)

func testHoverExample(owner:PACASInteractionObject)->void:
	#can do anything, you could even use this to outline.
	#since it was called by a logic piece, you can even only do this if a certain condition was met
	#I.E. you cant see something is even grabbable until you can grab it.
	owner.get_child(1).text="Unhover Me to change my text"

func testUnhoverExample(owner:PACASInteractionObject)->void:
	#the example here is used to undo what happens when it is hovered.
	#if you add an outline, it doenst automatically remove itself so you
	#would do that here
	owner.get_child(1).text="Hover Me to change my text"


func testGiveTestTag(owner:PACASInteractionObject)->void:
	print("Owner: %s\nTriggered the ExampleLogicCalledScript method (testGiveTestTag)\nTagging __GLOBAL__ with \"testTag\""%owner)
	PACASInteractions.dataModel.addTag("testTag",null)

func testTetureChangeTag(owner:PACASInteractionObject,target:String="")->void:
	print("Owner: %s\nTriggered the ExampleLogicCalledScript method (testTetureChangeTag)\nTagging %s with \"CanOpenDoor\""%[owner,target])
	
	PACASInteractions.findByUUID(target).setTag("CanOpenDoor",null,false)

func openCloseDoorTest(owner:PACASInteractionObject)->void:
	print("Owner: %s\nTriggered the ExampleLogicCalledScript method (openCloseDoorTest)\nUn/Tagging with \"DoorOpen\""%[owner])
	if owner.dataModel.checkForTag(&"CanOpenDoor"):
		owner.dataModel.setTag(&"DoorOpen",
			null,owner.dataModel.checkForTag(&"DoorOpen")
		)
