FROM rust:1.90-slim AS rust-builder
WORKDIR /usr/src/crawler
COPY ./crawler ./
RUN cargo build --release
FROM python:3.12-slim
ENV UV_PROJECT_ENVIRONMENT=/app/.venv \
    UV_PYTHON_PREFERENCE=only-system \
    UV_COMPILE_BYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
WORKDIR /app
COPY ./backend/pyproject.toml ./backend/uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev
COPY ./backend /app
COPY --from=rust-builder /usr/src/crawler/target/release/jwc-crawler /app/bin/jwc-crawler
RUN chmod +x /app/bin/jwc-crawler
EXPOSE 8080
ENV PATH="/app/.venv/bin:$PATH"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
