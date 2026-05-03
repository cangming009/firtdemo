extends Node2D

enum MoleState { HIDDEN, RISING, VISIBLE, HIDING, WHACKED }

@export var rise_time: float = 0.3
@export var visible_time: float = 1.5
@export var hide_time: float = 0.2

var state: MoleState = MoleState.HIDDEN
var is_whacked: bool = false

@onready var mole_sprite: ColorRect = $Mole/MoleSprite

signal mole_whacked

func _ready() -> void:
	print("[Mole] _ready called")
	hide_mole_instant()
	print("[Mole] _ready done")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if state == MoleState.VISIBLE and not is_whacked:
				var mole_rect = mole_sprite.get_global_rect()
				if mole_rect.has_point(event.global_position):
					whack()
					get_tree().root.push_input(event)

func show_mole() -> void:
	if state != MoleState.HIDDEN:
		print("[Mole] show_mole skipped, state=", state)
		return

	print("[Mole] show_mole start")
	is_whacked = false
	state = MoleState.RISING
	mole_sprite.show()

	var tween = create_tween()
	if not tween:
		push_error("[Mole] create_tween() failed")
		return
	tween.set_parallel(true)
	if not tween.tween_property(mole_sprite, "position:y", -30.0, rise_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT):
		push_error("[Mole] tween_property failed")

	await tween.finished
	state = MoleState.VISIBLE

	await get_tree().create_timer(visible_time).timeout
	if state == MoleState.VISIBLE and not is_whacked:
		hide_mole()

func hide_mole() -> void:
	if state == MoleState.WHACKED:
		return

	state = MoleState.HIDING
	var tween = create_tween()
	if not tween:
		push_error("[Mole] create_tween() failed in hide_mole")
		return
	tween.set_parallel(true)
	tween.tween_property(mole_sprite, "position:y", 0.0, hide_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished
	hide_mole_instant()

func whack() -> void:
	is_whacked = true
	state = MoleState.WHACKED

	spawn_explosion()

	var tween = create_tween()
	if not tween:
		push_error("[Mole] create_tween() failed in whack")
		return
	tween.set_parallel(true)
	tween.tween_property(mole_sprite, "position:y", -50.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(mole_sprite, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished
	hide_mole_instant()
	mole_whacked.emit()

func spawn_explosion() -> void:
	var explosion = Node2D.new()
	explosion.global_position = mole_sprite.global_position
	add_child(explosion)

	var colors = [Color(1, 0.5, 0, 1), Color(1, 0.8, 0, 1), Color(1, 1, 0, 1), Color(1, 0.3, 0, 1)]
	for i in 8:
		var particle = ColorRect.new()
		particle.color = colors[i % colors.size()]
		particle.size = Vector2(12, 12)
		particle.pivot_offset = Vector2(6, 6)
		explosion.add_child(particle)

		var angle = (i / 8.0) * TAU
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", Vector2(cos(angle) * 60, sin(angle) * 60), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(particle, "scale", Vector2(0.1, 0.1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.4).timeout
	explosion.queue_free()

func hide_mole_instant() -> void:
	mole_sprite.position.y = 0.0
	mole_sprite.modulate.a = 1.0
	mole_sprite.hide()
	state = MoleState.HIDDEN
	is_whacked = false

func is_mole_visible() -> bool:
	return state == MoleState.VISIBLE or state == MoleState.RISING or state == MoleState.WHACKED
