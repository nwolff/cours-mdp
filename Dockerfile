# Inspired by https://github.com/astral-sh/uv-docker-example/blob/main/Dockerfile

FROM ghcr.io/astral-sh/uv:python3.14-trixie-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

WORKDIR /app 

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Omit development dependencies
ENV UV_NO_DEV=1

# Ensure installed tools can be executed out of the box
ENV UV_TOOL_BIN_DIR=/usr/local/bin

# Copy local code to the container image.
COPY . ./

# Reset the entrypoint, don't invoke `uv`
ENTRYPOINT []

# Run the gunicorn application by default
# Uses `uv run` to sync dependencies on startup, respecting UV_NO_DEV
EXPOSE $PORT
CMD uv run gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
# CMD ["uv", "run", "gunicorn", "--bind", $PORT, "--workers", 1, "--threads",8, "--timeout", 0,  "main:app"]