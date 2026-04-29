# 小智 (xiaozhi) 项目架构

## 概述
开源 AI 语音助手项目，目标是做儿童智能音箱。端到端方案：ESP32 录音 → WebSocket 推流 → 后端 ASR/LLM/TTS → 音频回播放。

## 目录结构
- `xiaozhi-esp32/` — ESP32 固件（C++，ESP-IDF v5.5+），版本 2.2.5
- `xiaozhi-esp32-server/` — Python 后端服务
- `esp-idf/` — ESP-IDF 框架

## 固件核心 (xiaozhi-esp32/main/)
- `main.cc` → `application.cc` — 入口和核心状态机
- `audio/` — 音频编解码（ES83xx系列）、唤醒词、AFE
- `display/` — LVGL LCD/OLED 显示，表情动画
- `protocols/` — WebSocket（主）+ MQTT（备）
- `boards/` — 96+ 开发板配置
- `led/` — LED 控制
- `mcp_server.cc` — MCP 协议支持
- `ota.cc` — OTA 固件升级
- 设备状态：Starting → WiFiConfig → Idle → Connecting → Listening → Speaking → Upgrading

## 后端核心 (xiaozhi-esp32-server/main/xiaozhi-server/)
- `app.py` — 入口
- `config.yaml` — 主配置（56KB）
- `core/` — WebSocket/HTTP 服务器
- `core/providers/` — ASR 10+、LLM 10+、TTS 15+ 提供商
- `plugins_func/` — 功能插件（天气、新闻、音乐、HA 等）
- `models/` — 本地 ASR/VAD 模型

## 关键配置
- OTA: `http://192.168.3.33:8003`
- 自定义分区表：8MB/16MB Flash
- 60+ IDF 组件依赖
- 支持 30+ 语言
