FROM kasmweb/kali-rolling-desktop:1.17.0

# Base stays: FROM kasmweb/kali-rolling-desktop:1.17.0
USER root

# 1) Fix Kali apt key (Apr 2025 rotation)
RUN wget -q https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg

# 2) Essentials + curl for uv
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl git ca-certificates fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# 3) Install uv and put it on PATH
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# 4) Install CPython 3.12 and create a 3.12 venv for Agent Zero
RUN uv python install 3.12 \
 && uv venv -p 3.12 /opt/az

# 5) Get Agent Zero and install deps into that venv (incl. Playwright)
RUN git clone https://github.com/agent0ai/agent-zero.git /opt/agent-zero
RUN /opt/az/bin/uv pip install --upgrade pip setuptools wheel \
 && /opt/az/bin/uv pip install -r /opt/agent-zero/requirements.txt \
 && /opt/az/bin/uv pip install playwright \
 && /opt/az/bin/python -m playwright install --with-deps chromium

# Start Agent Zero on session start (as kasm_user)
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

EXPOSE 6901 80
