#!/usr/bin/env bash
set -euo pipefail

# If Kasm provides a helper, wait for the desktop to be ready
if command -v /usr/bin/desktop_ready >/dev/null 2>&1; then
  /usr/bin/desktop_ready
else
  # Fallback: short delay to let Xfce come up
  sleep 3
fi

# Ensure we use the Py3.12 env
export PATH="/opt/az-venv/bin:${PATH}"
export DISPLAY=:1

# API keys can be injected via environment (Compose/Coolify)
# export OPENROUTER_API_KEY=...
# export OPENAI_API_KEY=...

# Launch AgentZero UI on 0.0.0.0:50001 (adjust if your entry changes)
nohup python /opt/agent-zero/run_ui.py --host 0.0.0.0 --port 50001 \
  >/home/kasm-user/agentzero.log 2>&1 &
