tool
extends GraphNode

signal target_clicked

const BackNode = preload("../nodes/back_node.gd")

func init(node : BackNode) -> void:
	$TargetButton.text = str(node.target)


func _on_TargetButton_pressed() -> void:
	emit_signal("target_clicked")
