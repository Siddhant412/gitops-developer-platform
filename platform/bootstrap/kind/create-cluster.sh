#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE="${SCRIPT_DIR}/cluster.yaml"
KUBECONTEXT="kind-${CLUSTER_NAME}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command docker
require_command kind
require_command kubectl

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "kind cluster '${CLUSTER_NAME}' already exists"
  exit 0
fi

kind create cluster --name "${CLUSTER_NAME}" --config "${CONFIG_FILE}"

kubectl --context "${KUBECONTEXT}" wait --for=condition=Ready nodes --all --timeout=180s

cat <<EOF

kind cluster '${CLUSTER_NAME}' is ready.
Kubectl context: ${KUBECONTEXT}
Ingress test ports:
  http://localhost:8080
  https://localhost:8443
EOF
