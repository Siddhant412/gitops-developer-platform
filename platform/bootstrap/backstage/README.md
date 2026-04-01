# Backstage Local Kubernetes Access

These assets configure the local Backstage app to read Kubernetes resources from the `kind` cluster used for platform development.

## What It Does

The setup script:

- creates a read-only service account in the local cluster
- binds it to the built-in `view` cluster role
- creates a long-lived service account token secret
- writes `backstage/app-config.local.yaml` with the cluster URL, CA data, and token

This gives the Backstage Kubernetes plugin enough access to show Deployments, Pods, and Services for generated components.

## Local Flow

1. Make sure the local cluster exists:

   ```bash
   ./platform/bootstrap/bootstrap-local.sh
   ```

2. Generate local Backstage Kubernetes config:

   ```bash
   ./platform/bootstrap/backstage/configure-local-kubernetes.sh
   ```

3. Start Backstage:

   ```bash
   cd backstage
   PATH=/opt/homebrew/bin:$PATH yarn start
   ```

4. Open the generated service entity and check the `Kubernetes` tab.
