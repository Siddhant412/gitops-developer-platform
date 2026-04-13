# Kyverno Bootstrap

This directory installs Kyverno into the local cluster and applies the platform guardrail policies from `platform/policies/kyverno/`.

Run:

```bash
./platform/bootstrap/kyverno/install.sh
```

After install, useful checks are:

```bash
kubectl get pods -n kyverno --context kind-idp-dev
kubectl get clusterpolicies --context kind-idp-dev
kubectl get policyreports -A --context kind-idp-dev
```
