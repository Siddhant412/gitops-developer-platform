#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

"${SCRIPT_DIR}/kind/create-cluster.sh"
"${SCRIPT_DIR}/argocd/install.sh"

cat <<'EOF'

Local platform bootstrap complete.

Next steps:
  1. ./platform/bootstrap/argocd/port-forward.sh
  2. ./platform/bootstrap/argocd/get-admin-password.sh
  3. ./platform/bootstrap/argocd/register-generated-app.sh --help
EOF
