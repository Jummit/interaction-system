tool
extends Resource
class_name InteractionNode

"""
The base node of an `InteractionTree`
"""

export var position : Vector2

# An array of node ids the output ports lead to. The size of this array
# determines the number of output ports.
export var paths : PoolIntArray = [-1]
