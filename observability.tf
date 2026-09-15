locals {
  datadog_enabled = var.datadog_api_key != "" && var.datadog_app_key != ""
}

resource "datadog_logs_metric" "orders_created" {
  count = local.datadog_enabled ? 1 : 0
  name  = "oficina.service_orders.created"
  filter { query = "service:oficina-api @Status:Received" }
  compute { aggregation_type = "count" }
}

resource "datadog_logs_metric" "status_duration" {
  count = local.datadog_enabled ? 1 : 0
  name  = "oficina.service_orders.status_duration_hours"
  filter { query = "service:oficina-api @EventType:ServiceOrderStatusChanged" }
  compute {
    aggregation_type = "distribution"
    path             = "@DurationHours"
  }
  group_by {
    path     = "@Status"
    tag_name = "status"
  }
}

resource "datadog_logs_metric" "integration_errors" {
  count = local.datadog_enabled ? 1 : 0
  name  = "oficina.integrations.errors"
  filter { query = "service:oficina-api status:error" }
  compute { aggregation_type = "count" }
}

resource "datadog_dashboard_json" "operations" {
  count = local.datadog_enabled ? 1 : 0
  dashboard = jsonencode({
    title       = "Oficina Mecânica — Operação"
    description = "Volume de OS, duração por status, recursos do Kubernetes e falhas."
    layout_type = "ordered"
    widgets = [
      {
        definition = {
          type     = "timeseries"
          title    = "Volume diário de ordens de serviço"
          requests = [{ q = "sum:oficina.service_orders.created{*}.as_count().rollup(sum,86400)", display_type = "bars" }]
        }
      },
      {
        definition = {
          type     = "timeseries"
          title    = "Tempo médio por status (horas)"
          requests = [{ q = "avg:oficina.service_orders.status_duration_hours{*} by {status}", display_type = "line" }]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "CPU e memória dos pods"
          requests = [
            { q = "avg:kubernetes.cpu.usage.total{kube_namespace:oficina-mecanica} by {pod_name}", display_type = "line" },
            { q = "avg:kubernetes.memory.usage{kube_namespace:oficina-mecanica} by {pod_name}", display_type = "line", on_right_yaxis = true }
          ]
        }
      },
      {
        definition = {
          type      = "query_value"
          title     = "Erros de integração"
          requests  = [{ q = "sum:oficina.integrations.errors{*}.as_count()", aggregator = "sum" }]
          autoscale = true
          precision = 0
        }
      }
    ]
  })
}
