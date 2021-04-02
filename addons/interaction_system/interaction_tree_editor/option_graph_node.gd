tool
extends GraphNode

"""
"""

signal option_edited(option_num)
signal option_added
signal option_removed

const OptionsInteractionNode = preload("res://addons/interaction_system/nodes/options_node.gd")

onready var remove_option_button : Button = $Buttons/RemoveOptionButton

func init(node : OptionsInteractionNode) -> void:
	for option_num in node.option_data.size():
		var option := Button.new()
		option.text = node.option_data[option_num].get_name()
		option.connect("pressed", self, "_on_OptionButton_pressed",
				[option_num])
		add_child(option)
		move_child(option, option_num)
		set_slot(option_num, option_num == 0, 0, Color.white, true, 0, Color.white)
	if node.option_data.empty():
		set_slot(0, true, 0, Color.white, false, 0, Color.white)
	remove_option_button.disabled = node.option_data.empty()


func _on_OptionButton_pressed(option_num : int) -> void:
	emit_signal("option_edited", option_num)


func _on_AddOptionButton_pressed() -> void:
	emit_signal("option_added")


func _on_RemoveOptionButton_pressed() -> void:
	emit_signal("option_removed")
