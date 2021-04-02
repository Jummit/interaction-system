tool
extends InteractionMessage

"""
A message that makes the `InteractionMenu` emit an event
"""

func _init(_text := "").(_text) -> void:
	node_name = "Event"
