# GitOps Examples

This directory models the GitOps control-plane content that Argo CD consumes.

## Layout

- `bootstrap/` contains namespaces and shared Argo CD project definitions
- `applications/` is where generated Argo CD `Application` manifests can be stored

For early local development, the bootstrap resources can be applied directly with:

```bash
kubectl apply -k platform/gitops-examples/bootstrap
```

Later, when this repo is hosted in Git, Argo CD can point at `platform/gitops-examples/bootstrap` as a root application path.
