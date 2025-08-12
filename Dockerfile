# Full Kali desktop streamed via KasmVNC
FROM kasmweb/kali-rolling-desktop:1.17.0-rolling-daily

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Basics
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git bash \
 && rm -rf /var/lib/apt/lists/*

# --- Install micromamba (tiny conda) ---
# Official one-liner from mamba docs
# https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html
RUN bash -lc "${SHELL:-bash} <(curl -L micro.mamba.pm/install.sh)"
ENV MAMBA_ROOT_PREFIX="/root/.local/share/micromamba"
ENV PATH="/root/.local/bin:${PATH}"

# --- Create a Python 3.12 env at /opt/az-venv and expose it on PATH ---
RUN micromamba create -y -p /opt/az-venv python=3.12 pip \
 && ln -s /opt/az-venv/bin/python /usr/local/bin/python \
 && ln -s /opt/az-venv/bin/pip /usr/local/bin/pip
ENV PATH="/opt/az-venv/bin:${PATH}"

# --- Get AgentZero and install its deps into the Py3.12 env ---
RUN git clone https://github.com/agent0ai/agent-zero /opt/agent-zero \
 && pip install --no-cache-dir -r /opt/agent-zero/requirements.txt

# --- Install Playwright + browsers + OS deps (Python CLI) ---
# Docs: playwright Python + install-deps / --with-deps
# https://playwright.dev/python/docs/browsers
RUN pip install --no-cache-dir playwright \
 && playwright install-deps chromium \
 && playwright install chromium

# Optional: more shared memory helps Chromium
# (we also set shm_size in compose)
# RUN mkdir -p /dev/shm && chmod 1777 /dev/shm

# --- Add a simple startup script for AgentZero UI ---
# Kasm images call /dockerstartup/custom_startup.sh if present
# (We guard in case desktop helper exists later.)
RUN mkdir -p /dockerstartup
COPY dockerstartup/custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# Permissions so the desktop user can read/execute the env & code
RUN chown -R 1000:1000 /opt/agent-zero /opt/az-venv

USER 1000
