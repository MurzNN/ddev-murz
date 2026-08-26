#!/usr/bin/env bash
# Idempotent post-checkout checks. Docker Engine, DDEV and mkcert are baked
# into the environment image (see .cursor/Dockerfile); this script only
# verifies they are present and refreshes the local mkcert CA trust.
set -euo pipefail

echo "==> Verifying tools from environment image"
docker --version
# Use --version (not `ddev version`) so we don't require a running Docker
# daemon — install runs before start.sh brings dockerd up.
ddev --version
mkcert -version

echo "==> Ensuring mkcert local CA is trusted"
mkcert -install || echo "WARN: mkcert -install failed (non-fatal)"

echo "==> install.sh complete"
