# terraform-oracle-tf2-server

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-blue)](https://www.terraform.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Wiki](https://img.shields.io/badge/Documentation-Wiki-informational)](https://github.com/sonikro/terraform-oracle-tf2-server/wiki)

A Terraform Module for deploying long-lived Team Fortress 2 servers on Oracle Cloud Infrastructure (OCI) using Oracle Container Instances.

## Features

- **Long-lived servers**: Containers are configured with `ALWAYS` restart policy to ensure continuous availability
- **Multiple servers**: Deploy multiple TF2 servers sharing the same network infrastructure
- **Modular design**: Separate modules for network, IAM, vault, and server deployment
- **Flexible configuration**: Customize server settings, container resources, and game configurations


## Module Structure

```
.
├── modules/
│   ├── network/          # VCN, subnet, and security groups
│   ├── tf2-server/       # Individual TF2 server deployment
│   ├── vault/            # Docker registry credentials (optional)
│   └── iam/              # IAM policies for container instances
└── examples/
    └── simple/           # Example deploying multiple servers
```

## ⚠️ Cost Warning

**Important:** Deploying these Terraform modules will incur costs on your Oracle Cloud Infrastructure account. TF2 servers do not run on ARM64 processors, so they cannot use the Oracle Cloud free tier. With default settings (1 OCPU and 4GB memory), expect approximately **$23.08 USD per month** in operational costs per server. See [Oracle Cloud Cost Estimator](https://www.oracle.com/cloud/costestimator.html) for details.

**You are responsible for all charges.** If you are only experimenting, ensure you destroy the resources when finished to avoid unexpected bills.

## Quick Start

### Prerequisites

1. An Oracle Cloud Infrastructure account
2. Terraform >= 1.0
3. OCI CLI configured with credentials
4. A Steam Game Server Login Token (GSLT) from https://steamcommunity.com/dev/managegameservers (optional)

### Basic Usage

```hcl
# Configure the OCI provider
provider "oci" {
  region = "us-ashburn-1"
}

# Create shared network infrastructure
module "network" {
  source = "git::https://github.com/sonikro/terraform-oracle-tf2-server.git?ref=modules/network/v1.0.0"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"
}

# Create IAM policies (once per compartment)
module "iam" {
  source = "git::https://github.com/sonikro/terraform-oracle-tf2-server.git?ref=modules/iam/v1.0.0"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"
}

# Deploy a TF2 server
module "tf2_server" {
  source = "git::https://github.com/sonikro/terraform-oracle-tf2-server.git?ref=modules/tf2-server/v1.0.0"

  compartment_id      = var.compartment_id
  server_name         = "my-tf2-server"
  availability_domain = module.network.availability_domain
  subnet_id           = module.network.subnet_id
  nsg_ids             = [module.network.nsg_id]

  # TF2 server configuration
  server_token    = var.server_token
  server_hostname = "My TF2 Server"
  rcon_password   = var.rcon_password

  depends_on = [module.iam]
}

output "server_ip" {
  value = module.tf2_server.public_ip
}
```

### Deploying Multiple Servers

```hcl
# Shared infrastructure (created once)
module "network" {
  source = "git::https://github.com/sonikro/terraform-oracle-tf2-server.git?ref=modules/network/v1.0.0"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"
}

module "iam" {
  source = "git::https://github.com/sonikro/terraform-oracle-tf2-server.git?ref=modules/iam/v1.0.0"

  compartment_id = var.compartment_id
}

# Define server configurations
locals {
  servers = {
    base = {
      server_hostname = "Standard Server"
      image           = "ghcr.io/melkortf/tf2-base"
    }
    competitive = {
      server_hostname = "Competitive Server"
      image           = "ghcr.io/melkortf/tf2-competitive"
    }
  }
}

# Deploy multiple servers using for_each
module "tf2_servers" {
  source   = "git::https://github.com/sonikro/terraform-oracle-tf2-server.git?ref=modules/tf2-server/v1.0.0"
  for_each = local.servers

  compartment_id      = var.compartment_id
  server_name         = "tf2-${each.key}-server"
  availability_domain = module.network.availability_domain
  subnet_id           = module.network.subnet_id
  nsg_ids             = [module.network.nsg_id]
  tf2_image           = each.value.image

  server_token    = var.server_token
  server_hostname = each.value.server_hostname

  depends_on = [module.iam]
}
```

## Modules

### Network Module

Creates shared network infrastructure for TF2 servers.

| Variable | Description | Default |
|----------|-------------|---------|
| `compartment_id` | OCI compartment OCID | Required |
| `name_prefix` | Prefix for resource names | `"tf2-servers"` |
| `vcn_cidr_block` | CIDR block for VCN | `"10.0.0.0/16"` |
| `subnet_cidr_block` | CIDR block for subnet | `"10.0.1.0/24"` |
| `availability_domain` | Availability domain | First AD |

### TF2 Server Module

Deploys a single TF2 server container instance. Environment variables are configured for the [melkortf/tf2-base](https://github.com/melkortf/tf2-servers) Docker image.

| Variable | Description | Default |
|----------|-------------|---------|
| `compartment_id` | OCI compartment OCID | Required |
| `server_name` | Name for the server | Required |
| `availability_domain` | Availability domain | Required |
| `subnet_id` | Subnet OCID | Required |
| `nsg_ids` | Network security group OCIDs | `[]` |
| `container_shape` | Container instance shape | `"CI.Standard.E4.Flex"` |
| `container_ocpus` | Number of OCPUs | `1` |
| `container_memory_in_gbs` | Memory in GB | `4` |
| `tf2_image` | Docker image | `"ghcr.io/melkortf/tf2-base"` |
| `tf2_image_tag` | Docker image tag | `"latest"` |
| `server_token` | Steam GSLT token | `""` |
| `server_hostname` | Server display name | `"A Team Fortress 2 server"` |
| `server_password` | Server password | `""` |
| `rcon_password` | RCON password | `"123456"` |
| `port` | Game server port | `27015` |
| `client_port` | Client port | `27016` |
| `steam_port` | Master server updater port | `27018` |
| `stv_port` | SourceTV port | `27020` |
| `stv_name` | SourceTV host name | `"Source TV"` |
| `stv_title` | SourceTV spectator UI title | `"A Team Fortress 2 server Source TV"` |
| `stv_password` | SourceTV password | `""` |
| `download_url` | FastDL URL | `"https://fastdl.serveme.tf/"` |
| `enable_fake_ip` | Enable SDR (-enablefakeip) | `0` |
| `ip` | Bind address | `"0.0.0.0"` |
| `demos_tf_apikey` | demos.tf API key | `""` |
| `logs_tf_apikey` | logs.tf API key | `""` |
| `additional_env_vars` | Additional env vars | `{}` |
| `image_pull_secrets` | Vault secret OCID for registry credentials | `""` |
| `registry_endpoint` | Docker registry endpoint | `"https://ghcr.io"` |

### IAM Module

Creates IAM policies for container instances. Should only be created once per compartment.

The IAM module creates a dynamic group and policies that allow container instances to:
- Read vault secret bundles (required if using private Docker registries with the vault module)

| Variable | Description | Default |
|----------|-------------|---------|
| `compartment_id` | OCI compartment OCID | Required |
| `name_prefix` | Prefix for resource names | `"tf2-servers"` |

### Vault Module (Optional)

Creates a vault with Docker Hub credentials for private images.

| Variable | Description | Default |
|----------|-------------|---------|
| `compartment_id` | OCI compartment OCID | Required |
| `name_prefix` | Prefix for resource names | `"tf2-servers"` |
| `docker_username` | Docker Hub username | Required |
| `docker_password` | Docker Hub password | Required |

## Network Ports

The network module configures the following ports for TF2:

| Port Range | Protocol | Description |
|------------|----------|-------------|
| 27015-27020 | TCP | Game server and SourceTV |
| 27015-27020 | UDP | Game server and SourceTV |

## License

MIT License - see [LICENSE](LICENSE) for details.

## References

- [TF2-QuickServer](https://github.com/sonikro/TF2-QuickServer) - Reference implementation for on-demand TF2 servers
- [melkortf/tf2-servers](https://github.com/melkortf/tf2-servers) - Docker images for TF2 servers
- [Oracle Container Instances](https://docs.oracle.com/en-us/iaas/Content/container-instances/home.htm) - OCI Container Instances documentation
