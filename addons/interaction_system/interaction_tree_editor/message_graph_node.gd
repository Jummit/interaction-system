tool
extends GraphNode

"""
The `GraphNode` representation of a `MessageNode`
"""

signal message_edited

const MessageNode = preload("res://addons/interaction_system/nodes/message_node.gd")

func init(node : MessageNode) -> void:
	$MessageButton.text = node.data.get_name()


func _on_MessageButton_pressed() -> void:
	emit_signal("message_edited")
