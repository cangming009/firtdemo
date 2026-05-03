extends Node2D

enum GameState { IDLE, PLAYING, GAME_OVER }

@export var current_level: int = 1

var state: GameState = GameState.IDLE
var score: int = 0
var time_remaining: float = 0.0

@export var game_duration: float = 30.0
@export var mole_spawn_interval_min: float = 0.5
@export var mole_spawn_interval_max: float = 1.5
@export var visible_time: float = 1.5

@onready var score_label: Label = $UI/ScoreLabel
@onready var timer_label: Label = $UI/TimerLabel
@onready var start_button: Button = $UI/StartButton
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var combo_label: Label = $UI/ComboLabel
@onready var holes: Array = $GameBoard.get_children()
@onready var audio_hit: AudioStreamPlayer = $AudioHit

var spawn_timer: Timer
var game_timer: Timer
var combo_count: int = 0
var combo_timer: Timer

func _ready() -> void:
    print("[GameManager] _ready called, level=", current_level)

    var level_config = LevelConfig.get_level_config(current_level)
    mole_spawn_interval_min = level_config.spawn_interval_min
    mole_spawn_interval_max = level_config.spawn_interval_max
    visible_time = level_config.visible_time
    game_duration = level_config.game_duration

    spawn_timer = Timer.new()
    spawn_timer.timeout.connect(_on_spawn_timeout)
    add_child(spawn_timer)

    game_timer = Timer.new()
    game_timer.timeout.connect(_on_game_timeout)
    add_child(game_timer)

    combo_timer = Timer.new()
    combo_timer.timeout.connect(_on_combo_timeout)
    combo_timer.one_shot = true
    add_child(combo_timer)

    start_button.pressed.connect(_on_start_button_pressed)
    game_over_label.hide()
    combo_label.hide()
    update_ui()

    var hit_stream = load("res://hit.wav")
    if hit_stream:
        audio_hit.stream = hit_stream

    print("[GameManager] _ready done, holes count: ", holes.size())

func _on_start_button_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_main_menu()

func start_game() -> void:
    print("[GameManager] start_game called")
    state = GameState.PLAYING
    score = 0
    time_remaining = game_duration

    start_button.hide()
    game_over_label.hide()

    game_timer.start(1.0)
    schedule_next_spawn()

    update_ui()

func schedule_next_spawn() -> void:
    var interval = randf_range(mole_spawn_interval_min, mole_spawn_interval_max)
    spawn_timer.start(interval)

func _on_spawn_timeout() -> void:
    if state != GameState.PLAYING:
        return

    var available_holes: Array = holes.filter(func(h): return not h.is_mole_visible())
    if available_holes.size() > 0:
        var random_hole = available_holes[randi() % available_holes.size()]
        random_hole.show_mole()

    schedule_next_spawn()

func _on_game_timeout() -> void:
    time_remaining -= 1.0
    update_ui()

    if time_remaining <= 0:
        end_game()

func end_game() -> void:
    state = GameState.GAME_OVER
    spawn_timer.stop()
    game_timer.stop()

    for hole in holes:
        hole.hide_mole()

    var sm = get_node_or_null("/root/ScoreManager")
    if sm:
        sm.add_score(current_level, score)
        if score > 0:
            sm.unlock_next_level()

    game_over_label.text = "Game Over!\nScore: %d" % score
    game_over_label.show()
    start_button.text = "返回菜单"
    start_button.show()

func add_score(points: int, mole_pos: Vector2 = Vector2.ZERO) -> void:
    if state == GameState.PLAYING:
        score += points
        update_ui()
        if audio_hit.stream:
            var am = get_node_or_null("/root/AudioManager")
            if am:
                am.play_sfx(audio_hit.stream)
            else:
                audio_hit.play()
        spawn_score_popup(mole_pos, points)

        combo_count += 1
        combo_timer.start(1.5)

        combo_label.text = "Combo: %d" % combo_count
        combo_label.show()
        combo_label.scale = Vector2(1.2, 1.2)
        var tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

        show_combo_text()

func spawn_score_popup(world_pos: Vector2, points: int) -> void:
    var popup = Label.new()
    popup.text = "+%d" % points
    popup.add_theme_font_size_override("font_size", 24)
    popup.modulate = Color(0.3, 0.85, 0.3, 1)
    popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    popup.z_index = 100
    add_child(popup)

    var camera_pos = Vector2.ZERO
    var camera = get_viewport().get_camera_2d()
    if camera:
        camera_pos = camera.global_position
    popup.global_position = camera_pos + world_pos + Vector2(0, -20)

    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(popup, "position:y", camera_pos.y + world_pos.y - 80, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(popup, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

    await get_tree().create_timer(0.8).timeout
    popup.queue_free()

func update_ui() -> void:
    score_label.text = "Score: %d" % score
    timer_label.text = "Time: %d" % max(0, int(time_remaining))

func _on_combo_timeout() -> void:
    combo_count = 0
    combo_label.hide()

func show_combo_text() -> void:
    var text = ""
    if combo_count >= 6:
        text = "Amazing!"
    elif combo_count >= 4:
        text = "Great!"
    elif combo_count >= 2:
        text = "Nice!"
    else:
        return

    combo_label.text = text
    combo_label.show()

    combo_label.scale = Vector2(2.0, 2.0)
    combo_label.modulate.a = 0.0
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(combo_label, "modulate:a", 1.0, 0.2)

    await get_tree().create_timer(0.5).timeout
    combo_label.hide()
