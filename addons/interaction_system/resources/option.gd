tool
extends Resource
class_name InteractionOption

"""
The data of an `OptionNode`

See `InteractionActionData`
"""

export var text : String
# If the option should be clickable when revisited.
export var repeatable := false
export var condition : InteractionCondition

func _init(_text := "") -> void:
	text = _text


func get_name() -> String:
	if text.length() > 15:
		return text.substr(0, 12) + "..."
	return text


func condition_met(state : GlobalInteractionState) -> bool:
	return not condition or condition.is_met(state)
