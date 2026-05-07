FROM python:3.14-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

COPY pyproject.toml ./
COPY README.md ./
COPY .env.example ./
RUN uv pip install --system --editable .

COPY . .

ENV HOST=0.0.0.0
ENV PORT=8082

EXPOSE 8082

CMD ["uv", "run", "uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8082"]