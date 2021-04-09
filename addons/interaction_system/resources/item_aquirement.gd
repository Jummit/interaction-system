tool
extends InteractionActionData

"""
A  that gives the player an item
"""

export var item : InteractionItem

func _init() -> void:
	node_name = "Get Item"


func get_content_string() -> String:
	print(item.resource_name)
	return "" if not item else item.resource_path.get_file().split(".")[0].capitalize()
