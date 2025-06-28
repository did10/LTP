class_name DontStarve2 extends Objective


func _init(a: Agent) -> void:
	super(a, "Dont starve: food > 10")
	
func _work():
	add_task(GatherFood2.new(agent), "gather")

func _can_work():
	# has no active task or task is resolved
	return not has_task("gather")

func _update():
	update_priority(clamp(10 - (agent.food/10) * (agent.food/10) * 10, 0, 10))

func _check_resolved():
	#high number of food         
	return  agent.food > 10
