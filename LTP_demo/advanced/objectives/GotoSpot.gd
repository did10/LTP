class_name GotoSpot extends Objective

var target_spot

func _init(a: Agent, target: Node2D, name: String) -> void:
	super(a, "Go to " + name)
	target_spot = target.position

func _work():
	agent.move_towards(target_spot)

func _check_resolved():
	return (agent.position - target_spot).length() < 10
