extends CanvasLayer

var treeRoot:TreeItem

var debugLogs:Array=[]

var typeFilters:PackedStringArray=[]

@export var maxLogsShown:int=100

func _ready() -> void:
	setupLogTree()
	setupTypeFilters()
	
	$PanelContainer/TabContainer.tab_changed.connect(func(tab:int):
		if tab==0:
			reloadLogs()
		)
	
	
	PACASInteractions.ObjectInteracted.connect(logInteraction)

func setupLogTree()->void:
	%EventList.clear()
	treeRoot=%EventList.create_item()
	%EventList.set_column_title(0,"Time")
	%EventList.set_column_title(1,"Interaction")
	%EventList.set_column_title(2,"Object")
	%EventList.set_column_expand(0,true)
	%EventList.set_column_expand_ratio(0,1)
	%EventList.set_column_expand(1,true)
	%EventList.set_column_expand_ratio(1,1)
	%EventList.set_column_expand(2,true)
	%EventList.set_column_expand_ratio(2,3)
	
	%EventList.nothing_selected.connect(
		func():
			$HighlightRect.visible=false
	)
	
	%EventList.item_selected.connect(
		func():
			var selected:TreeItem = %EventList.get_selected()
			var objID = selected.get_metadata(2)
			var instance = instance_from_id(objID) as PACASInteractionObject
			$HighlightRect.visible=true
			$HighlightRect.position=instance.get_rect().position
			$HighlightRect.size=instance.get_rect().size
			
	)
	

func setupTypeFilters()->void:
	for type in PACASInteractions.InteractionTypes.keys():
		var btn=CheckBox.new()
		btn.text=type
		btn.button_pressed=true
		btn.toggled.connect(
			func(pressed:bool):
				if pressed:typeFilters.push_back(type)
				else:typeFilters.erase(type)
		)
		typeFilters.push_back(type)
		%EventTypeFilters.add_child(btn)

func logInteraction(interaction:PACASInteractions.InteractionTypes,interactedObject:PACASInteractionObject)->void:
	var runTime=Time.get_ticks_msec()
	var hours=runTime / 3600000
	var minutes=(runTime / 60000)%60
	var seconds = (runTime / 1000)%60
	
	var data={
		"Time":"%02d:%02d:%02d"%[hours,minutes,seconds],
		"Type":PACASInteractions.InteractionTypes.find_key(interaction),
		"Object":str(interactedObject),
		"ObjectID":interactedObject.get_instance_id()
		}
	debugLogs.push_back(data)
	
	var loggedItem:TreeItem = createLog(data)
	
	if not checkLogPassedFilters(data):
		treeRoot.remove_child(loggedItem)
	else:
		%EventList.scroll_to_item(loggedItem)

func createLog(data:Dictionary)->TreeItem:
	if treeRoot.get_child_count()>maxLogsShown:
		treeRoot.remove_child(treeRoot.get_first_child())
	var loggedItem:TreeItem = treeRoot.create_child()
	loggedItem.set_text(0,data["Time"])
	loggedItem.set_text(1,data["Type"])
	loggedItem.set_tooltip_text(2,data["Object"])
	loggedItem.set_text(2,data["Object"])
	loggedItem.set_metadata(2,data["ObjectID"])
	return loggedItem


func reloadLogs()->void:
	%EventList.clear()
	treeRoot=%EventList.create_item()
	var validLogs:int=0
	var atDepth:int=debugLogs.size()-1
	while true:
		if validLogs>=maxLogsShown||atDepth<0:break
		var log=debugLogs[atDepth]
		if checkLogPassedFilters(log):
			var loggedItem:TreeItem=createLog(log);validLogs+=1
			loggedItem.move_before(treeRoot.get_first_child())
		atDepth-=1
	


func checkLogPassedFilters(log:Dictionary)->bool:
	var passedTypeFilter:bool=typeFilters.has(log["Type"])
	return passedTypeFilter
