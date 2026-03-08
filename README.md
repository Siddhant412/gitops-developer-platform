# GitOps Developer Platform

This project is an internal developer platform portfolio build, a Backstage-based portal that lets engineers create services from approved golden paths, register ownership as code, publish docs, and deploy through a governed GitOps workflow instead of hand-written infrastructure and Kubernetes YAML.

## Target Outcome

The platform should make a new service look like this:

1. A developer opens Backstage and chooses a template such as `Node API`, `Python Worker`, or `Docs Component`.
2. Backstage scaffolds a new repository with starter code, `catalog-info.yaml`, TechDocs, CI, and deployment manifests.
3. GitHub Actions runs tests, builds an image, and publishes artifacts.
4. A GitOps repository receives deployment configuration updates.
5. Argo CD syncs the desired state to Kubernetes.
6. Backstage shows service ownership, docs, and runtime information in one place.
7. Kyverno enforces platform rules such as labels, probes, image sources, and resource defaults.

## Core Stack

- Backstage for the developer portal, software catalog, templates, and TechDocs
- GitHub + GitHub Actions for source control and CI
- Kubernetes for runtime
- Argo CD for GitOps CD
- Terraform for infrastructure in the first portfolio version
- Kyverno for policy and governance

## Delivery Phases

### Phase 1: MVP

- Bootstrap Backstage
- Add Catalog, Scaffolder, TechDocs, and Kubernetes plugins
- Create three golden path templates:
  - `node-api`
  - `python-worker`
  - `docs-component`
- Generate repos with starter code, docs, CI, Dockerfile, and Kustomize manifests

### Phase 2: GitOps Deployment

- Add Argo CD and a separate GitOps repo
- Have templates also create or update deployment config
- Show deployment status and Kubernetes objects from the Backstage service page

### Phase 3: Platform Provisioning

- Add Terraform modules for shared platform resources
- Provision namespaces and one or two backing services through code
- Connect CI/CD outputs to provisioned runtime dependencies

### Phase 4: Governance and Multi-Tenancy

- Add Kyverno policies for labels, probes, resource limits, registries, and non-root containers
- Add Argo CD AppProjects and team boundaries
- Expose policy failures clearly in the platform workflow

## Repo Direction

This repo acts as the platform control plane and local development environment, not as a generated service repository. Backstage source, template skeletons, platform bootstrap, catalog entities, policies, and local GitOps examples live here. Generated services should be created in separate repos.

The detailed build plan is in docs/build-plan.md
