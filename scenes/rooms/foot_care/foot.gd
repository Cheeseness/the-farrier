extends Area2D

var vm
var comfort = {
	"level": 0,
	"indicator": null
}
var foot_positions
var splinters_removed = 0
var splinters_total = 3
var bruises_removed = 0
var bruises_total = 2
var bandage_applied = 0

func set_comfort_level(increase=true):
	if increase:
		comfort["level"] += 1
		comfort["indicator"].set_text("Level: %d" % [comfort["level"]])

func input(viewport, event, shape_idx):
	# TODO: Distinguish between clicks and swipes
	# TODO: Block action if comfort level of dino is too low
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			prints("grooming_tool", Tool.selected())
			# TEMPORARY!

			if Tool.selected():
				set_comfort_level()

			var condition = Conditions.at(get_local_mouse_pos())

			# TODO: Handle this in a less shitty way
			if Tool.is("pliers") && condition && condition.get_name().find("splinter") >= 0 && not condition.is_hidden():
				condition.set_hidden(true)
				splinters_removed += 1
				printt("splinters removed", splinters_removed)
				vm.set_global("splinter_removed", true)
				if splinters_removed == splinters_total:
					vm.set_global("splinters_removed", true)

			if Tool.is("poultice") && condition && condition.get_name().find("bruise") >= 0:
				var animation = condition.get_node("animation")
				if animation.get_current_animation() != "poultice":
					animation.play("poultice")
					# Bruises aren't actually removed at this stage, but poultice has been applied
					bruises_removed += 1
					printt("poultice applied", bruises_removed)

			if Tool.is("bandage") && bruises_removed == bruises_total && bandage_applied < 3:
				bandage_applied += 1
				get_node("bandage%d" % bandage_applied).show()
				printt("bandage applied", bandage_applied)

func _ready():
	vm = get_tree().get_root().get_node("/root/vm")
	connect("input_event", self, "input")
	
	# TODO Set initial dino sounds somewhere (else?)
	vm.set_global("dino_hello", "*ergjbld*")
	vm.set_global("dino_goodbye", "*asdfkld*")

	Conditions.init(self)

	# Hook up a temporary comfort level indicator
	# TODO Change facial expression instead
	comfort["indicator"] = get_parent().get_node("comfort_indicator")
	comfort["indicator"].set_text("Level: 0")
