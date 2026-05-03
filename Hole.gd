extends Node2D

@onready var mole: Node2D = $Mole

func _ready() -> void:
	print("[Hole] _ready called")
	mole.mole_whacked.connect(_on_mole_whacked)
	print("[Hole] _ready done")

func show_mole() -> void:
	mole.show_mole()

func hide_mole() -> void:
	mole.hide_mole()

func is_mole_visible() -> bool:
	return mole.is_mole_visible()

func _on_mole_whacked() -> void:
	var mole_pos = mole.global_position
	get_parent().get_parent().add_score(10, mole_pos)
