class_name HaveWood extends Objective

var x

func _init(a: Agent, x: int) -> void:
	super(a, "Have " + str(x) + " wood")
	self.x = x
	
func _work():
	add_task(GatherWood.new(agent), "gather")

func _can_work():
	return not has_task("gather")

func _check_resolved():
	return  agent.wood >= x
