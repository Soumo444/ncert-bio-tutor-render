FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HOME=/home/user \
    ANONYMIZED_TELEMETRY=False \
    READ_ONLY_MODE=true \
    ANSWER_MODE=auto \
    LLM_PROVIDER=groq \
    LLM_FALLBACKS=gemini \
    GROQ_MODEL=openai/gpt-oss-120b \
    GROQ_REASONING_FAST=low \
    GROQ_REASONING_STRONG=medium \
    GROQ_MAX_TOKENS_STRONG=3000 \
    GEMINI_MODEL=gemini-3.1-flash-lite \
    GEMINI_MODEL_STRONG=gemini-3.5-flash \
    GEMINI_FALLBACK_MODELS=gemini-3.1-flash-lite,gemini-3.5-flash \
    JUDGE_PROVIDER=gemini \
    RATE_LIMIT_PER_HOUR=60 \
    PORT=7860 \
    HOST=0.0.0.0

WORKDIR /app

# libgomp1 is needed by the onnxruntime wheel pulled in by Chroma.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# The app, code and pre-built Chroma index are stored as a public tarball on
# the Hugging Face Hub, so the Git repository stays tiny and LFS-free.
RUN python -c "import urllib.request; urllib.request.urlretrieve('https://huggingface.co/datasets/Soumojit444/ncert-bio-tutor-deploy/resolve/main/bundle.tar.gz', '/tmp/bundle.tar.gz')" \
    && tar -xzf /tmp/bundle.tar.gz -C /app \
    && rm /tmp/bundle.tar.gz

RUN useradd -m -u 1000 user \
    && chown -R user:user /app
USER user

EXPOSE 7860

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-7860}"]
