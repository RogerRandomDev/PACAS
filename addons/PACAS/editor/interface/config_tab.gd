@tool
extends HBoxContainer


func _ready() -> void:
	loadDefaults()
	
	#root folder selection
	%ChangeRootFolder.pressed.connect(func():%RootFolderSelectDialog.popup())
	%RootFolderSelectDialog.dir_selected.connect(func(dir:String):
		%RootFolderDisplay.text=dir
		%RootFolderDisplay.tooltip_text=dir
		PACASInteractions.PACASDefaults.rootFolder=dir
		ResourceSaver.save(PACASInteractions.PACASDefaults,"res://addons/PACAS/PACASDefaults.tres")
		)
	#texture folder selection
	%ChangeTextureFolder.pressed.connect(func():%TextureFolderSelectDialog.popup())
	%TextureFolderSelectDialog.dir_selected.connect(func(dir:String):
		%TextureFolderDisplay.text=dir
		%TextureFolderDisplay.tooltip_text=dir
		PACASInteractions.PACASDefaults.texturesFolder=dir
		ResourceSaver.save(PACASInteractions.PACASDefaults,"res://addons/PACAS/PACASDefaults.tres")
		)

func openTab()->void:pass

func loadDefaults()->void:
	%RootFolderDisplay.text=PACASInteractions.PACASDefaults.rootFolder
	%RootFolderDisplay.tooltip_text=PACASInteractions.PACASDefaults.rootFolder
	
	%TextureFolderDisplay.text=PACASInteractions.PACASDefaults.texturesFolder
	%TextureFolderDisplay.tooltip_text=PACASInteractions.PACASDefaults.texturesFolder
