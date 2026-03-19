# Bootstrap Assets

This directory holds local environment bootstrap assets.

- `kind/` for local Kubernetes cluster creation
- `argocd/` for Argo CD install and application bootstrap
- `backstage/` for Backstage deployment manifests used outside local `yarn start`

## Local Bootstrap Flow

1. Create a local Kubernetes cluster:

   ```bash
   ./platform/bootstrap/kind/create-cluster.sh
   ```

2. Install Argo CD and apply the local GitOps bootstrap resources:

   ```bash
   ./platform/bootstrap/argocd/install.sh
   ```

3. Open the Argo CD UI:

   ```bash
   ./platform/bootstrap/argocd/port-forward.sh
   ```

4. Print the initial Argo CD admin password:

   ```bash
   ./platform/bootstrap/argocd/get-admin-password.sh
   ```

5. Register a generated service repo as an Argo CD `Application`:

   ```bash
   ./platform/bootstrap/argocd/register-generated-app.sh \
     --app-name payments-api-dev \
     --repo-url https://github.com/<owner>/payments-api.git \
     --path kustomize/overlays/dev \
     --namespace dev \
     --apply
   ```

`kind` and `argocd` CLIs are expected to be installed locally. `kubectl` and Docker must also be available.
