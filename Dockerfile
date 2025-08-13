FROM kasmweb/kali-rolling-desktop:1.17.0

USER root

# Preload the new Kali repository signing key (Apr 2025)
RUN wget -q https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg

# Base tools for Agent Zero + Playwright
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip git curl fonts-liberation \
  && rm -rf /var/lib/apt/lists/*

# (Optional but recommended) disable internal TLS for KasmVNC; Traefik will do HTTPS
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml

# Create Agent Zero venv and install
RUN python3 -m venv /opt/az \
 && /opt/az/bin/pip install --upgrade pip

# Pull Agent Zero source and deps (official repo)
RUN git clone https://github.com/agent0ai/agent-zero.git /opt/agent-zero
RUN /opt/az/bin/pip install -r /opt/agent-zero/requirements.txt

# Playwright browsers + system deps (needed by browser-use)
RUN /opt/az/bin/pip install playwright \
 && /opt/az/bin/python -m playwright install --with-deps chromium

# Start Agent Zero on session start (as kasm_user)
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

EXPOSE 6901 80
