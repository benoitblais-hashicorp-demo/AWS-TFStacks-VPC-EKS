variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "tfc_hostname" {
  type    = string
  default = "https://app.terraform.io"
}

variable "tfc_kubernetes_audience" {
  type = string
}

variable "create_clusteradmin_role" {
  description = "Whether to create a new IAM role for cluster admin access. If false, must provide eks_clusteradmin_arn and eks_clusteradmin_username"
  type        = bool
  default     = false
}

variable "clusteradmin_role_name" {
  description = "Name for the IAM role to create for cluster admin access (only used if create_clusteradmin_role is true)"
  type        = string
  default     = ""
}

variable "eks_clusteradmin_arn" {
  description = "ARN of existing IAM role/user to grant cluster admin access (only used if create_clusteradmin_role is false)"
  type        = string
  default     = ""
}

variable "eks_clusteradmin_username" {
  description = "Username for cluster admin access (only used if create_clusteradmin_role is false)"
  type        = string
  default     = ""
}
