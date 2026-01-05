resource "aws_scheduler_schedule" "cron" {
  name       = "${var.service_name}-${var.environment}-cron-${var.cron_name}"
  group_name = var.group_name
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.schedule_expression
  target {
    arn      = var.ecs_cluster_arn
    role_arn = aws_iam_role.cron.arn
    ecs_parameters {
      task_definition_arn = trimsuffix(aws_ecs_task_definition.cron.arn, ":${aws_ecs_task_definition.cron.revision}")
      launch_type         = length(var.capacity_providers) > 0 ? null : var.use_ec2 ? "EC2" : "FARGATE"
      network_configuration {
        assign_public_ip = false
        security_groups  = [aws_security_group.cron.id]
        subnets          = var.subnets
      }
      enable_execute_command = true
      dynamic "capacity_provider_strategy" {
        for_each = var.capacity_providers
        content {
          capacity_provider = capacity_provider_strategy.value.capacity_provider
          base              = capacity_provider_strategy.value.base
          weight            = capacity_provider_strategy.value.weight
        }
      }
    }
    dead_letter_config {
      arn = aws_sqs_queue.deadletter_queue.arn
    }
    retry_policy {
      maximum_event_age_in_seconds = 300
      maximum_retry_attempts       = 10
    }
  }
}
