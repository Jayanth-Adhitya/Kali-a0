#!/usr/bin/env bash
set -euo pipefail

# This helper is provided by Kasm — it blocks until the desktop is ready,
# so your app launches *after* the VNC/Xfce session is up.
# (documented in the Kasm custom image guide)
if command -v /usr/bin/desktop_ready >/dev/null 2>&1; then
  /usr/bin/desktop_ready
fi

# Activate AgentZero venv
source /opt/az-venv/bin/activate

# Environment for your model provider (set in Compose at runtime is better)
# export OPENROUTER_API_KEY=...
# export OPENAI_API_KEY=...

# Launch AgentZero UI, listening on 0.0.0.0:50001
# AgentZero provides a Docker quickstart on port 80, but from source we can serve any port.
# The repo includes run_ui.py which starts the web UI.
nohup python /opt/agent-zero/run_ui.py --host 0.0.0.0 --port 50001 >/home/kasm-user/agentzero.log 2>&1 &

# If you want the agent to default to a headed browser on the desktop, ensure DISPLAY is set.
export DISPLAY=:1
