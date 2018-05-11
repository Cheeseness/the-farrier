extends Area2D

var comfort = {
	"level": 0,
	"indicator": null
}
var bandage_applied = 0

func set_comfort_level(increase=true):
	if increase:
		comfort["level"] += 1
		comfort["indicator"].set_text("Level: %d" % [comfort["level"]])

func input(viewport, event, shape_idx):
	# TODO: Distinguish between clicks and swipes
	# TODO: Block action if comfort level of dino is too low

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			prints("grooming_tool", Tool.selected())

			if Tool.selected():
				set_comfort_level()

			var condition = Conditions.at(get_local_mouse_position())

			if Tool.is_name("pliers") && condition && condition.get_name().find("splinter") >= 0 && condition.visible:
				condition.visible = !(true)
				Conditions.remove("splinter")
				if Conditions.is_removed("splinter"):
					vm.set_global("foot_healed", true)

			if Tool.is_name("poultice") && condition && condition.get_name().find("bruise") >= 0:
				var animation = condition.get_node("animation")
				if animation.get_current_animation() != "poultice":
					animation.play("poultice")
					# Bruises aren't actually removed at this stage, but poultice has been applied
					Conditions.remove("bruise")

			if Tool.is_name("bandage") && Conditions.is_removed("bruise") && bandage_applied < 3:
				bandage_applied += 1
				get_node("bandage%d" % bandage_applied).show()

func _ready():
	connect("input_event", self, "input")
	
	# TODO Set initial dino sounds somewhere (else?)
	vm.set_global("dino_hello", "*ergjbld*")
	vm.set_global("dino_goodbye", "*asdfkld*")

	# Set conditions here to enable without playing reception area first
	# Conditions.set_condition("bruise", 3, null)
	# Conditions.set_condition("splinter", 2, null)
	Conditions.init(self)

	# Hook up a temporary comfort level indicator
	# TODO Change facial expression instead
	comfort["indicator"] = get_parent().get_node("comfort_indicator")
	comfort["indicator"].set_text("Level: 0")
