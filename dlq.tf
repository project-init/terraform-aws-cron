resource "aws_sqs_queue" "deadletter_queue" {
  name                       = "${var.service_name}-cron-${var.cron_name}-DLQ"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 43200
  sqs_managed_sse_enabled    = true
}