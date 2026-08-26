#!/usr/bin/env bash
# Per-boot startup for the ddev-murz development environment.
# Starts the Docker daemon (there is no systemd in the Cloud Agent VM) and
# applies the networking tweak required for DDEV's router to reach containers.
set -euo pipefail

DOCKERD_LOG="/tmp/dockerd.log"

start_dockerd() {
  if docker info >/dev/null 2>&1; then
    echo "==> Docker daemon already running"
    return 0
  fi
  echo "==> Starting Docker daemon"
  sudo rm -f /var/run/docker.pid
  sudo nohup dockerd >"$DOCKERD_LOG" 2>&1 &

  echo "==> Waiting for Docker daemon to become ready"
  for _ in $(seq 1 60); do
    if sudo docker info >/dev/null 2>&1; then
      echo "==> Docker daemon is ready"
      return 0
    fi
    sleep 1
  done
  echo "ERROR: Docker daemon did not become ready in time" >&2
  tail -n 40 "$DOCKERD_LOG" >&2 || true
  return 1
}

start_dockerd

# Allow the current user to talk to the daemon without sudo for this session.
# dockerd can leave /var/run mode 0700, which blocks non-root access to the
# socket even when the socket itself is world-writable.
sudo chmod 755 /run /var/run 2>/dev/null || true
sudo chmod 666 /var/run/docker.sock || true

# In this nested-container environment, same-bridge container-to-container
# traffic is filtered through iptables and dropped, which makes DDEV's traefik
# router return 504 for every project URL. Letting bridged L2 traffic bypass
# iptables restores container-to-container connectivity.
if [ -e /proc/sys/net/bridge/bridge-nf-call-iptables ]; then
  echo "==> Disabling bridge-nf-call-iptables so DDEV routing works"
  sudo sysctl -w net.bridge.bridge-nf-call-iptables=0 >/dev/null || true
  sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=0 >/dev/null || true
fi

echo "==> start.sh complete"
