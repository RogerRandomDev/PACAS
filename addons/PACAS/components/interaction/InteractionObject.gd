@tool
extends Control
class_name PACASInteractionObject


@export var uniqueID:StringName
@export_group("LogicEvents")
## Left click
@export var onClicked:PACASLogicBase
## Right click
@export var onAlternateClicked:PACASLogicBase
## Released after drag
@export var onDragReleased:PACASLogicBase
## On hovering over
@export var onHover:PACASLogicBase
# On stop hovering
@export var onUnhover:PACASLogicBase
@export_group("Data")
@export var dataModel:PACASObjectDataModel
@export var groups:PackedStringArray

var hasDragged:bool=false
var currentPressed:int=-1

func _ready() -> void:
	if Engine.is_editor_hint():return
	#next line is test for now, not permanent solution
	#replace once i have a better method to waste less memory
	PACASInteractions.loadInteractiveObject(self)
	
	for group in groups:
		add_to_group(group)
	#hover events
	mouse_entered.connect(func():
		if onHover:onHover.execute(self)
		PACASInteractions.ObjectInteracted.emit(
			PACASInteractions.InteractionTypes.Hover,
			self)
		)
	mouse_exited.connect(func():
		if onUnhover:onUnhover.execute(self)
		PACASInteractions.ObjectInteracted.emit(
			PACASInteractions.InteractionTypes.Unhover,
			self)
		)

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():return
	#click logic
	if event is InputEventMouseButton:
		if currentPressed!=-1&&event.button_index!=currentPressed:return
		# mark as not having dragged if a valid click event has started
		if event.is_pressed() and [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT].has(event.button_index):
			currentPressed=event.button_index
			hasDragged=false
		# When releasing left click, and still over the object, execute onClicked
		if currentPressed==MOUSE_BUTTON_LEFT and event.is_released() and not hasDragged:
			if get_rect().has_point(event.global_position):
				if onClicked:onClicked.execute(self)
				PACASInteractions.ObjectInteracted.emit(
					PACASInteractions.InteractionTypes.LeftClick,
					self)
		if currentPressed==MOUSE_BUTTON_RIGHT and event.is_released() and not hasDragged:
			if get_rect().has_point(event.global_position):
				if onAlternateClicked:onAlternateClicked.execute(self)
				PACASInteractions.ObjectInteracted.emit(
					PACASInteractions.InteractionTypes.RightClick,
					self)
		#if we dragged it, run this instead
		if event.is_released() and hasDragged:
			if onDragReleased:onDragReleased.execute(self)
			PACASInteractions.ObjectInteracted.emit(
					PACASInteractions.InteractionTypes.DragRelease,
					self)
		if event.is_released():currentPressed=-1
	#drag logic
	#TODO: store start position, if hasDragged &| start position is more than X away from current pos, start drag as well.
	if event is InputEventMouseMotion:
		# When releasing left click, and still over the object, execute onClicked
		if event.button_mask==MOUSE_BUTTON_LEFT:
			if not get_rect().has_point(event.global_position) or hasDragged:
				#if onDrag:onDrag.execute(self)
				hasDragged=true
				PACASInteractions.ObjectInteracted.emit(
					PACASInteractions.InteractionTypes.DragLeft,
					self)
		if event.button_mask==MOUSE_BUTTON_RIGHT:
			if not get_rect().has_point(event.global_position) or hasDragged:
				#if onDrag:onDrag.execute(self)
				hasDragged=true
				PACASInteractions.ObjectInteracted.emit(
					PACASInteractions.InteractionTypes.DragRight,
					self)
