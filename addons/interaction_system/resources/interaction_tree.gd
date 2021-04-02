tool
extends Resource
class_name InteractionTree

"""

"""

# A map of id to `InteractionNode`. The 0th node is always the `StartNode`.
export var nodes : Dictionary
export var comments : Array

const StartNode = preload("res://addons/interaction_system/nodes/start_node.gd")

func _init() -> void:
	if nodes.empty():
		nodes[0] = StartNode.new()


func get_available_id() -> int:
	var max_id := 0
	for node_id in nodes:
		max_id = max(max_id, node_id)
	return max_id + 1
