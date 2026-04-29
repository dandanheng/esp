# 儿童智能音箱项目 - 工作上下文

## 目标
基于 ESP32-S3-BOX-3 硬件，构建一个儿童智能音箱：
- 使用高质量 LLM（Claude/GPT-4/Qwen-Max 等）
- 自定义儿童专属系统提示词（内容过滤、说话风格）
- 自定义 TTS 音色（儿童友好）
- 后期扩展 Agent（讲故事、天气、家长控制等）

---

## 硬件
- **设备**：乐鑫 ESP32-S3-BOX-3
- **连接**：USB-C 连接 Mac，识别为 `/dev/cu.usbmodem1201`
- **系统**：Mac M2（ARM64）

---

## 架构方案

```
ESP32-S3-BOX-3
    ↓ WebSocket
xiaozhi-esp32-server（自建后端，运行在 Mac 本地或服务器）
    ↓ API
LLM（自选模型） + TTS（自选音色） + ASR（FunASR 本地）
```

设备端固件：**xiaozhi-esp32**（开源，改 OTA 地址后编译刷入）
后端服务：**xiaozhi-esp32-server**（Python 版，xinnan-tech 出品）

---

## 代码目录
```
/Users/lldd/codes/esp/
├── xiaozhi-esp32/          # 设备端固件（已 clone）
├── xiaozhi-esp32-server/   # 后端服务（已 clone）
└── PROJECT_CONTEXT.md      # 本文件
```

---

## 当前进度

### 已完成
- [x] 了解 esp-box、xiaozhi-esp32、esp_xiaozhi 组件的区别
- [x] 在 xiaozhi.me 注册账号
- [x] 刷入官方小智固件，体验验证（结论：模型差、无法定制提示词和音色）
- [x] 确定方案：自建后端 + 重编译固件
- [x] 安装 VS Code + ESP-IDF 插件 + ESP-IDF v5.4
- [x] clone xiaozhi-esp32 固件项目
- [x] clone xiaozhi-esp32-server 后端项目
- [x] 安装 pyenv，安装 Python 3.10.14（后端要求 3.10）
- [x] ffmpeg 和 opus 已通过 Homebrew 安装

### 待完成
- [ ] **后端**：创建 `data/.config.yaml`，配置 LLM API Key、IP、TTS
- [ ] **后端**：`pip install -r requirements.txt`（含 torch，体积较大）
- [ ] **后端**：下载 FunASR 语音识别模型文件（SenseVoiceSmall）
- [ ] **后端**：启动服务，确认 OTA 地址和 WebSocket 地址
- [ ] **固件**：修改 `main/Kconfig.projbuild` 第5行 OTA 地址
- [ ] **固件**：在 VS Code 中编译，选择目标芯片 esp32s3
- [ ] **固件**：刷入设备，验证设备连接自建后端

---

## 关键文件

### 固件 OTA 地址配置
```
文件：/Users/lldd/codes/esp/xiaozhi-esp32/main/Kconfig.projbuild
第5行：default "https://api.tenclass.net/xiaozhi/ota/"
改为：default "http://你的局域网IP:8003/xiaozhi/ota/"
```

### 后端配置文件
```
文件：/Users/lldd/codes/esp/xiaozhi-esp32-server/main/xiaozhi-server/data/.config.yaml
需要配置：server.ip、server.websocket、LLM API Key、TTS 配置
```

### 后端启动
```bash
cd /Users/lldd/codes/esp/xiaozhi-esp32-server/main/xiaozhi-server
python3 app.py
```

---

## 环境信息
- Mac M2（ARM64），macOS
- Python 3.10.14（通过 pyenv 管理，项目目录已设置 local）
- Python 3.12 / 3.14 系统默认（不用于此项目）
- Homebrew 已安装：ffmpeg、opus、pyenv
- ESP-IDF v5.4（VS Code 插件安装）
- OpenOCD 配置：ESP32-S3 chip (via builtin USB-JTAG)

---

## 技术说明

### 为什么不用 Docker？
xiaozhi-esp32-server Docker 镜像从 v0.8.2 起只支持 x86，M2 是 ARM64，不兼容。

### 为什么不用 esp_xiaozhi 组件？
esp_xiaozhi 是乐鑫官方组件，只连 xiaozhi.me 官方服务，无配套自建后端，且需要写 C 代码。

### 为什么不用 Go 版后端？
两个 Go 版本（AnimeAIChat/xiaozhi-server-go、hackers365/xiaozhi-esp32-server-golang）
Star 数分别为 420 和 261，远低于 Python 版（9214），文档少，功能不完整。
