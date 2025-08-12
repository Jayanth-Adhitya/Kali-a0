# Full Kali desktop streamed via KasmVNC (web)
FROM kasmweb/kali-rolling-desktop:1.17.0-rolling-daily

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Basics
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git bash \
 && rm -rf /var/lib/apt/lists/*

# --- Micromamba: place single binary on PATH (no shell init needed) ---
# Official release channel hosts static binaries
# https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html
RUN curl -L https://micro.mamba.pm/api/micromamba/linux-64/latest \
      -o /usr/local/bin/micromamba && \
    chmod +x /usr/local/bin/micromamba

# --- Create isolated Python 3.12 env for AgentZero (PEP 668 safe) ---
RUN micromamba create -y -p /opt/az-venv python=3.12 pip
ENV PATH="/opt/az-venv/bin:${PATH}"

# --- Get AgentZero and install deps into the Py3.12 env ---
RUN git clone https://github.com/agent0ai/agent-zero /opt/agent-zero && \
    pip install --no-cache-dir -r /opt/agent-zero/requirements.txt

# --- Playwright + browsers + OS deps (Python CLI, documented) ---
# You can combine these as `playwright install --with-deps chromium`
RUN pip install --no-cache-dir playwright && \
    playwright install-deps chromium && \
    playwright install chromium

# Optional: shared memory helps Chromium; Compose will also set shm_size
# RUN mkdir -p /dev/shm && chmod 1777 /dev/shm

# --- Startup hook so AgentZero starts after the desktop ---
RUN mkdir -p /dockerstartup
COPY dockerstartup/custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# Desktop user owns the env & repo
RUN chown -R 1000:1000 /opt/az-venv /opt/agent-zero

USER 1000
