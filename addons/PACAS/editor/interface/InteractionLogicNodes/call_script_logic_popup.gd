@tool
extends Window

var parameterPath:String=""
var logicOwner:Object=null
var editingLogicItem:PACASLogicBase=null

func _ready() -> void:
	loadLogicScriptOptions()
	
	
	%LogicScriptTypeChangeButton.item_selected.connect(
		func(id:int)->void:
			if %LogicScriptTypeChangeButton.get_item_text(id)==getType(editingLogicItem):return
			var newLogicItem:PACASLogicBase=load(
				"res://addons/PACAS/components/logic/%s.gd"%
				%LogicScriptTypeChangeButton.get_item_text(id)
			).new()
			#keep all data that is shared
			if editingLogicItem!=null:
				var baseValues = Resource.new().get_property_list().map(func(a):return a.name)
				var values = editingLogicItem.get_property_list().map(func(a):return a.name)
				var newValues = newLogicItem.get_property_list().map(func(a):return a.name)
				for value in values:
					if baseValues.has(value):continue
					if newValues.has(value):
						newLogicItem.set(
							value,editingLogicItem.get(value)
						)
			#update the owner item/node that this is replacing the old item
			logicOwner.set(parameterPath,newLogicItem)
			loadContents(newLogicItem,logicOwner,parameterPath)
	)

func loadLogicScriptOptions()->void:
	%LogicScriptTypeChangeButton.clear()
	var dir:=DirAccess.open("res://addons/PACAS/components/logic/")
	for option in dir.get_files():
		if not option.ends_with(".gd"):continue
		%LogicScriptTypeChangeButton.add_item(option.trim_suffix(".gd"))

func loadContents(content:PACASLogicBase=null,ownedBy=null,parameter:String="")->void:
	for child in %LogicModuleContainer.get_children():
		child.queue_free()
	parameterPath=parameter
	logicOwner=ownedBy
	editingLogicItem=content
	
	if content==null:
		for i in %LogicScriptTypeChangeButton.item_count:
			if %LogicScriptTypeChangeButton.get_item_text(i)=="LogicBase":
				%LogicScriptTypeChangeButton.select(i);break
		return
	#select type in the top dropdown
	for i in %LogicScriptTypeChangeButton.item_count:
		if %LogicScriptTypeChangeButton.get_item_text(i)==getType(content):
			%LogicScriptTypeChangeButton.select(i);break
	
	var type:String=getType(content)
	var typeModule:String="res://addons/PACAS/editor/interface/InteractionLogicNodes/DATAVIEW_%s.tscn"%type
	if not FileAccess.file_exists(typeModule):return
	var module=load(typeModule).instantiate()
	%LogicModuleContainer.add_child(module)


func getType(content:PACASLogicBase=null)->String:
	if content==null:return ""
	var objectSubset:String = content.get_script().get_global_name()
	return objectSubset

func loadNewPopup(content:PACASLogicBase=null,parameter:String="")->void:
	var popup :Window= load("res://addons/PACAS/editor/interface/InteractionLogicNodes/CallScriptLogicPopup.tscn").instantiate()
	popup.close_requested.connect(
		func():
			popup.queue_free
			show()
	)
	popup.loadContents(content,editingLogicItem,parameter)
	add_child(popup)
	popup.popup()
	hide()
