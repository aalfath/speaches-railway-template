# Speaches: OpenAI-compatible speech-to-text and text-to-speech server (CPU build).
# Official image, pinned by version and digest. Bump both together and add a CHANGELOG entry.
FROM ghcr.io/speaches-ai/speaches:0.9.0-rc.3-cpu@sha256:2163775b6df5e451a71200e8f675fed68dbd8ab184fc604453d549e486f22fd2

# The start script runs as root only long enough to give the Railway volume to the
# image's "ubuntu" user (uid 1000), then drops to that user for the server itself.
USER root
COPY --chmod=755 start.sh /usr/local/bin/speaches-start
# OpenAI clients that send "whisper-1" get the preloaded Whisper model instead of
# a 404 for large-v3, which upstream's alias points at but nothing downloads.
COPY --chown=1000:1000 model_aliases.json /home/ubuntu/speaches/model_aliases.json

ENV HF_HUB_CACHE=/home/ubuntu/.cache/huggingface/hub
EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/speaches-start"]
