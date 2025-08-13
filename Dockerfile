# syntax=docker/dockerfile:1
FROM kasmweb/kali-rolling-desktop:1.17.0

USER root
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/kasm-default-profile \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize container here #########

# Base tools + Python
RUN apt-get update && apt-get install -y \
      git curl python3 python3-venv python3-pip \
  && rm -rf /var/lib/apt/lists/*

# AgentZero
RUN git clone --depth=1 https://github.com/agent0ai/agent-zero /opt/agent-zero \
 && pip3 install --upgrade pip \
 && pip3 install -r /opt/agent-zero/requirements.txt \
 && python3 -m playwright install --with-deps chromium

# Start AgentZero UI when the Kasm desktop is ready (runs as user 1000)
RUN printf '%s\n' \
  '/usr/bin/desktop_ready' \
  'cd /opt/agent-zero' \
  'exec /usr/bin/python3 /opt/agent-zero/run_ui.py --host 0.0.0.0 --port 8080 &' \
  > $STARTUPDIR/custom_startup.sh \
  && chmod +x $STARTUPDIR/custom_startup.sh

######### End customizations #########

# Restore Kasm user context
RUN chown 1000:0 $HOME && $STARTUPDIR/set_user_permission.sh $HOME \
 && mkdir -p /home/kasm-user && chown -R 1000:0 /home/kasm-user
ENV HOME=/home/kasm-user
WORKDIR $HOME
USER 1000

# AgentZero UI + KasmVNC desktop
EXPOSE 8080 6901
ENV VNC_PW=changeme
