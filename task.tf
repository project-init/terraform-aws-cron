data "aws_region" "current" {}

locals {
  task_env_variables = concat(var.environment_variables, [
    { name : "ENV", value : var.environment },
    // This is a commonly overlooked variable as it is needed to have your aws default config correctly manage the region.
    { name : "AWS_REGION", value : data.aws_region.current.region }
  ])
}

resource "aws_ecs_task_definition" "cron" {
  family = "${var.service_name}-${var.environment}-cron-${var.cron_name}"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = <<DEFINITION
  [
    {
      "name": "main",
      "image": "${var.image}",
      "entryPoint": [],
      "environment": ${jsonencode(local.task_env_variables)},
      "secrets": ${jsonencode(var.secrets)},
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "${var.service_name}-${var.environment}"
        }
      },
      "cpu": ${var.cpu},
      "memory": ${var.memory},
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = [var.use_ec2 ? "EC2" : "FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.cron.arn
  task_role_arn            = aws_iam_role.cron.arn

  tags = {
    Name = "${var.service_name}-${var.environment}-cron-${var.cron_name}"
  }
}
