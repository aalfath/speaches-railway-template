#!/bin/sh
# Railway wrapper for Speaches. Sets safe defaults, prepares the model volume and
# starts the server as the unprivileged "ubuntu" user.
set -eu

# Listen where Railway's domain and health check look.
export UVICORN_HOST="${UVICORN_HOST:-0.0.0.0}"
export UVICORN_PORT="${PORT:-${UVICORN_PORT:-8000}}"

# The playground and the realtime API call this same server; behind Railway's proxy
# Gradio can't guess the URL, so point it at the local port.
export LOOPBACK_HOST_URL="${LOOPBACK_HOST_URL:-http://127.0.0.1:${UVICORN_PORT}}"

# CPU defaults (Railway has no GPUs). Upstream logs at debug level by default.
export WHISPER__INFERENCE_DEVICE="${WHISPER__INFERENCE_DEVICE:-cpu}"
export WHISPER__COMPUTE_TYPE="${WHISPER__COMPUTE_TYPE:-int8}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# Models to download at startup (they stay on the volume). Speaches never downloads
# a model on demand, so without this the API answers 404 until you add one.
export PRELOAD_MODELS="${PRELOAD_MODELS:-[\"Systran/faster-whisper-small\",\"speaches-ai/Kokoro-82M-v1.0-ONNX\"]}"

# Refuse to start an open server by accident: the speech API would be usable by
# anyone with the URL. Set API_KEY_DISABLED=true only for a private-network-only service.
if [ -z "${API_KEY:-}" ] && [ "${API_KEY_DISABLED:-false}" != "true" ]; then
  echo "speaches-start: API_KEY is empty. Set API_KEY (the template generates one), or API_KEY_DISABLED=true to run without auth." >&2
  exit 1
fi
if [ -z "${API_KEY:-}" ]; then unset API_KEY; fi

# Railway mounts volumes as root; hand the model cache to uid 1000.
mkdir -p "$HF_HUB_CACHE"
if [ "$(stat -c %u "$HF_HUB_CACHE")" != "1000" ]; then
  chown -R 1000:1000 "$HF_HUB_CACHE"
fi

cd /home/ubuntu/speaches
if [ "$#" -eq 0 ]; then
  set -- uvicorn --factory speaches.main:create_app
fi
exec setpriv --reuid=1000 --regid=1000 --init-groups env HOME=/home/ubuntu "$@"
