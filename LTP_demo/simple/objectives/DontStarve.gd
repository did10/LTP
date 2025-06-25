class_name DontStarve extends Objective


func _init(a: Agent) -> void:
	super(a, "Dont starve: food > 10")
	
func _work():
	add_task(GatherFood.new(agent), "gather")

func _can_work():
	# has no active task or task is resolved
	return not has_task("gather")
	
func _check_resolved():
	#high number of food         
	return  agent.food > 10
