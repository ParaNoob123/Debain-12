#!/bin/bash
# Start SSH
service ssh start

# Start XFCE desktop inside VNC session
export DISPLAY=:0
startxfce4 &

# Start noVNC
websockify --web=/usr/share/novnc/ 6080 localhost:5900
