output "namespace" {
  value = length(kubernetes_namespace_v1.example) > 0 ? kubernetes_namespace_v1.example[0].metadata[0].name : null
}