extends InteractionMenu

"""
A simple implementation of an `InteractionMenu`

Shows a scrollable log of messages with the option buttons at the bottom.
"""

onready var messages : VBoxContainer = $ScrollContainer/Control/Messages
onready var options_container : VBoxContainer = $ScrollContainer/Control/Options
onready var end_button : Button = $EndButton
onready var continue_button : Button = $ContinueButton
onready var character_info : VBoxContainer = $CharacterInfo
onready var character_texture : TextureRect = $CharacterInfo/CharacterTexture
onready var character_name : Label = $CharacterInfo/CharacterName

var next := -1

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
	scroll_to_bottom()


func show_action_node(node : ActionNode) -> void:
	.show_action_node(node)
	var data : InteractionActionData = node.data
	if data is Message:
		var message_label := Label.new()
		message_label.text = tr(data.text)
		messages.add_child(message_label)
		character_info.visible = data.from != null
		if data.from:
			character_texture.texture = data.from.icon
			character_name.text = data.from.name
		next = node.paths[0]
	elif data is ItemAquirement:
		var texture := TextureRect.new()
		texture.texture = data.item.icon
		messages.add_child(texture)
	var next_id := node.paths[0]
	var next_node : InteractionNode = interaction.nodes[next_id]
	if data is Message and next_node is ActionNode and\
			next_node.data is Message:
		# Show the continue button when there are multiple messages
		# back-to-back.
		continue_button.show()
	else:
		show_node(node.paths[0])
	scroll_to_bottom()


func show_end(end : EndNode) -> void:
	.show_end(end)


func end_interaction() -> void:
	end_button.show()
	yield(end_button, "pressed")
	.end_interaction()


func clear() -> void:
	.clear()
	end_button.hide()
	for message in messages.get_children():
		message.queue_free()
	for option in options_container.get_children():
		option.queue_free()
	hide()


func scroll_to_bottom() -> void:
	yield(get_tree(), "idle_frame")
	$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scrollbar().max_value


func _on_OptionButton_pressed(option : int) -> void:
	for option in options_container.get_children():
		option.queue_free()
	option_selected(option)


func _on_ContinueButton_pressed() -> void:
	show_node(next)
	next = -1
	continue_button.hide()
