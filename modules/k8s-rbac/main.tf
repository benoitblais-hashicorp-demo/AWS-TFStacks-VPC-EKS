
# Wait for EKS cluster to be fully ready
resource "time_sleep" "wait_for_cluster" {
  create_duration = "30s"

  # Trigger on cluster endpoint to ensure it exists
  triggers = {
    cluster_endpoint = var.cluster_endpoint
  }
}

# odic-identity pre-requisite
resource "kubernetes_cluster_role_binding_v1" "oidc_role" {
  depends_on = [time_sleep.wait_for_cluster]
  
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
