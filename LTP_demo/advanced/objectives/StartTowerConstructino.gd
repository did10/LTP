class_name StartTowerConstruction extends Objective

var tower = null

func _init(a: Agent) -> void:
	super(a, "Supply tower ressources")
	tower = agent.get_parent().get_node("Tower")
	add_precondition(HaveStone.new(agent, 10), "have_stone")
	add_precondition(HaveWood.new(agent, 3), "have_wood")

func _work():
	agent.stone = agent.stone -  10
	agent.wood = agent.wood -  3
	tower.pay_for_ressources()
	
func _check_resolved():       
	return  tower.ressources_supplied or tower.working
