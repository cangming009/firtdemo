# 打地鼠游戏 - 完整游戏架构实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将打地鼠游戏重构为具有主菜单、关卡选择、设置、排行榜的生产级游戏，采用 Godot 原生目录结构。

**Architecture:** 场景分离：menu/（菜单相关）/ game/（游戏逻辑）/ shared/（通用组件）。通过 MenuManager 统一管理场景切换。数据通过 ScoreManager 持久化到本地 JSON。

**Tech Stack:** Godot 4.6, GDScript, FileAccess JSON

---

## 文件映射

| 原文件 | 新路径 |
|--------|--------|
| GameManager.gd | scripts/game/GameManager.gd |
| Mole.gd | scripts/game/Mole.gd |
| Hole.gd | scripts/game/Hole.gd |
| Hole.tscn | scenes/shared/GameBoard.tscn (洞口部分) |
| main.tscn | scenes/game/Game.tscn |

---

## 任务列表

### Task 1: 创建目录结构

**Files:**
- Create: `scenes/menu/` 目录
- Create: `scenes/game/` 目录
- Create: `scenes/shared/` 目录
- Create: `scripts/menu/` 目录
- Create: `scripts/shared/` 目录
- Create: `resources/audio/` 目录
- Create: `resources/fonts/` 目录
- Create: `resources/themes/` 目录

**Steps:**
- [ ] **Step 1: 创建所有目录**

```bash
mkdir -p scenes/menu scenes/game scenes/shared scripts/menu scripts/shared resources/audio resources/fonts resources/themes
```

---

### Task 2: 创建 LevelConfig.gd（关卡配置）

**Files:**
- Create: `scripts/shared/LevelConfig.gd`

**Steps:**
- [ ] **Step 1: 编写关卡配置脚本**

```gdscript
extends RefCounted

class LevelData:
    var spawn_interval_min: float
    var spawn_interval_max: float
    var visible_time: float
    var game_duration: float

    func _init(p_min: float, p_max: float, v_time: float, duration: float) -> void:
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
```

- [ ] **Step 2: 提交**

```bash
git add scripts/shared/LevelConfig.gd && git commit -m "feat: 添加关卡配置脚本"
```

---

### Task 3: 创建 ScoreManager.gd（本地存储）

**Files:**
- Create: `scripts/shared/ScoreManager.gd`

**Steps:**
- [ ] **Step 1: 编写分数管理脚本**

```gdscript
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
```

- [ ] **Step 2: 提交**

```bash
git add scripts/shared/ScoreManager.gd && git commit -m "feat: 添加分数管理脚本（本地JSON存储）"
```

---

### Task 4: 创建 AudioManager.gd（音量管理）

**Files:**
- Create: `scripts/shared/AudioManager.gd`

**Steps:**
- [ ] **Step 1: 编写音量管理脚本**

```gdscript
extends Node

var music_vol: float = 0.8
var sfx_vol: float = 1.0

@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
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
```

- [ ] **Step 2: 提交**

```bash
git add scripts/shared/AudioManager.gd && git commit -m "feat: 添加音量管理脚本"
```

---

### Task 5: 创建 MenuManager.gd（场景切换）

**Files:**
- Create: `scripts/menu/MenuManager.gd`

**Steps:**
- [ ] **Step 1: 编写场景切换脚本**

```gdscript
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
```

- [ ] **Step 2: 提交**

```bash
git add scripts/menu/MenuManager.gd && git commit -m "feat: 添加场景切换管理脚本"
```

---

### Task 6: 创建 MainMenu.tscn + MainMenu.gd

**Files:**
- Create: `scenes/menu/MainMenu.tscn`
- Create: `scenes/menu/MainMenu.gd`

**Steps:**
- [ ] **Step 1: 编写 MainMenu.gd**

```gdscript
extends Control

@onready var start_button: Button = $VBox/StartButton
@onready var leaderboard_button: Button = $VBox/LeaderboardButton
@onready var settings_button: Button = $VBox/SettingsButton

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    leaderboard_button.pressed.connect(_on_leaderboard_pressed)
    settings_button.pressed.connect(_on_settings_pressed)

func _on_start_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_level_select()

func _on_leaderboard_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_leaderboard()

func _on_settings_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_settings()
```

- [ ] **Step 2: 在 MainMenu.tscn 中创建场景**

创建包含以下元素的 Control 节点：
- VBoxContainer（垂直居中）
  - Title: "Whack-a-Mole" 标题标签
  - StartButton: "开始游戏"
  - LeaderboardButton: "排行榜"
  - SettingsButton: "设置"

- [ ] **Step 3: 提交**

```bash
git add scenes/menu/MainMenu.tscn scenes/menu/MainMenu.gd && git commit -m "feat: 添加主菜单场景"
```

---

### Task 7: 创建 LevelSelect.tscn + LevelSelect.gd

**Files:**
- Create: `scenes/menu/LevelSelect.tscn`
- Create: `scenes/menu/LevelSelect.gd`

**Steps:**
- [ ] **Step 1: 编写 LevelSelect.gd**

```gdscript
extends Control

@onready var grid: GridContainer = $GridContainer
@onready var back_button: Button = $BackButton

var level_buttons: Array = []

func _ready() -> void:
    var sm = get_node_or_null("/root/ScoreManager")
    var unlocked = 1
    if sm:
        unlocked = sm.get_unlocked_level()
    
    for i in range(1, 10):
        var btn = Button.new()
        btn.text = "关卡 %d" % i
        if i <= unlocked:
            btn.pressed.connect(_on_level_button_pressed.bind(i))
        else:
            btn.disabled = true
            btn.modulate.a = 0.5
        grid.add_child(btn)
        level_buttons.append(btn)
    
    back_button.pressed.connect(_on_back_pressed)

func _on_level_button_pressed(level: int) -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.start_game(level)

func _on_back_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_main_menu()
```

- [ ] **Step 2: 在 LevelSelect.tscn 中创建场景**

创建包含以下元素的 Control 节点：
- 标题："选择关卡"
- GridContainer（3x3 网格）
- BackButton: "返回"

- [ ] **Step 3: 提交**

```bash
git add scenes/menu/LevelSelect.tscn scenes/menu/LevelSelect.gd && git commit -m "feat: 添加关卡选择场景"
```

---

### Task 8: 创建 Settings.tscn + Settings.gd

**Files:**
- Create: `scenes/menu/Settings.tscn`
- Create: `scenes/menu/Settings.gd`

**Steps:**
- [ ] **Step 1: 编写 Settings.gd**

```gdscript
extends Control

@onready var music_slider: HSlider = $VBox/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBox/SFXContainer/SFXSlider
@onready var back_button: Button = $BackButton

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
```

- [ ] **Step 2: 在 Settings.tscn 中创建场景**

创建包含以下元素的 Control 节点：
- VBoxContainer（垂直居中）
  - MusicContainer: HBoxContainer + Label + HSlider
  - SFXContainer: HBoxContainer + Label + HSlider
- BackButton: "返回"

- [ ] **Step 3: 提交**

```bash
git add scenes/menu/Settings.tscn scenes/menu/Settings.gd && git commit -m "feat: 添加设置页面"
```

---

### Task 9: 创建 Leaderboard.tscn + Leaderboard.gd

**Files:**
- Create: `scenes/menu/Leaderboard.tscn`
- Create: `scenes/menu/Leaderboard.gd`

**Steps:**
- [ ] **Step 1: 编写 Leaderboard.gd**

```gdscript
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
```

- [ ] **Step 2: 在 Leaderboard.tscn 中创建场景**

创建包含以下元素的 Control 节点：
- VBoxContainer（垂直居中）
  - LevelFilter: OptionButton（下拉选择关卡）
  - ScoreList: VBoxContainer（分数列表）
- BackButton: "返回"

- [ ] **Step 3: 提交**

```bash
git add scenes/menu/Leaderboard.tscn scenes/menu/Leaderboard.gd && git commit -m "feat: 添加排行榜场景"
```

---

### Task 10: 创建 Game.tscn + 迁移 GameManager.gd

**Files:**
- Create: `scenes/game/Game.tscn`
- Create: `scripts/game/GameManager.gd`（迁移+适配）
- Move: `scripts/game/Mole.gd`（从根目录移动）
- Move: `scripts/game/Hole.gd`（从根目录移动）
- Create: `scenes/shared/GameBoard.tscn`

**Steps:**
- [ ] **Step 1: 创建 Game.tscn**

场景结构：
- Root: Node2D
  - GameBoard (GameBoard.tscn instance)
  - UI (CanvasLayer)
    - ScoreLabel, TimerLabel, ComboLabel, StartButton, GameOverLabel
  - AudioHit (AudioStreamPlayer)

- [ ] **Step 2: 编写适配后的 GameManager.gd**

```gdscript
extends Node2D

enum GameState { IDLE, PLAYING, GAME_OVER }

@export var current_level: int = 1

var state: GameState = GameState.IDLE
var score: int = 0
var time_remaining: float = 0.0

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

func _on_start_button_pressed() -> void:
    var mm = get_tree().root.get_meta("menu_manager")
    mm.go_to_main_menu()
```

- [ ] **Step 3: 创建 GameBoard.tscn**

将现有 Hole.tscn 洞口网格（3x3）放入 GameBoard.tscn，作为共享游戏板。

- [ ] **Step 4: 提交**

```bash
git add scenes/game/Game.tscn scenes/shared/GameBoard.tscn scripts/game/GameManager.gd && git commit -m "feat: 创建游戏场景并迁移GameManager"
```

---

### Task 11: 修改 main.tscn（入口场景）

**Files:**
- Modify: `main.tscn`

**Steps:**
- [ ] **Step 1: 修改为自动加载 MainMenu**

将 main.tscn 的根节点设为 MainMenu，自动加载菜单场景。

- [ ] **Step 2: 提交**

```bash
git add main.tscn && git commit -m "feat: 修改入口场景为MainMenu"
```

---

### Task 12: 更新 project.godot（自动加载配置）

**Files:**
- Modify: `project.godot`

**Steps:**
- [ ] **Step 1: 添加自动加载**

在 project.godot 中添加：
```
[autoload]
ScoreManager="*res://scripts/shared/ScoreManager.gd"
AudioManager="*res://scripts/shared/AudioManager.gd"
MenuManager="*res://scripts/menu/MenuManager.gd"
LevelConfig="*res://scripts/shared/LevelConfig.gd"
```

- [ ] **Step 2: 提交**

```bash
git add project.godot && git commit -m "feat: 配置自动加载脚本"
```

---

## 验证清单

- [ ] 主菜单可正常显示并导航到其他页面
- [ ] 关卡选择显示 9 个关卡，已解锁关卡可点击
- [ ] 设置页面可调节音量
- [ ] 排行榜显示分数列表（可筛选关卡）
- [ ] 游戏场景正常加载并使用关卡配置
- [ ] 游戏结束后分数保存到本地
- [ ] 通过最后一关后解锁下一关
- [ ] 所有场景切换正常
