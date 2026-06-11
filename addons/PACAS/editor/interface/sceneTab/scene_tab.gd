@tool
extends HSplitContainer

signal sceneLoaded(scene:Node)

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
	if selectedScene:selectedScene.queue_free()
	selectedScene=load(scene).instantiate()
	viewport.add_child(selectedScene)
	sceneLoaded.emit(selectedScene)
