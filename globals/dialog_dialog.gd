extends Control

export var mouse_enter_color = Color(1,1,0.3)
export var mouse_enter_shadow_color = Color(0.6,0.4,0)
export var mouse_exit_color = Color(1,1,1)
export var mouse_exit_shadow_color = Color(1,1,1)

var vm
var cmd
var container
var context
var item
var animation
var ready = false
var option_selected
var timer
var timer_timeout = 0
var timeout_option = 0

func selected(n):
	if !ready:
		return
	option_selected = n
	animation.play("hide")
	ready = false
	if timer != null:
		timer.stop()
		animation.set_speed(1)

func timer_timeout():
	selected(timeout_option)

func start(params, p_context):
	#stop()
	printt("dialog start with params ", params.size())
	context = p_context
	cmd = params[0]
	# Intercept and add dialogue options
	append_words(cmd)
	var i = 0
	var visible = 0
	for q in cmd:
		if !vm.test(q):
			i+=1
			continue
		var it = item.duplicate()
		var but = it.get_node("button")
		var label = but.get_node("label")

		var force_ids = Globals.get("debug/force_text_ids")
		var text = q.params[0]
		var sep = text.find(":\"")
		if sep > 0:
			var tid = text.substr(0, sep)
			text = text.substr(sep + 2, text.length() - (sep + 2))
	
			# This won't work unless we put the placeholder variables in translation files - Flesk
			#var ptext = TranslationServer.translate(tid)
			#if ptext != tid:
			#	text = ptext
			#elif force_ids:
			#	text = tid + " (" + text + ")"

		elif force_ids:
			text = "(no id) " + text
			
		# Interpolate global variables - Flesk
		text = vm.interpolate_globals(text)

		label.set_text(text)
		but.connect("pressed", self, "selected", [i])
		but.connect("mouse_enter",self,"_on_mouse_enter",[but])
		but.connect("mouse_exit",self,"_on_mouse_exit",[but])

		var height_ratio = Globals.get("platform/dialog_option_height")
		var size = it.get_custom_minimum_size()
		size.y = size.y * height_ratio
		it.set_custom_minimum_size(size)


		container.add_child(it)
		if i == 0:
			but.grab_focus()
		i+=1
		visible += 1

		_on_mouse_exit(but)

	if has_node("anchor/avatars"):
		var avatar = "default"
		if params.size() >= 3:
			avatar = params[2]
		var avatars = get_node("anchor/avatars")
		for i in range(avatars.get_child_count()):
			var c = avatars.get_child(i)
			if c.get_name() == avatar:
				c.show()
			else:
				c.hide()

	timer_timeout = 0
	timeout_option = 0
	if params.size() >= 4:
		timer_timeout = float(params[3])
		if params.size() >= 5:
			timeout_option = int(params[4])

	if timer_timeout > 0:
		printt("********* dialog has timeout", timer_timeout, timeout_option)
		timer = Timer.new()
		add_child(timer)
		timer.set_one_shot(true)
		timer.set_wait_time(timer_timeout)
		timer.connect("timeout", self, "timer_timeout")
		#timer.start()

	ready = false
	animation.play("show")
	animation.seek(0, true)
	
func _on_mouse_enter(button):
	button.get_node("label").add_color_override("font_color", mouse_enter_color)
	button.get_node("label").add_color_override("font_color_shadow", mouse_enter_shadow_color)
	
func _on_mouse_exit(button):
	button.get_node("label").add_color_override("font_color", mouse_exit_color)
	button.get_node("label").add_color_override("font_color_shadow", mouse_exit_shadow_color)

func stop():
	hide()
	while container.get_child_count() > 0:
		var c = container.get_child(0)
		container.remove_child(c)
		c.free()
	vm.request_autosave()
	queue_free()

func game_cleared():
	queue_free()

func anim_finished():
	var cur = animation.get_current_animation()
	if cur == "show":
		ready = true
		if timer_timeout > 0:
			timer.start()
			if animation.has_animation("timer"):
				animation.set_current_animation("timer")
				var len = animation.get_current_animation_length()
				animation.set_speed(len / timer_timeout)
				animation.play()

	if cur == "hide":
		vm.finished(context)
		vm.add_level(cmd[option_selected].params[1], false)
		stop()

func _ready():

	printt("dialog ready")
	hide()
	vm = get_tree().get_root().get_node("vm")
	container = get_node("anchor/scroll/container")
	container.set_stop_mouse(false)
	#add_to_group("dialog_dialog")
	item = get_node("item")
	item.get_node("button/label").set_stop_mouse(false)
	item.get_node("button").set_stop_mouse(false)
	item.set_stop_mouse(false)
	call_deferred("remove_child", item)
	animation = get_node("animation")
	animation.connect("finished", self, "anim_finished")
	#get_node("anchor/scroll").set_theme(preload("res://game/globals/dialog_theme.xml"))
	add_to_group("game")

	# Set global word list
	if not "words" in vm.get_global_list():
		vm.set_global("words", {
			"*bruuuuugh*": ["greeting", 0],
			"*hmndn*": ["human", 0]
		})

func append_words(cmd):
	# Append words to dialogue options dynamically from list
	
	# 0 - not learned, only appears the "turn" after it was spoken by dino
	# 1 - learned, appears if repeated by player
	# 2 - understood, always appears translated

	# Correct words will be defined by .esc scripts,
	# so make not to repeat words already in list.

	# Get current player and dino from globals
	var player = "yemm_anchor"
	var dino = "test_dino"

	# Remove temporary words - this approach is problematic if .esc scripts
	# use any of the same word for dialogue branches
	remove_words(cmd)

	var words = vm.get_global("words")
	for word in words:
		var meaning = words[word][0]
		# If not heard, don't repeat
		if not vm.get_global("heard/%s" % meaning):
			continue
		var p = {"name": "*", "params": [word, []]}
		p["params"][1].append({"name": "say", "params": [player, word]})
		p["params"][1].append({"name": "set_global", "params": ["%s_learned" % meaning, "true"]})
		cmd.append(p)

	# If not repeated on following "turn", learning opportunity is lost for now
	vm.set_globals("heard/*", false)

func remove_words(cmd):
	# Removing items in place doesn't work, so we'll use a temporary array
	var remove = []
	
	for c in cmd:
		if c["params"][0] in vm.get_global("words"):
			remove.append(c)

	for r in remove:
		cmd.erase(r)

# TODO: Ugh! We want to remove lines too, so this is useless
func get_lines(cmd):
	var lines = []
	for c in cmd:
		var append = true
		if "if_true" in c:
			for key in c["if_true"]:
				if !vm.get_global(key):
					append = false
					continue
		if append:
			lines.append(c["params"][0])
	return lines