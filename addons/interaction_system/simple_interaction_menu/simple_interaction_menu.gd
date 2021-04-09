extends InteractionMenu

"""
A simple implementation of an `InteractionMenu`

Shows a scrollable log of messages with the option buttons at the bottom.
"""

onready var messages : VBoxContainer = $ScrollContainer/Control/Messages
onready var options_container : VBoxContainer = $ScrollContainer/Control/Options
onready var end_button : Button = $EndButton

func show_start(start : StartNode) -> void:
	show()
	.show_start(start)


func show_options(options : OptionsNode) -> void:
	.show_options(options)
	for option_num in options.option_data.size():
		var data : InteractionOption = options.option_data[option_num]
		if not data.condition_met(state):
			continue
		var option_button := Button.new()
		option_button.text = tr(data.text)
		option_button.connect("pressed", self, "_on_OptionButton_pressed",
				[option_num])
		option_button.disabled = visited_option(options, option_num)
		options_container.add_child(option_button)


func show_action_node(node : ActionNode) -> void:
	.show_action_node(node)
	if node.data is Message:
		var message_label := Label.new()
		message_label.text = tr(node.data.text)
		messages.add_child(message_label)
	show_node(node.paths[0])


func show_end(end : EndNode) -> void:
	.show_end(end)


func end_interaction() -> void:
	end_button.show()
	yield(end_button, "pressed")
	.end_interaction()


func clear() -> void:
	end_button.hide()
	for message in messages.get_children():
		message.queue_free()
	for option in options_container.get_children():
		option.queue_free()
	hide()


func _on_OptionButton_pressed(option : int) -> void:
	for option in options_container.get_children():
		option.queue_free()
	option_selected(option)
