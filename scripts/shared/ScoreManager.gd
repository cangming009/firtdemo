extends Node

const SAVE_FILE := "user://whackamole_save.json"
const MAX_SCORES_PER_LEVEL := 10

var save_data: Dictionary = {
    "levels": {},
    "unlocked_level": 1,
    "settings": {"music_vol": 0.8, "sfx_vol": 1.0}
}

func _ready() -> void:
    load_data()

func load_data() -> void:
    if FileAccess.file_exists(SAVE_FILE):
        var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
        if file:
            var json_str = file.get_as_text()
            file.close()
            var json = JSON.new()
            if json.parse(json_str) == OK:
                save_data = json.data
    else:
        for i in range(1, 10):
            save_data["levels"][str(i)] = []

func save_data_to_file() -> void:
    var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    if file:
        var json_str = JSON.stringify(save_data)
        file.store_string(json_str)
        file.close()

func add_score(level: int, score: int) -> void:
    var level_str = str(level)
    if not save_data["levels"].has(level_str):
        save_data["levels"][level_str] = []

    var scores = save_data["levels"][level_str]
    scores.append({"score": score, "date": Time.get_datetime_string_from_system()})
    scores.sort_custom(func(a, b): return a["score"] > b["score"])
    if scores.size() > MAX_SCORES_PER_LEVEL:
        scores.resize(MAX_SCORES_PER_LEVEL)
    save_data["levels"][level_str] = scores
    save_data_to_file()

func get_scores(level: int) -> Array:
    var level_str = str(level)
    if save_data["levels"].has(level_str):
        return save_data["levels"][level_str]
    return []

func get_unlocked_level() -> int:
    return save_data.get("unlocked_level", 1)

func unlock_next_level() -> void:
    var current = save_data.get("unlocked_level", 1)
    if current < 9:
        save_data["unlocked_level"] = current + 1
        save_data_to_file()

func set_music_vol(vol: float) -> void:
    save_data["settings"]["music_vol"] = vol
    save_data_to_file()

func set_sfx_vol(vol: float) -> void:
    save_data["settings"]["sfx_vol"] = vol
    save_data_to_file()

func get_music_vol() -> float:
    return save_data["settings"].get("music_vol", 0.8)

func get_sfx_vol() -> float:
    return save_data["settings"].get("sfx_vol", 1.0)
