#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
KUBECONTEXT="${KUBECONTEXT:-kind-${CLUSTER_NAME}}"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../../.." && pwd)
BOOTSTRAP_KUSTOMIZE_DIR="${ROOT_DIR}/platform/gitops-examples/bootstrap"
ARGOCD_INSTALL_URL="${ARGOCD_INSTALL_URL:-https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml}"

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

kubectl --context "${KUBECONTEXT}" create namespace argocd --dry-run=client -o yaml | kubectl --context "${KUBECONTEXT}" apply -f -
kubectl --context "${KUBECONTEXT}" apply -n argocd -f "${ARGOCD_INSTALL_URL}"
kubectl --context "${KUBECONTEXT}" wait --for=condition=Established crd/appprojects.argoproj.io --timeout=120s
kubectl --context "${KUBECONTEXT}" wait --for=condition=Established crd/applications.argoproj.io --timeout=120s
kubectl --context "${KUBECONTEXT}" rollout status deployment/argocd-server -n argocd --timeout=300s
kubectl --context "${KUBECONTEXT}" apply -k "${BOOTSTRAP_KUSTOMIZE_DIR}"

cat <<EOF

Argo CD is installed in context '${KUBECONTEXT}'.

Open the UI:
  ./platform/bootstrap/argocd/port-forward.sh

Print the initial admin password:
  ./platform/bootstrap/argocd/get-admin-password.sh
EOF
