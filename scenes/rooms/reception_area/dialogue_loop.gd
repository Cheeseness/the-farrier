extends Node2D

var vm

func global_listener(name):
	if name == "customer_dialogue_ended":
		start_dialogue()

# Function is first started by timer to dodge race conditions
func start_dialogue():
	var customer = vm.get_global("customer")
	get_tree().call_group(0, "game", "clicked", customer, customer.get_pos())

func _ready():
	printt("customer scene is ready")
	vm = get_tree().get_root().get_node("/root/vm")
	vm.set_global("customer", get_parent().get_node("PlaceholderCustomer"))
	# Use listener to restart dialogue tree
	vm.connect("global_changed", self, "global_listener")
