
# odic-identity pre-requisite
resource "kubernetes_cluster_role_binding_v1" "oidc_role" {
  count = var.delete ? 0 : 1
  metadata {
    generate_name = "odic-identity"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.tfc_organization_name
  }
}
