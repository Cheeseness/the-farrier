extends Node

var disposition_change = {
	"increase_disposition_small": 1,
	"increase_disposition_big": 3,
	"decrease_disposition_small": -1,
	"decrease_disposition_big": -3
}
var disposition_frame = {
	"angry": 0,
	"annoyed": 1, 
	"neutral": 5,
	"content": 2,
	"happy": 4,
	"growling": 3,
}
var current_disposition = 0

func get_value():
	return current_disposition

func set_value(value):
	current_disposition = value

func get_frame():
	# Return animation frame for current disposition
	if current_disposition > 7:
		return disposition_frame["happy"]
	elif current_disposition > 2:
		return disposition_frame["content"]
	elif current_disposition > -2:
		return disposition_frame["neutral"]
	elif current_disposition > -7:
		return disposition_frame["annoyed"]
	else:
		return disposition_frame["angry"]

func is_trigger(name):
	# Check if global is trigger for change of disposition
	if name in disposition_change or name == "reset_disposition":
		return true
	return false

func change(name):
	if name == "reset_disposition":
		current_disposition = 0
	elif name in disposition_change:
		current_disposition += disposition_change[name]
