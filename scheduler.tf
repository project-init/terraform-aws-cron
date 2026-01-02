resource "aws_scheduler_schedule" "cron" {
  name       = "${var.service_name}-${var.environment}-cron-${var.cron_name}"
  group_name = var.service_name
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.schedule_expression
  target {
    arn      = var.ecs_cluster_arn
    role_arn = aws_iam_role.cron.arn
    ecs_parameters {
      task_definition_arn = trimsuffix(aws_ecs_task_definition.cron.arn, ":${aws_ecs_task_definition.cron.revision}")
      launch_type         = var.use_ec2 ? "EC2" : "FARGATE"
      network_configuration {
        assign_public_ip = false
        security_groups  = [aws_security_group.cron.id]
        subnets          = var.subnets
      }
    }
    retry_policy {
      maximum_event_age_in_seconds = 300
      maximum_retry_attempts       = 10
    }
  }
}
