########################################################################################################################
### Common
########################################################################################################################

variable "environment" {
  type        = string
  nullable    = false
  description = "The environment to deploy the grpc service to."
}

variable "cron_name" {
  type        = string
  nullable    = false
  description = "The name of the cron task."
}

variable "service_name" {
  type        = string
  nullable    = false
  description = "The name of the service."
}

########################################################################################################################
### Cron
########################################################################################################################

variable "schedule_expression" {
  type        = string
  nullable    = false
  description = "The cron schedule expression for the task."
}

########################################################################################################################
### ECS Cluster/Service
########################################################################################################################

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ecs cluster to deploy the service on."
}

variable "subnets" {
  type        = set(string)
  description = "The subnets to deploy the service in to."
}

variable "security_groups" {
  type        = list(string)
  description = "IDs of the extra security groups you want the task to have access to."
}

variable "use_ec2" {
  type        = bool
  default     = false
  description = "Whether to deploy the service on an ec2 backed service or fargate."
}

########################################################################################################################
### ECS Task
########################################################################################################################

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "The environment variables to use for the service."
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default     = []
  description = "The secrets to use for the service."
}

variable "image" {
  type        = string
  nullable    = false
  description = "The docker image to use for the container."
}

variable "cpu" {
  type        = number
  default     = 256
  description = "The cpu value to give to the ecs task."
}

variable "memory" {
  type        = number
  default     = 512
  description = "The memory value to give to the ecs task."
}

########################################################################################################################
### Security/Networking
########################################################################################################################

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "The VPC ID being deployed to."
}
