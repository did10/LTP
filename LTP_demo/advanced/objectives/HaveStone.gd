class_name HaveStone extends Objective

var x

func _init(a: Agent, x: int) -> void:
	super(a, "Have " + str(x) + " stone")
	self.x = x
	
func _work():
	add_task(GatherStone.new(agent), "gather")

func _can_work():
	return not has_task("gather")

func _check_resolved():
	return  agent.stone >= x
