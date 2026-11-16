output "task_role_name" {
  description = "Name of the IAM role used by the cron task. Attach extra policies with aws_iam_role_policy_attachment."
  value       = aws_iam_role.cron.name
}

output "task_role_arn" {
  description = "ARN of the IAM role used by the cron task (both task role and execution role)."
  value       = aws_iam_role.cron.arn
}
