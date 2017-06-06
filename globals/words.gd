extends Node

var words = {
	"*bruuuuugh*": ["(greeting)", 0],
	"*pbbbbt*" : ["(goodbye)", 0],
	"*proooom*" : ["(sad)", 0],
	"*braaa*" : ["(happy)", 0],
	"*hmndn*" : ["(human)", 0],
	"*pum*" : ["(no)", 0],
	"*reehii*" : ["(yes)", 0],
	"*ghneeku*" : ["(cave)", 0],
	"*yeeduu*" : ["(dinosaur)", 0],
	"*browmm*" : ["(pain)", 0],
	"*harroot*" : ["(cave)", 0],
	"*drrrrgl*" : ["(food)", 0]
}

# TODO: Figure out what kinds of convenience function we need and implement

func all():
	return words

func get(dino_word):
	# TODO: Lookup by dino word and/or "human" word
	if dino_word in words:
		return words[dino_word]

func heard(dino_word):
	return _check_value(dino_word, 1)

func learned(dino_word):
	return _check_value(dino_word, 2)

func understood(dino_word):
	return _check_value(dino_word, 3)

func _check_value(dino_word, value):
	# Helper function for learning state functions
	if dino_word in words and words[dino_word][1] == value:
		return true
	return false

func reset_unlearned():
	# Reset words that have been heard, but not learned
	# Is being called both from dialog_dialog.gd and event_trigger.gd
	for word in words:
		if words[word][1] == 1:
			words[word][1] = 0

func increment_state_by_dialogue(dino_word):
	# Change state of words in list if seen in dialogue
	# From "unheard" to "heard", from "learned" to "understood"
	# TODO: Check if this is working as intended
	if dino_word in words and words[dino_word][1] != 1:
		words[dino_word][1] += 1

func set_learned_by_event(name):
	# Mark word as learned if global is set in esc script
	# Not sure if this was being used.
	for word in words:
		var ev_name = "%s_learned" % words[word][0]
		if name == ev_name:
			words[word][1] = 2
			break
