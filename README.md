# TFStacks VPC & EKS Demo

This repository demonstrates a production-ready HCP Terraform Stacks deployment that creates a complete AWS EKS infrastructure with Fargate compute, including networking, RBAC, add-ons, and a sample application.

## What This Demo Demonstrates

This demo showcases the power of **HCP Terraform Stacks** for managing complex, multi-component infrastructure deployments:

- **Multi-Region Capability**: Deploy identical infrastructure across multiple AWS regions using `for_each`
- **Component Dependencies**: Automatic dependency resolution between VPC, EKS, RBAC, add-ons, and applications
- **Workload Identity Integration**: Secure authentication using AWS and Kubernetes OIDC federation (no stored credentials)
- **Infrastructure Composition**: Modular design with reusable Terraform modules
- **Deployment Orchestration**: Coordinated deployment of 6 distinct components in proper order
- **State Isolation**: Each component maintains its own state while sharing outputs

## Key Integration Points

1. **AWS OIDC Integration**: Dynamic AWS credentials via workload identity tokens
2. **Kubernetes OIDC Integration**: EKS cluster access via HCP Terraform identity federation
3. **Cross-Component Dependencies**: VPC outputs feed into EKS, EKS outputs feed into add-ons
4. **IRSA (IAM Roles for Service Accounts)**: Secure pod-level AWS permissions without long-lived credentials
5. **Fargate Native**: Serverless Kubernetes without managing EC2 instances
6. **AWS Load Balancer Controller**: Native integration with ALB/NLB via Kubernetes Ingress

## Demo Components

This stack deploys 6 interconnected components:

| Component | Module | Purpose |
|-----------|--------|---------|
| **vpc** | `aws-vpc` | Multi-AZ VPC with public/private subnets, NAT gateway, EKS-tagged subnets |
| **eks** | `aws-eks-fargate` | EKS cluster on Fargate with OIDC provider and optional admin IAM role |
| **k8s-rbac** | `k8s-rbac` | ClusterRoleBinding for HCP Terraform organization-wide cluster access |
| **k8s-addons** | `aws-eks-addon` | CoreDNS, VPC-CNI, kube-proxy, AWS Load Balancer Controller |
| **k8s-namespace** | `k8s-namespace` | Kubernetes namespace for application deployment |
| **deploy-hashibank** | `hashibank-deploy` | Sample banking application with ALB ingress |

## How Stacks Works in This Demo

### Stack Structure

```
AWS-TFStacks-VPC-EKS/
├── components.tfcomponent.hcl    # Component definitions and dependencies
├── deployments.tfdeploy.hcl      # Deployment configurations (dev, staging, prod)
├── variables.tfcomponent.hcl     # Stack-level input variables
├── providers.tfcomponent.hcl     # Provider configurations with OIDC auth
└── modules/                      # Reusable Terraform modules
    ├── aws-vpc/
    ├── aws-eks-fargate/
    ├── aws-eks-addon/
    ├── k8s-namespace/
    ├── k8s-rbac/
    └── hashibank-deploy/
```

### Execution Flow

1. **Identity Tokens Generated**: HCP Terraform creates ephemeral JWT tokens for AWS and Kubernetes
2. **Provider Authentication**: Providers use OIDC to exchange tokens for temporary credentials
3. **Component Orchestration**: Stack deploys components in dependency order:
   - VPC (foundation)
   - EKS (depends on VPC)
   - RBAC (depends on EKS)
   - Add-ons (depends on EKS + RBAC)
   - Namespace (depends on Add-ons)
   - Application (depends on Namespace)
4. **State Management**: Each component's state is tracked independently
5. **Output Sharing**: Components share outputs (e.g., VPC IDs, EKS endpoint) via Stacks orchestration

### Multi-Region Deployment

The stack uses `for_each = var.regions` to deploy all components across specified regions:

```hcl
component "vpc" {
  for_each = var.regions  # e.g., ["ca-central-1", "us-east-1"]
  source = "./modules/aws-vpc"
  inputs = { ... }
}
```

## Demo Value Proposition

### For Platform Teams

- **Consistency**: Same infrastructure pattern across all regions/environments
- **Reduced Complexity**: Single stack definition replaces dozens of workspace configurations
- **Dependency Management**: No manual ordering or coordination required
- **Faster Deployments**: Parallel component execution where possible

### For Security Teams

- **Zero Static Credentials**: Everything uses OIDC workload identity
- **Least Privilege**: Each component uses scoped permissions
- **Audit Trail**: Complete deployment history in HCP Terraform
- **Compliance Ready**: Infrastructure-as-code with version control

### For Developers

- **Self-Service**: Easy to create new deployments via simple variable changes
- **Predictable**: Consistent infrastructure across environments
- **Fast Iteration**: Quick deployment and teardown for testing

## Expected Behavior

### Successful Deployment

When you deploy this stack, you should see:

1. **VPC Creation** (~2-3 minutes)
   - VPC with 6 subnets (3 public, 3 private across 3 AZs)
   - Internet Gateway and NAT Gateway
   - Route tables configured

2. **EKS Cluster Creation** (~10-12 minutes)
   - EKS control plane
   - Fargate profiles for `kube-system` and application namespaces
   - OIDC identity provider configured
   - Optional IAM admin role created

3. **RBAC Configuration** (~30 seconds)
   - ClusterRoleBinding for HCP Terraform organization

4. **Add-ons Deployment** (~5-7 minutes)
   - CoreDNS (Fargate-optimized)
   - VPC-CNI and kube-proxy
   - AWS Load Balancer Controller via Helm

5. **Application Deployment** (~2-3 minutes)
   - Kubernetes namespace created
   - HashiBank demo app deployed
   - ALB provisioned via Ingress

**Total Deployment Time**: ~20-25 minutes

### Accessing the Cluster

After deployment, configure kubectl:

```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
kubectl get nodes  # Should show Fargate nodes
kubectl get pods -n hashibank  # Should show running pods
```

## Requirements

| Name | Version |
|------|---------|
| [HCP Terraform](https://app.terraform.io) / Terraform Enterprise | Latest |
| [Terraform](https://www.terraform.io/downloads.html) | >= 1.7.0 (for Stacks support) |
| [AWS Account](https://aws.amazon.com) | Active account with OIDC configured |
| [AWS IAM Role](https://aws.amazon.com/iam/) | Role with EKS, VPC, IAM permissions configured for OIDC |

**Note**: For AWS OIDC configuration setup, see: https://github.com/hashi-demo-lab/aws-openid-role-for-stacks

## Modules

This stack uses 6 custom modules:

| Module | Path | Description |
|--------|------|-------------|
| **aws-vpc** | `./modules/aws-vpc` | Creates multi-AZ VPC with public/private subnets |
| **aws-eks-fargate** | `./modules/aws-eks-fargate` | Deploys EKS cluster with Fargate profiles |
| **aws-eks-addon** | `./modules/aws-eks-addon` | Installs EKS add-ons and Load Balancer Controller |
| **k8s-namespace** | `./modules/k8s-namespace` | Creates Kubernetes namespace |
| **k8s-rbac** | `./modules/k8s-rbac` | Configures RBAC for HCP Terraform access |
| **hashibank-deploy** | `./modules/hashibank-deploy` | Deploys demo banking application |

See individual module README files in `./modules/*/README.md` for detailed documentation.

## Required Inputs

| Name | Description | Type | Example |
|------|-------------|------|---------|
| `aws_identity_token` | Ephemeral AWS identity token (auto-generated) | `string` | `identity_token.aws.jwt` |
| `k8s_identity_token` | Ephemeral Kubernetes identity token (auto-generated) | `string` | `identity_token.k8s.jwt` |
| `role_arn` | ARN of IAM role for AWS operations | `string` | `arn:aws:iam::123456789012:role/tfc-role` |
| `cluster_name` | Name of the EKS cluster | `string` | `eksdev` |
| `vpc_name` | Name of the VPC | `string` | `vpc-dev` |
| `vpc_cidr` | CIDR block for VPC | `string` | `10.0.0.0/16` |
| `tfc_organization_name` | HCP Terraform organization name | `string` | `my-org` |

## Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `regions` | AWS regions for deployment | `set(string)` | `["ca-central-1"]` |
| `kubernetes_version` | EKS Kubernetes version | `string` | `"1.29"` |
| `namespace` | Kubernetes namespace for app | `string` | `"hashibank"` |
| `tfc_hostname` | Terraform Cloud hostname | `string` | `"https://app.terraform.io"` |
| `tfc_kubernetes_audience` | OIDC audience for K8s | `string` | `"k8s.workload.identity"` |
| `create_clusteradmin_role` | Create new IAM role for admin | `bool` | `false` |
| `clusteradmin_role_name` | Name for created admin role | `string` | `""` (auto-generated) |
| `eks_clusteradmin_arn` | Existing IAM principal ARN for admin | `string` | `""` |
| `eks_clusteradmin_username` | Username for existing IAM principal | `string` | `""` |

### EKS Cluster Admin Access Options

You have three options for cluster admin access:

**Option 1: Create a new IAM role** (recommended for automation)
```hcl
create_clusteradmin_role = true
clusteradmin_role_name   = "eksdev-admin"  # optional
```

**Option 2: Use an existing IAM role/user**
```hcl
create_clusteradmin_role  = false
eks_clusteradmin_arn      = "arn:aws:iam::123456789012:role/MyAdminRole"
eks_clusteradmin_username = "my-admin"
```

**Option 3: Cluster creator only** (no additional admin)
```hcl
create_clusteradmin_role = false
# Don't provide arn/username
```

## Resources Created

This stack creates the following AWS and Kubernetes resources:

### AWS Resources

- **VPC**: 1 VPC per region
  - 3 Public Subnets (one per AZ)
  - 3 Private Subnets (one per AZ)
  - 1 Internet Gateway
  - 1 NAT Gateway
  - Route Tables and Routes
  - EKS subnet tags

- **EKS**: 1 Cluster per region
  - EKS Control Plane
  - 2+ Fargate Profiles (kube-system, app namespaces)
  - OIDC Identity Provider
  - Cluster Access Entry (optional)
  - Optional IAM Role for admin

- **IAM**: Per cluster
  - EKS Cluster IAM Role
  - Fargate Pod Execution Role
  - IRSA Role for AWS Load Balancer Controller
  - Optional Cluster Admin Role

- **EKS Add-ons**:
  - CoreDNS
  - kube-proxy
  - VPC-CNI

### Kubernetes Resources

- **Namespaces**: 
  - kube-system (default)
  - Application namespace (default: hashibank)

- **RBAC**:
  - ClusterRoleBinding for HCP Terraform organization

- **Workloads**:
  - AWS Load Balancer Controller Deployment
  - HashiBank Demo Application Deployment
  - Supporting Services and ConfigMaps

- **Networking**:
  - Ingress for HashiBank (creates ALB)
  - Services for applications

## Outputs

### Stack-Level Outputs

After deployment, the stack provides outputs for each region:

| Output | Description | Example |
|--------|-------------|---------|
| `vpc_id` | VPC ID | `vpc-0123456789abcdef0` |
| `private_subnets` | List of private subnet IDs | `["subnet-abc...", "subnet-def..."]` |
| `cluster_name` | EKS cluster name | `eksdev` |
| `cluster_endpoint` | EKS API endpoint | `https://ABC123...eks.amazonaws.com` |
| `cluster_version` | EKS Kubernetes version | `1.30` |
| `oidc_provider_arn` | OIDC provider ARN | `arn:aws:iam::123...` |
| `clusteradmin_role_arn` | Admin role ARN (if created) | `arn:aws:iam::123.../eksdev-admin` |
| `clusteradmin_role_name` | Admin role name | `eksdev-admin` |
| `namespace` | Application namespace | `hashibank` |

### Accessing Outputs

Outputs are accessible via HCP Terraform UI or can be retrieved programmatically through the Terraform Cloud API.

## Resource Management

### Destroying Resources

To destroy all resources managed by this Terraform Stack:

1. **Set the destroy flag to true** in `deployments.tfdeploy.hcl`:

```hcl
deployment "development" {
  destroy = true  # Set to true to destroy all resources
  inputs = {
    ...
  }
}
```

2. **Apply the change** - Terraform Stacks will automatically destroy all resources in the proper dependency order

3. **To recreate**, set `destroy = false` and apply again

<!-- BEGIN_TF_DOCS -->
# HCP Vault Bootstrap

This Terraform configuration bootstraps HashiCorp Vault with authentication methods, policies, users, and groups for administrative access and HCP Terraform integration.

## Permissions

### Vault Provider Permissions

The Vault provider requires a token with sufficient permissions to:

- Create and manage authentication methods (`sys/auth/*`)
- Create and manage policies (`sys/policies/acl/*`)
- Create and manage identity entities and groups (`identity/*`)
- Configure authentication backends and roles

## Authentication

### Vault Provider Authentication

Configure the Vault provider using environment variables:

- `VAULT_ADDR` - The address of the Vault server (e.g., `https://vault.example.com:8200`)
- `VAULT_TOKEN` - A Vault token with appropriate permissions
- `VAULT_NAMESPACE` - (Optional) The Vault namespace to use

## Features

- **Userpass Authentication**: Configures userpass auth method at `userpass-admin` path for administrative access
- **User Management**: Creates two administrative users:
  - `superadmin` - User with root policy (full access)
  - `admin` - User with admin policy (administrative capabilities)
- **Policy Management**: Manages policies from external HCL files:
  - Root policy (`policies/root.hcl`) - Full access to all Vault paths
  - Admin policy (`policies/admins.hcl`) - Administrative permissions
- **Identity System**: Configures Vault identity entities, groups, and aliases for centralized access management
- **JWT Authentication**: Enables JWT/OIDC authentication for HCP Terraform integration
- **HCP Terraform Integration**: Configures JWT role for HCP Terraform workloads in the "HCP Vault" project
- **Random Password Generation**: Generates secure, complex passwords for all users (24 characters with special characters)

## Documentation

## Requirements

No requirements.

## Modules

No modules.

## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Resources

No resources.

## Outputs

No outputs.

<!-- markdownlint-enable -->
<!-- markdownlint-disable-next-line MD041 -->
## External Documentation

This configuration was built using the following official documentation:

- [Vault Provider Documentation](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Vault Userpass Auth Method](https://developer.hashicorp.com/vault/docs/auth/userpass)
- [Vault JWT/OIDC Auth Method](https://developer.hashicorp.com/vault/docs/auth/jwt)
- [Vault Policies](https://developer.hashicorp.com/vault/docs/concepts/policies)
- [Vault Identity System](https://developer.hashicorp.com/vault/docs/secrets/identity)
- [HCP Terraform Dynamic Provider Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)
<!-- END_TF_DOCS -->