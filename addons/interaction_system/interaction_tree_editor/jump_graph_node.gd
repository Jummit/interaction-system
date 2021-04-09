tool
extends GraphNode

"""
The `GraphNode` representation of a `JumpNode`
"""

signal target_clicked

const JumpNode = preload("../nodes/jump_node.gd")

func init(node : JumpNode) -> void:
	$TargetButton.text = str(node.target)


func _on_TargetButton_pressed() -> void:
	emit_signal("target_clicked")
