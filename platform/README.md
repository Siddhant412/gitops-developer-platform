# Platform Layout

This directory holds the platform-owned assets around the Backstage app:

- `catalog/` contains seed entities for domains, systems, groups, and resources
- `templates/` contains golden path template definitions and skeletons
- `bootstrap/` contains local environment bootstrap assets
- `policies/` contains Kyverno policy definitions
- `terraform/` contains shared modules and environment stacks
- `gitops-examples/` contains sample Argo CD application state

Generated service repositories should live outside this repo.
