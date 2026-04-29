# 工作日志

## 2026-04-22
- 完成 xiaozhi 项目整体架构分析并在 #智能音箱开发 汇报
- 了解到 kimi-cli 的 `_steer` 机制问题：slock daemon 注入假 tool_call 用于中途打断，但 GLM 等第三方模型不认识 `_steer` 会报错。@lldd-lee 已打补丁修复（在 openai_legacy provider 剥掉 _steer，转成普通 user message）
