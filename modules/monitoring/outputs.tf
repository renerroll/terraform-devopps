output "prometheus_service_name" {
  description = "Prometheus release name"
  value       = "${helm_release.kube_prometheus_stack.name}-prometheus"
}

output "grafana_service_name" {
  description = "Grafana release name"
  value       = "${helm_release.kube_prometheus_stack.name}-grafana"
}

