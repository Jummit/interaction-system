tool
extends GraphNode

"""
The `GraphNode` representation of a `MessageNode`
"""

signal message_edited

const MessageNode = preload("../nodes/message_node.gd")

func init(node : MessageNode) -> void:
	var node_name : String = node.data.get_name()
	if node_name.length() > 15:
		node_name = node_name.substr(0, 12) + "..."
	$MessageButton.text = node_name


func _on_MessageButton_pressed() -> void:
	emit_signal("message_edited")
