# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Engine**: Godot 4.6 (GL Compatibility renderer, D3D12 on Windows)
**Type**: Whack-a-mole game
**Main scene**: `res://main.tscn`

## Running the Game

```bash
# Via Godot CLI (ensure GODOT_PATH is set to your Godot executable)
godot --path C:/Users/admin/Documents/game/firtdemo --editor

# Or run directly
godot --path C:/Users/admin/Documents/game/firtdemo
```

## Architecture

```
main.tscn (GameManager)
├── GameField (Node2D)
│   ├── Hole1–Hole9 (each is Hole.tscn instance)
│   └── 9 holes arranged in a 3×3 grid at (120,100) + offsets
├── UI (CanvasLayer)
│   ├── ScoreLabel, TimerLabel, StartButton, GameOverLabel
│   └── AudioHit (AudioStreamPlayer)
└── GameManager.gd — game state machine, spawning logic, scoring
```

**State flow**: `IDLE → PLAYING → GAME_OVER` (via `GameManager`)

### Key Scripts

| File | Responsibility |
|------|----------------|
| `GameManager.gd` | Game state, timer management, random mole spawning, score tracking |
| `Hole.gd` / `Hole.tscn` | Wrapper around a single mole; emits `mole_whacked` up to GameManager |
| `Mole.gd` | Individual mole state machine (`HIDDEN → RISING → VISIBLE → HIDING/WHACKED`), tweens for animation |

### Mole State Machine (Mole.gd)

```
HIDDEN ──show_mole()──▶ RISING ──tween done──▶ VISIBLE ──timer──▶ HIDING ──tween done──▶ HIDDEN
                            │                      │
                            │                      └──whack()──▶ WHACKED ──tween done──▶ HIDDEN
                            └─ can be whacked in VISIBLE state
```

## Godot API 版本约束

**必须使用 Godot 4.6 API** — 本项目使用 GL Compatibility 渲染器，Target Godot 4.6。

常见版本不匹配问题：

| 场景 | 错误写法（Godot 3.x / 其他版本） | 正确写法（Godot 4.6） |
|------|--------------------------------|---------------------|
| Tween 过渡类型 | `EASE_OUT`（这是 `EaseType`） | `Tween.TransitionType.TRANS_EASE_OUT` |
| Input 检测 | `Input.action_pressed("ui_accept")`（4.3+） | `Input.is_action_pressed("ui_accept")` |
| 信号连接 | `obj.connect("signal", self, "method")` | `obj.signal.connect(method.bind())` |
| 节点路径 | `"node_path"` 普通字符串 | 优先用 `StringName("node_path")` |

如果遇到 `Invalid call` 或 `Method not found` 错误，先查 Godot 4.6 API 文档确认方法名。

## Tween 常量说明

Godot 4 的 `TransitionType` 枚举使用 `TRANS_*` 前缀，例如 `Tween.TransitionType.TRANS_EASE_OUT`。单独使用 `EASE_OUT`/`EASE_IN` 是错的——那是 `EaseType` 枚举的值。`Mole.gd` 第 38、54、65、66 行已修正为此格式。

## 项目结构

```
firtdemo/
├── main.tscn          # Main scene (game board + UI)
├── GameManager.gd     # Game logic script
├── Hole.tscn/.gd      # Mole hole container scene
├── Mole.gd            # Individual mole logic + animation
├── hit.wav            # Sound effect on whack
├── icon.svg           # Project icon
└── project.godot      # Godot 4.6 project config
```
