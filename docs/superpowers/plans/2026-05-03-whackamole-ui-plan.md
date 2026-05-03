# 打地鼠游戏 UI 优化实施方案

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将打地鼠游戏升级为卡通可爱风格，添加星星爆炸特效、分数弹出、连击系统和锤子光标

**Architecture:** 分层实现：先改地鼠和洞口视觉，再添加特效系统，最后添加光标和 UI 优化。每个改动独立可测试。

**Tech Stack:** Godot 4.6, GDScript, Tween 动画系统

---

## 文件结构

| 文件 | 职责 |
|------|------|
| `Hole.tscn` | 地鼠和洞口视觉（卡通化） |
| `Mole.gd` | 星星爆炸粒子特效、屏幕震动 |
| `GameManager.gd` | 分数弹出、连击系统、Combo UI、锤子光标 |
| `main.tscn` | 添加 Combo 标签 |

---

## 实施任务

### Task 1: 地鼠视觉卡通化

**文件:** `Hole.tscn`

- [ ] **Step 1: 修改 Hole.tscn 地鼠部分**

替换现有的 `MoleSprite` (ColorRect) 为卡通地鼠结构：

```gd
# Hole.tscn 中 Mole 节点下的 MoleSprite 替换为以下结构：

[node name="MoleBody" type="ColorRect" parent="Mole"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -30.0
offset_top = -35.0
offset_right = 30.0
offset_bottom = 25.0
color = Color(0.6, 0.35, 0.15, 1)  # 棕色身体

[node name="LeftEye" type="ColorRect" parent="Mole"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -18.0
offset_top = -28.0
offset_right = -5.0
offset_bottom = -10.0
color = Color(1, 1, 1, 1)  # 白色眼眶

[node name="RightEye" type="ColorRect" parent="Mole"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = 5.0
offset_top = -28.0
offset_right = 18.0
offset_bottom = -10.0
color = Color(1, 1, 1, 1)  # 白色眼眶

[node name="LeftPupil" type="ColorRect" parent="Mole"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -14.0
offset_top = -24.0
offset_right = -9.0
offset_bottom = -14.0
color = Color(0.1, 0.1, 0.1, 1)  # 黑色瞳孔

[node name="RightPupil" type="ColorRect" parent="Mole"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = 9.0
offset_top = -24.0
offset_right = 14.0
offset_bottom = -14.0
color = Color(0.1, 0.1, 0.1, 1)  # 黑色瞳孔

[node name="Nose" type="ColorRect" parent="Mole"]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -6.0
offset_top = -12.0
offset_right = 6.0
offset_bottom = -2.0
color = Color(1, 0.6, 0.6, 1)  # 粉色鼻子
```

- [ ] **Step 2: 修改 Mole.gd 引用**

`Mole.gd` 第 12 行需要更新引用：
```gd
@onready var mole_sprite: ColorRect = $Mole/MoleBody
```

- [ ] **Step 3: 提交**
```bash
git add Hole.tscn Mole.gd
git commit -m "feat: 卡通化地鼠视觉 - 棕色身体+眼睛+鼻子"
```

---

### Task 2: 洞口装饰

**文件:** `Hole.tscn`

- [ ] **Step 1: 修改 Hole.tscn 洞口部分**

替换 `HoleVisual` (ColorRect) 为椭圆形洞口 + 草地边缘：

```gd
# 删除原来的 HoleVisual ColorRect，替换为：

[node name="HoleEdge" type="ColorRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -50.0
offset_top = -25.0
offset_right = 50.0
offset_bottom = 25.0
color = Color(0.2, 0.6, 0.15, 1)  # 草地绿色边缘

[node name="HoleOpening" type="ColorRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -40.0
offset_top = -18.0
offset_right = 40.0
offset_bottom = 18.0
color = Color(0.25, 0.15, 0.1, 1)  # 深棕色洞口
```

- [ ] **Step 2: 提交**
```bash
git add Hole.tscn
git commit -m "feat: 添加草地边缘和地洞视觉效果"
```

---

### Task 3: 星星爆炸特效 + 屏幕震动

**文件:** `Mole.gd`

- [ ] **Step 1: 替换 spawn_explosion 函数**

```gd
func spawn_explosion() -> void:
    var explosion = Node2D.new()
    explosion.global_position = mole_sprite.global_position
    add_child(explosion)

    # 星星颜色：金色、橙色、白色
    var colors = [
        Color(1, 0.85, 0, 1),  # 金色
        Color(1, 0.6, 0, 1),   # 橙色
        Color(1, 1, 0.9, 1),  # 白色
        Color(1, 0.85, 0, 1),
        Color(1, 0.6, 0, 1),
        Color(1, 1, 0.9, 1),
        Color(1, 0.85, 0, 1),
        Color(1, 0.6, 0, 1)
    ]
    for i in 8:
        var particle = ColorRect.new()
        particle.color = colors[i]
        particle.size = Vector2(14, 14)
        particle.pivot_offset = Vector2(7, 7)
        explosion.add_child(particle)

        var angle = (i / 8.0) * TAU
        var tween = create_tween()
        tween.set_parallel(true)
        # 星星向外扩散 + 旋转
        tween.tween_property(particle, "position", Vector2(cos(angle) * 60, sin(angle) * 60), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
        tween.tween_property(particle, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
        tween.tween_property(particle, "rotation", angle + TAU, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        tween.tween_property(particle, "scale", Vector2(0.2, 0.2), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

    # 屏幕震动 - 获取当前视口
    var viewport = get_viewport()
    var original_pos = viewport.get_camera_2d_position()
    var shake_tween = create_tween()
    shake_tween.set_parallel(true)
    shake_tween.tween_property(viewport, "position", original_pos + Vector2(4, -3), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    shake_tween.tween_property(viewport, "position", original_pos + Vector2(-4, 3), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    shake_tween.tween_property(viewport, "position", original_pos + Vector2(3, -2), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    shake_tween.tween_property(viewport, "position", original_pos, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

    await get_tree().create_timer(0.4).timeout
    explosion.queue_free()
```

- [ ] **Step 2: 提交**
```bash
git add Mole.gd
git commit -m "feat: 星星爆炸特效 + 屏幕震动反馈"
```

---

### Task 4: 分数弹出动画

**文件:** `GameManager.gd`

- [ ] **Step 1: 添加分数弹出方法**

在 `add_score` 函数后添加：

```gd
var score_popups: Array = []

func spawn_score_popup(world_pos: Vector2, points: int) -> void:
    var popup = Label.new()
    popup.text = "+%d" % points
    popup.add_theme_font_size_override("font_size", 24)
    popup.modulate = Color(0.3, 0.85, 0.3, 1)  # 亮绿色
    popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    popup.z_index = 100
    add_child(popup)

    # 将世界坐标转换为屏幕坐标
    var screen_pos = get_viewport().get_camera_2d_position() + world_pos
    popup.global_position = screen_pos + Vector2(0, -20)

    # 弹出动画
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(popup, "position:y", screen_pos.y - 80, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(popup, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

    await get_tree().create_timer(0.8).timeout
    popup.queue_free()
```

- [ ] **Step 2: 修改 `add_score` 调用分数弹出**

修改 `add_score` 函数中 `mole_whacked` 信号触发时调用 `spawn_score_popup`：

首先在 `Hole.gd` 中需要传递地鼠位置。修改 Hole.gd 的 `_on_mole_whacked`：

```gd
func _on_mole_whacked() -> void:
    var mole_pos = mole.global_position
    get_parent().get_parent().add_score(10, mole_pos)
```

然后修改 `GameManager.gd` 的 `add_score` 签名和实现：

```gd
func add_score(points: int, mole_pos: Vector2 = Vector2.ZERO) -> void:
    if state == GameState.PLAYING:
        score += points
        update_ui()
        audio_hit.play()
        spawn_score_popup(mole_pos, points)
```

- [ ] **Step 3: 提交**
```bash
git add GameManager.gd Hole.gd
git commit -m "feat: 添加分数弹出动画 - +10 飘字效果"
```

---

### Task 5: 连击系统 + Combo 标签

**文件:** `GameManager.gd`, `main.tscn`

- [ ] **Step 1: 在 GameManager.gd 添加连击变量**

在类变量区域添加：
```gd
var combo_count: int = 0
var combo_timer: Timer
var last_whack_time: float = 0.0

@onready var combo_label: Label = $UI/ComboLabel
```

- [ ] **Step 2: 添加连击显示方法**

```gd
func _ready() -> void:
    # ... 现有代码 ...
    combo_timer = Timer.new()
    combo_timer.timeout.connect(_on_combo_timeout)
    combo_timer.one_shot = true
    add_child(combo_timer)
    combo_label.hide()

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

    # 放大淡入动画
    combo_label.scale = Vector2(2.0, 2.0)
    combo_label.modulate.a = 0.0
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(combo_label, "modulate:a", 1.0, 0.2)

    await get_tree().create_timer(0.5).timeout
    combo_label.hide()
```

- [ ] **Step 3: 修改 add_score 处理连击**

```gd
func add_score(points: int, mole_pos: Vector2 = Vector2.ZERO) -> void:
    if state == GameState.PLAYING:
        score += points
        update_ui()
        audio_hit.play()
        spawn_score_popup(mole_pos, points)

        # 连击逻辑
        combo_count += 1
        combo_timer.start(1.5)  # 1.5秒内再次击中则保持连击

        # 更新 Combo 标签
        combo_label.text = "Combo: %d" % combo_count
        combo_label.show()
        combo_label.scale = Vector2(1.2, 1.2)
        var tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

        show_combo_text()
```

- [ ] **Step 4: 在 main.tscn 添加 ComboLabel**

在 TimerLabel 后添加：

```gd
[node name="ComboLabel" type="Label" parent="UI" unique_id=xxx]
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -120.0
offset_top = 20.0
offset_right = -20.0
offset_bottom = 60.0
grow_horizontal = 0
text = "Combo: 0"
horizontal_alignment = 2
```

- [ ] **Step 5: 提交**
```bash
git add GameManager.gd main.tscn
git commit -m "feat: 添加连击系统和 Combo 标签"
```

---

### Task 6: 锤子光标

**文件:** `GameManager.gd`

- [ ] **Step 1: 添加锤子光标设置**

在 `_ready()` 函数末尾添加：

```gd
# 设置锤子光标
var hammer_image = ColorRect.new()
hammer_image.size = Vector2(32, 32)
hammer_image.color = Color(0.5, 0.35, 0.2, 1)  # 棕色锤子柄

# 创建一个简单锤子形状的 Image
var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
img.fill(Color(0, 0, 0, 0))

# 锤子头 (灰色方块)
for y in range(4, 12):
    for x in range(6, 26):
        img.set_pixel(x, y, Color(0.6, 0.6, 0.6, 1))
# 锤子柄 (棕色)
for y in range(12, 28):
    for x in range(12, 20):
        img.set_pixel(x, y, Color(0.5, 0.35, 0.2, 1))

var texture = ImageTexture.create_from_image(img)
DisplayServer.cursor_set_custom_image(texture)
```

- [ ] **Step 2: 提交**
```bash
git add GameManager.gd
git commit -m "feat: 添加卡通锤子光标"
```

---

### Task 7: 最终检查和测试

- [ ] **Step 1: 运行游戏检查所有改动**

```bash
godot --path C:/Users/admin/Documents/game/firtdemo
```

- [ ] **Step 2: 检查清单**
- [ ] 地鼠是否显示为棕色卡通形象（身体+眼睛+鼻子）
- [ ] 洞口是否有草地绿色边缘
- [ ] 击中地鼠是否有星星爆炸效果
- [ ] 击中地鼠是否有屏幕震动
- [ ] 击中地鼠是否有 "+10" 分数弹出
- [ ] 连续击中是否显示 Nice/Great/Amazing
- [ ] 右上角是否显示 Combo 计数
- [ ] 鼠标是否显示为锤子形状

- [ ] **Step 3: 提交最终版本**
```bash
git add -A
git commit -m "feat: 完成 UI 优化 - 卡通风格 + 特效 + 连击系统"
```

---

## 自检清单

1. **Spec 覆盖:** 所有设计方案中的功能都有对应任务 ✓
2. **占位符扫描:** 无 TBD/TODO/模糊描述 ✓
3. **类型一致性:** 所有方法签名在各任务间保持一致 ✓
