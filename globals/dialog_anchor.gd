extends "res://globals/interactive.gd"

export var tooltip = ""
export var global_id = ""

func set_state(p_state, p_force = false):
	pass

func set_speaking(p_speaking):
	pass
	
func _ready():
	if global_id != "":
		vm = get_tree().get_root().get_node("vm")
		vm.register_object(global_id, self)
