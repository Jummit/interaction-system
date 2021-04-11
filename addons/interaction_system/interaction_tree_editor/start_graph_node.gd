tool
extends GraphNode

const StartNode = preload("../nodes/start_node.gd")

func init(start_node : StartNode) -> void:
	$Label.text = "%s. Time" % (start_node.number + 1)
	
