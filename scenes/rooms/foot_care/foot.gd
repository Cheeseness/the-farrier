extends Area2D

var vm
var comfort = {
	"level": 0,
	"indicator": null
}
var foot_positions
var splinters_removed = 0
var splinters_total = 3
var bruises_removed = 0
var bruises_total = 2
const splinter_scene = preload("res://scenes/conditions/splinter/splinter.tscn")
const bruise_a_scene = preload("res://scenes/conditions/bruise/bruise_a.tscn")
const bruise_b_scene = preload("res://scenes/conditions/bruise/bruise_b.tscn")

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

			# TODO: When bruises are treated with poultice, change animation:
			# bruise.get_node("animation").play("poultice")

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
							if splinters_removed == splinters_total:
								vm.set_global("splinters_removed", true)

			if grooming_tool && grooming_tool == "poultice":
				for child in get_children():
					if child.get_name().find("bruise") >= 0:
						var animation = child.get_node("animation")
						var dist = child.get_pos().distance_to(get_local_mouse_pos())
						if dist <= 100:
							if animation.get_current_animation() != "poultice":
								animation.play("poultice")
								# Bruises aren't actually removed at this stage, but poultice has been applied
								bruises_removed += 1
								printt("poultice applied", bruises_removed)

			if grooming_tool && grooming_tool == "bandage" && bruises_removed == bruises_total:
				pass

func init_foot_positions():
	foot_positions = []
	for child in get_children():
		if child.get_type() == "Position2D":
			foot_positions.append(child)

func get_foot_positions(num):
	if typeof(foot_positions) == TYPE_NIL:
		init_foot_positions()

	randomize()
	var picks = []

	for i in range(num):
		if foot_positions.empty():
			break
		var idx = randi() % foot_positions.size()
		picks.append(foot_positions[idx])
		foot_positions.remove(idx)

	return picks

func add_splinters():
	for child in get_foot_positions(splinters_total):
		var splinter = splinter_scene.instance()
		splinter.set_pos(child.get_pos())
		add_child(splinter)

func add_bruises():
	randomize()
	for child in get_foot_positions(bruises_total):
		var bruise
		if randi() % 2:
			bruise = bruise_a_scene.instance()
		else:
			bruise = bruise_b_scene.instance()
		bruise.set_pos(child.get_pos())
		add_child(bruise)

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	connect("input_event", self, "input")
	
	# TODO Set initial dino sounds somewhere (else?)
	vm.set_global("dino_hello", "*ergjbld*")
	vm.set_global("dino_goodbye", "*asdfkld*")

	add_splinters()
	add_bruises()

	# Hook up a temporary comfort level indicator
	# TODO Change facial expression instead
	comfort["indicator"] = get_parent().get_node("comfort_indicator")
	comfort["indicator"].set_text("Level: 0")
