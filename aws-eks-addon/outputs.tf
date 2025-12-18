output "argo_workflows" {
  description = "Map of attributes of the Helm release created"
  value       = length(module.eks_blueprints_addons) > 0 ? module.eks_blueprints_addons[0].argo_workflows : null
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = length(module.eks_blueprints_addons) > 0 ? module.eks_blueprints_addons[0].aws_load_balancer_controller : null
}

output "eks_addons" {
  description = "Map of attributes for each EKS addons enabled"
  value       = length(module.eks_blueprints_addons) > 0 ? module.eks_blueprints_addons[0].eks_addons : null
}

