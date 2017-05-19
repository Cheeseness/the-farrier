extends Node2D

var vm

func global_listener(name):
	if name == "customer_dialogue_ended":
		start_dialogue()

# Function is first started by timer to dodge race conditions
func start_dialogue():
	var customer = get_parent().get_node("customer_onda")
	get_tree().call_group(0, "game", "clicked", customer, customer.get_pos())

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	# Use listener to restart dialogue tree
	vm.connect("global_changed", self, "global_listener")
