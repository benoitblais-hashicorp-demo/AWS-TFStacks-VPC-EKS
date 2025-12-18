resource "kubernetes_namespace_v1" "example" {
  count = var.delete ? 0 : 1
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "example-label"
    }

    name = var.namespace
  }
}