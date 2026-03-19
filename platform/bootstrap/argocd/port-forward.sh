#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
KUBECONTEXT="${KUBECONTEXT:-kind-${CLUSTER_NAME}}"

exec kubectl --context "${KUBECONTEXT}" -n argocd port-forward svc/argocd-server 8080:443
