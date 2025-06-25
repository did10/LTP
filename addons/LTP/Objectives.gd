class_name Objective extends RefCounted  
var title : String

var _preconditions: Dictionary[String, Objective]
var _tasks: Dictionary[String, Objective] = {}
var _resolved_tasks: Dictionary[String, bool] = {}

var level = 0
var priority = 10

var _work_started := false
var _work_finished := false
var _is_paused := false
var _task_parent = null
var _resolved := false

var agent: AgentInterface
var prefered_next_task = null # A task that will be prefered after this task. Helpfull e.g. after a goto 

var debug_text = ""


#  States that can be assumed:
#  waiting_for_preconditions  --start_work--> working(work_started) --stop_work--> resolved
#                                     paused   ,      can't work
func _init(agent: AgentInterface, title:String) -> void:
	self.agent=agent
	self.title=title
	if agent != null:
		agent.new_objective(self)

func _preconditions_resolved() -> bool:
	for req in _preconditions:
		if _preconditions[req].is_resolved() == false:
			return false
	return true
	
	
## Debug something, can later be found in debug_text. Helpfull for debugging individual Objectivs
func debug(text):
	debug_text = debug_text + str(text) + "\n"

func _remove_finished_tasks():
	for key in _tasks:
		if _tasks[key].is_resolved():
			remove_task(key, true)

## work on this objective. Starts work if not already happend.
## The idea is that every agent can only work on one objective at a time.
## This could mean that the agent can only either chop wood or drink water in one tick, but not both
## This method also updates the state just in case. Might remove the update and security checks in the default setup without concequnces.
func work():
	debug("Update objective")
	_update_state()
	if not _resolved and _preconditions_resolved() and _can_work(): ##  _preconditions_resolved() and _can_work() can be removed if you trust the scoring enogh
		if not _work_started:
			debug("Start")
			_work_started = _start_work()
		if _work_started:
			debug("work")
			_work()

## call _check_resolved, update the internal state if necessary and returns wether this task is resolved or not.
## This might change later after which the task is reactivated
func _update_state():
	_resolved = _check_resolved()
	if _work_finished and not _resolved: #resetart task
		reset()
	if _resolved and not _work_finished:
		_end_work()
		
## how likely the agent wants to do this task, higher -> more probable 
## Values below 0 won't be executed. 
## The score automatically gets set to below 0 to avoid execution if it can't be worked on right now
func update_and_score() -> float:
	_update_state()
	if _resolved or _is_paused or not _can_work() or not _preconditions_resolved():
		return -1
	return _raw_score()


func _end_work():
	if _work_started:
		debug("Stopped work successfully")
		_stop_work()
	_work_started = false
	_work_finished = true
	_pause_children()
	if _task_parent != null:
		_task_parent._remove_finished_tasks()

func reset():
	_work_started = false
	_work_finished = false
	debug_text = ""
	if _work_started and not _work_finished:
		debug("Stop work")
		_stop_work()
	_reset()
	_unpause_children()
	debug("Reset objective to start")


## Sample raw score implementation
## depending on you situation you will likely override this. 
## One example could be that if there is a goal that the agent doesn't want to starve
## the objective might get a higher score -> a higher over all priority when close to starving
##
## The level is set automatically. 
## For a "root objective" the first one created by you, the level is 0. Every objective or task that 
## is created to accomplish this objective will increase the level by one.
## The idea of the default scoring is that higher level objectives are higher prioritized. 
## E.g. "don't starv"  -->  "gather food" --> "find food"
## level:          0                   1               2
##
## This means that the agend will always eat food first when starving (if food is available)
##   instead of going to hunt even tough the agend is hungry
##
## Priority is set by the parent task. So the root task/objective sets the priority of its children.
## If a child has a higher priority than its parent's thats keept tho.
func _raw_score() -> float:
	return ((1)/((level+1)*0.5)) + priority

## Reset is called if the objective state changes back to start. 
## Please implement if you have some state that has to be reset, so the objective looks like newely implemented
func _reset():
	pass
## Called once directly before work starts. Can be used e.g. to allocate ressources, tiles etc. 
func _start_work() -> bool:
	return true
## Called once as soon as _check_resolved istrue for the first time or when reset is called and _start_work was called before.
## This allows you to clean after up after the objective is over. 
## This could e.g. be the freeing of allocated ressources etc.
func _stop_work():
	pass
	
## Here your actual work is done. Do things in here that bring you closer to _check_resolved being true. 
## This might also include the spawing of new tasks.
func _work() -> void:
	pass
## additional checks wether you can work or not. Can work needs to be true for _start_work and _work to be called.
## This allows you to limit when work can be called. E.g. the objective "Drink" might only be called if water > 5.
func _can_work() -> bool:
	return true

## If true the objective is resolved. This means that no additional work can or has to be done. 
## If a parent task is resolved all childern are paused. 
## If the objective is a task returning true will result in the deletion of the task 
func _check_resolved() -> bool:
	return true 

# Returns wether the task is resolved without calling an update on the state
func is_resolved() -> bool:
	return _resolved

## Pause the objective and therefor all of its children. 
## So all tasks and preconditions this objective might wait on
func pause():
	_is_paused = true
	_pause_children()

## Unpause this objective and all of its children
func unpause():
	_is_paused = false
	_unpause_children()
	
func _pause_children():
	for pre in _preconditions:
		_preconditions[pre].pause()
	for task in _tasks:
		_tasks[task].pause()
		
func _unpause_children():
	for pre in _preconditions:
		_preconditions[pre].unpause()
	for task in _tasks:
		_tasks[task].unpause()
		

## Allow for the reset, after a precondition is set all children mus be updated as well!
func _reset_preconditions():
	for key in _preconditions:
		var precon = _preconditions[key]
		precon.level = max(precon.level, level + 1)
		precon.priority = max(precon.priority, priority )

## sets a list of precondition, removes the old preconditions
## Please supply a list of objectives and supply a name.
## The added objective can later be checked on by the name via precondition(key)
##
## By design preconditions are things that have to be true for work to be started.
## Without them beeing resolved work won't start, 
## and by default work will also stop if they aren't resolved during work anymore.
##
## Preconditions differ from tasks that they are supposed to potentially switch between 
## Resolved and unresolved often. Tasks are single shot in nature.
##
## A precondition could be:
## E.g. "eat food"  -->  "have food" --> "collect_food_at_pos_(1,1)"
## type  preconditions    preconditions   task
## level:       0                 1               2
## You have to set up the objectives reset method so it can correctly revert the state back to it's beginning
func set_preconditions(preconditions: Dictionary[String,Objective]):
	_preconditions = {}
	for key in preconditions.keys():
		add_precondition(preconditions[key], key)

## Add a new precondition with a name
func add_precondition(precondition: Objective, key: String):
	precondition.level = max(precondition.level, level + 1)
	precondition.priority = max(precondition.priority, priority )
	_preconditions[key] = precondition
	precondition._reset_preconditions()
	precondition._reset_tasks()

## returns a precondition for a given key
func precondition(key: String)->Objective:
	return _preconditions[key]

func _reset_tasks():
	for key in _tasks:
		var task = _tasks[key]
		task.level = max(task.level, level + 1)
		task.priority = max(task.priority, priority )
		_resolved_tasks[key] = false

## Tasks are also objectives, but they are single shot. 
## Sets a list of named tasks that can later be checked on by name using task(key)
## They are removed from the active tasks and freed after they are first resolved
## For a better explenation see set_preconditions
func set_tasks(tasks: Dictionary[String, Objective]):
	_tasks = {}
	for key in tasks:
		add_task(tasks[key], key)

## Adds a single task with or without a name. When no name is supplied a random name wil be generated.
## This makes accessing the task later a bit harder but might still be relevant for easy single shot tasks. 
func add_task(task: Objective, key = null):
	if key == null:
		key = str(randi())
	task.level = max(task.level, level + 1)
	task.priority = max(task.priority, priority )
	task._task_parent = self
	_tasks[key] = task
	_resolved_tasks[key] = false
	task._reset_preconditions()
	task._reset_tasks()

func remove_task(task: String, is_resolved: bool):
	_resolved_tasks[task] = true
	remove_from_agent(_tasks[task])
	_tasks.erase(task)
## Returns a task by its name 
func task(key: String)->Objective:
	return _tasks[key]
## Returns wether the task with key is part of the **active** tasks.
## Tasks that are alredy resolved and therefore removed can't be accessed anymore, and won't be listed here
func has_task(key: String)->bool:
	return _tasks.has(key)

## Returns wether a task is resolved or not by key. 
## If it is resolved will return true even tho the task is already deleted. 
## If another task is spawned with the same key it will now reflect the status of this new task
## If the task does not exists will return false
func task_resolved(key: String)->bool:
	return _resolved_tasks.has(key) and _resolved_tasks[key]

## Will remove this objective, and all of its children from its agent
func remove_from_agent(o: Objective) -> void:
	agent.remove_objective(o)
	for pre in o._preconditions:
		remove_from_agent(o._preconditions[pre])
	for task in o._tasks:
		remove_from_agent(o._tasks[task])
