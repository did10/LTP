class_name Agent extends AgentInterface
## A sample agent implementation that also contains the objective updating
## There is probably a good amount of room for performance increases but i didn't have problems until now.
## If you do some improvements you are increadably welcome to merge them :) 


var objectives: Array[Objective]=[]
var candidates:Array[Objective] = []
var weights:Array[float] = []

var current_active_task: Objective
var current_task_score_multiplier = 3  # The current active task is prioritized so there are no constant task switches. 
var prefered_next_task_multiplier = 1.8 # If there is a prefered next task this will be multiplied to the score at the check for the next task. E.g. goto water -> drink water
var prefered_next_task = null # the prefered next task, if there is one
var allow_task_switches = true #  if there is another task with a score higher than the currently active * current_task_score_multiplier 
		# the task is stopped and the one with higher priority pursuits

func _init() -> void:
	LTPTicker.tick.connect(_tick)

func new_objective(objective: Objective):
	objectives.append(objective)
func remove_objective(o: Objective):
	objectives.erase(o)

func _tick( ) -> void:
	candidates = []
	weights = []
	var current_task_score = -1
	var prefered_next_task_score = -1
	for obj in objectives:
		obj.update_state()
	for obj in objectives:
		var score = obj.score()# update the objective state and get score
		var weight = score * abs(score)
		if obj == current_active_task:
			weight = weight * current_task_score_multiplier  
			current_task_score = weight
		if obj == prefered_next_task:
			prefered_next_task_score = weight  
		if score >= 0: #only add objectives with a score > 0. Below 0 an objective is blocked by something. E.g. preconditions
			candidates.append(obj)
			weights.append(weight) # make it exponential so higher scores are choosen with a higher chance
	if current_active_task == null or current_task_score < 0:
		if current_active_task:
			current_active_task.temporary_stop_work()
		current_active_task = select_next_task(candidates, weights, prefered_next_task_score)
		if current_active_task != null:
			prefered_next_task = current_active_task.prefered_next_task
		else:
			prefered_next_task = null
	elif allow_task_switches and len(weights) > 0:
		var max_weight = weights.max()
		if max_weight > current_task_score:
			var i = weights.find(max_weight)
			current_active_task.temporary_stop_work()
			current_active_task = candidates[i]
			prefered_next_task = current_active_task.prefered_next_task
	if current_active_task != null:
		current_active_task.work()
		
	_update()

func select_next_task(candidates: Array[Objective], weights:Array[float], prefered_next_task_score) -> Objective:
	if prefered_next_task != null:
		var max_weight = weights.max()
		if max_weight < prefered_next_task_score * prefered_next_task_multiplier:
			var i = weights.find(max_weight)
			return candidates[i]
	return select_new_random_task(candidates, weights)
	

## Chooses the next task to work on by score and random chance. 
## Higher score leads to a higher chance of working on the task
func select_new_random_task(candidates: Array[Objective], weights:Array[float]) -> Objective:
	if candidates.size() == 0:
		return
	var total_weight = sum_array(weights)
	var rand = randf() * total_weight
	
	var cumulative = 0.0
	
	for i in range(candidates.size()):
		cumulative += weights[i]
		if rand <= cumulative:
			return candidates[i]
	return null

## override in your Agent implementations for your own updates (every tick) 
func _update():
	pass
	
func sum_array(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum
