FROM rust:1.90-slim AS rust-builder
WORKDIR /usr/src/crawler
COPY ./crawler ./
RUN cargo build --release
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
WORKDIR /app
COPY ./backend/pyproject.toml ./backend/uv.lock ./
RUN uv sync --frozen --no-install-project
COPY ./backend /app
COPY --from=rust-builder /usr/src/crawler/target/release/jwc-crawler /app/bin/jwc-crawler
RUN chmod +x /app/bin/jwc-crawler
EXPOSE 8080
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
