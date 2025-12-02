# terraform-oracle-tf2-server

A Terraform Module for deploying long-lived Team Fortress 2 servers on Oracle Cloud Infrastructure (OCI) using Oracle Container Instances.

## Features

- **Long-lived servers**: Containers are configured with `ALWAYS` restart policy to ensure continuous availability
- **Multiple servers**: Deploy multiple TF2 servers sharing the same network infrastructure
- **Modular design**: Separate modules for network, IAM, vault, and server deployment
- **Flexible configuration**: Customize server settings, container resources, and game configurations
- **Free tier compatible**: Works with Oracle Cloud's Always Free tier resources

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

## Quick Start

### Prerequisites

1. An Oracle Cloud Infrastructure account
2. Terraform >= 1.0
3. OCI CLI configured with credentials
4. A Steam Game Server Login Token (GSLT) from https://steamcommunity.com/dev/managegameservers

### Basic Usage

```hcl
# Configure the OCI provider
provider "oci" {
  region = "us-ashburn-1"
}

# Create shared network infrastructure
module "network" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/network"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"
}

# Create IAM policies (once per compartment)
module "iam" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/iam"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"
}

# Deploy a TF2 server
module "tf2_server" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/tf2-server"

  compartment_id      = var.compartment_id
  server_name         = "my-tf2-server"
  availability_domain = module.network.availability_domain
  subnet_id           = module.network.subnet_id
  nsg_ids             = [module.network.nsg_id]

  # TF2 server configuration
  srcds_token     = var.srcds_token
  server_hostname = "My TF2 Server"
  map             = "cp_badlands"
  maxplayers      = 24
  rcon_password   = var.rcon_password

  depends_on = [module.iam]
}

output "server_ip" {
  value = module.tf2_server.public_ip
}

output "connect_command" {
  value = module.tf2_server.connect_command
}
```

### Deploying Multiple Servers

```hcl
# Shared infrastructure (created once)
module "network" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/network"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"
}

module "iam" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/iam"

  compartment_id = var.compartment_id
}

# Server 1: Payload
module "tf2_payload" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/tf2-server"

  compartment_id      = var.compartment_id
  server_name         = "tf2-payload"
  availability_domain = module.network.availability_domain
  subnet_id           = module.network.subnet_id
  nsg_ids             = [module.network.nsg_id]

  srcds_token     = var.srcds_token
  server_hostname = "Payload Server"
  map             = "pl_upward"

  depends_on = [module.iam]
}

# Server 2: KOTH
module "tf2_koth" {
  source = "github.com/sonikro/terraform-oracle-tf2-server//modules/tf2-server"

  compartment_id      = var.compartment_id
  server_name         = "tf2-koth"
  availability_domain = module.network.availability_domain
  subnet_id           = module.network.subnet_id
  nsg_ids             = [module.network.nsg_id]

  srcds_token     = var.srcds_token
  server_hostname = "KOTH Server"
  map             = "koth_viaduct"

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

Deploys a single TF2 server container instance.

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
| `tf2_image` | Docker image | `"cm2network/tf2"` |
| `tf2_image_tag` | Docker image tag | `"latest"` |
| `srcds_token` | Steam GSLT token | `""` |
| `server_hostname` | Server display name | `"Team Fortress 2 Server"` |
| `server_password` | Server password | `""` |
| `rcon_password` | RCON password | `""` |
| `map` | Starting map | `"cp_badlands"` |
| `maxplayers` | Max players (2-32) | `24` |
| `enable_sourcemod` | Enable SourceMod | `false` |
| `additional_env_vars` | Additional env vars | `{}` |

### IAM Module

Creates IAM policies for container instances. Should only be created once per compartment.

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
| 27015-27020 | TCP | Game server and RCON |
| 27015-27020 | UDP | Game server and SourceTV |

## License

MIT License - see [LICENSE](LICENSE) for details.

## References

- [TF2-QuickServer](https://github.com/sonikro/TF2-QuickServer) - Reference implementation for on-demand TF2 servers
- [cm2network/tf2](https://hub.docker.com/r/cm2network/tf2) - Docker image for TF2 servers
- [Oracle Container Instances](https://docs.oracle.com/en-us/iaas/Content/container-instances/home.htm) - OCI Container Instances documentation
