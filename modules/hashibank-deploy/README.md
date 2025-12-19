# HashiBank Application Deployment

This Terraform module deploys the HashiBank demo application to a Kubernetes cluster, including the deployment, service, and ingress resources for exposing the application via AWS Load Balancer Controller.

## Permissions

### Kubernetes Provider Permissions

The Kubernetes provider requires a service account or user with sufficient permissions to:

- Create and manage deployments (`apps/v1` API group, `deployments` resource with `create`, `update`, `delete`, `get` verbs)
- Create and manage services (`v1` API group, `services` resource with `create`, `update`, `delete`, `get` verbs)
- Create and manage ingresses (`networking.k8s.io/v1` API group, `ingresses` resource with `create`, `update`, `delete`, `get` verbs)
- Read and manage pods (`v1` API group, `pods` resource with `get`, `list`, `watch` verbs)

Required RBAC permissions example:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: hashibank-deployer
  namespace: hashibank
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["create", "delete", "get", "list", "patch", "update"]
- apiGroups: [""]
  resources: ["services", "pods"]
  verbs: ["create", "delete", "get", "list", "patch", "update"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["create", "delete", "get", "list", "patch", "update"]
```

### Time Provider Permissions

No special permissions required (logical provider for time-based operations).

## Authentication

### Kubernetes Provider Authentication

Configure the Kubernetes provider using one of the following methods:

- **Kubeconfig File**:
  - Default location: `~/.kube/config`
  - Set via `KUBECONFIG` environment variable
  - Supports multiple contexts and clusters

- **In-Cluster Configuration**:
  - Automatic when running inside Kubernetes pod
  - Uses mounted service account token

- **EKS Cluster Authentication**:
  - Cluster endpoint URL
  - Cluster CA certificate
  - AWS authentication token via `aws eks get-token`
  - Requires AWS IAM permissions for EKS

- **OIDC Authentication** (HCP Terraform):
  - Workload identity tokens
  - RBAC configured via k8s-rbac module
  - No static credentials needed

### Time Provider Authentication

No authentication required - logical provider for resource timing.

## Features

- **HashiBank Demo Application**: Deploys the HashiBank banking demo application (version 0.0.3)
- **Development Mode**: Runs in development mode with in-memory data storage
- **Fargate Optimized**: Resource requests and limits configured for AWS Fargate:
  - CPU requests: 100m, limits: 200m
  - Memory requests: 128Mi, limits: 256Mi
- **Single Replica**: Configured for demo/development with 1 replica
- **Service Exposure**: ClusterIP service on port 80, routing to container port 8080
- **Ingress Configuration**: ALB ingress with:
  - Internet-facing Application Load Balancer
  - IP target type for Fargate compatibility
  - Health check path configured to `/`
  - Automatic DNS name from ALB
- **Wait Time Management**: 60-second delay after deployment to allow ingress controller setup
- **Non-Blocking Deployment**: `wait_for_rollout = false` for faster Terraform applies
- **Target Group Binding**: Direct pod-to-ALB target group binding for Fargate
- **Auto-Scaling Ready**: Can be extended with HPA (Horizontal Pod Autoscaler)

## Usage

```hcl
module "hashibank_deploy" {
  source = "./hashibank-deploy"

  hashibank_namespace = "hashibank"
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.hashibank](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.hashibank](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_service_v1.hashibank](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hashibank_namespace"></a> [hashibank\_namespace](#input\_hashibank\_namespace) | hashibank namespace | `string` | n/a | yes |
