class_name DrinkWater2 extends Objective

var gathering_progress = 0

func _init(a: Agent) -> void:
	super(a, "Gather water")
	var parent = agent.get_parent()
	## usually you would do that using globals so an autoload or something
	var water = [parent.get_node("Water"), parent.get_node("Water2")]
	var water_to_gather_from = water.pick_random()
	add_precondition(GotoFarm2.new(agent,  water_to_gather_from), "gather_water")
	precondition("gather_water").prefered_next_task = self

func _work():
	gathering_progress = gathering_progress + 1

func _stop_work():
	agent.water = agent.water + 5

func _check_resolved():
	return gathering_progress > 5 # time it takes to gather food

func _reset():
	gathering_progress = 0
