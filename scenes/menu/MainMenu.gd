extends Control

@onready var start_button: Button = $VBox/StartButton
@onready var leaderboard_button: Button = $VBox/LeaderboardButton
@onready var settings_button: Button = $VBox/SettingsButton

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    leaderboard_button.pressed.connect(_on_leaderboard_pressed)
    settings_button.pressed.connect(_on_settings_pressed)

func _on_start_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_level_select()

func _on_leaderboard_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_leaderboard()

func _on_settings_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_settings()
