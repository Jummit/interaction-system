tool
extends Resource
class_name InteractionTree

"""
The interaction tree that contains a list of `InteractionNode`s
"""

# A map of id to `InteractionNode`. The 0th node is always the `StartNode`.
export var nodes : Dictionary
export var comments : Array

const StartNode = preload("../nodes/start_node.gd")

func _init() -> void:
	if nodes.empty():
		nodes[0] = StartNode.new()


func get_available_id() -> int:
	var max_id := 0
	for node_id in nodes:
		max_id = max(max_id, node_id)
	return max_id + 1


func get_available_start() -> int:
	var last := -1
	var start_nodes := Array(get_start_nodes())
	start_nodes.sort()
	for node_id in start_nodes:
		var start : int = nodes[node_id].number
		if start == (last + 1):
			last += 1
		else:
			# Discontinuity.
			return last + 1
	return last + 1


func get_start_nodes() -> PoolIntArray:
	var start_nodes : PoolIntArray = []
	for node_num in nodes:
		if nodes[node_num] is StartNode:
			start_nodes.append(node_num)
	return start_nodes
