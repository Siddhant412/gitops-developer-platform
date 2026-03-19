# Applications

Store Argo CD `Application` manifests for generated service repositories here.

Example:

```bash
./platform/bootstrap/argocd/register-generated-app.sh \
  --app-name payments-api-dev \
  --repo-url https://github.com/<owner>/payments-api.git \
  --path kustomize/overlays/dev \
  --output platform/gitops-examples/applications/payments-api-dev.yaml
```

That file can then be committed and later managed by a root Argo CD application once this repo is hosted remotely.
