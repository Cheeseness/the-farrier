extends Node2D

var vm

func global_listener(name):
	if name == "splinters_removed":
		Input.set_custom_mouse_cursor(null)
		vm.set_globals("cursor/", false)
		vm.set_globals("grooming_tool", false)
		start_dialogue()
	if name == "dinosaur_dialogue_ended":
		# TODO Check if we're done with all our tasks - if so, go back to reception area
		if vm.get_global("splinters_removed"):
			# Reset flag, so that it works on coming back.
			# Not an issue if we're not just reloading the same room over and over.
			vm.set_global("splinters_removed", false)
			go_to_reception()

func go_to_reception():
	get_parent().queue_free()
	get_tree().change_scene("res://scenes/rooms/reception_area/reception_area.tscn")

# Function is first started by timer to dodge race conditions
func start_dialogue():
	var parasaur = get_parent().get_node("parasaur")
	get_tree().call_group(0, "game", "clicked", parasaur, parasaur.get_pos())

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	# Use listener to restart dialogue tree
	vm.connect("global_changed", self, "global_listener")
