# HAZEL — Dave's Vet Station (exotics: reptiles, birds, small mammals, fish)
# Cloned from the proven JOE/ALICE/DAVE service. All lessons baked in (CPU-only
# torch, model pre-download, persistent volume for the knowledge base).
#
# Hazel's brain (her exotic-knowledge ChromaDB) is DATA, not code — it lives on a
# PERSISTENT VOLUME at /data/hazel_exotic_db so it survives redeploys/reboots.
#
# Coolify setup:
#   - Persistent Storage: mount a volume at  /data
#   - Env vars: ANTHROPIC_API_KEY, CREDENTIALS_FILE, CHROMA_DB_PATH, (opt) CLAUDE_MODEL, RAG_SERVICE_URL
#   - Credentials: mount service-account JSON at /data/credentials.json
#   - Port Exposes: 5007   (Dave=5005, Alice=5006, Hazel=5007, Joe=5008)

FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download the embedding model at build time
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

COPY hazel_vet_api.py .
COPY hazel_vet_ingest.py .

ENV CHROMA_DB_PATH=/data/hazel_exotic_db
ENV CREDENTIALS_FILE=/data/credentials.json
ENV PORT=5007

EXPOSE 5007

CMD ["python", "hazel_vet_api.py"]
