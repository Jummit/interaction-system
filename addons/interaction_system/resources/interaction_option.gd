tool
extends Resource
class_name InteractionOption

"""
The data of an option

See `InteractionMessage`
"""

export var text : String

func _init(_text := "") -> void:
	text = _text


func get_name() -> String:
	return text
