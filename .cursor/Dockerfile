# Cloud Agent base for ddev-murz.
#
# Reuses the official DDEV CI image (ghcr.io/ddev/ddev-gitlab-ci) for the
# statically-linked ddev / ddev-hostname / mkcert binaries. That image is
# Alpine-based and cannot itself be the Cloud Agent base OS — Cursor injects
# Ubuntu/apt tooling (Chrome, VNC desktop, etc.) on top of the environment.
#
# Docker Engine is installed the Cursor-recommended way (fuse-overlayfs +
# iptables-legacy) so nested docker-in-docker works in the agent VM.
FROM ghcr.io/ddev/ddev-gitlab-ci:stable AS ddev-tools

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        git \
        sudo \
        iptables \
    && rm -rf /var/lib/apt/lists/*

# Docker CE (unpinned — pin only if a specific version is required)
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl --retry 3 --retry-delay 5 -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Nested-container storage + iptables (Cursor Cloud Agent docker-in-docker)
RUN apt-get update \
    && apt-get install -y --no-install-recommends fuse-overlayfs \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/docker \
    && printf '%s\n' '{' '  "storage-driver": "fuse-overlayfs"' '}' > /etc/docker/daemon.json \
    && update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# DDEV + mkcert from the official reusable image (static Go binaries)
COPY --from=ddev-tools /usr/local/bin/ddev /usr/local/bin/ddev
COPY --from=ddev-tools /usr/local/bin/ddev-hostname /usr/local/bin/ddev-hostname
COPY --from=ddev-tools /usr/local/bin/mkcert /usr/local/bin/mkcert

# Non-root agent user (uid 1000 matches Cloud Agent conventions)
RUN id -u ubuntu >/dev/null 2>&1 || useradd -m -s /bin/bash ubuntu \
    && groupadd -f docker \
    && usermod -aG docker ubuntu \
    && usermod -aG sudo ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu
