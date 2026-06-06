@tool
extends HSplitContainer

var selectedModel:PACASObjectDataModel
var selectedModelTreeItem:TreeItem=null

var validTagTypes:PackedInt32Array=[
	TYPE_NIL,
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_VECTOR2,
	TYPE_VECTOR3,
	TYPE_VECTOR4,
	TYPE_COLOR
]
@onready var validTagList=",".join(Array(validTagTypes).map(func(t):return type_string(t)))


func openTab()->void:
	loadFileSelection()


func _ready() -> void:
	setupObjectTagTree()
	
	#select object to open
	%ObjectFileSelections.item_selected.connect(func():
		var fullPath:String=""
		var startFrom:TreeItem=%ObjectFileSelections.get_selected()
		while startFrom is TreeItem:
			fullPath=startFrom.get_text(0)+"/"+fullPath
			startFrom=startFrom.get_parent()
		fullPath=fullPath.trim_suffix("/")
		if FileAccess.file_exists(fullPath):
			if selectedModel&&fullPath==selectedModel.resource_path:
				#trying to clear unsaved changes but it hates me
				selectedModel=null
			var loaded=load(fullPath)
			if loaded is PACASObjectDataModel:
				setSelectedModel(loaded)
				selectedModelTreeItem=%ObjectFileSelections.get_selected()
		)
	##file list to keep the closest-visible-item as the selected one
	#var selectClosestVisible=(
		#func(val=null,val2=null):
			#if selectedModelTreeItem==null:return
			#var climbStep:TreeItem=selectedModelTreeItem
			##a bit shenanigan but it works
			#var collapsedAt:=climbStep
			#while climbStep.get_parent():
				#climbStep=climbStep.get_parent()
				#if climbStep.collapsed:collapsedAt=climbStep
			#%ObjectFileSelections.set_selected(collapsedAt,0)
			#)
	##might just clear this system out. not particularly neccessary at all
	#%ObjectFileSelections.gui_input.connect(func(event:InputEvent):
		#if event is InputEventMouseButton and not event.is_pressed():
			#selectClosestVisible.call()
		#)
	##%ObjectFileSelections.item_mouse_selected.connect(selectClosestVisible)
	##%ObjectFileSelections.item_selected.connect(selectClosestVisible)
	#%ObjectFileSelections.nothing_selected.connect(selectClosestVisible)
	#%ObjectFileSelections.item_collapsed.connect(selectClosestVisible)
	%ObjectFileSelections.updateObjectFilePath.connect(
		func(item:TreeItem):
			var originalPath = item.get_metadata(0)
			var itemPath:String=item.get_text(0)
			while %ObjectFileSelections.get_root()!=item:
				item=item.get_parent()
				itemPath = item.get_text(0)+"/"+itemPath
			DirAccess.rename_absolute(originalPath,itemPath)
			#we need to update the metadata for original paths on the sub items now
			#placeholder cause it is slower than just being more particular but it will do for now
			loadFileSelection.call_deferred()
	)
	
	
	selectedModelTreeItem
	#create new tag
	%ObjectTagAddButton.pressed.connect(func():
		if selectedModel==null:return
		if selectedModel.tags.keys().any(func(t):return t.to_lower()==%ObjectTagAddName.text.to_lower()):return
		var newTag = %ObjectTagAddName.text
		%ObjectTagAddName.text=&""
		selectedModel.tags[newTag]=null
		addTagToList(newTag)
		)
	#edit an existing tag
	%ObjectTagTree.item_edited.connect(func():
		if selectedModel==null:return
		var item:TreeItem = %ObjectTagTree.get_selected()
		var column:int = %ObjectTagTree.get_selected_column()
		#might make one where its a path, and turns it into a file selection button
		#would be useful for things like tags ith a texture to them, etc.
		if column==1:
			#at some point, do a custom parser so we can have it more neat and lenient in some areas
			var newValue = item.get_text(1)
			var valueType:String=item.get_text(2).split(",")[item.get_range(2)]
			var typeNum:int=validTagTypes[item.get_range(2)]
			#make sure the typing can convert
			var parsed:Variant=parseStr(newValue,typeNum)
			if parsed==null and typeNum!=TYPE_NIL:
				item.set_text(1,item.get_metadata(1))
				return
			item.set_text(1,asString(parsed))
			#type_convert forces it to be the matching type.
			#also allows the default value if it cant properly convert
			selectedModel.tags[item.get_text(0)]=type_convert(parsed,validTagTypes[item.get_range(2)])
			item.set_metadata(1,newValue)
		)
	#object name/description
	%ObjectNameEdit.text_changed.connect(
		func(new_text:String):
			if selectedModel==null:return
			selectedModel.name=new_text
	)
	%ObjectDescriptionEdit.text_changed.connect(
		func(new_text:String):
			if selectedModel==null:return
			selectedModel.description=new_text
	)
	#revert
	%UndoObjectChangesButton.pressed.connect(
		func():
			if selectedModel==null:return
			%UndoObjectChangesButton.get_child(0).popup()
	)
	%UndoObjectChangesButton.get_child(0).confirmed.connect(
		func():
			if selectedModel==null:return
			setSelectedModel(ResourceLoader.load(selectedModel.resource_path,"",ResourceLoader.CACHE_MODE_REPLACE))
	)
	#duplicate
	%DuplicateObjectButton.pressed.connect(
		func():
			if selectedModel==null:return
			#will need to create copy in the file system
			#should check for matcching names and do the (copy) (N) as a placeholder till the user changes it
			pass
	)
	#save
	%SaveObjectButton.pressed.connect(
		func():
			if selectedModel==null:return
			%SaveObjectButton.get_child(0).popup()
	)
	%SaveObjectButton.get_child(0).confirmed.connect(
		func():
			if selectedModel==null:return
			ResourceSaver.save(selectedModel,selectedModel.resource_path)
	)
	

func setSelectedModel(model:PACASObjectDataModel)->void:
	selectedModel=model
	loadSelectedModelData()

func loadSelectedModelData()->void:
	%ObjectSelectedPath.text=selectedModel.resource_path
	%ObjectNameEdit.text=selectedModel.name
	%ObjectDescriptionEdit.text=selectedModel.description
	%ObjectTexturePath.text=selectedModel.texturePath
	#tags
	%ObjectTagTree.clear()
	%ObjectTagTree.create_item()
	
	for tag in selectedModel.tags:
		addTagToList(tag)

func addTagToList(tag:String)->void:
	var root :TreeItem= %ObjectTagTree.get_root()
	var tagItem :TreeItem= root.create_child()
	tagItem.set_text(0,tag)
	tagItem.set_text(1,asString(selectedModel.tags[tag]))
	tagItem.set_metadata(1,asString(selectedModel.tags[tag]))
	tagItem.set_editable(1,true)
	tagItem.set_cell_mode(2,TreeItem.CELL_MODE_RANGE)
	tagItem.set_editable(2,true)
	tagItem.set_range(2,validTagTypes.find(typeof(selectedModel.tags[tag])))
	tagItem.set_text(2,validTagList)
	tagItem.set_text_alignment(2,HORIZONTAL_ALIGNMENT_CENTER)

func setupObjectTagTree()->void:
	var root=%ObjectTagTree.create_item()
	%ObjectTagTree.set_column_title(0,"Tag")
	%ObjectTagTree.set_column_title(1,"Value")
	%ObjectTagTree.set_column_title(2,"Type")
	%ObjectTagTree.set_column_expand_ratio(0,2)
	%ObjectTagTree.set_column_expand_ratio(1,2)
	


func loadFileSelection()->void:
	%ObjectFileSelections.clear()
	var root:TreeItem = %ObjectFileSelections.create_item()
	var rootLocation = PACASInteractions.PACASDefaults.rootFolder
	root.set_text(0,rootLocation)
	loadFilesIterator(root,DirAccess.open(rootLocation))
	
	
func loadFilesIterator(curRoot:TreeItem,folder:DirAccess):
	
	for item in folder.get_directories():
		var subFolder :TreeItem=curRoot.create_child()
		subFolder.set_text(0,item)
		subFolder.set_metadata(0,folder.get_current_dir()+"/"+item)
		loadFilesIterator(subFolder,DirAccess.open(folder.get_current_dir()+"/"+item))
	for item in folder.get_files():
		if not item.ends_with("res"):continue
		var data :TreeItem=curRoot.create_child()
		data.set_text(0,item)
		data.set_metadata(0,folder.get_current_dir()+"/"+item)



func parseStr(string:String,toType:int)->Variant:
	var values=string.split(" ")
	match toType:
		TYPE_NIL:return null
		TYPE_BOOL:return string.to_lower()=="true"
		TYPE_FLOAT:return string.to_float()
		TYPE_INT:return string.to_int()
		TYPE_VECTOR2:
			if values.size()!=2:return null
			return Vector2(values[0].to_float(),values[1].to_float())
		TYPE_VECTOR3:
			if values.size()!=3:return null
			return Vector3(values[0].to_float(),values[1].to_float(),values[2].to_float())
		TYPE_VECTOR4:
			if values.size()!=4:return null
			return Vector4(values[0].to_float(),values[1].to_float(),values[2].to_float(),values[3].to_float())
		TYPE_STRING:return string
	return null

func asString(value:Variant)->String:
	var type=typeof(value)
	match type:
		TYPE_NIL:return "null"
		TYPE_BOOL:return "TRUE" if value else "FALSE"
		TYPE_FLOAT:return str(value)
		TYPE_INT:return str(value)
		TYPE_VECTOR2:
			return " ".join([
				str(value.x),str(value.y)
			])
		TYPE_VECTOR3:
			return " ".join([
				str(value.x),str(value.y),str(value.z)
			])
		TYPE_VECTOR4:
			return " ".join([
				str(value.x),str(value.y),str(value.z),str(value.w)
			])
		TYPE_STRING:return value
	return "<null>"
