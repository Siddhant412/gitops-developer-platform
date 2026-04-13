# Bootstrap Assets

This directory holds local environment bootstrap assets.

- `kind/` for local Kubernetes cluster creation
- `argocd/` for Argo CD install and application bootstrap
- `kyverno/` for policy engine install and guardrail bootstrap
- `backstage/` for local Backstage Kubernetes access and deployment manifests used outside local `yarn start`

## Local Bootstrap Flow

1. Create a local Kubernetes cluster:

   ```bash
   ./platform/bootstrap/kind/create-cluster.sh
   ```

2. Install Argo CD and Kyverno guardrails:

   ```bash
   ./platform/bootstrap/argocd/install.sh
   ./platform/bootstrap/kyverno/install.sh
   ```

3. Open the Argo CD UI:

   ```bash
   ./platform/bootstrap/argocd/port-forward.sh
   ```

4. Print the initial Argo CD admin password:

   ```bash
   ./platform/bootstrap/argocd/get-admin-password.sh
   ```

5. Apply the shared environment repo bootstrap once. This creates namespaces, the `platform-dev` Argo CD project, and the root app that watches `argocd/applications/` in the env repo:

   ```bash
   cd /path/to/gitops-platform-environments
   kubectl apply -k bootstrap --context kind-idp-dev
   ```

6. Verify Kyverno is active:

   ```bash
   kubectl get pods -n kyverno --context kind-idp-dev
   kubectl get clusterpolicies --context kind-idp-dev
   ```

7. After that, new services only need to commit Argo `Application` manifests into `argocd/applications/`; the root app discovers them automatically.

8. Configure local Backstage Kubernetes access:

   ```bash
   ./platform/bootstrap/backstage/configure-local-kubernetes.sh
   ```

`kind` and `argocd` CLIs are expected to be installed locally. `kubectl` and Docker must also be available.
