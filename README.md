[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/speaches-1?utm_medium=integration&utm_source=button&utm_campaign=speaches)

# Speaches on Railway

One-click Railway template for [Speaches](https://github.com/speaches-ai/speaches), the open-source (MIT) OpenAI-compatible server for speech to text (faster-whisper) and text to speech (Kokoro, Piper).

## What it deploys

| | |
|---|---|
| Service | `Speaches`, built from this repo's `Dockerfile` |
| Upstream image | `ghcr.io/speaches-ai/speaches:0.9.0-rc.3-cpu@sha256:2163775b6df5e451a71200e8f675fed68dbd8ab184fc604453d549e486f22fd2` (CPU build; `0.9.0-rc.3` is upstream's current GitHub "Latest" release) |
| Volume | `/home/ubuntu/.cache/huggingface/hub`: every downloaded model, so redeploys and restarts don't download again |
| Public URL | Railway domain on port 8000: the Gradio playground at `/`, the API at `/v1`, API docs at `/docs` |
| Health check | `/health` (public, no key needed) |

On first boot it downloads `Systran/faster-whisper-small` (speech to text) and `speaches-ai/Kokoro-82M-v1.0-ONNX` (text to speech, about 400 MB together) to the volume. Later boots reuse them.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `API_KEY` | `${{secret(48)}}` | Bearer key for every `/v1` route. Generated at deploy; copy it from the service's Variables tab. The server refuses to start without one |
| `PORT` | `8000` | Port the server listens on and the Railway domain targets |
| `PRELOAD_MODELS` | Whisper small + Kokoro | JSON list of models downloaded at startup. Add more, for example `"Systran/faster-whisper-large-v3"` (needs about 4 GB RAM) |

Everything else has a safe default in `start.sh` (CPU, int8, log level `info`, model unload after 300 s idle). Any [Speaches setting](https://speaches.ai/configuration/) can be added as a variable, for example `ALLOW_ORIGINS='["https://your-app.example"]'` for browser apps, or `CHAT_COMPLETION_BASE_URL` / `CHAT_COMPLETION_API_KEY` for the voice-chat tab.

## Using it

```sh
curl https://YOUR-DOMAIN.up.railway.app/v1/audio/transcriptions \
  -H "Authorization: Bearer YOUR-API-KEY" \
  -F file=@audio.wav -F model=Systran/faster-whisper-small

curl https://YOUR-DOMAIN.up.railway.app/v1/audio/speech \
  -H "Authorization: Bearer YOUR-API-KEY" -H "Content-Type: application/json" \
  -d '{"model":"speaches-ai/Kokoro-82M-v1.0-ONNX","voice":"af_heart","input":"Hello from Railway"}' -o hello.mp3
```

OpenAI SDKs work by setting the base URL to `https://YOUR-DOMAIN.up.railway.app/v1` and the API key to `API_KEY`. The names `whisper-1`, `tts-1` and `tts-1-hd` map to the preloaded models.

## Updates

Deployers get Railway's "update available" notice when this repo's `main` changes. Each version is listed in [CHANGELOG.md](CHANGELOG.md), breaking changes first. Your models stay on the volume across updates.

## Licence

The wrapper in this repo is MIT, like Speaches itself.
