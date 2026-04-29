# ESP 儿童智能音箱项目

基于 ESP32-S3-BOX-3 硬件构建的儿童智能音箱，使用小智开源方案（xiaozhi-esp32）自建后端，支持自定义 LLM、TTS 音色和系统提示词。

## 架构

```
ESP32-S3-BOX-3 (设备端)
    ↓ WebSocket
xiaozhi-esp32-server (自建后端)
    ↓ API
LLM (Claude / GPT-4 / Qwen / Kimi) + TTS + ASR (SenseVoiceSmall)
```

## 仓库结构

本仓库采用 **Git 子模块**管理三个独立项目：

| 目录 | 说明 | 远程仓库 |
|------|------|----------|
| `esp-idf/` | 乐鑫官方开发框架 (v5.5.2) | [espressif/esp-idf](https://github.com/espressif/esp-idf) |
| `xiaozhi-esp32/` | 设备端固件（含本地修改） | [dandanheng/xiaozhi-esp32](https://github.com/dandanheng/xiaozhi-esp32) |
| `xiaozhi-esp32-server/` | Python 后端服务 | [dandanheng/xiaozhi-esp32-server](https://github.com/dandanheng/xiaozhi-esp32-server) |
| `docs/` | 项目升级规划文档 | — |
| `notes/` | 开发笔记与记录 | — |

> 子模块保留了各自的 Git 历史，可独立更新、提交和推送。

## 快速开始

### 克隆

```bash
# 方式一：一步克隆所有子模块
git clone --recurse-submodules https://github.com/dandanheng/esp.git

# 方式二：先克隆主仓库，再拉子模块
git clone https://github.com/dandanheng/esp.git
cd esp
git submodule update --init --recursive
```

### 后端启动

```bash
cd xiaozhi-esp32-server/main/xiaozhi-server
source venv/bin/activate
python app.py
```

### 固件编译与烧录

使用 VS Code + ESP-IDF 插件打开 `xiaozhi-esp32/`，选择目标芯片 `esp32s3` 编译并烧录。

## 技术栈

| 组件 | 选型 |
|------|------|
| **设备** | ESP32-S3-BOX-3 |
| **固件** | xiaozhi-esp32 (开源) |
| **后端** | xiaozhi-esp32-server (Python) |
| **LLM** | Kimi (moonshot-v1-8k) |
| **ASR** | FunASR (SenseVoiceSmall，本地) |
| **TTS** | EdgeTTS (zh-CN-XiaoxiaoNeural) |
| **VAD** | SileroVAD (本地 ONNX) |

## 子模块常用操作

```bash
# 更新所有子模块到各自远程最新版
git submodule update --remote

# 更新单个子模块
git submodule update --remote xiaozhi-esp32-server

# 进入子模块改代码（和正常 Git 仓库一样）
cd xiaozhi-esp32
git add .
git commit -m "fix: xxx"
git push origin main

# 回到主仓库，记录子模块版本变更
cd ..
git add xiaozhi-esp32
git commit -m "update: 同步 xiaozhi-esp32 到最新提交"
git push origin main
```

## 大文件排除说明

以下文件/目录已排除在版本控制之外，需自行准备：

- `venv/` — Python 虚拟环境（通过 `pip install -r requirements.txt` 重建）
- `build/` — ESP32 编译产物
- `models/SenseVoiceSmall/model.pt` — ASR 模型文件（~893MB，需单独下载）
- `*.cmo3` — Live2D 测试模型资源

## 环境要求

- macOS (ARM64) / Linux
- Python 3.10
- ESP-IDF v5.4+
- Homebrew: `ffmpeg`, `opus`

## 文档索引

- [项目上下文](PROJECT_CONTEXT.md) — 目标、硬件、架构、进度
- [后端处理流程](PROJECT_PIPELINE.md) — VAD/ASR/LLM/TTS 完整链路
- [升级规划](docs/v1-upgrade-plan.md) — v1 到 v2 迁移计划
