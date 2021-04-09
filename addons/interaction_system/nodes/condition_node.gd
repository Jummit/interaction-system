tool
extends InteractionNode

"""
Node that allows branching based on a condition
"""

export var condition : InteractionCondition

func _init() -> void:
	paths = [-1, -1]
