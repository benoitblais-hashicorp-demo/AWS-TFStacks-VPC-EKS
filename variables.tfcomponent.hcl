# variable "aws_auth_roles" {
#   description = "List of IAM roles to map to Kubernetes RBAC groups for EKS cluster authentication."
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))
#   default = []
# }

variable "aws_identity_token" {
  description = "(Required) Ephemeral AWS identity token for authentication with AWS services."
  type        = string
  ephemeral   = true
  sensitive   = true
}

variable "cluster_name" {
  description = "(Required) Name of the EKS cluster to be created."
  type        = string
}

variable "k8s_identity_token" {
  description = "(Required) Ephemeral Kubernetes identity token for authentication with the Kubernetes cluster."
  type        = string
  ephemeral   = true
  sensitive   = true
}

variable "tfc_organization_name" {
  description = "(Required) Name of the Terraform Cloud organization"
  type        = string
}

variable "vpc_cidr" {
  description = "(Required) CIDR block for the VPC network"
  type        = string
}

variable "vpc_name" {
  description = "(Required) Name of the VPC to be created"
  type        = string
}

variable "delete" {
  description = "(Optional) Flag to indicate whether resources should be deleted."
  type        = bool
  default     = false
}

# to change to create a new one
variable "eks_clusteradmin_arn" {
  description = "(Optional) ARN of the IAM role or user to grant cluster admin access in EKS."
  type        = string
}

# to change to create a new one
variable "eks_clusteradmin_username" {
  description = "(Optional) Username to assign to the EKS cluster administrator."
  type        = string
}

variable "kubernetes_version" {
  description = "(Optional) Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "namespace" {
  description = "(Optional) Kubernetes namespace for application deployment"
  type        = string
  default     = "hashibank"
}

variable "regions" {
  description = "(Optional) Set of AWS regions where resources will be deployed"
  type        = set(string)
  default     = ["ca-central-1"]
}

# to change to create a new one
variable "role_arn" {
  description = "(Optional) ARN of the IAM role to assume for AWS operations"
  type        = string
}

variable "tfc_hostname" {
  description = "(Optional) Hostname of the Terraform Cloud or Terraform Enterprise instance"
  type        = string
  default     = "https://app.terraform.io"
}

variable "tfc_kubernetes_audience" {
  description = "(Optional) Audience value for Terraform Cloud workload identity federation with Kubernetes"
  type        = string
  default     = "k8s.workload.identity"
}

# variable "workload_idp_name" {
#   description = "Name of the workload identity provider for TFStacks authentication"
#   type = string
#   default = "tfstacks-workload-identity-provider"
# }
