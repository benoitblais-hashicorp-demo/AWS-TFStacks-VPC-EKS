# Kubernetes RBAC Configuration

This Terraform module configures Kubernetes Role-Based Access Control (RBAC) by creating a cluster role binding that grants cluster admin privileges to HCP Terraform/Terraform Cloud workload identities via OIDC authentication.

## Permissions

### Kubernetes Provider Permissions

The Kubernetes provider requires a service account or user with sufficient permissions to:

- Create cluster role bindings (`clusterrolebindings` resource with `create` verb)
- Manage cluster-wide RBAC (`rbac.authorization.k8s.io` API group access)
- Read cluster roles (`clusterroles` resource with `get` verb)

Required RBAC permissions example:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: rbac-manager
rules:
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["clusterrolebindings", "clusterroles"]
  verbs: ["create", "delete", "get", "list", "patch", "update"]
```

**Note**: This module requires cluster-admin level access to create cluster role bindings that grant admin privileges.

## Authentication

### Kubernetes Provider Authentication

Configure the Kubernetes provider using one of the following methods:

- **Kubeconfig File**:
  - Default location: `~/.kube/config`
  - Specify with `KUBECONFIG` environment variable
  - Provider configuration: `config_path = "~/.kube/config"`

- **In-Cluster Configuration**:
  - Automatically used when running inside Kubernetes
  - Uses service account token at `/var/run/secrets/kubernetes.io/serviceaccount/token`

- **EKS Cluster Authentication** (used in this stack):
  - Cluster endpoint URL
  - Cluster CA certificate data
  - AWS authentication via `aws eks get-token` command
  - Requires AWS credentials with EKS describe permissions

- **OIDC Token Authentication**:
  - Bearer token from identity provider
  - Used by HCP Terraform workload identity
  - Mapped to Kubernetes groups via cluster role binding

- **Client Certificates**:
  - TLS client certificate and private key
  - Certificate must be signed by cluster CA

## Features

- **OIDC Identity Integration**: Enables HCP Terraform/Terraform Cloud to authenticate to Kubernetes using OIDC tokens
- **Cluster Admin Access**: Grants full cluster administration privileges to the HCP Terraform organization
- **Group-Based Authorization**: Maps HCP Terraform organization to Kubernetes RBAC group
- **Dynamic Name Generation**: Uses `generate_name` for automatic unique binding names
- **Workload Identity Support**: Prerequisite for HCP Terraform Stacks Kubernetes operations
- **Zero Credentials Storage**: No need to store Kubernetes credentials in HCP Terraform
- **Secure Authentication**: Leverages OIDC federation for temporary, scoped access
- **Organization-Level Binding**: Single configuration applies to entire HCP Terraform organization

## Usage

```hcl
module "k8s_rbac" {
  source = "./k8s-rbac"

  cluster_endpoint          = "https://ABCD1234EFGH5678IJKL.gr7.us-east-1.eks.amazonaws.com"
  tfc_organization_name     = "my-terraform-org"
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role_binding_v1.oidc_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_tfc_organization_name"></a> [tfc\_organization\_name](#input\_tfc\_organization\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_binding_id"></a> [oidc\_binding\_id](#output\_oidc\_binding\_id) | n/a |
