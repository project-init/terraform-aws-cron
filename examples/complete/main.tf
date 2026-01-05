resource "aws_scheduler_schedule_group" "group" {
  name = "group"
}

module "cron" {
  source = "project-init/worker-service/aws"
  # Project Init recommends pinning every module to a specific version
  # version = "vX.X.X"

  environment  = "staging"
  service_name = "service"
  group_name   = aws_scheduler_schedule_group.group.name
  cron_name    = "cron"

  schedule_expression = "rate(30 minutes)"

  # ECS Cluster/Service
  ecs_cluster_arn = "ecs_arn"
  subnets         = ["subnet1"]
  security_groups = []

  # ECS Task
  image                 = "123456789.dkr.ecr.us-east-1.amazonaws.com/image:v0.0.1"
  environment_variables = []

  cpu    = 256
  memory = 512

  # Load Balancer/Routing
  vpc_id = "vpc_id"
}
