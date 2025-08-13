# Kali Linux desktop w/ KasmVNC (browser-streamed desktop)
FROM kasmweb/kali-rolling-desktop:1.17.0

USER root
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# Essentials + Python
RUN apt-get update && apt-get install -y \
    git curl python3 python3-venv python3-pip \
 && pip3 install --upgrade pip \
 && rm -rf /var/lib/apt/lists/*

# Pull AgentZero
RUN git clone --depth=1 https://github.com/agent0ai/agent-zero /opt/agent-zero
WORKDIR /opt/agent-zero

# Python deps + Playwright (Chromium) + system deps
RUN pip3 install -r requirements.txt \
 && python3 -m playwright install --with-deps chromium

# Make a writable logs dir for kasm-user
RUN mkdir -p /opt/agent-zero/logs && chown -R 1000:1000 /opt/agent-zero

# Supervisor program to run AgentZero alongside Kasm services
RUN bash -lc 'cat >/etc/supervisor/conf.d/agentzero.conf <<EOF
[program:agentzero]
command=/usr/bin/python3 /opt/agent-zero/run_ui.py --host 0.0.0.0 --port 8080
directory=/opt/agent-zero
user=kasm-user
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/agentzero.log
stderr_logfile=/var/log/supervisor/agentzero.err
environment=HOME="/home/kasm-user",USER="kasm-user"
EOF'

# Expose AgentZero UI and Kasm desktop ports
EXPOSE 8080 6901

# Default VNC basic-auth password (override via env)
ENV VNC_PW=changeme
