extends Resource
class_name GlobalInteractionState

"""
A GDScript wrapper for a dictionary

Used in `Condition`s expressions to allow access to the contents of the global
state.
"""

export var state : Dictionary

func _get(property : String):
	if property in state:
		return state[property]


func _set(property : String, value) -> bool:
	state[property] = value
	return true
