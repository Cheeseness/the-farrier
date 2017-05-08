extends Node2D

var vm
var cursors = {}
var nope = false

func set_cursor(name):
	if nope or name.find("cursor/") < 0:
		return
		
	var type = name.substr(7, name.length() - 7)
	var texture = null
	
	if type in cursors:
		texture = cursors[type]
	else:
		return
	
	# Change mouse cursor and position interaction point in the middle of texture
	var width = texture.get_width()
	var height = texture.get_height()
	Input.set_custom_mouse_cursor(texture, Vector2(width / 2, height / 2))
	
	# Update other cursor globals without endless recursion
	nope = true
	vm.set_globals("cursor/", false)
	vm.set_globals(name, true)
	nope = false

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_RIGHT:
		Input.set_custom_mouse_cursor(null)
		vm.set_globals("cursor/", false)
		vm.set_globals("grooming_tool", false)

func _ready():
	for child in get_children():
		if not child.is_type("Sprite"):
			continue
		cursors[child.get_name()] = child.get_texture()
	
	set_process_input(true)
	vm = get_tree().get_root().get_node("/root/vm")
	vm.connect("global_changed", self, "set_cursor")