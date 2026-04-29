# xiaozhi-esp32-server 处理流程文档

> 生成时间：2026-04-11

---

## 一、整体架构

```
设备 (ESP32-S3-BOX-3)
  ↓ WebSocket
后端服务 (xiaozhi-esp32-server)
  ├── VAD（语音活动检测）
  ├── ASR（语音识别）
  ├── LLM（大语言模型 + Function Call）
  ├── Tool（工具执行）
  └── TTS（文本转语音）
  ↓ WebSocket
设备播放音频
```

---

## 二、完整处理流程

```
设备说话
  ↓
① WebSocket 连接层
  ↓
② 音频接收 & 路由
  ↓
③ VAD 语音活动检测
   检测说话 / 静音，静默 >1000ms 触发识别
  ↓
④ ASR 语音识别
   Opus 解码 → PCM → 文字
  ↓
⑤ 意图识别
   判断：退出 / 唤醒 / 工具调用 / 普通对话
  ↓
⑥ LLM 调用
   携带：系统提示词 + 对话历史 + 工具列表
  ↓
⑦ 工具执行（如需要）
   并行执行，超时 30s，结果二次喂给 LLM
  ↓
⑧ TTS 合成
   文本 → Opus 音频流
  ↓
⑨ 音频发送回设备
   流控发送，60ms/帧
  ↓
设备播放
```

---

## 三、核心文件对照表

| 环节 | 文件路径 | 关键函数 / 类 |
|------|---------|--------------|
| 服务启动 | `app.py` | `main()` |
| WebSocket 服务 | `core/websocket_server.py` | `WebSocketServer`, `_handle_connection()` |
| 主控逻辑 | `core/connection.py` | `ConnectionHandler`, `chat()` (行 840) |
| 音频接收 | `core/handle/receiveAudioHandle.py` | `handleAudioMessage()`, `startToChat()` |
| VAD | `core/providers/vad/silero.py` | `VADProvider`, `is_vad()` |
| ASR | `core/providers/asr/fun_local.py` | `ASRProvider`, `speech_to_text()` |
| ASR 基类 | `core/providers/asr/base.py` | `handle_voice_stop()` |
| 意图识别 | `core/handle/intentHandler.py` | `handle_user_intent()` |
| LLM（OpenAI兼容） | `core/providers/llm/openai/openai.py` | `response()`, `response_with_functions()` |
| 工具管理器 | `core/providers/tools/unified_tool_manager.py` | `ToolManager`, `get_all_tools()` |
| 工具执行器 | `core/providers/tools/unified_tool_handler.py` | `UnifiedToolHandler` |
| TTS | `core/providers/tts/edge.py` | `TTSProvider`, `text_to_speak()` |
| TTS 基类 | `core/providers/tts/base.py` | `TTSProviderBase`, `to_tts_stream()` |
| 音频发送 | `core/handle/sendAudioHandle.py` | `sendAudioMessage()`, `sendAudio()` |
| 模块初始化 | `core/utils/modules_initialize.py` | `initialize_modules()` |
| 对话历史 | `core/utils/dialogue.py` | `Dialogue`, `Message` |

---

## 四、文本消息处理器

设备发来的文本消息按类型路由到不同处理器：

| 消息类型 | 处理文件 | 说明 |
|---------|---------|------|
| `hello` | `core/handle/textHandler/helloMessageHandler.py` | 连接初始化，发送欢迎语 |
| `listen` | `core/handle/textHandler/listenMessageHandler.py` | 监听模式开关 |
| `iot` | `core/handle/textHandler/iotMessageHandler.py` | IoT 设备控制 |
| `mcp` | `core/handle/textHandler/mcpMessageHandler.py` | MCP 协议消息（设备上报工具列表） |
| `ping` | `core/handle/textHandler/pingMessageHandler.py` | 心跳检测 |
| `abort` | `core/handle/textHandler/abortMessageHandler.py` | 中止当前交互 |

---

## 五、工具执行体系

LLM 通过 Function Call 触发工具执行，支持 5 类执行器：

```
UnifiedToolHandler
  ├── ServerPluginExecutor   本地插件（天气、新闻、音乐等）
  ├── ServerMCPExecutor      服务端 MCP 工具
  ├── DeviceIoTExecutor      IoT 设备控制
  ├── DeviceMCPExecutor      设备端 MCP 工具（音量、亮度、主题）
  └── MCPEndpointExecutor    远程 MCP 接入点
```

**当前设备（BOX-3）支持的工具：**

| 工具名 | 功能 |
|--------|------|
| `self.get_device_status` | 查询设备状态（音量/屏幕/电量/网络） |
| `self.audio_speaker.set_volume` | 设置音量（0-100） |
| `self.screen.set_brightness` | 设置屏幕亮度（0-100） |
| `self.screen.set_theme` | 切换主题（light / dark） |
| `get_weather` | 查询天气 |
| `play_music` | 播放音乐 |
| `get_news_from_newsnow` | 获取新闻 |
| `change_role` | 切换角色 |
| `get_lunar` | 获取农历 |
| `handle_exit_intent` | 退出对话 |

---

## 六、当前配置

```yaml
LLM:    Kimi（moonshot-v1-8k）
ASR:    FunASR（SenseVoiceSmall，本地）
TTS:    EdgeTTS（zh-CN-XiaoxiaoNeural，远程）
VAD:    SileroVAD（本地 ONNX）
```

---

## 七、关键参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| WebSocket 端口 | `8000` | 设备连接地址 |
| HTTP 端口 | `8003` | OTA 接口地址 |
| 静默超时 | `1000ms` | 触发 ASR 识别 |
| 无语音断连 | `120s` | 无交互自动断开 |
| 工具调用超时 | `30s` | 单个工具最长执行时间 |
| TTS 超时 | `15s` | 合成超时时间 |
| 音频帧时长 | `60ms` | 发送节奏控制 |
| 预缓冲包数 | `5` | 前 5 包直接发送 |
| LLM 递归深度 | `5` | Function Call 最大递归次数 |

---

## 八、后端服务地址（本机）

| 接口 | 地址 |
|------|------|
| WebSocket | `ws://192.168.3.112:8000/xiaozhi/v1/` |
| OTA | `http://192.168.3.112:8003/xiaozhi/ota/` |
| 视觉分析 | `http://192.168.3.112:8003/mcp/vision/explain` |

---

## 九、启动命令

```bash
cd /Users/lldd/codes/esp/xiaozhi-esp32-server/main/xiaozhi-server
source venv/bin/activate
python app.py
```
