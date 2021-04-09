tool
extends GraphNode

"""
The `GraphNode` representation of a `ActionNode`
"""

signal message_edited

const ActionNode = preload("../nodes/action_node.gd")

func init(node : ActionNode) -> void:
	title = node.data.node_name
	$MessageButton.text = node.data.get_name()


func _on_MessageButton_pressed() -> void:
	emit_signal("message_edited")
