extends Control

@onready var grid: GridContainer = $VBox/GridContainer
@onready var back_button: Button = $VBox/BackButton

var level_buttons: Array = []

func _ready() -> void:
	var sm = get_node_or_null("/root/ScoreManager")
	var unlocked = 1
	if sm:
		unlocked = sm.get_unlocked_level()

	for i in range(1, 10):
		var btn = Button.new()
		btn.text = "关卡 %d" % i
		if i <= unlocked:
			btn.pressed.connect(_on_level_button_pressed.bind(i))
		else:
			btn.disabled = true
			btn.modulate.a = 0.5
		grid.add_child(btn)
		level_buttons.append(btn)

	back_button.pressed.connect(_on_back_pressed)

func _on_level_button_pressed(level: int) -> void:
	var mm = get_tree().root.get_meta("menu_manager")
	mm.start_game(level)

func _on_back_pressed() -> void:
	var mm = get_tree().root.get_meta("menu_manager")
	mm.go_to_main_menu()
