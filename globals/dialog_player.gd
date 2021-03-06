extends ResourcePreloader

var types = {}

func say(params, callback):
	var type
	printt("params", params[0], params[1])
	if params.size() < 2 || !has_resource(params[0]):
		type = "default"
	else:
		type = params[0]
	type = type + Globals.get("platform/dialog_type_suffix")
	var inst = get_resource(type).instance()
	var z = inst.get_z()
	get_tree().get_root().get_child(0).add_child(inst)
	var intro = true
	var outro = true
	if type in types:
		intro = types[type][0]
		outro = types[type][1]
	inst.init(params, callback, intro, outro)
	inst.set_z(z)

func config(params):
	types[params[0]] = [params[1], params[2]]

func _ready():
	add_to_group("dialog")
