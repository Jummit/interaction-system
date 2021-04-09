extends Resource
class_name GlobalInteractionState

"""

"""

export var state : Dictionary

func _get(property : String):
	if property in state:
		return state[property]


func _set(property : String, value) -> bool:
	state[property] = value
	return true
