tool
extends InteractionActionData

"""
An action that shows a message
"""

export var text : String
# The person/thing saying the message.
export var from : InteractionCharacter

func _init() -> void:
	node_name = "Message"
	content_member = "text"
