tool
extends Resource
class_name InteractionMessage

"""

"""

export var text : String

func _init(_text := "") -> void:
	text = _text


func get_name() -> String:
	return text
