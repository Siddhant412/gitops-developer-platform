#!/usr/bin/env bash

set -euo pipefail

: "${GITOPS_REPO:?GITOPS_REPO is required}"
: "${GITOPS_REPO_TOKEN:?GITOPS_REPO_TOKEN is required}"
: "${SERVICE_NAME:?SERVICE_NAME is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

SOURCE_REPO_DIR="${GITHUB_WORKSPACE:-$(pwd)}"
TARGET_APP_DIR="apps/${SERVICE_NAME}"
TARGET_DEV_OVERLAY="${TARGET_APP_DIR}/overlays/dev/kustomization.yaml"
ARGO_APPS_DIR="argocd/applications"
ARGO_KUSTOMIZATION="${ARGO_APPS_DIR}/kustomization.yaml"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

require_source_path() {
  if [[ ! -e "$1" ]]; then
    echo "Missing required source path: $1" >&2
    exit 1
  fi
}

require_source_path "${SOURCE_REPO_DIR}/kustomize"

git clone "https://x-access-token:${GITOPS_REPO_TOKEN}@github.com/${GITOPS_REPO}.git" "${TMP_DIR}/gitops-repo"

cd "${TMP_DIR}/gitops-repo"

mkdir -p "${TARGET_APP_DIR}"
if [[ ! -f "${TARGET_DEV_OVERLAY}" ]]; then
  rm -rf "${TARGET_APP_DIR}"
  mkdir -p "${TARGET_APP_DIR}"
  cp -R "${SOURCE_REPO_DIR}/kustomize/." "${TARGET_APP_DIR}/"
fi

mkdir -p "${ARGO_APPS_DIR}"

render_application() {
  local environment="$1"
  local file_path="${ARGO_APPS_DIR}/${SERVICE_NAME}-${environment}.yaml"

  if [[ -f "${file_path}" ]]; then
    return
  fi

  cat > "${file_path}" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${SERVICE_NAME}-${environment}
  namespace: argocd
spec:
  project: platform-dev
  source:
    repoURL: https://github.com/${GITOPS_REPO}.git
    targetRevision: HEAD
    path: apps/${SERVICE_NAME}/overlays/${environment}
  destination:
    server: https://kubernetes.default.svc
    namespace: ${environment}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
}

render_application dev
render_application staging

python3 - "${ARGO_KUSTOMIZATION}" "${SERVICE_NAME}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
service = sys.argv[2]
expected = [f"{service}-dev.yaml", f"{service}-staging.yaml"]

if path.exists():
    lines = path.read_text().splitlines()
else:
    lines = [
        "apiVersion: kustomize.config.k8s.io/v1beta1",
        "kind: Kustomization",
        "resources:",
    ]

if "resources:" not in lines:
    lines.append("resources:")

resource_lines = [line.strip()[2:] for line in lines if line.startswith("  - ")]
for item in expected:
    if item not in resource_lines:
        lines.append(f"  - {item}")

path.write_text("\n".join(lines) + "\n")
PY

python3 - "${TARGET_DEV_OVERLAY}" "${IMAGE_TAG}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
tag = sys.argv[2]
lines = path.read_text().splitlines()

for index, line in enumerate(lines):
    stripped = line.lstrip()
    if stripped.startswith("newTag:"):
        indent = line[: len(line) - len(stripped)]
        lines[index] = f"{indent}newTag: {tag}"
        break
else:
    raise SystemExit(f"Could not find newTag in {path}")

path.write_text("\n".join(lines) + "\n")
PY

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git add "${TARGET_APP_DIR}" "${ARGO_APPS_DIR}"

if git diff --cached --quiet; then
  echo "GitOps repo already matches image tag ${IMAGE_TAG}"
  exit 0
fi

git commit -m "deploy(${SERVICE_NAME}): update dev image to ${IMAGE_TAG}"
git push origin HEAD:main
