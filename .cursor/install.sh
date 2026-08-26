#!/usr/bin/env bash
# Idempotent setup for the ddev-murz development environment.
# Installs Docker, DDEV and mkcert so the add-on can be installed into a
# DDEV project and tested. Runs during environment setup / build.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
# Keep existing config files on conffile conflicts without prompting. The base
# image ships a pre-existing /etc/fuse.conf, and installing fuse-overlayfs pulls
# in fuse3, whose conffile prompt would otherwise hang/abort a non-interactive
# install even with DEBIAN_FRONTEND=noninteractive set.
APT_OPTS=(-y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

echo "==> Installing base packages (fuse-overlayfs, curl, ...)"
sudo apt-get update -y
# fuse-overlayfs lets Docker's overlay storage work inside the nested
# container used by Cloud Agents (the default overlay2 driver cannot mount).
sudo apt-get install "${APT_OPTS[@]}" --no-install-recommends \
  curl ca-certificates fuse-overlayfs

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Installing Docker Engine"
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
else
  echo "==> Docker already installed: $(docker --version)"
fi

echo "==> Configuring Docker daemon (fuse-overlayfs storage driver)"
sudo mkdir -p /etc/docker
echo '{ "storage-driver": "fuse-overlayfs" }' | sudo tee /etc/docker/daemon.json >/dev/null

echo "==> Ensuring '$USER' can use Docker without sudo"
sudo groupadd -f docker
sudo usermod -aG docker "$USER"

if ! command -v ddev >/dev/null 2>&1; then
  echo "==> Installing DDEV + mkcert"
  curl -fsSL https://ddev.com/install.sh | bash
else
  echo "==> DDEV already installed: $(ddev --version)"
fi

echo "==> Installing mkcert local CA"
mkcert -install || echo "WARN: mkcert -install failed (non-fatal)"

echo "==> install.sh complete"
