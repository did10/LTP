class_name GatherStone extends GatherRessource


func _init(a: Agent) -> void:
	var parent = a.get_parent()
	super(a, "Stone", [parent.get_node("Stone")])
	

func _stop_work():
	agent.stone = agent.stone + 1

func _check_resolved():
	return gathering_progress > 20
