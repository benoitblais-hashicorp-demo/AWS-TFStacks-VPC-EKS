output "vpc_id" {
  description = "vpc id"
  value       = length(module.vpc) > 0 ? module.vpc[0].vpc_id : null
}

output "private_subnets" {
  description = "private subnet ids"
  value       = length(module.vpc) > 0 ? module.vpc[0].private_subnets : null
}

output "route_table_id" {
  description = "private route table id"
  value       = length(module.vpc) > 0 ? module.vpc[0].private_route_table_ids : null
} 