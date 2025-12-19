# AWS EKS Fargate

This Terraform module creates an Amazon EKS cluster configured to run workloads exclusively on AWS Fargate, eliminating the need to provision and manage EC2 worker nodes.

## Permissions

### AWS Provider Permissions

The AWS provider requires an IAM role or user with sufficient permissions to:

- Create and manage EKS clusters (`eks:CreateCluster`, `eks:DeleteCluster`, `eks:DescribeCluster`)
- Create and manage Fargate profiles (`eks:CreateFargateProfile`, `eks:DeleteFargateProfile`)
- Create and manage IAM roles and policies (`iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PassRole`)
- Create and manage security groups (`ec2:CreateSecurityGroup`, `ec2:AuthorizeSecurityGroupIngress`)
- Configure cluster access entries (`eks:CreateAccessEntry`, `eks:AssociateAccessPolicy`)
- Enable OIDC provider for IRSA (`iam:CreateOpenIDConnectProvider`)
- Manage cluster logging configuration (`eks:UpdateClusterConfig`)

### Additional Provider Permissions

- **CloudInit**: No special permissions required (used for local rendering)
- **Kubernetes**: Requires cluster admin access for initial configuration
- **Time**: No special permissions required (logical provider)
- **TLS**: No special permissions required (logical provider)

## Authentication

### AWS Provider Authentication

Configure the AWS provider using one of the following methods:

- **Environment Variables**:
  - `AWS_ACCESS_KEY_ID` - AWS access key
  - `AWS_SECRET_ACCESS_KEY` - AWS secret key
  - `AWS_SESSION_TOKEN` - (Optional) AWS session token
  - `AWS_REGION` - AWS region

- **AWS IAM Role** (recommended):
  - OIDC federation with HCP Terraform/Terraform Cloud
  - IAM roles for service accounts (IRSA)
  - EC2 instance profiles

### Kubernetes Provider Authentication

The Kubernetes provider automatically authenticates using:
- EKS cluster endpoint
- Cluster certificate authority data
- AWS authentication token via `aws eks get-token`

## Features

- **Serverless EKS**: Fully managed Kubernetes control plane with Fargate compute
- **Multiple Fargate Profiles**: Pre-configured profiles for different namespace patterns:
  - Application namespaces (`hashibank*`, `product*`, `consul*`, `frontend*`, `payments*`)
  - System namespaces (`kube-system`)
- **IRSA Support**: IAM Roles for Service Accounts (IRSA) enabled for pod-level IAM permissions
- **Public API Access**: Cluster endpoint accessible publicly (can be restricted)
- **Cluster Admin Access**: Configurable admin access entry with EKSClusterAdminPolicy
- **Security Optimization**: Uses cluster primary security group, eliminates need for additional security groups
- **Cost Optimization**: Cluster logging disabled by default (lab environment)
- **Extended Timeouts**: 30-minute timeouts for Fargate profile operations to handle AWS API delays
- **Identity Provider Integration**: Configurable for HCP Terraform/Terraform Cloud workload identity
- **OIDC Provider Configuration**: Automatic OIDC provider setup for service account authentication

## Usage

**Option 1: Create a new IAM role for cluster admin access**

```hcl
module "eks" {
  source = "./aws-eks-fargate"

  vpc_id                        = "vpc-0123456789abcdef0"
  private_subnets               = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  kubernetes_version            = "1.30"
  cluster_name                  = "my-eks-cluster"
  tfc_hostname                  = "https://app.terraform.io"
  tfc_kubernetes_audience       = "k8s.workload.identity"
  
  # Create a new IAM role for cluster admin
  create_clusteradmin_role      = true
  clusteradmin_role_name        = "my-eks-cluster-admin"  # Optional
}
```

**Option 2: Use an existing IAM role/user for cluster admin access**

```hcl
module "eks" {
  source = "./aws-eks-fargate"

  vpc_id                        = "vpc-0123456789abcdef0"
  private_subnets               = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  kubernetes_version            = "1.30"
  cluster_name                  = "my-eks-cluster"
  tfc_hostname                  = "https://app.terraform.io"
  tfc_kubernetes_audience       = "k8s.workload.identity"
  
  # Use existing IAM principal
  create_clusteradmin_role      = false
  eks_clusteradmin_arn          = "arn:aws:iam::123456789012:role/EKSClusterAdmin"
  eks_clusteradmin_username     = "cluster-admin"
}
```

**Option 3: Skip additional admin access (cluster creator only)**

```hcl
module "eks" {
  source = "./aws-eks-fargate"

  vpc_id                        = "vpc-0123456789abcdef0"
  private_subnets               = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  kubernetes_version            = "1.30"
  cluster_name                  = "my-eks-cluster"
  tfc_hostname                  = "https://app.terraform.io"
  tfc_kubernetes_audience       = "k8s.workload.identity"
  
  # No additional admin access - only cluster creator
  create_clusteradmin_role      = false
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_identity_provider_config.oidc_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_identity_provider_config) | resource |
| [aws_eks_cluster.upstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.upstream_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | `"eks-cluster"` | no |
| <a name="input_eks_clusteradmin_arn"></a> [eks\_clusteradmin\_arn](#input\_eks\_clusteradmin\_arn) | n/a | `string` | n/a | yes |
| <a name="input_eks_clusteradmin_username"></a> [eks\_clusteradmin\_username](#input\_eks\_clusteradmin\_username) | n/a | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | n/a | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-2"` | no |
| <a name="input_tfc_hostname"></a> [tfc\_hostname](#input\_tfc\_hostname) | n/a | `string` | `"https://app.terraform.io"` | no |
| <a name="input_tfc_kubernetes_audience"></a> [tfc\_kubernetes\_audience](#input\_tfc\_kubernetes\_audience) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | eks output cluster\_certificate\_authority\_data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | eks cluster\_endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | eks cluster\_name |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | eks cluster\_version |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_eks_token"></a> [eks\_token](#output\_eks\_token) | n/a |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | eks idc\_provider\_arn |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_identity_provider_config.oidc_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_identity_provider_config) | resource |
| [aws_iam_role.eks_clusteradmin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.upstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.upstream_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | `"eks-cluster"` | no |
| <a name="input_clusteradmin_role_name"></a> [clusteradmin\_role\_name](#input\_clusteradmin\_role\_name) | Name for the IAM role to create for cluster admin access (only used if create\_clusteradmin\_role is true) | `string` | `""` | no |
| <a name="input_create_clusteradmin_role"></a> [create\_clusteradmin\_role](#input\_create\_clusteradmin\_role) | Whether to create a new IAM role for cluster admin access. If false, must provide eks\_clusteradmin\_arn and eks\_clusteradmin\_username | `bool` | `false` | no |
| <a name="input_eks_clusteradmin_arn"></a> [eks\_clusteradmin\_arn](#input\_eks\_clusteradmin\_arn) | ARN of existing IAM role/user to grant cluster admin access (only used if create\_clusteradmin\_role is false) | `string` | `""` | no |
| <a name="input_eks_clusteradmin_username"></a> [eks\_clusteradmin\_username](#input\_eks\_clusteradmin\_username) | Username for cluster admin access (only used if create\_clusteradmin\_role is false) | `string` | `""` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | n/a | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-2"` | no |
| <a name="input_tfc_hostname"></a> [tfc\_hostname](#input\_tfc\_hostname) | n/a | `string` | `"https://app.terraform.io"` | no |
| <a name="input_tfc_kubernetes_audience"></a> [tfc\_kubernetes\_audience](#input\_tfc\_kubernetes\_audience) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | eks output cluster\_certificate\_authority\_data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | eks cluster\_endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | eks cluster\_name |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | eks cluster\_version |
| <a name="output_clusteradmin_role_arn"></a> [clusteradmin\_role\_arn](#output\_clusteradmin\_role\_arn) | ARN of the created cluster admin IAM role (if created) |
| <a name="output_clusteradmin_role_name"></a> [clusteradmin\_role\_name](#output\_clusteradmin\_role\_name) | Name of the cluster admin IAM role (created or provided) |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_eks_token"></a> [eks\_token](#output\_eks\_token) | n/a |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | eks idc\_provider\_arn |
<!-- END_TF_DOCS -->