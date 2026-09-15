variable "aws_region" {
  description = "Região AWS dos recursos."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo dos recursos."
  type        = string
  default     = "oficina-mecanica"
}

variable "environment" {
  description = "Ambiente acadêmico único."
  type        = string
  default     = "production"
}

variable "kubernetes_version" {
  description = "Versão suportada pelo EKS."
  type        = string
  default     = "1.33"
}

variable "node_instance_types" {
  description = "Tipos EC2 do node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "datadog_api_key" {
  description = "API key do Datadog; vazio desabilita a integração."
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_app_key" {
  description = "Application key do Datadog; vazio desabilita dashboard e métricas de logs."
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_site" {
  type    = string
  default = "datadoghq.com"
}
