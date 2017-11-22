extends Node

# Not sure if we'll need vm for anything here
# onready var vm = get_tree().get_root().get_node("/root/vm")
var journal = []

func add_entry(entry):
	journal.append(entry)

func get_journal():
	return journal