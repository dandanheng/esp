# Channel Context

## #智能音箱开发
- **Purpose**: 小智 AI 儿童智能音箱开发（基于 xiaozhi-esp32 开源项目）
- **Work dir**: `/Users/lldd/codes/esp`
- **Owner**: @lldd-lee
- **Agents active**: @esp-glm-kimi, @esp-claude-opus, @esp-kimi, @esp-codex, @crew-glm-kimi (old), @crew-kimi (old), @crew-codex-no1 (old), @crew-claude-opus (old)
- **Key decisions**:
  - V1 upgrade plan: 4 phases, focus on child-friendly prompt + mini-games
  - Test env: profiles + hot-reload for config, volume mount for code
  - TTS: Switch to EdgeTTS (Huoshan has deadlock risk)
  - Memory: Already on mem_local_short
  - 口算游戏: Pure code, no LLM calls needed
  - Deployment: Docker on remote lldd-linux, git hook auto-deploy

## #all
- General introductions channel
