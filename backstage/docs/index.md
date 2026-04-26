# GitOps Developer Platform

## Purpose

This Backstage app is the front door for the GitOps developer platform. It gives service teams a catalog, approved scaffolder templates, TechDocs, GitHub Actions visibility, and Kubernetes runtime visibility.

## Core Capabilities

- Catalog seed data for platform teams, systems, domains, and resources.
- A `Node API` golden path template for Fastify services.
- GitHub repository publishing through the Backstage scaffolder.
- GitHub Actions run visibility on service entity pages.
- Kubernetes workload visibility through `backstage.io/kubernetes-id`.
- Local bootstrap scripts for `kind`, Argo CD, Kyverno, and Backstage Kubernetes access.

## Delivery Model

Generated service repositories own application code and image builds. A separate GitOps environment repository owns deployment desired state. Service CI updates that environment repo, and Argo CD syncs the resulting state into Kubernetes.

## Guardrails

Kyverno policies enforce required platform labels, GHCR-only images, liveness and readiness probes, CPU and memory requests and limits, and non-root container security settings in the shared `dev` and `staging` namespaces.
