extends Node

# Not sure if we'll need vm for anything here
# onready var vm = get_tree().get_root().get_node("/root/vm")
var journal = []
var dinosaur = ""

func set_dinosaur(name):
	dinosaur = name

func add_entry(entry):
	journal.append({"dinosaur": dinosaur, "entry": entry, "date": _get_date()})

func get_journal():
	return journal

func _get_date():
	var date = OS.get_date()
	return "%04d-%02d-%02d" % [date["year"], date["month"], date["day"]]