extends Node

# Example: var seeds = {"bruise": {"number": 3, "variance": 1}, "wound": {"number": 2, "removed": 1}}
var conditions = {}
var target
onready var vm = get_tree().get_root().get_node("/root/vm")

const splinter_scene = preload("res://scenes/conditions/splinter/splinter.tscn")
const bruise_a_scene = preload("res://scenes/conditions/bruise/bruise_a.tscn")
const bruise_b_scene = preload("res://scenes/conditions/bruise/bruise_b.tscn")

func set_condition(name, number, variance):
	# TODO: variance should only be used locally, and if not 0, should update number with correct value
	# (Otherwise, the check in is_removed() will fail.)
	conditions[name] = {"number": number}
	if variance:
		conditions[name]["variance"] = variance

func init(foot):
	target = foot
	var positions = get_positions(foot)

	for name in conditions:
		var num = conditions[name]["number"]
		# TODO: Break if there are no positions left
		for i in range(num):
			var cond
			if name == "splinter":
				cond = splinter_scene.instance()
			elif name == "bruise":
				# TODO: Randomize instead of picking every other
				if i % 2:
					cond = bruise_a_scene.instance()
				else:
					cond = bruise_b_scene.instance()
			if cond:
				var pos = positions[0]
				positions.remove(0)
				cond.set_position(pos.get_position())
				foot.add_child(cond)

func reset():
	conditions = {}
	target = null

func at(mouse_pos):
	# Checks if there's a condition at the given mouse position
	for child in target.get_children():
		var name = child.get_name()
		if name.find("splinter") >= 0 || name.find("bruise") >= 0:
			if child.position.distance_to(mouse_pos) <= 100:
				return child
	return null

func remove(name):
	# Remove one unit of named condition
	if not name in conditions:
		return
	if not "removed" in conditions[name]:
		conditions[name]["removed"] = 0
	conditions[name]["removed"] += 1
	# TODO: Should probably replace this with a single global
	vm.set_global("%s_removed" % name, true)

func is_removed(name):
	# Check if all units of named condition have been removed
	if not name in conditions \
		or conditions[name]["removed"] != conditions[name]["number"]:
		return false
	return true

# Helper functions
func get_positions(foot):
	# Return randomized list of positions
	var temp = []
	var positions = []

	for child in foot.get_children():
		if child is Position2D:
			temp.append(child)

	randomize()

	while not temp.empty():
		var idx = randi() % temp.size()
		positions.append(temp[idx])
		temp.remove(idx)

	return positions