class_name DrinkWater2 extends GatherRessource


func _init(a: Agent) -> void:
	var parent = a.get_parent()
	super(a, "Water",  [parent.get_node("Water"), parent.get_node("Water2")])
	

func _stop_work():
	agent.water = agent.water + 5

func _check_resolved():
	return gathering_progress > 5 # time it takes to gather food
