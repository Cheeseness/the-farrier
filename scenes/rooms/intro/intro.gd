extends TextureFrame

########
#This script controls a slideshow style background with text dialogue
########
#
# * Backgrounds and their durations are added to the backgrounds array.
#Background durations are extended to encompass dialogue durations.
# * Dialogue lines are added to the lines dict grouped by background name.
# * colour_list declares colours for dialogue matching the speaker in the
#lines dict. If no colour is present, the default (white) is used.
# * Dialogue lines are positioned based on the location of a child Node2D
#with the same name as the speaker in the lines dict. If no matching
#Node2D is present, the line is positioned in the centre of the screen.

#the name of the scene to transition to after this one is done
var next_scene = "res://scenes/rooms/reception_area/reception_area.tscn"

#optional colours for speaking characters
var colour_list = {
					"yemm": "8a9af3",
					"yemm2": "8a9af3",
					"yemm3": "8a9af3",
					"papa": "b0b0b0",
					"dinosaur": "be1946",
					"dinosaur2": "be1946",
					"bell": "e1e11d",
					}

# dialogue lines declared per background as as speaker, line, start, duration
var lines = {
			"thefarrier_intro_01.png": [
				["yemm", "Papa, why do you talk to them?", 1, 2],
			],
			"thefarrier_intro_02.png": [
				["dinosaur", "*whebbebb*", 0, 1],
				["papa", "Woah there, easy now. It's OK.", 0.75, 2],
				["papa", "To keep them calm. It's important to reassure them even if they can't understand.", 3, 3],
			],
			"thefarrier_intro_03.png": [
				["papa", "Pass me the pliers, would you Yemm?", 0.5, 1.5],
			],
			"thefarrier_intro_07.png": [
				["papa", "Thank you.", 0, 1],
			],
			"thefarrier_intro_08.png":
			[
				["papa", "Shh, this'll only hurt a bit.", 0.5, 2.0],
			],
			"thefarrier_intro_09.png": [
				["papa", "And sometimes perhaps, it's to reassure us as well...", 0, 3],
			],
			"thefarrier_intro_10.png": [
				["yemm", "*gasp*", 0, 0.75],
				["dinosaur", "*browmm*", 0, 0.75],
			],
			"thefarrier_intro_12.png": [
				["papa", "There we go. Good as new.", 0.5, 1.5],
				["dinosaur", "*braaa*", 2.5, 1.5],
			],
			"thefarrier_intro_14.png":
			[
				["yemm2", "Shh, this'll only hurt a bit.", 0, 2.0],
			],
			"thefarrier_intro_15.png":
			[
				["dinosaur2", "*browmm*", 0, 2.0],
			],
			"thefarrier_intro_16.png":
			[
				["yemm2", "There we go. Good as new.", 0.5, 1.5],
				["dinosaur2", "*braaa*", 2.5, 1.5],
			],
			"thefarrier_intro_17.png":
			[
				["bell", "*ding*", 0, 1],
				["yemm2", "*sigh*", 1, 1.5],
				["yemm3", "Coming!", 3, 1.5],
			],
		}

# backgrounds declared as filename, duration
# (duration will be automatically increased where dialogue overflows)
var backgrounds = [
					["thefarrier_intro_01.png", 2.5],
					["thefarrier_intro_02.png", 2.5],
					["thefarrier_intro_03.png", 1], #papa reaches
					["thefarrier_intro_04.png", 0.5],
					["thefarrier_intro_05.png", 0.5],
					["thefarrier_intro_06.png", 0.5],
					["thefarrier_intro_07.png", 0.5], #Yemm hands pliers
					["thefarrier_intro_08.png", 0.75], #papa gets ready
					["thefarrier_intro_09.png", 2.5],
					["thefarrier_intro_10.png", 0.5],
					["thefarrier_intro_11.png", 0.5],
					["thefarrier_intro_12.png", 5.0],
					["thefarrier_intro_13.png", 1], #Yemm all grown up
					["thefarrier_intro_14.png", 2.5],
					["thefarrier_intro_15.png", 2.5],
					["thefarrier_intro_16.png", 2.5],
					["thefarrier_intro_17.png", 2.5],
					]
var background_list = {}
var counter = 0
var current_index

# pending_lines end up stored as start time: speaker, string, end time
var pending_lines = {}
# current_lines end up stored as end time: node
var current_lines = {}

func _ready():
	#print("Ready...")
	current_index = 0
	setup_backgrounds()
	setup_lines(backgrounds[current_index][0])
	set_process(true)
	set_process_input(true)

func _input(event):
	if event.is_action("skip") and not event.is_pressed():
		transition_scene()

func _process(delta):
	counter += delta

	#Remove any expired lines
	while !current_lines.empty():
		var line_end = get_first_dict_index(current_lines)
		if counter >= line_end:
			current_lines[line_end].queue_free()
			current_lines.erase(line_end)
		else:
			break

	#Add any new lines
	while !pending_lines.empty():
		var line_start = get_first_dict_index(pending_lines)
		if counter >= line_start:
			#print("Adding label ", pending_lines[line_start][1])
			var label = Label.new()
			label.set_size(Vector2(800, 100))
			label.set_custom_minimum_size(Vector2(800, 100))
			label.set_pos(Vector2(960 - 400, 540))
			label.set_autowrap(true)
			if has_node(pending_lines[line_start][0]):
				var anchor = get_node(pending_lines[line_start][0])
				label.set_pos(Vector2(anchor.get_pos()[0] - 400, anchor.get_pos()[1]))
			label.set_valign(Label.VALIGN_BOTTOM)
			label.set_align(Label.ALIGN_CENTER)
			label.set_text(pending_lines[line_start][1])
			label.add_font_override("font", load("res://ui/fonts/overlock_bold.fnt"))
			label.add_constant_override("shadow_offset_x", 2)
			label.add_constant_override("shadow_offset_y", 2)
			label.add_color_override("font_color_shadow", Color(0,0,0))
			if (colour_list.has(pending_lines[line_start][0])):
				label.add_color_override("font_color", Color(colour_list[pending_lines[line_start][0]]))
			#todo: position offset based on count of currently displayed lines from that speaker

			#fixme: This is silly
			var temp = pending_lines[line_start][2]
			while current_lines.has(temp):
				temp += 0.1

			current_lines[temp] = label
			add_child(label)
			pending_lines.erase(line_start)
		else:
			break

	#print("Checking backgrounds...")
	if counter > background_list[current_index][1]:
		if current_index < background_list.size() - 1:
			current_index += 1
			set_texture(background_list[current_index][0])
			setup_lines(backgrounds[current_index][0])
			counter = 0
			# clear dialogue lines?
		else:
			#print("Done")
			transition_scene()

func transition_scene():
	get_parent().queue_free()
	get_tree().change_scene(next_scene)


func setup_backgrounds():
	for i in range(backgrounds.size()):
		var it = ImageTexture.new()
		#print("loading", backgrounds[i][0])
		it.load("res://scenes/rooms/intro/sprites/" + backgrounds[i][0])
		background_list[i] = [it, backgrounds[i][1]]

		if lines.has(backgrounds[i][0]):
			for l in lines[backgrounds[i][0]]:
				if l[3] + l[2] > background_list[i][1]:
					background_list[i][1] = l[3] + l[2]

func get_first_dict_index(d):
	if !d.empty():
		var k = d.keys()
		k.sort()
		return k[0]
	else:
		return null

func setup_lines(background):
	#print("Setting up lines for", background)
	for l in current_lines.keys():
		current_lines[l].queue_free()
	current_lines.clear()

	pending_lines.clear()
	if lines.has(background):
		for l in lines[background]:
			#print("Setting up line",l," for background", background)
			var temp = l[2] #fixme: This is silly
			while pending_lines.has(temp):
				temp += 0.1
			pending_lines[temp] = [l[0], l[1], l[3] + temp]
	#print("Done.")