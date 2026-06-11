@tool
extends Camera2D


var default_resolution:Vector2i=Vector2i(1152,648)

func _ready() -> void:
	#keep ratio right to show the full scene(assuming default resolution)
	$"../../../../..".resized.connect(updateResize)
	$"../../../..".resized.connect(updateResize)
	
func updateResize()->void:
	var resolution_scale:Vector2=($"../../../..".size/Vector2(default_resolution))
	var minScaled:Vector2=Vector2(
		min(resolution_scale.x,resolution_scale.y),
		min(resolution_scale.x,resolution_scale.y)
	)
	if minScaled.x==0:return
	zoom=minScaled
	
	var ratio=float(default_resolution.x)/float(default_resolution.y)
	#keeps ratio for visibility consistent
	if minScaled.x==resolution_scale.x:
		$"../..".custom_minimum_size.x=$"../../../..".size.x
		$"../..".custom_minimum_size.y=$"../../../..".size.x / ratio 
	else:
		$"../..".custom_minimum_size.x=$"../../../..".size.y * ratio
		$"../..".custom_minimum_size.y=$"../../../..".size.y 
	$"../..".size=Vector2.ZERO
	$"../..".position=-$"../..".custom_minimum_size*0.5
	
	
