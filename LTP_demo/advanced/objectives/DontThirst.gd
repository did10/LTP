class_name DontThirst2 extends Objective


func _init(a: Agent) -> void:
	super(a, "Dont thirst: water > 10")
	
func _work():
	add_task(DrinkWater2.new(agent), "gather")

func _can_work():
	# has no active task or task is resolved
	return not has_task("gather")

func _update():
	update_priority(clamp(10 - (agent.water/10) * abs(agent.water/10) * 10, 0, 10))


func _check_resolved():
	#high number of food         
	return  agent.water > 10
