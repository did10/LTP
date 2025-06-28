class_name GatherFood2 extends GatherRessource


func _init(a: Agent) -> void:
	var parent = a.get_parent()
	super(a, "Food", [parent.get_node("Farm"), parent.get_node("Farm2"), parent.get_node("Farm3")])

func _stop_work():
	agent.food = agent.food + 5
