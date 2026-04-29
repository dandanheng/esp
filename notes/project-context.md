# 小智 AI 儿童智能音箱 — Project Context

## Overview
- **Goal**: Build a child-friendly smart speaker for a 6-year-old boy
- **Hardware**: ESP32-S3-BOX-3 (ESP32-S3)
- **Software Stack**: ESP32 firmware (C++) + Python backend (xiaozhi-esp32-server)
- **Pipeline**: Device records audio → WebSocket → ASR → LLM → TTS → Audio back to device

## Architecture
- **Firmware**: `xiaozhi-esp32/` (ESP-IDF v5.5+, C++, state machine in application.cc)
- **Backend**: `xiaozhi-esp32-server/` (Python, providers for ASR/LLM/TTS/Memory)
- **Remote**: `lldd-linux` (Ubuntu x86_64, Docker, Tailscale 100.92.85.48)

## V1 Upgrade Plan (docs/v1-upgrade-plan.md)
- **Phase 0** (half day): Lock baseline — EdgeTTS + FunASR + SileroVAD + mem_local_short
- **Phase 1** (1-2 days): Child-friendly prompt, shorten responses, fuzzy catch
- **Phase 2** (3-5 days): Mini-games (riddles, mental math, themed Q&A)
- **Phase 3** (3-4 days): Memory improvements

## Current Status
- Basic pipeline works (ASR → LLM → TTS → device playback)
- HuoshanDoubleStreamTTS has deadlock risk (switch to EdgeTTS pending)
- Memory (mem_local_short) already enabled
- Child-friendly prompt already in data/.config.yaml
- Remote deployment: Docker on lldd-linux, code baked into image (not volume-mounted)
