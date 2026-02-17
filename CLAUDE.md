# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Self-hosted Azure DevOps Pipelines Linux agents deployed as Azure Container Instances (ACI) inside private VNets. Used across EastPack projects (MyOrchard, PalletPlacement, Platform) to run CI/CD pipelines with access to VNet-internal resources.

## Architecture

Subscription-level Bicep deployment with four modules orchestrated by `main.bicep`:

1. **`create-resource-group.bicep`** — Ensures resource groups exist (VNet RG + optional separate registry RG)
2. **`network.bicep`** — Creates or references an existing VNet and adds a subnet delegated to `Microsoft.ContainerInstance/containerGroups`
3. **`registry.bicep`** — Deploys Azure Container Registry and triggers an ACR Task Run that builds the Docker image from `docker/Dockerfile` via a Git source repo
4. **`containers.bicep`** — Deploys N container group instances (one ACI per agent), each connected to the VNet subnet with Azure DNS (`168.63.129.16`) for private endpoint resolution

The `targetScope` is `subscription` (not `resourceGroup`), so deployments use `az deployment sub create`.

### Docker Image

`docker/Dockerfile` builds an Ubuntu 24.04 image with Azure CLI, Git, and standard build tools. `docker/start.sh` handles agent bootstrap: downloads the latest Azure Pipelines agent, configures it against the ADO org/pool, and runs it. On container stop, it deregisters the agent.

### Environment Variables (container runtime)

| Variable | Purpose |
|----------|---------|
| `AZP_URL` | Azure DevOps organization URL |
| `AZP_TOKEN` | PAT token for agent registration |
| `AZP_POOL` | Agent pool name |
| `AZP_AGENT_NAME` | Agent display name |

## Deployment Commands

Deploy an agent set (subscription-level):
```bash
az deployment sub create -n <deploymentName> --location australiaeast \
  --template-file ./main.bicep \
  --parameters ./azuredeploy.<project>.<env>.parameters.json \
  --parameters @pat-tokens.json
```

Delete an agent container:
```bash
az container delete -g <resourceGroup> --name <agentName> --yes
```

## Parameter Files

Each file configures agents for a specific project/environment: VNet name, subnet CIDR, container registry, CPU/memory, ADO org URL, pool name, and agent count.

| File | Project | Environment |
|------|---------|-------------|
| `azuredeploy.orchard.dev.parameters.json` | MyOrchard | Dev |
| `azuredeploy.orchard.uat.parameters.json` | MyOrchard | UAT |
| `azuredeploy.pallet.dev.parameters.json` | PalletPlacement | Dev |
| `azuredeploy.pallet.uat.parameters.json` | PalletPlacement | UAT |
| `azuredeploy.platform.dev.parameters.json` | Platform | Dev |
| `azuredeploy.parameters.json` | Default/template | — |

`pat-tokens.json` supplies the `patToken` parameter separately and is gitignored.

## Key Design Decisions

- **`useExistingVnet` (default: true)**: Most deployments reference a pre-existing VNet rather than creating one. The network module only creates/updates the ACI-delegated subnet, leaving other subnets untouched.
- **ACR Task Run for image build**: The container image is built server-side by ACR (not locally), pulling the Dockerfile from a Git repo URL specified via `dockerSourceRepo` parameter.
- **Subscription scope**: The deployment creates resource groups as needed, so the caller only needs subscription-level permissions.
- **`restartPolicy: Always`**: Containers auto-restart, keeping agents persistent.
