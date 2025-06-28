class_name BuildTower extends Objective

var tower = null
var building_progress = 0

func _init(a: Agent) -> void:
	super(a, "Build a tower")
	tower = agent.get_parent().get_node("Tower")
	

func _work():
	if not tower.ressources_supplied and not has_task("tower_con"):
		add_task(StartTowerConstruction.new(agent), "tower_con")
	if tower.ressources_supplied  and  not _preconditions.has("goto"):
		add_precondition(GotoSpot.new(agent, tower, "tower"), "goto")
		precondition("goto").prefered_next_task = self
	elif tower.ressources_supplied:
		tower.start_construction()
		building_progress = building_progress + 1
	if building_progress > 400:
		building_progress = 0
		tower.build()
		remove_precondition("goto")
func _can_work():
	return not has_task("tower_con") or tower.ressources_supplied
func _check_resolved():       
	return  tower.working
