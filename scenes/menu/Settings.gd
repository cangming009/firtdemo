extends Control

@onready var music_slider: HSlider = $VBox/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBox/SFXContainer/SFXSlider
@onready var back_button: Button = $VBox/BackButton

func _ready() -> void:
    var sm = get_node_or_null("/root/ScoreManager")
    if sm:
        music_slider.value = sm.get_music_vol() * 100
        sfx_slider.value = sm.get_sfx_vol() * 100

    music_slider.value_changed.connect(_on_music_changed)
    sfx_slider.value_changed.connect(_on_sfx_changed)
    back_button.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
    var sm = get_node_or_null("/root/ScoreManager")
    if sm:
        sm.set_music_vol(value / 100.0)

func _on_sfx_changed(value: float) -> void:
    var am = get_node_or_null("/root/AudioManager")
    if am:
        am.set_sfx_volume(value / 100.0)

func _on_back_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_main_menu()
