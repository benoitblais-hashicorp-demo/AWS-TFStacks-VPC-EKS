# AWS EKS Add-ons

This Terraform module configures essential EKS add-ons and deploys the AWS Load Balancer Controller for managing Application and Network Load Balancers in an EKS cluster running on Fargate.

## Permissions

### AWS Provider Permissions

The AWS provider requires an IAM role or user with sufficient permissions to:

- Manage EKS add-ons (`eks:CreateAddon`, `eks:DeleteAddon`, `eks:DescribeAddon`)
- Create and manage IAM roles and policies for service accounts (`iam:CreateRole`, `iam:AttachRolePolicy`)
- Create and manage IAM OIDC provider (`iam:GetOpenIDConnectProvider`)
- Manage load balancers (`elasticloadbalancing:*`)
- Manage target groups (`elasticloadbalancing:CreateTargetGroup`, `elasticloadbalancing:DeleteTargetGroup`)
- Query EC2 resources (`ec2:DescribeSubnets`, `ec2:DescribeSecurityGroups`, `ec2:DescribeVpcs`)

### Kubernetes Provider Permissions

Requires cluster admin or equivalent permissions to:
- Create and manage Kubernetes service accounts
- Deploy controllers and CRDs
- Manage cluster-wide resources

### Helm Provider Permissions

Requires permissions to:
- Install and manage Helm releases
- Create Kubernetes resources via Helm charts

## Authentication

### AWS Provider Authentication

Configure the AWS provider using:

- **Environment Variables**:
  - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

- **OIDC Federation** (recommended for HCP Terraform):
  - Workload identity with IAM role assumption
  - No long-lived credentials required

### Kubernetes Provider Authentication

Authenticates using:
- EKS cluster endpoint
- Cluster CA certificate
- OIDC-based authentication for service accounts

### Helm Provider Authentication

Inherits Kubernetes provider authentication:
- Uses same cluster credentials as Kubernetes provider
- Requires Tiller-free Helm 3

## Features

- **CoreDNS Add-on**: DNS service optimized for Fargate with appropriate resource limits
  - Configured for Fargate compute type
  - Resource requests/limits set to 0.25 CPU and 256MB memory for cost optimization
  - Fits within smallest Fargate task size (512MB)
- **VPC CNI Add-on**: Amazon VPC Container Network Interface for pod networking
  - Manages IP address allocation for pods
  - Enables pods to have VPC IP addresses
- **Kube-proxy Add-on**: Network proxy for Kubernetes services
  - Maintains network rules on nodes
  - Enables service abstraction
- **AWS Load Balancer Controller**: Manages AWS Elastic Load Balancers for Kubernetes services
  - Provisions Application Load Balancers (ALB) for Ingress resources
  - Provisions Network Load Balancers (NLB) for LoadBalancer services
  - Automatic target registration and health checks
  - Integration with AWS WAF and Shield
- **EKS Blueprints Add-ons**: Uses AWS-maintained module for consistent add-on management
- **Extended Timeouts**: 25-minute create timeout for CoreDNS to handle Fargate provisioning delays
- **IRSA Integration**: Uses IAM Roles for Service Accounts for secure AWS API access
- **Dependency Management**: Waits for RBAC configuration before deploying add-ons

## Usage

```hcl
module "eks_addons" {
  source = "./aws-eks-addon"

  cluster_name                           = "my-eks-cluster"
  vpc_id                                 = "vpc-0123456789abcdef0"
  private_subnets                        = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  cluster_endpoint                       = "https://ABCD1234EFGH5678IJKL.gr7.us-east-1.eks.amazonaws.com"
  cluster_version                        = "1.30"
  oidc_provider_arn                      = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/ABCD1234EFGH5678IJKL"
  cluster_certificate_authority_data     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."
  oidc_binding_id                        = "01234567-89ab-cdef-0123-456789abcdef"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.12 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.25 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | 1.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | n/a | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | n/a | yes |
| <a name="input_oidc_binding_id"></a> [oidc\_binding\_id](#input\_oidc\_binding\_id) | used for component dependency | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argo_workflows"></a> [argo\_workflows](#output\_argo\_workflows) | Map of attributes of the Helm release created |
| <a name="output_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#output\_aws\_load\_balancer\_controller) | Map of attributes of the Helm release and IRSA created |
| <a name="output_eks_addons"></a> [eks\_addons](#output\_eks\_addons) | Map of attributes for each EKS addons enabled |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | 1.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | n/a | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | n/a | yes |
| <a name="input_oidc_binding_id"></a> [oidc\_binding\_id](#input\_oidc\_binding\_id) | used for component dependency | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argo_workflows"></a> [argo\_workflows](#output\_argo\_workflows) | Map of attributes of the Helm release created |
| <a name="output_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#output\_aws\_load\_balancer\_controller) | Map of attributes of the Helm release and IRSA created |
| <a name="output_eks_addons"></a> [eks\_addons](#output\_eks\_addons) | Map of attributes for each EKS addons enabled |
<!-- END_TF_DOCS -->