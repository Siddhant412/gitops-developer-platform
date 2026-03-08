# Build Plan

## What We Are Building

Build a portfolio-grade internal developer platform with one clear workflow:

1. Discover services and ownership in Backstage.
2. Create a new service from a golden path template.
3. Build and test automatically in GitHub Actions.
4. Deploy through GitOps with Argo CD.
5. Enforce guardrails with Kyverno.
6. Surface docs and runtime status back in the portal.

This is not a generic tool installation exercise. The value comes from proving that a platform can standardize developer experience and reduce the manual steps required to create and operate a service.

## Opinionated Decisions

These choices keep the first version realistic and buildable.

### Use Terraform before Crossplane

Terraform is the better first implementation for this repo because:

- it is faster to wire into CI
- recruiters will immediately recognize it
- it reduces the amount of platform abstraction work needed before the demo is usable

Crossplane is a strong phase-two enhancement once the core workflow already works.

### Use Kustomize for application deployment config

Kustomize is a better fit than Helm for the first iteration because:

- the service skeletons stay easy to read
- `base` plus `overlays/dev` and `overlays/staging` maps cleanly to GitOps
- it avoids introducing chart logic before the platform workflow is proven

Helm can still be added later for more reusable platform packaging.

### Use a local Kubernetes cluster first

Start with `kind` or `k3d` for development. That gives you:

- cheap local iteration
- deterministic demos
- a clear path to later moving the same manifests to a managed cluster

### Keep generated services in separate repos

This repo should own the platform. Generated services should be created elsewhere. That makes the story more realistic:

- this repo contains the portal, templates, bootstrap, policies, and examples
- generated app repos represent what service teams would actually own
- a separate GitOps repo models the runtime control plane cleanly

## Proposed Repository Layout

Use this repo as the platform mono-repo:

```text
.
|-- backstage/
|   |-- packages/app
|   `-- packages/backend
|-- platform/
|   |-- templates/
|   |   |-- node-api/
|   |   |-- python-worker/
|   |   `-- docs-component/
|   |-- catalog/
|   |   |-- groups/
|   |   |-- systems/
|   |   `-- domains/
|   |-- bootstrap/
|   |   |-- kind/
|   |   |-- argocd/
|   |   `-- backstage/
|   |-- policies/
|   |   `-- kyverno/
|   |-- terraform/
|   |   |-- modules/
|   |   `-- environments/
|   `-- gitops-examples/
|-- docs/
`-- examples/
```

Recommended external repos:

- `idp-service-<name>` for generated application source
- `idp-gitops-envs` for Argo CD deployment state

## System Architecture

### Portal Layer

Backstage is the front door. It should provide:

- Software Catalog for `Component`, `System`, `API`, `Resource`, and `Group`
- Scaffolder templates for approved service types
- TechDocs for docs-as-code
- Kubernetes plugin for runtime visibility
- GitHub integrations for repo links and build status

### Delivery Layer

GitHub Actions should own CI:

- lint
- unit tests
- image build
- image push
- optional SAST or dependency scanning
- GitOps repo update with the image tag or manifest patch

Argo CD should own deployment:

- read desired state from Git only
- sync to Kubernetes automatically for `dev`
- allow manual approval or promotion for `staging`
- group services into AppProjects by team

### Runtime Layer

Kubernetes should host:

- Backstage
- example workloads created from golden paths
- Argo CD
- Kyverno

The service templates should include:

- deployment
- service
- ingress or gateway config if needed
- health and readiness probes
- resource requests and limits
- standard labels and annotations

### Governance Layer

Kyverno should enforce rules that match the golden paths:

- required `owner`, `system`, and `environment` labels
- images only from approved registries
- non-root security context
- required readiness and liveness probes
- required resource limits

The point is not just to reject bad manifests. The point is to make platform rules visible and explainable.

## Phase 1: Strong MVP

### Goal

Show that a developer can create a new service from Backstage and immediately get ownership metadata, docs, CI, and deployable manifests.

### Work

- Bootstrap Backstage in `backstage/`
- Configure catalog entities for sample teams, systems, and domains
- Install and configure:
  - Catalog
  - Scaffolder
  - TechDocs
  - Kubernetes plugin
- Build three scaffolder templates:
  - `node-api`
  - `python-worker`
  - `docs-component`
- For each template, generate:
  - starter source code
  - `catalog-info.yaml`
  - `mkdocs.yml`
  - `docs/index.md`
  - `Dockerfile`
  - `.github/workflows/ci.yaml`
  - `kustomize/base`
  - `kustomize/overlays/dev`
  - `kustomize/overlays/staging`

### Acceptance Criteria

- A new service can be created from the portal in under five minutes.
- The generated repo appears in the Backstage catalog.
- TechDocs renders from the generated repo.
- CI runs automatically on push.

## Phase 2: GitOps Deployment

### Goal

Show governed deployments rather than direct cluster mutation.

### Work

- Create a separate GitOps repo structure
- Install Argo CD into the local cluster
- Model one `Application` per service
- Model one or more `AppProject` resources for team boundaries
- Make the generated CI workflow update the GitOps repo after a successful build
- Link Argo CD status and cluster objects back into Backstage

### Acceptance Criteria

- A merged change updates desired state in Git.
- Argo CD syncs that state to the cluster.
- The service page links to the running workload and shows Kubernetes objects.

## Phase 3: Platform Provisioning

### Goal

Show that the platform can also provision the runtime dependencies a service needs.

### Work

- Add Terraform modules for shared platform resources
- Start with a minimal set:
  - namespace
  - container registry or image repository
  - one backing service such as a bucket or database
- Feed outputs into CI/CD or deployment config safely
- Document the platform contract for when a service can request extra resources

### Acceptance Criteria

- At least one service can be created with an attached managed resource.
- Provisioning is reproducible from code.
- The service template and deploy path remain mostly unchanged for the service developer.

## Phase 4: Governance and Multi-Tenancy

### Goal

Show that the platform supports multiple teams and guardrails instead of a single happy path.

### Work

- Add Kyverno validation and mutation policies
- Add team-scoped Argo CD projects
- Add namespace or environment boundaries
- Make policy failures observable in the developer workflow

### Acceptance Criteria

- A bad manifest is rejected with a visible reason.
- Team boundaries are represented in Argo CD and Kubernetes.
- The platform demo shows both a successful flow and a governed failure case.

## Recommended Build Order

If you want the strongest outcome quickly, build in this order:

1. Backstage bootstrap with catalog, techdocs, and sample entities
2. One golden path template end to end: `node-api`
3. Local Kubernetes plus Argo CD
4. GitHub Actions build and image publishing
5. GitOps repo update flow
6. Backstage Kubernetes visibility
7. Second and third templates
8. Kyverno policies
9. Terraform-backed resources

Do not start by trying to integrate every tool at once. The first complete vertical slice should be:

1. Create service in Backstage
2. Repo generated with docs and CI
3. Image built in CI
4. Deployment config committed to GitOps repo
5. Argo CD deploys to local cluster
6. Backstage shows the created service and its runtime objects

Once that works, everything else becomes iteration instead of risk.

## Golden Path Contract

Each service template should guarantee the following defaults:

- standard repo layout
- ownership metadata
- docs skeleton
- health endpoints
- structured logging
- containerization
- CI workflow
- deployable manifests
- observability hooks such as labels or annotations
- secure defaults for resource limits and security context

That is what makes this a platform instead of just a repo generator.

## Demo Storyline

Your demo should prove three things.

### Before the platform

Creating a new service means:

- setting up a repo manually
- writing CI manually
- copying deployment YAML
- figuring out ownership metadata
- forgetting docs and health probes

### With the platform

Creating a new service means:

- open Backstage
- pick a template
- fill in a short form
- get a working service with docs, CI, deploy config, and ownership automatically

### Governance in action

If a team tries to bypass the paved road:

- Argo CD still deploys only from Git
- Kyverno blocks non-compliant manifests
- the reason is visible

That is the portfolio narrative recruiters will remember.

## Immediate Next Steps For This Repo

1. Scaffold Backstage into `backstage/`
2. Add a local cluster bootstrap under `platform/bootstrap/`
3. Implement the `node-api` scaffolder template first
4. Create sample catalog entities for one domain, one system, and two teams
5. Stand up Argo CD locally and wire one sample application
6. Add a single Kyverno policy after the first deployment works

That is the smallest sequence that produces a compelling end-to-end demo.
