class_name GotoFarm extends Objective

var target_farm

func _init(a: Agent, target: Node2D) -> void:
	super(a, "Go to farm")
	target_farm = target.position

func _work():
	agent.move_towards(target_farm)

func _check_resolved():
	return (agent.position - target_farm).length() < 10
