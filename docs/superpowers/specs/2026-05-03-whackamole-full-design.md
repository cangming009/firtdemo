# 打地鼠游戏 - 完整游戏架构设计

**日期:** 2026-05-03
**状态:** 已批准

## 目标

将打地鼠游戏从单场景游戏升级为具有主菜单、关卡选择、设置、排行榜的生产级游戏，并采用正确的 Godot 目录结构。

---

## 1. 目录结构

```
firtdemo/
├── scenes/
│   ├── menu/
│   │   ├── MainMenu.tscn       # 主菜单
│   │   ├── LevelSelect.tscn    # 关卡选择
│   │   ├── Settings.tscn       # 设置页面
│   │   └── Leaderboard.tscn    # 排行榜
│   ├── game/
│   │   └── Game.tscn           # 游戏主场景
│   └── shared/
│       └── GameBoard.tscn      # 游戏板（9洞口）
├── scripts/
│   ├── game/
│   │   ├── GameManager.gd
│   │   ├── Mole.gd
│   │   └── Hole.gd
│   ├── menu/
│   │   ├── MainMenu.gd
│   │   ├── LevelSelect.gd
│   │   ├── Settings.gd
│   │   ├── Leaderboard.gd
│   │   └── MenuManager.gd
│   └── shared/
│       ├── ScoreManager.gd     # 本地存储
│       ├── AudioManager.gd     # 音量管理
│       └── LevelConfig.gd      # 关卡配置
├── resources/
│   ├── audio/
│   ├── fonts/
│   └── themes/
├── main.tscn                   # 入口 → MainMenu
└── docs/
```

---

## 2. 场景流程

```
MainMenu
  ├── "开始游戏" → LevelSelect
  │                └── 选择关卡 → Game.tscn
  │                              └── 结束 → GameOverUI → Leaderboard
  ├── "排行榜"   → Leaderboard
  └── "设置"     → Settings
```

---

## 3. 关卡配置（LevelConfig.gd）

| 关卡 | 出现间隔 | 可见时间 | 游戏时长 |
|------|---------|---------|---------|
| 1    | 1.0~2.0s | 1.5s    | 30s     |
| 2    | 1.0~2.0s | 1.5s    | 30s     |
| 3    | 1.0~2.0s | 1.5s    | 30s     |
| 4    | 0.7~1.5s | 1.2s    | 45s     |
| 5    | 0.7~1.5s | 1.2s    | 45s     |
| 6    | 0.7~1.5s | 1.2s    | 45s     |
| 7    | 0.5~1.0s | 0.8s    | 60s     |
| 8    | 0.5~1.0s | 0.8s    | 60s     |
| 9    | 0.5~1.0s | 0.8s    | 60s     |

### 解锁机制
- 通关第 N 关自动解锁第 N+1 关
- 第 1 关默认解锁

---

## 4. 分数存储（ScoreManager.gd）

**文件路径:** `user://whackamole_save.json`

**数据结构:**
```json
{
  "levels": {
    "1": [{"score": 120, "date": "2026-05-03"}, ...],
    "2": [{"score": 80, "date": "2026-05-03"}, ...]
  },
  "unlocked_level": 3,
  "settings": {
    "music_vol": 0.8,
    "sfx_vol": 1.0
  }
}
```

**最大记录数:** 每关卡保留 10 条最高分

---

## 5. 设置页面（Settings.tscn）

| 设置项 | 类型 | 默认值 |
|--------|------|--------|
| 音乐音量 | HSlider (0~1) | 0.8 |
| 音效音量 | HSlider (0~1) | 1.0 |
| 重新开始 | Button | 返回主菜单 |

---

## 6. 排行榜（Leaderboard.tscn）

**布局:** 居中列表
**显示内容:** 排名 (#1~#10)、关卡、分数、日期
**排序:** 按分数降序

---

## 7. 入口（main.tscn）

- 自动加载 `MainMenu.tscn`
- 无需保留现有游戏 UI（分数、计时器）

---

## 8. 实现顺序

1. **目录结构重构** — 创建文件夹，移动文件
2. **Shared 脚本** — ScoreManager, AudioManager, LevelConfig
3. **MenuManager** — 场景切换
4. **Menu 场景** — MainMenu, LevelSelect, Settings, Leaderboard
5. **Game 场景** — GameManager 适配新架构
6. **入口** — main.tscn → MainMenu
7. **数据迁移** — 现有分数导入新存储

---

## 9. 改动文件清单

| 文件 | 操作 |
|------|------|
| scenes/menu/* | 新建 |
| scenes/game/* | 新建（Game.tscn 继承 main.tscn 逻辑）|
| scenes/shared/* | 新建 |
| scripts/game/* | 移动 + 适配 |
| scripts/menu/* | 新建 |
| scripts/shared/* | 新建 |
| main.tscn | 修改为入口场景 |
| Hole.tscn, Mole.gd, GameManager.gd | 保留并移动 |
