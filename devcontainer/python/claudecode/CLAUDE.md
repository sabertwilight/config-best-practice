# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands use `uv run` prefix:

```bash
uv sync --extra dev          # Install dependencies
uv run python app.py         # Run Flask app
uv run pytest                # Run tests
uv run black . && ruff check . && mypy .   # Lint & format
```

## Tool Configs (pyproject.toml)

- Black/Ruff: line-length 100, Python 3.12
- MyPy: strict mode
- Ruff lint rules: E, F, I, N, W, UP

## Dev Container Notes

- Post-create script: `.devcontainer/post-create.sh`
- Proxy configured for BuildKit (host.docker.internal:7890)
- Claude Code settings mounted from host
