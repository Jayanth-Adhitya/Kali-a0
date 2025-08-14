# Full desktop in browser (KasmVNC) + s6 supervisor
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# We need root to install packages; webtop will drop to user abc at runtime
USER root

# Python + build tools + git
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip git curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Create a venv for Agent Zero to keep it clean
RUN python3 -m venv /opt/agentzero-venv
ENV PATH="/opt/agentzero-venv/bin:${PATH}"

# Pull Agent Zero and deps (browser-use + playwright)
# Agent Zero repo: https://github.com/agent0ai/agent-zero
RUN git clone --depth=1 https://github.com/agent0ai/agent-zero.git /opt/agent-zero \
 && pip install --upgrade pip \
 && pip install -r /opt/agent-zero/requirements.txt \
 && pip install "browser-use==0.*" "playwright>=1.45" \
 && playwright install chromium --with-deps --no-shell

# Add s6 services for Chromium (with remote debugging) and Agent Zero UI
COPY root/ /

# Expose internal ports used by s6 services
# 3000 -> webtop HTTP (Coolify will terminate TLS for you)
# 8080 -> Agent Zero UI
# 9222 -> Chromium CDP (internal only; don't map a domain to this)
EXPOSE 3000 8080 9222

# webtop uses s6-overlay; nothing else needed here
