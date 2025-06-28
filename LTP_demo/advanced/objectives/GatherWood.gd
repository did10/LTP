class_name GatherWood extends GatherRessource


func _init(a: Agent) -> void:
	var parent = a.get_parent()
	super(a, "Wood", [parent.get_node("Wood")])
	

func _stop_work():
	agent.wood = agent.wood + 1

func _check_resolved():
	return gathering_progress > 17
