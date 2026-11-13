output "task_role_name" {
  description = "Name of the IAM role used by the cron task. Attach extra policies with aws_iam_role_policy_attachment."
  value       = aws_iam_role.cron.name
}
