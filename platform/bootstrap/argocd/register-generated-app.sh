#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-idp-dev}"
KUBECONTEXT="${KUBECONTEXT:-kind-${CLUSTER_NAME}}"
APP_NAME=""
REPO_URL=""
PATH_IN_REPO=""
PROJECT="${PROJECT:-platform-dev}"
DEST_NAMESPACE="${DEST_NAMESPACE:-dev}"
DEST_SERVER="${DEST_SERVER:-https://kubernetes.default.svc}"
REVISION="${REVISION:-HEAD}"
OUTPUT_FILE=""
APPLY_MANIFEST=false

usage() {
  cat <<'EOF'
Usage:
  register-generated-app.sh \
    --app-name <application name> \
    --repo-url <service repo url> \
    --path <git repo path> \
    [--project platform-dev] \
    [--namespace dev] \
    [--revision HEAD] \
    [--output <file>] \
    [--apply]

Examples:
  ./platform/bootstrap/argocd/register-generated-app.sh \
    --app-name payments-api-dev \
    --repo-url https://github.com/<owner>/payments-api.git \
    --path kustomize/overlays/dev \
    --output platform/gitops-examples/applications/payments-api-dev.yaml

  ./platform/bootstrap/argocd/register-generated-app.sh \
    --app-name payments-api-dev \
    --repo-url https://github.com/<owner>/payments-api.git \
    --path kustomize/overlays/dev \
    --apply
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)
      APP_NAME="$2"
      shift 2
      ;;
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --path)
      PATH_IN_REPO="$2"
      shift 2
      ;;
    --project)
      PROJECT="$2"
      shift 2
      ;;
    --namespace)
      DEST_NAMESPACE="$2"
      shift 2
      ;;
    --revision)
      REVISION="$2"
      shift 2
      ;;
    --output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --apply)
      APPLY_MANIFEST=true
      shift
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

if [[ -z "${APP_NAME}" || -z "${REPO_URL}" || -z "${PATH_IN_REPO}" ]]; then
  usage
  exit 1
fi

MANIFEST=$(cat <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: argocd
spec:
  project: ${PROJECT}
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${REVISION}
    path: ${PATH_IN_REPO}
  destination:
    server: ${DEST_SERVER}
    namespace: ${DEST_NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
)

if [[ -n "${OUTPUT_FILE}" ]]; then
  mkdir -p "$(dirname "${OUTPUT_FILE}")"
  printf '%s\n' "${MANIFEST}" > "${OUTPUT_FILE}"
  echo "Wrote ${OUTPUT_FILE}"
fi

if [[ "${APPLY_MANIFEST}" == "true" ]]; then
  printf '%s\n' "${MANIFEST}" | kubectl --context "${KUBECONTEXT}" apply -f -
fi

if [[ -z "${OUTPUT_FILE}" && "${APPLY_MANIFEST}" != "true" ]]; then
  printf '%s\n' "${MANIFEST}"
fi
