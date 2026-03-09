# ${{ values.name }}

## Purpose

${{ values.description }}

## Ownership

- Owner: `${{ values.owner }}`
- System: `${{ values.system }}`

## Runtime

- Port: `${{ values.port }}`
- Liveness: `/health/live`
- Readiness: `/health/ready`

## Deployment Notes

Deployment manifests are under `kustomize/` with environment overlays for `dev` and `staging`.
