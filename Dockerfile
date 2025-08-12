# Base: full Kali desktop that streams over the web via KasmVNC
# Choose a tag that matches your Kasm version; rolling is kept fresh.
# See "Default Docker Images" & "Building Custom Images" docs.
# e.g., 1.17.0-rolling-daily
FROM kasmweb/kali-rolling-desktop:1.17.0-rolling-daily


USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git && rm -rf /var/lib/apt/lists/*

# 1) Install uv (fast Python & package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# 2) Get AgentZero
RUN git clone https://github.com/agent0ai/agent-zero /opt/agent-zero

# 3) Create a venv with *Python 3.12* and install deps there
RUN uv python install 3.12 && \
    uv venv /opt/az-venv --python 3.12 && \
    uv pip install --python /opt/az-venv/bin/python -r /opt/agent-zero/requirements.txt

ENV PATH="/opt/az-venv/bin:${PATH}"

# Pull AgentZero source & install
# (You can pin a specific tag/commit if you prefer.)
RUN git clone https://github.com/agent0ai/agent-zero /opt/agent-zero && \
    pip install --no-cache-dir -r /opt/agent-zero/requirements.txt

# Install Playwright browsers so the agent can drive a real browser on the desktop
RUN pip install --no-cache-dir playwright && \
    python -m playwright install chromium

# Add a startup script that waits for the desktop then launches AgentZero UI
# Kasm images auto-execute /dockerstartup/custom_startup.sh when a session spawns.
# (Runs as the regular desktop user.)
COPY dockerstartup/custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# Optional: give Chromium more shared memory (helps avoid crashes)
# Compose will set shm_size, but this is also OK:
# RUN mkdir -p /dev/shm && chmod 1777 /dev/shm

USER 1000
