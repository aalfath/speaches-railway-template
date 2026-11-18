# Changelog

## 0.9.0-rc.3 (2026-11-18)

First release of this template.

- Speaches `0.9.0-rc.3-cpu`, pinned by digest `sha256:2163775b6df5e451a71200e8f675fed68dbd8ab184fc604453d549e486f22fd2`.
- Model cache on a Railway volume at `/home/ubuntu/.cache/huggingface/hub`, owned by the image's `ubuntu` user (the server no longer runs as root).
- Generated `API_KEY`; the server refuses to start without one.
- Preloads `Systran/faster-whisper-small` and `speaches-ai/Kokoro-82M-v1.0-ONNX`; `whisper-1` maps to the preloaded Whisper model.
- Health check on `/health`.
