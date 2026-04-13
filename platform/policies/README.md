# Policy Definitions

This directory holds governance rules for platform-managed workloads.

## Current Kyverno Guardrails

Policies under `kyverno/` enforce the following for workloads in the `dev` and `staging` namespaces:

- required workload and pod-template labels
- images must come from `ghcr.io`
- liveness and readiness probes are required
- CPU and memory requests and limits are required
- containers must run as non-root, disallow privilege escalation, and drop `ALL` capabilities

## Install

```bash
./platform/bootstrap/kyverno/install.sh
```

## Demo

To see the guardrails fail on a bad manifest:

```bash
kubectl apply -f platform/policies/examples/bad-deployment.yaml --context kind-idp-dev
```

To inspect policy state and reports:

```bash
kubectl get clusterpolicies --context kind-idp-dev
kubectl get policyreports -A --context kind-idp-dev
```
