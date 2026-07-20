@tool
extends Camera2D


var default_resolution:Vector2i=Vector2i(1152,648)

func _ready() -> void:
	#keep ratio right to show the full scene(assuming default resolution)
	$"../../../../..".resized.connect(updateResize)
	$"../../../..".resized.connect(updateResize)
	
func updateResize()->void:
	var resolution_scale:Vector2=(($"../../../..".size)/Vector2(default_resolution))
	var minScaled:Vector2=Vector2(
		min(resolution_scale.x,resolution_scale.y),
		min(resolution_scale.x,resolution_scale.y)
	)
	if minScaled.x==0:return
	zoom=minScaled
	
	$"../..".custom_minimum_size=Vector2(default_resolution)*minScaled
	$"../..".size=Vector2.ZERO
	$"../..".position=-Vector2(default_resolution)*minScaled*0.5
	
