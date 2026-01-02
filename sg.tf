resource "aws_security_group" "cron" {
  name        = "${var.service_name}-${var.environment}-${var.cron_name}-sg"
  description = "Allow outbound traffic from ${var.service_name} (${var.cron_name}) in ${var.environment}."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment}-${var.cron_name}-sg"
  }
}

resource "aws_security_group_rule" "cron_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.cron.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
