# ${{ values.name }}

${{ values.description }}

## Local Development

```bash
npm install
npm start
```

The service listens on port `${{ values.port }}` by default and exposes:

- `GET /`
- `GET /health/live`
- `GET /health/ready`

## Testing

```bash
npm test
```

## Container Image

Pushes to `main` publish a container image to:

- `ghcr.io/<owner>/<repo>:latest`
- `ghcr.io/<owner>/<repo>:<git-sha>`

The published image path is normalized to lowercase to satisfy GHCR naming rules.
Images are published for both `linux/amd64` and `linux/arm64` so they can run on common cloud nodes and local Apple Silicon clusters.

## GitOps Deployment Flow

This service repo publishes the image and then updates a separate GitOps environment repo.

On the first successful push to `main`, the workflow will:

- push the container image to GHCR
- seed `apps/<service>/` into the GitOps repo if it does not exist yet
- create Argo CD application manifests for `dev` and `staging` if they are missing
- update the `dev` overlay to the new image SHA

To allow that write-back step, add this GitHub Actions secret in the generated repository:

- `GITOPS_REPO_TOKEN`

That token needs write access to the GitOps environment repo selected during scaffolding.

## Repository Layout

- `src/` contains the application entrypoint and server setup
- `test/` contains smoke tests for the HTTP endpoints
- `docs/` contains TechDocs content
- `kustomize/` contains the deployment manifests that seed the shared GitOps repo
- `.platform/gitops.env` stores the generated GitOps repo coordinates
