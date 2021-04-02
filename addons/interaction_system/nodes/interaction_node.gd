tool
extends Resource
class_name InteractionNode

"""
The base node of an `InteractionTree`
"""

export var position : Vector2

# Returns true if the branch ended.
func execute(_menu : Panel, _state : Dictionary) -> bool:
	return false
