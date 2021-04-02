tool
extends Resource
class_name InteractionMessage

"""
The data of a message

By default this only holds text, but can be extended to store more information.
It is editable in the editor by clicking on the text of a `MessageNode`.
"""

export var text : String

func _init(_text := "") -> void:
	text = _text


func get_name() -> String:
	return text
