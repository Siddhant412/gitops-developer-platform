#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
KUBECONTEXT="${KUBECONTEXT:-kind-${CLUSTER_NAME}}"
KYVERNO_VERSION="${KYVERNO_VERSION:-v1.16.2}"
KYVERNO_INSTALL_URL="${KYVERNO_INSTALL_URL:-https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml}"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)
POLICY_DIR="${ROOT_DIR}/platform/policies/kyverno"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command kubectl

if ! kubectl --context "${KUBECONTEXT}" cluster-info >/dev/null 2>&1; then
  cat <<EOF >&2
Kubernetes context '${KUBECONTEXT}' is not reachable.
Create the local cluster first:
  ./platform/bootstrap/kind/create-cluster.sh
EOF
  exit 1
fi

kubectl --context "${KUBECONTEXT}" apply --server-side --force-conflicts -f "${KYVERNO_INSTALL_URL}"
kubectl --context "${KUBECONTEXT}" wait --for=condition=Established crd/clusterpolicies.kyverno.io --timeout=120s
kubectl --context "${KUBECONTEXT}" wait --for=condition=Established crd/policyreports.wgpolicyk8s.io --timeout=120s
kubectl --context "${KUBECONTEXT}" wait --for=condition=Available deployment --all -n kyverno --timeout=300s

# Kyverno registers admission webhooks before the service is always ready to accept traffic.
# Wait for the admission service to publish endpoints before applying any policies.
for attempt in $(seq 1 30); do
  ENDPOINTS=$(kubectl --context "${KUBECONTEXT}" get endpoints/kyverno-svc -n kyverno -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)
  if [[ -n "${ENDPOINTS}" ]]; then
    break
  fi
  sleep 2
done

if [[ -z "${ENDPOINTS:-}" ]]; then
  echo "Kyverno admission service did not become ready in time." >&2
  kubectl --context "${KUBECONTEXT}" get pods,svc,endpoints -n kyverno >&2 || true
  exit 1
fi

kubectl --context "${KUBECONTEXT}" apply -k "${POLICY_DIR}"

cat <<EOF

Kyverno is installed in context '${KUBECONTEXT}' and platform policies are applied.

Useful checks:
  kubectl get pods -n kyverno --context ${KUBECONTEXT}
  kubectl get clusterpolicies --context ${KUBECONTEXT}
  kubectl get policyreports -A --context ${KUBECONTEXT}
EOF
