extends PACASDefaultsDataModel
class_name PACASRoomDataModel
## data model for handling separating objects by rooms/groups.
## allows keeping memory usage lower by only having neccessary rooms loaded
## or to keep groups organized

@export_group("Room Data")
@export var roomID:StringName=&""
