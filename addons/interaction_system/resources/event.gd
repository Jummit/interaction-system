tool
extends InteractionActionData

"""
An action that makes the `InteractionMenu` emit a signal
"""

export var event : String

func _init() -> void:
	node_name = "Event"
	content_member = "event"
