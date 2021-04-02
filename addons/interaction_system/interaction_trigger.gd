extends Node
class_name InteractionTrigger, "interaction_trigger_icon.svg"

"""
A node that can be used to start an interaction
"""

signal triggered

export var interaction : InteractionTree

func trigger() -> void:
	emit_signal("triggered")
