#!/usr/bin/env bash
set -e
# Wait until the desktop is ready (Kasm-provided helper)
 /usr/bin/desktop_ready

# Start Agent Zero UI (same container). It binds to port 80 by default.
cd /opt/agent-zero
# pass through any model keys you set in env (Coolify)
# e.g., OPENAI_API_KEY / OPENROUTER_API_KEY
/opt/az/bin/python /opt/agent-zero/run_ui.py --host 0.0.0.0 --port 80 &
