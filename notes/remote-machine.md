# Remote Machine: lldd-linux

## Connection
- **SSH**: `ssh lldd@100.92.85.48` (Tailscale IP, user `lldd`)
- **LAN IP**: 192.168.3.33 (not reachable from Mac which is on 192.168.0.x)
- **Tailscale**: 100.92.85.48 (relay DERP WH, ~85ms latency)

## System
- Ubuntu x86_64, kernel 6.17, 32GB RAM, 468GB SSD
- Tailscale node name: lldd-linux

## Docker Deployment
- **Container**: `xiaozhi-esp32-server`, image `ghcr.nju.edu.cn/xinnan-tech/xiaozhi-esp32-server:server_latest`
- **Ports**: 8000 (WebSocket), 8003 (HTTP/OTA)
- **Volume Mounts**:
  - `./data` → `/opt/xiaozhi-esp32-server/data` (config)
  - `./models/SenseVoiceSmall/model.pt` → ASR model
- **Code is baked into the image** — NOT volume-mounted. Changing code requires rebuild or adding volume mount.
- **Git bare repo**: `/home/lldd/codes/xiaozhi-server/xiaozhi-server.git` for git hook auto-deploy
- **Project dir**: `/home/lldd/codes/xiaozhi-server/`

## Current Config (data/.config.yaml)
- LLM: KimiLLM (moonshot-v1-128k)
- ASR: FunASR (local, SenseVoiceSmall)
- TTS: HuoshandDoubleStreamTTS (HAS DEADLOCK RISK — should switch to EdgeTTS)
- Memory: mem_local_short
- Prompt: Child-friendly, uses agent-base-prompt.txt template

## Known Issues
- HuoshanDoubleStreamTTS deadlock risk (partial fix, EdgeTTS recommended)
- Memory save error: `Expecting value: line 1 column 1` (JSON parse bug)
