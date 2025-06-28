extends Node

var timer: float = 0.0
var interval: float = 0.3
var active = false
var n_tick := 0

var time_since_reset = 0
var ticks_at_last_reset = 0
var ticks_per_sec = 0

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
	time_since_reset += delta
	if time_since_reset >= 1:
		ticks_per_sec = (n_tick - ticks_at_last_reset)
		ticks_at_last_reset = n_tick
		time_since_reset = 0
		
