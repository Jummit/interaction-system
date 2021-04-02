extends Area2D

func _input_event(_viewport : Object, event : InputEvent,
		_shape_idx : int) -> void:
	if event is InputEventMouseButton and event.pressed and\
			event.button_index == BUTTON_LEFT:
		$InteractionTrigger.trigger()
