@tool
extends HSplitContainer

signal sceneLoaded(scene:Node)
signal itemSelected(item:PACASInteractionObject)

var sceneList:Dictionary

var selectedScene
var selectedSceneTreeItem:TreeItem


func openTab()->void:
	loadFileSelection()

func _ready() -> void:
	loadFileSelection()
	
	%SceneSelectionTree.item_selected.connect(func():
		var fullPath:String=""
		var startFrom:TreeItem=%SceneSelectionTree.get_selected()
		while startFrom is TreeItem:
			fullPath=startFrom.get_text(0)+"/"+fullPath
			startFrom=startFrom.get_parent()
		fullPath=fullPath.trim_suffix("/")
		if FileAccess.file_exists(fullPath):
			setSelectedScene(fullPath)
			selectedSceneTreeItem=%SceneSelectionTree.get_selected()
		)
	
	
	%SceneSelectionTree.updateObjectFilePath.connect(
		func(item:TreeItem):
			var originalPath = item.get_metadata(0)
			var itemPath:String=item.get_text(0)
			while %SceneSelectionTree.get_root()!=item:
				item=item.get_parent()
				itemPath = item.get_text(0)+"/"+itemPath
			DirAccess.rename_absolute(originalPath,itemPath)
			#we need to update the metadata for original paths on the sub items now
			#placeholder cause it is slower than just being more particular but it will do for now
			loadFileSelection.call_deferred()
	)
	
	%ActiveSceneOptionsTabBar.tab_changed.connect(
		func(id:int)->void:
			var tab_scene=%ActiveSceneOptionsTabBar.get_tab_metadata(id)
			if tab_scene==null:return
			setSelectedScene(tab_scene)
	)
	%ActiveSceneOptionsTabBar.tab_close_pressed.connect(
		func(id:int)->void:
			var tab_scene=%ActiveSceneOptionsTabBar.get_tab_metadata(id)
			if tab_scene==null:return
			#should give a popup to ask if you want to save or cancel
			%ActiveSceneOptionsTabBar.remove_tab(id)
			sceneList[tab_scene].queue_free()
			sceneList.erase(tab_scene)
	)



func loadFileSelection()->void:
	%SceneSelectionTree.clear()
	var root:TreeItem = %SceneSelectionTree.create_item()
	var rootLocation = PACASInteractions.PACASDefaults.scenesFolder
	root.set_text(0,rootLocation)
	loadFilesIterator(root,DirAccess.open(rootLocation))
	
func loadFilesIterator(curRoot:TreeItem,folder:DirAccess):
	
	for item in folder.get_directories():
		var subFolder :TreeItem=curRoot.create_child()
		subFolder.set_text(0,item)
		subFolder.set_metadata(0,folder.get_current_dir()+"/"+item)
		loadFilesIterator(subFolder,DirAccess.open(folder.get_current_dir()+"/"+item))
	for item in folder.get_files():
		if not item.ends_with("scn"):continue
		var data :TreeItem=curRoot.create_child()
		data.set_text(0,item)
		data.set_metadata(0,folder.get_current_dir()+"/"+item)


func setSelectedScene(scene:String)->void:
	loadSceneForEdit(scene)

func loadSceneForEdit(scene:String)->void:
	var viewport=%SceneHolderPanel.get_child(0).get_child(0).get_child(0)
	if selectedScene:
		storeSceneEditState(sceneList.find_key(selectedScene))
		selectedScene.hide()
	if sceneList.has(scene):
		#update tab selection if not a match
		if (%ActiveSceneOptionsTabBar.current_tab!=-1 and 
			%ActiveSceneOptionsTabBar.get_tab_metadata(%ActiveSceneOptionsTabBar.current_tab)!=scene
			):
			for i in %ActiveSceneOptionsTabBar.tab_count:
				if %ActiveSceneOptionsTabBar.get_tab_metadata(i)==scene:
					%ActiveSceneOptionsTabBar.current_tab=i;break
		selectedScene=sceneList[scene]
	else:
		selectedScene=load(scene).instantiate()
		viewport.add_child(selectedScene)
		addScene(scene,selectedScene)
	loadSceneEditState.call_deferred(scene)
	selectedScene.show()
	sceneLoaded.emit(selectedScene)

func addScene(scene:String,node:Node)->void:
	sceneList[scene]=node
	
	updateSceneSelection()

func updateSceneSelection()->void:
	var alreadyLoaded:Dictionary={}
	for tab in %ActiveSceneOptionsTabBar.tab_count:
		alreadyLoaded[%ActiveSceneOptionsTabBar.get_tab_title(tab)]=%ActiveSceneOptionsTabBar.get_tab_metadata(tab)
	for scene in sceneList:
		if alreadyLoaded.values().has(scene):continue
		%ActiveSceneOptionsTabBar.add_tab(scene.split("/")[-1])
		%ActiveSceneOptionsTabBar.set_tab_metadata(%ActiveSceneOptionsTabBar.tab_count-1,scene)
		if sceneList[scene]==selectedScene:
			%ActiveSceneOptionsTabBar.current_tab=%ActiveSceneOptionsTabBar.tab_count-1


func storeSceneEditState(scene:String)->void:
	var selectedItem=%SceneInteractionItemSideBarHolder.get_child(0).activeSelection
	sceneList[scene].set_meta(&"EditState",{
		&"Camera":%SceneTabCamera.transform,
		&"SelectedItem":&"" if selectedItem == null else sceneList[scene].get_path_to(selectedItem)
	})

func loadSceneEditState(scene:String)->void:
	if not sceneList[scene].has_meta(&"EditState"):
		loadDefaultState();return
	
	var data=sceneList[scene].get_meta(&"EditState",null)
	if data==null:return
	var selectedItem=data[&"SelectedItem"]
	%SceneTabCamera.transform=data[&"Camera"]
	
	#bit jank but works for now
	for child in %SceneInteractionObjectListTree.get_root().get_children():
		if String(sceneList[scene].get_path_to(child.get_meta("Object")))==String(selectedItem):
			child.select(0);break
	
	itemSelected.emit(null if selectedItem.is_empty() else sceneList[scene].get_node(selectedItem))

func loadDefaultState()->void:
	%SceneTabCamera.transform=Transform2D()
	
