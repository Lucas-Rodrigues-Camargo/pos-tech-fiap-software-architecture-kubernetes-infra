resource "datadog_logs_metric" "phase4_volume" {
  count = local.datadog_enabled ? 1 : 0
  name  = "oficina.phase4.orders"
  filter { query = "service:oficina-os @State.EventType:OpenOrder" }
  compute { aggregation_type = "count" }
}
resource "datadog_logs_metric" "phase4_duration" {
  count = local.datadog_enabled ? 1 : 0
  name  = "oficina.phase4.duration_seconds"
  filter { query = "service:(oficina-os OR oficina-billing OR oficina-execution) @State.DurationSeconds:*" }
  compute {
    aggregation_type = "distribution"
    path             = "@State.DurationSeconds"
  }
  group_by {
    path     = "@State.FromStatus"
    tag_name = "status"
  }
}
resource "datadog_logs_metric" "phase4_errors" {
  count = local.datadog_enabled ? 1 : 0
  name  = "oficina.phase4.errors"
  filter { query = "service:(oficina-os OR oficina-billing OR oficina-execution) status:error" }
  compute { aggregation_type = "count" }
}
resource "datadog_monitor" "phase4_failure" {
  count   = local.datadog_enabled ? 1 : 0
  name    = "Oficina Phase 4 — failures in distributed processing"
  type    = "metric alert"
  message = "Inspect correlationId/orderId, SQS DLQ and compensation history. Never mark a pending refund as canceled."
  query   = "sum(last_5m):sum:oficina.phase4.errors{*}.as_count() > 0"
  monitor_thresholds { critical = 0 }
  notify_no_data = false
}
resource "datadog_dashboard_json" "phase4" {
  count = local.datadog_enabled ? 1 : 0
  dashboard = jsonencode({
    title       = "Oficina — Fase 4 microsserviços"
    layout_type = "ordered"
    widgets = [
      { definition = {
        type     = "timeseries", title = "Volume diário de OS"
        requests = [{ q = "sum:oficina.phase4.orders{*}.as_count().rollup(sum,86400)", display_type = "bars" }]
      } },
      { definition = {
        type     = "timeseries", title = "Tempo médio por status em segundos"
        requests = [{ q = "avg:oficina.phase4.duration_seconds{*} by {status}", display_type = "line" }]
      } },
      { definition = {
        type     = "timeseries", title = "Falhas de integração e processamento"
        requests = [{ q = "sum:oficina.phase4.errors{*}.as_count()", display_type = "bars" }]
      } },
      { definition = {
        type     = "timeseries", title = "CPU por serviço"
        requests = [{ q = "avg:kubernetes.cpu.usage.total{kube_namespace:oficina-phase4} by {kube_deployment}", display_type = "line" }]
      } }
    ]
  })
}
