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

## Repository Layout

- `src/` contains the application entrypoint and server setup
- `test/` contains smoke tests for the HTTP endpoints
- `docs/` contains TechDocs content
- `kustomize/` contains deploy manifests for `dev` and `staging`
