extends Node

var timer: float = 0.0
var interval: float = 0.3
var active = false
var n_tick := 0
signal tick(n: int)

func start():
	active = true
func pause():
	active = false

func _process(delta: float) -> void:
	if active:
		timer += min(delta, 1/60.)
		while timer >= interval:
			timer -= interval
			tick.emit()
			n_tick = n_tick + 1
