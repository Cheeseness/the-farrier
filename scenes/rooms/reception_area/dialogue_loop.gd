extends Node2D

var vm

func global_listener(name):
	if name == "customer_dialogue_ended":
		start_dialogue()

# Function is first started by timer to dodge race conditions
func start_dialogue():
	var customer_name = "customer_onda"
	if vm.get_global("next_customer"):
		customer_name = vm.get_global("next_customer")
		show_hide_customers(customer_name)
	var customer = get_parent().get_node(customer_name)
	get_tree().call_group(0, "game", "clicked", customer, customer.get_pos())

func show_hide_customers(customer_name):
	if customer_name == "customer_onda":
		get_parent().get_node("customer_onda").show()
		get_parent().get_node("customer_wu").hide()
		get_parent().get_node("customer_herk").hide()
		get_parent().get_node("lull").show()
		get_parent().get_node("krik").hide()
		get_parent().get_node("bern").hide()
	elif customer_name == "customer_wu":
		get_parent().get_node("customer_onda").hide()
		get_parent().get_node("customer_wu").show()
		get_parent().get_node("customer_herk").hide()
		get_parent().get_node("lull").hide()
		get_parent().get_node("krik").show()
		get_parent().get_node("bern").hide()
	elif customer_name == "customer_herk":
		get_parent().get_node("customer_onda").hide()
		get_parent().get_node("customer_wu").hide()
		get_parent().get_node("customer_herk").show()
		get_parent().get_node("lull").hide()
		get_parent().get_node("krik").hide()
		get_parent().get_node("bern").show()

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	# Use listener to restart dialogue tree
	vm.connect("global_changed", self, "global_listener")
