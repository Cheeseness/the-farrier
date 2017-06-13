extends Area2D

var vm
var comfort = {
	"level": 0,
	"indicator": null
}
var splinters_removed = 0
const splinter_scene = preload("res://scenes/conditions/splinter/splinter.tscn")

func set_comfort_level(increase=true):
	if increase:
		comfort["level"] += 1
		comfort["indicator"].set_text("Level: %d" % [comfort["level"]])

func input(viewport, event, shape_idx):
	# TODO: Distinguish between clicks and swipes
	# TODO: Block action if comfort level of dino is too low
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			var grooming_tool = vm.get_global("grooming_tool")
			prints("grooming_tool", grooming_tool)
			# TEMPORARY!
			
			if grooming_tool:
				set_comfort_level()
			
			# TODO: Handle this in a less shitty way
			if grooming_tool && grooming_tool == "pliers":
				for child in get_children():
					if child.get_name().find("splinter") >= 0 and not child.is_hidden():
						var dist = child.get_pos().distance_to(get_local_mouse_pos())
						if dist <= 100:
							child.set_hidden(true)
							splinters_removed += 1
							printt("splinters removed", splinters_removed)
							vm.set_global("splinter_removed", true)
							if splinters_removed == 3:
								vm.set_global("splinters_removed", true)

func add_splinters():
	for child in get_children():
		if child.get_type() == "Position2D":
			var splinter = splinter_scene.instance()
			splinter.set_pos(child.get_pos())
			splinter.set_scale(Vector2(0.648465, 0.648465))
			add_child(splinter)

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	connect("input_event", self, "input")
	
	# TODO Set initial dino sounds somewhere (else?)
	vm.set_global("dino_hello", "*ergjbld*")
	vm.set_global("dino_goodbye", "*asdfkld*")

	add_splinters()

	# Hook up a temporary comfort level indicator
	# TODO Change facial expression instead
	comfort["indicator"] = get_parent().get_node("comfort_indicator")
	comfort["indicator"].set_text("Level: 0")
