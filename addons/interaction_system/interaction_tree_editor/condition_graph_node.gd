tool
extends GraphNode

"""
The `GraphNode` representation of a `ConditionNode`
"""

signal condition_edited

const ConditionInteractionNode = preload("../nodes/condition_node.gd")

func init(node : ConditionInteractionNode) -> void:
	$HBoxContainer/ConditionButton.text = node.condition.expression


func _on_ConditionButton_pressed() -> void:
	emit_signal("condition_edited")
