extends Node2D

enum GameState { IDLE, PLAYING, GAME_OVER }

@export var game_duration: float = 30.0
@export var mole_spawn_interval_min: float = 0.5
@export var mole_spawn_interval_max: float = 1.5

var state: GameState = GameState.IDLE
var score: int = 0
var time_remaining: float = 0.0

@onready var score_label: Label = $UI/ScoreLabel
@onready var timer_label: Label = $UI/TimerLabel
@onready var start_button: Button = $UI/StartButton
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var holes: Array = $GameField.get_children()
@onready var audio_hit: AudioStreamPlayer = $AudioHit

var spawn_timer: Timer
var game_timer: Timer

func _ready() -> void:
	print("[GameManager] _ready called")
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_spawn_timeout)
	add_child(spawn_timer)

	game_timer = Timer.new()
	game_timer.timeout.connect(_on_game_timeout)
	add_child(game_timer)

	start_button.pressed.connect(_on_start_button_pressed)
	game_over_label.hide()
	update_ui()

	var hit_stream = load("res://hit.wav")
	if hit_stream:
		audio_hit.stream = hit_stream

	print("[GameManager] _ready done, holes count: ", holes.size())

func _on_start_button_pressed() -> void:
	start_game()

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

	game_over_label.text = "Game Over!\nScore: %d" % score
	game_over_label.show()
	start_button.text = "Play Again"
	start_button.show()

func add_score(points: int) -> void:
	if state == GameState.PLAYING:
		score += points
		update_ui()
		audio_hit.play()

func update_ui() -> void:
	score_label.text = "Score: %d" % score
	timer_label.text = "Time: %d" % max(0, int(time_remaining))
