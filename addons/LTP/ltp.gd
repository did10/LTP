@tool
extends EditorPlugin

const GLOBAL_NAME := "LTPTicker"
const PATH := "globals/LTPTicker.gd"

func _enter_tree():
	add_autoload_singleton(GLOBAL_NAME, PATH)
func _exit_tree() -> void:
	remove_autoload_singleton(GLOBAL_NAME)
