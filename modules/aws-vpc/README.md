# AWS VPC

This Terraform module creates an Amazon VPC with public and private subnets across multiple availability zones, configured for EKS workloads with appropriate subnet tagging.

## Permissions

### AWS Provider Permissions

The AWS provider requires an IAM role or user with sufficient permissions to:

- Create and manage VPCs (`ec2:CreateVpc`, `ec2:DeleteVpc`, `ec2:DescribeVpcs`)
- Create and manage subnets (`ec2:CreateSubnet`, `ec2:DeleteSubnet`, `ec2:DescribeSubnets`)
- Create and manage internet gateways (`ec2:CreateInternetGateway`, `ec2:DeleteInternetGateway`)
- Create and manage NAT gateways (`ec2:CreateNatGateway`, `ec2:DeleteNatGateway`)
- Create and manage route tables (`ec2:CreateRouteTable`, `ec2:DeleteRouteTable`, `ec2:CreateRoute`)
- Create and manage elastic IPs (`ec2:AllocateAddress`, `ec2:ReleaseAddress`)
- Manage tags (`ec2:CreateTags`, `ec2:DeleteTags`)
- Query availability zones (`ec2:DescribeAvailabilityZones`)

## Authentication

### AWS Provider Authentication

Configure the AWS provider using one of the following methods:

- **Environment Variables**:
  - `AWS_ACCESS_KEY_ID` - AWS access key
  - `AWS_SECRET_ACCESS_KEY` - AWS secret key
  - `AWS_SESSION_TOKEN` - (Optional) AWS session token for temporary credentials
  - `AWS_REGION` - AWS region

- **AWS IAM Role** (recommended for CI/CD):
  - Use IAM roles for service accounts (IRSA) in EKS
  - Use IAM roles in EC2 instances
  - Use OIDC federation with HCP Terraform

- **Shared Credentials File**:
  - Default location: `~/.aws/credentials`
  - Specify profile with `AWS_PROFILE` environment variable

## Features

- **Multi-AZ VPC**: Creates VPC across 3 availability zones for high availability
- **Public Subnets**: Configured with internet gateway access for load balancers
- **Private Subnets**: Isolated subnets for EKS worker nodes and pods with NAT gateway access
- **NAT Gateway**: Single NAT gateway for cost optimization (can be configured for HA)
- **EKS Integration**: Automatic subnet tagging for EKS load balancer discovery
  - Public subnets tagged for external load balancers
  - Private subnets tagged for internal load balancers
- **CIDR Calculation**: Automatic subnet CIDR calculation based on VPC CIDR block
- **Resource Tagging**: Consistent tagging with Blueprint label for resource organization

## Usage

```hcl
module "vpc" {
  source = "./aws-vpc"

  vpc_name = "my-eks-vpc"
  vpc_cidr = "10.0.0.0/16"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | private subnet ids |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | private route table id |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | vpc id |
