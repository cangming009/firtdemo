extends Node

class LevelData:
    var spawn_interval_min: float
    var spawn_interval_max: float
    var visible_time: float
    var game_duration: float

    func _init(p_min: float = 1.0, p_max: float = 2.0, v_time: float = 1.5, duration: float = 30.0) -> void:
        spawn_interval_min = p_min
        spawn_interval_max = p_max
        visible_time = v_time
        game_duration = duration

static func get_level_config(level: int) -> LevelData:
    match level:
        1: return LevelData.new(1.0, 2.0, 1.5, 30.0)
        2: return LevelData.new(1.0, 2.0, 1.5, 30.0)
        3: return LevelData.new(1.0, 2.0, 1.5, 30.0)
        4: return LevelData.new(0.7, 1.5, 1.2, 45.0)
        5: return LevelData.new(0.7, 1.5, 1.2, 45.0)
        6: return LevelData.new(0.7, 1.5, 1.2, 45.0)
        7: return LevelData.new(0.5, 1.0, 0.8, 60.0)
        8: return LevelData.new(0.5, 1.0, 0.8, 60.0)
        9: return LevelData.new(0.5, 1.0, 0.8, 60.0)
        _: return LevelData.new(1.0, 2.0, 1.5, 30.0)

static func get_total_levels() -> int:
    return 9
