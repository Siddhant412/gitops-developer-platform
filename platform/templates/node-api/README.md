# Node API Template

Golden path for a Fastify-based Node.js HTTP API.

This template currently scaffolds:

- starter application code with health and readiness endpoints
- structured logging via Fastify
- `catalog-info.yaml`
- TechDocs starter files
- `Dockerfile` and `.dockerignore`
- GitHub Actions CI workflow
- Kustomize base plus `dev` and `staging` overlays

Inputs collected in Backstage:

- service name
- description
- owner
- system
- service port
- GitHub repository location

Next additions for this template:

- image publishing to GHCR
- GitOps repo update step
- security scanning
