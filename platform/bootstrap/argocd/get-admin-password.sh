#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
KUBECONTEXT="${KUBECONTEXT:-kind-${CLUSTER_NAME}}"

kubectl --context "${KUBECONTEXT}" -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
printf '\n'
