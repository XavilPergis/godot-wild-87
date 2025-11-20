extends Node
class_name Component

var _id: StringName

func _init(p_id: StringName) -> void:
	self._id = p_id

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED: get_parent().set_meta(_id, self)
		NOTIFICATION_UNPARENTED: get_parent().set_meta(_id, null)
