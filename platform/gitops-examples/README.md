# GitOps Examples

This directory models the old in-repo GitOps control-plane content that Argo CD consumed before the dedicated environment repo was introduced.

## Layout

- `bootstrap/` contains namespaces and shared Argo CD project definitions
- `applications/` is where generated Argo CD `Application` manifests can be stored

For early local development, the bootstrap resources can be applied directly with:

```bash
kubectl apply -k platform/gitops-examples/bootstrap
```

For the current project flow, prefer the separate `gitops-platform-environments` repo and its `bootstrap/` plus `argocd/applications/` directories instead.
