tool
extends InteractionActionData

"""
Message should be a GDScript expression that is run on the global state,
for example `health += 5`.
"""

export var expression : String

func _init() -> void:
	node_name = "State Change"
	content_member = "expression"
