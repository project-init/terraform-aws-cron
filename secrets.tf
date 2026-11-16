data "aws_partition" "current" {}

locals {
  secret_value_froms = distinct([for s in var.secrets : s.valueFrom])

  # Secrets Manager valueFrom may carry ":json-key:version-stage:version-id" after the secret ARN.
  # IAM evaluates against the secret ARN itself (the first 7 colon-separated fields).
  secretsmanager_arns = distinct([
    for v in local.secret_value_froms : join(":", slice(split(":", v), 0, 7))
    if startswith(v, "arn:") && split(":", v)[2] == "secretsmanager"
  ])

  # SSM valueFrom is either a parameter ARN or, for same-region parameters, a bare name.
  ssm_parameter_arns = distinct(concat(
    [for v in local.secret_value_froms : v if startswith(v, "arn:") && split(":", v)[2] == "ssm"],
    [
      for v in local.secret_value_froms :
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/${trimprefix(v, "/")}"
      if !startswith(v, "arn:")
    ],
  ))
}
