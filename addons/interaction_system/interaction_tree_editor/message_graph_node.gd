tool
extends GraphNode

"""
"""

signal message_edited

const MessageInteractionNode = preload("res://addons/interaction_system/nodes/message_node.gd")

func init(node : MessageInteractionNode) -> void:
	$MessageButton.text = node.data.get_name()


func _on_MessageButton_pressed() -> void:
	emit_signal("message_edited")
