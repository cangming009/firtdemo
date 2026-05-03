extends Node

var music_vol: float = 0.8
var sfx_vol: float = 1.0

var sfx_player: AudioStreamPlayer

func _ready() -> void:
    sfx_player = AudioStreamPlayer.new()
    sfx_player.name = "SFXPlayer"
    add_child(sfx_player)

    var sm = get_node_or_null("/root/ScoreManager")
    if sm:
        music_vol = sm.get_music_vol()
        sfx_vol = sm.get_sfx_vol()

func play_sfx(stream: AudioStream) -> void:
    if sfx_player and stream:
        sfx_player.stream = stream
        sfx_player.volume_db = linear_to_db(sfx_vol)
        sfx_player.play()

func set_sfx_volume(vol: float) -> void:
    sfx_vol = vol
    var sm = get_node_or_null("/root/ScoreManager")
    if sm:
        sm.set_sfx_vol(vol)
