extends Node2D

var vm
var dino

func global_listener(name):
	# More ugly hacks
	var words = vm.get_global("words")
	for word in words:
		var ev_name = "%s_learned" % words[word][0]
		if name == ev_name:
			words[word][1] = 2
			vm.set_global("words", words)
			break
	if Disposition.is_trigger(name):
		change_disposition(name)
	if name == "splinter_removed":
		if vm.get_global("splinter_removed"):
			Tool.select(null)
			change_disposition("decrease_disposition_small")
			start_dialogue()
			vm.set_global("splinter_removed", false)
	if name == "dinosaur_dialogue_ended":
		# TODO Check if we're done with all our tasks - if so, go back to reception area
		if vm.get_global("splinters_removed"):
			# Reset flag, so that it works on coming back.
			# Not an issue if we're not just reloading the same room over and over.
			vm.set_global("splinters_removed", false)
			go_to_reception()
	
func change_disposition(name):
	Disposition.change(name)
	print("current disposition is %d" % Disposition.get_value())

	# Set animation according to disposition
	dino.get_node("Sprite").set_frame(Disposition.get_frame())

func go_to_reception():
	# Remove heard but not learned (or more) words before going to reception?
	var words = vm.get_global("words")
	for word in words:
		if words[word][1] == 1:
			words[word][1] = 0
	vm.set_global("words", words)
	if !vm.get_global("customer_onda_end"):
		vm.set_global("customer_onda_end", true)
	elif !vm.get_global("customer_wu_end"):
		vm.set_global("customer_wu_end", true)
	elif !vm.get_global("customer_herk_end"):
		vm.set_global("customer_herk_end", true)
	get_parent().queue_free()
	get_tree().change_scene("res://scenes/rooms/reception_area/reception_area.tscn")

# Function is first started by timer to dodge race conditions
func start_dialogue():
	get_tree().call_group(0, "game", "clicked", dino, dino.get_pos())

func show_hide_dinosaurs(customer_name):
	for n in ["lull", "krik", "bern"]:
		get_parent().get_node(n).hide()

	if customer_name == "customer_onda":
		dino = get_parent().get_node("lull")
	elif customer_name == "customer_wu":
		dino = get_parent().get_node("krik")
	elif customer_name == "customer_herk":
		dino = get_parent().get_node("bern")

	if dino:
		dino.show()

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	# Use listener to restart dialogue tree
	vm.connect("global_changed", self, "global_listener")

	var customer_name = "customer_onda"
	if vm.get_global("next_customer"):
		customer_name = vm.get_global("next_customer")
	show_hide_dinosaurs(customer_name)

	# Set disposition to neutral
	Disposition.set_value(0)

	if dino:
		prints("has active dinosaur:", dino.get_name())
		dino.get_node("Sprite").set_frame(Disposition.get_frame())
