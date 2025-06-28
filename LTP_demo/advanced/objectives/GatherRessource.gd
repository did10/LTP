class_name GatherRessource extends Objective

var gathering_progress = 0

func _init(a: Agent, name: String, spots: Array[Node2D]) -> void:
	super(a, "Gather " + name)
	var random_spot = spots.pick_random()
	add_precondition(GotoSpot.new(agent,  random_spot, name), "goto")
	precondition("goto").prefered_next_task = self

func _work():
	gathering_progress = gathering_progress + 1

func _check_resolved():
	return gathering_progress > 10 # time it takes to gather food

func _reset():
	gathering_progress = 0
