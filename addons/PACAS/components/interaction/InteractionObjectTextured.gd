@tool
extends PACASInteractionObject
class_name PACASInteractionObjectTextured

@export_group("Textures")
@export var textures:Dictionary={}
@export_subgroup("Layout")
@export_enum(
	"Default",
	"Stretch",
	"Stretch Width",
	"Stretch Height",
	"Match Width",
	"Match Height"
) var layoutStretch:int=0:
	set(v):
		layoutStretch=v
		updateLayout()

var _textureSprite:Sprite2D=Sprite2D.new()

func _ready()->void:
	super()
	add_child(_textureSprite,false,Node.INTERNAL_MODE_BACK)
	resized.connect(updateLayout)
	initialTextureLoad()
	updateLayout()
	
	if Engine.is_editor_hint():return
	dataModel.tagged.connect(onTagged)

func initialTextureLoad()->void:
	if dataModel.texturePath!=null:
		_textureSprite.texture=load(dataModel.texturePath)
	if textures.has("default") and textures.get("default") is Texture:
		_textureSprite.texture=textures.get("default")

func updateLayout()->void:
	_textureSprite.position=size*0.5
	
	#layout stretching
	if _textureSprite.texture==null:return
	var textureSize=_textureSprite.texture.get_size()
	match layoutStretch:
		0:
			_textureSprite.scale=Vector2.ONE
		1:
			_textureSprite.scale=size/textureSize
		2:
			_textureSprite.scale=Vector2(size.x/textureSize.x,1.0)
		3:
			_textureSprite.scale=Vector2(1.0,size.y/textureSize.y)
		4:
			_textureSprite.scale=Vector2(size.x/textureSize.x,size.x/textureSize.x)
		5:
			_textureSprite.scale=Vector2(size.y/textureSize.y,size.y/textureSize.y)

func onTagged(tag:String,value:Variant)->void:
	#should account for priority at some point
	if textures.has(tag):
		var textureInfo=textures.get(tag)
		if not textureInfo[1] is Texture:return
		_textureSprite.texture=textureInfo[1]
