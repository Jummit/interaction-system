tool
extends GraphNode

"""

"""

signal comment_changed(to)

const CommentNode = preload("res://addons/interaction_system/nodes/comment_node.gd")

onready var comment_label : Label = $CommentLabel
onready var comment_edit : TextEdit = $CommentLabel/CommentEdit

func init(comment_node : CommentNode) -> void:
	offset = comment_node.position
	comment_label.text = comment_node.text
	comment_edit.text = comment_node.text
	rect_size = comment_node.size


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		comment_label.rect_size.y = rect_size.y


func _on_TextEdit_focus_exited() -> void:
	emit_signal("comment_changed", comment_edit.text)
	comment_edit.hide()


func _on_CommentLabel_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and\
			event.button_index == BUTTON_LEFT:
		comment_edit.show()
		comment_edit.call_deferred("grab_focus")
