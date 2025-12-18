output "oidc_binding_id" {
  value = length(kubernetes_cluster_role_binding_v1.oidc_role) > 0 ? kubernetes_cluster_role_binding_v1.oidc_role[0].id : null
}