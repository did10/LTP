class_name ChillAtTower extends Objective

var tower

func _init(a: Agent) -> void:
	super(a, "Chill at tower")
	add_precondition(BuildTower.new(agent), "tower")
	tower = agent.get_parent().get_node("Tower")
	
func _update():
	if not tower.working and _preconditions.has("goto"):
		remove_precondition("goto")
	elif tower.working and not _preconditions.has("goto"):
		add_precondition(GotoSpot.new(agent, tower, "tower"), "goto")

func _work():
	agent.chill = agent.chill + 1.75

func _check_resolved():
	return false
