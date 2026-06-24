@tool
extends "res://addons/PACAS/editor/interface/sceneTab/interactionObjectDataViews/scene_interaction_item_side_bar.gd"


func _ready() -> void:
	super()
	initializeTextureTree()
	loadTextureOptions()
	
	%InteractionObjectTextureAlignButton.item_selected.connect(
		func(id:int)->void:
			activeSelection.layoutStretch=id
	)

func initializeTextureTree()->void:
	%InteractionObjectTextureListEdit.set_column_title(0,"Priority")
	%InteractionObjectTextureListEdit.set_column_title(1,"Tag")
	%InteractionObjectTextureListEdit.set_column_title(2,"Texture")
	%InteractionObjectTextureListEdit.set_column_expand(0,true)
	%InteractionObjectTextureListEdit.set_column_expand_ratio(0,0)
	%InteractionObjectTextureListEdit.set_column_expand(1,true)
	%InteractionObjectTextureListEdit.set_column_expand_ratio(1,1)
	%InteractionObjectTextureListEdit.set_column_expand(2,true)
	%InteractionObjectTextureListEdit.set_column_expand_ratio(2,0)

func loadTextureOptions()->void:
	%InteractionObjectTextureListEdit.clear()
	var root :TreeItem= %InteractionObjectTextureListEdit.create_item()
	if activeSelection == null:return
	for content in activeSelection.textures:
		var item :TreeItem = root.create_child()
		item.set_cell_mode(0,TreeItem.CELL_MODE_RANGE)
		item.set_range(0,activeSelection.textures[content][0])
		item.set_range_config(0,-1024,1024,1,false)
		item.set_editable(0,true)
		item.set_text(1,content)
		item.set_cell_mode(2,TreeItem.CELL_MODE_ICON)
		item.set_icon_max_width(2,32)
		if activeSelection.textures[content][1]!=null:
			item.set_icon(2,activeSelection.textures[content][1])



func updateSelected(item:PACASInteractionObject)->void:
	if not item is PACASInteractionObjectTextured:return
	if activeSelection==item:return
	super(item)
	loadTextureOptions()
	%InteractionObjectTextureAlignButton.select(
		activeSelection.layoutStretch
	)
