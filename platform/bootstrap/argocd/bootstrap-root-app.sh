#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
KUBECONTEXT="${KUBECONTEXT:-kind-${CLUSTER_NAME}}"
REPO_URL=""
REVISION="${REVISION:-HEAD}"
PATH_IN_REPO="${PATH_IN_REPO:-platform/gitops-examples/bootstrap}"

usage() {
  cat <<'EOF'
Usage:
  bootstrap-root-app.sh --repo-url <git repo url> [--revision HEAD] [--path platform/gitops-examples/bootstrap]

Example:
  ./platform/bootstrap/argocd/bootstrap-root-app.sh \
    --repo-url https://github.com/<owner>/gitops-developer-platform.git
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --revision)
      REVISION="$2"
      shift 2
      ;;
    --path)
      PATH_IN_REPO="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${REPO_URL}" ]]; then
  usage
  exit 1
fi

cat <<EOF | kubectl --context "${KUBECONTEXT}" apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-bootstrap
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${REVISION}
    path: ${PATH_IN_REPO}
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
