extends Control

@onready var score_list: VBoxContainer = $VBox/ScoreList
@onready var level_filter: OptionButton = $VBox/LevelFilter
@onready var back_button: Button = $BackButton

var current_level: int = 0

func _ready() -> void:
    level_filter.add_item("全部关卡", 0)
    for i in range(1, 10):
        level_filter.add_item("关卡 %d" % i, i)
    level_filter.item_selected.connect(_on_level_selected)
    back_button.pressed.connect(_on_back_pressed)
    _on_level_selected(0)

func _on_level_selected(index: int) -> void:
    current_level = index
    _refresh_list()

func _refresh_list() -> void:
    for child in score_list.get_children():
        child.queue_free()

    var sm = get_node_or_null("/root/ScoreManager")
    if not sm:
        return

    var scores: Array
    if current_level == 0:
        scores = _get_all_scores(sm)
    else:
        scores = sm.get_scores(current_level)

    var rank = 1
    for entry in scores:
        var row = HBoxContainer.new()

        var rank_label = Label.new()
        rank_label.text = "#%d" % rank
        rank_label.custom_minimum_size.x = 50
        row.add_child(rank_label)

        var level_label = Label.new()
        level_label.text = "L%d" % current_level if current_level > 0 else "All"
        level_label.custom_minimum_size.x = 50
        row.add_child(level_label)

        var score_label = Label.new()
        score_label.text = str(entry["score"])
        score_label.custom_minimum_size.x = 80
        row.add_child(score_label)

        var date_label = Label.new()
        date_label.text = entry["date"]
        row.add_child(date_label)

        score_list.add_child(row)
        rank += 1

func _get_all_scores(sm) -> Array:
    var all_scores: Array = []
    for i in range(1, 10):
        var level_scores = sm.get_scores(i)
        for entry in level_scores:
            entry["level"] = i
            all_scores.append(entry)
    all_scores.sort_custom(func(a, b): return a["score"] > b["score"])
    if all_scores.size() > 20:
        all_scores.resize(20)
    return all_scores

func _on_back_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_main_menu()
