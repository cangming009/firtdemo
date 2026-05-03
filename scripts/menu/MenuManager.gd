extends Node

const MENU_SCENE := preload("res://scenes/menu/MainMenu.tscn")
const LEVEL_SELECT_SCENE := preload("res://scenes/menu/LevelSelect.tscn")
const SETTINGS_SCENE := preload("res://scenes/menu/Settings.tscn")
const LEADERBOARD_SCENE := preload("res://scenes/menu/Leaderboard.tscn")
const GAME_SCENE := preload("res://scenes/game/Game.tscn")

var current_level: int = 1

func _ready() -> void:
    get_tree().root.set_meta("menu_manager", self)

func go_to_main_menu() -> void:
    get_tree().change_scene_to_packed(MENU_SCENE)

func go_to_level_select() -> void:
    get_tree().change_scene_to_packed(LEVEL_SELECT_SCENE)

func go_to_settings() -> void:
    get_tree().change_scene_to_packed(SETTINGS_SCENE)

func go_to_leaderboard() -> void:
    get_tree().change_scene_to_packed(LEADERBOARD_SCENE)

func start_game(level: int) -> void:
    current_level = level
    get_tree().change_scene_to_packed(GAME_SCENE)

func go_to_game_from_result() -> void:
    get_tree().change_scene_to_packed(GAME_SCENE)

func get_current_level() -> int:
    return current_level
