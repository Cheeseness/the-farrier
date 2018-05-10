extends Node2D

var cursors = {}
var selected_tool

func is(tool_name):
	if selected_tool and selected_tool == tool_name:
		return true
	return false

func select(tool_name):
	if tool_name in cursors:
		selected_tool = tool_name
	else:
		selected_tool = null
	set_cursor(selected_tool)

func selected():
	return selected_tool

func set_cursor(name):
	if not name:
		Input.set_custom_mouse_cursor(null)
		return

	var texture = cursors[name]

	# Change mouse cursor and position interaction point to the middle of texture
	Input.set_custom_mouse_cursor(texture, texture.get_size() / 2)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed():
		# TODO: Figure out why is this called twice.
		select(null)

func _ready():
	for child in get_children():
		if not child.is_type("Sprite"):
			continue
		cursors[child.get_name()] = child.get_texture()

	set_process_input(true)
