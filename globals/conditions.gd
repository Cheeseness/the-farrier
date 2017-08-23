extends Node

# Example: var seeds = {"bruise": {"number": 3, "variance": 1}, "wound": {"number": 2}}
var conditions = {}

func set_condition(name, number, variance):
	printt("set_condition", name, number, variance)
	conditions[name] = {}
	conditions[name]["number"] = number
	if variance:
		conditions[name]["variance"] = variance
	printt("seeds", conditions)

# TODO: Add convenience function to get/set state of any condition

# TODO: Try to add conditions to current scene based on values in seeds
func add_conditions():
	pass

# TODO: Add tear-down function