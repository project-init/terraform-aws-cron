resource "aws_iam_role" "cron" {
  name               = "${var.service_name}-${var.cron_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.service_name}-${var.cron_name}-iam-role"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"
  # ECS Exec Permissions
  statement {
    effect = "Allow"
    actions = [
      "ssm:StartSession",
      "ssm:DescribeSessions",
      "ssm:TerminateSession",
      "ecs:ExecuteCommand",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [
      "*"
    ]
  }

  # Read access to exactly the secrets injected into the container via var.secrets
  dynamic "statement" {
    for_each = length(local.secretsmanager_arns) > 0 ? [1] : []
    content {
      sid       = "ReadInjectedSecretsManagerSecrets"
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = local.secretsmanager_arns
    }
  }

  dynamic "statement" {
    for_each = length(local.ssm_parameter_arns) > 0 ? [1] : []
    content {
      sid       = "ReadInjectedSSMParameters"
      effect    = "Allow"
      actions   = ["ssm:GetParameters"]
      resources = local.ssm_parameter_arns
    }
  }

  # DLQ Permissions
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.deadletter_queue.arn
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.service_name}-cron-${var.cron_name}-policy"
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "service_policy_events" {
  role       = aws_iam_role.cron.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_role_policy_attachment" "service_policy_ecs" {
  role       = aws_iam_role.cron.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "policy" {
  role       = aws_iam_role.cron.name
  policy_arn = aws_iam_policy.policy.arn
}
