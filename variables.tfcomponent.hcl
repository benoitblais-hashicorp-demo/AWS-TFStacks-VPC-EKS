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

variable "role_arn" {
  description = "(Required) ARN of the IAM role to assume for AWS operations"
  type        = string
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

variable "create_clusteradmin_role" {
  description = "(Optional) Whether to create a new IAM role for EKS cluster admin access. If true, a role will be created. If false, you must provide eks_clusteradmin_arn and eks_clusteradmin_username."
  type        = bool
  default     = false
}

variable "clusteradmin_role_name" {
  description = "(Optional) Name for the IAM role to create for cluster admin access. Only used if create_clusteradmin_role is true. Defaults to '<cluster_name>-clusteradmin' if not specified."
  type        = string
  default     = ""
}

variable "eks_clusteradmin_arn" {
  description = "(Optional) ARN of an existing IAM role or user to grant cluster admin access. Only used if create_clusteradmin_role is false. Leave empty to skip additional admin access."
  type        = string
  default     = ""
}

variable "eks_clusteradmin_username" {
  description = "(Optional) Username to assign to the existing IAM principal for cluster admin access. Only used if create_clusteradmin_role is false and eks_clusteradmin_arn is provided."
  type        = string
  default     = ""
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
