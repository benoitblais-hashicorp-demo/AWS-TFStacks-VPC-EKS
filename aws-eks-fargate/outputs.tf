output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = length(module.eks) > 0 ? "aws eks --region ${var.region} update-kubeconfig --name ${module.eks[0].cluster_name}" : null
}

output "cluster_name" {
  description = "eks cluster_name"
  value       = length(module.eks) > 0 ? module.eks[0].cluster_name : null
}

output "cluster_endpoint" {
  description = "eks cluster_endpoint"
  value       = length(module.eks) > 0 ? module.eks[0].cluster_endpoint : null
}

output "cluster_version" {
  description = "eks cluster_version"
  value       = length(module.eks) > 0 ? module.eks[0].cluster_version : null
}

output "oidc_provider_arn" {
  description = "eks idc_provider_arn"
  value       = length(module.eks) > 0 ? module.eks[0].oidc_provider_arn : null
}

output "cluster_certificate_authority_data" {
  description = "eks output cluster_certificate_authority_data"
  value       = length(module.eks) > 0 ? module.eks[0].cluster_certificate_authority_data : null
}

output "eks_token" {
  value     = length(data.aws_eks_cluster_auth.upstream_auth) > 0 ? data.aws_eks_cluster_auth.upstream_auth[0].token : null
  sensitive = true
}