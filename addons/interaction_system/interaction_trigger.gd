extends Node
class_name InteractionTrigger, "interaction_trigger_icon.svg"

"""
A node that can be used to start an interaction
"""

signal triggered

export var interaction : InteractionTree

func _enter_tree() -> void:
	add_to_group("InteractionTriggers")


# Start the interaction in an `InteractionMenu`.
func trigger() -> void:
	emit_signal("triggered")
