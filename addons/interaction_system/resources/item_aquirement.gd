tool
extends InteractionActionData

"""
An action that gives the player an item
"""

export var item : InteractionItem

func _init() -> void:
	node_name = "Get Item"


func get_content_string() -> String:
	return "" if not item else item.name
