class_name GatherFood extends Objective

var farms: Array[Node2D]
var gathering_progress = 0

func _init(a: Agent) -> void:
	super(a, "Gather food")
	var parent = agent.get_parent()
	## usually you would do that using globals so an autoload or something
	var farms = [parent.get_node("Farm"), parent.get_node("Farm2"), parent.get_node("Farm3")]
	var farm_to_gather_from = farms.pick_random()
	add_precondition(GotoFarm.new(agent,  farm_to_gather_from), "gather_food")

func _work():
	gathering_progress = gathering_progress + 1

func _stop_work():
	agent.food = agent.food + 5

func _check_resolved():
	return gathering_progress > 7 # time it takes to gather food

func _reset():
	gathering_progress = 0
