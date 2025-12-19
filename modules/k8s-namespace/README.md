# Kubernetes Namespace

This Terraform module creates a Kubernetes namespace with custom annotations and labels for organizing and isolating application workloads within an EKS cluster.

## Permissions

### Kubernetes Provider Permissions

The Kubernetes provider requires a service account or user with sufficient permissions to:

- Create namespaces (`kubectl create namespace` or RBAC: `namespaces` resource with `create` verb)
- Manage namespace metadata (`namespaces` resource with `update`, `patch` verbs)
- Read namespace information (`namespaces` resource with `get`, `list` verbs)

Required RBAC permissions example:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-manager
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["create", "delete", "get", "list", "patch", "update"]
```

## Authentication

### Kubernetes Provider Authentication

Configure the Kubernetes provider using one of the following methods:

- **Kubeconfig File**:
  - Default location: `~/.kube/config`
  - Specify with `KUBECONFIG` environment variable
  - Can specify path in provider configuration

- **In-Cluster Configuration**:
  - Automatically used when running inside a Kubernetes pod
  - Uses service account token mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`

- **EKS Cluster Authentication**:
  - Cluster endpoint URL
  - Cluster CA certificate
  - AWS authentication token via `aws eks get-token`

- **Service Account Token**:
  - Bearer token for service account authentication
  - Useful for CI/CD pipelines

- **Client Certificates**:
  - TLS client certificate and key
  - Less common, typically used for legacy systems

## Features

- **Namespace Creation**: Creates a dedicated Kubernetes namespace for workload isolation
- **Custom Annotations**: Supports custom annotations for metadata and integration with tools
- **Custom Labels**: Applies labels for resource organization and selector-based operations
- **Declarative Management**: Manages namespace lifecycle through Terraform state
- **Idempotent Operations**: Safe to run multiple times without side effects
- **Integration Ready**: Designed to work with EKS add-ons and wait for cluster readiness

## Usage

```hcl
module "k8s_namespace" {
  source = "./k8s-namespace"

  namespace = "my-application"
  labels = {
    environment = "production"
    team        = "platform"
  }
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
| [kubernetes_namespace_v1.example](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `any` | <pre>{<br/>  "mylabel": "example-label"<br/>}</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | n/a |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.25 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.25 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.example](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `any` | <pre>{<br/>  "mylabel": "example-label"<br/>}</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | n/a |
<!-- END_TF_DOCS -->