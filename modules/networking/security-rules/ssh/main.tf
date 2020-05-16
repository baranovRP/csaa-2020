###
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = var.security_group_id

  from_port   = 22
  to_port     = 22
  protocol    = "TCP"
  cidr_blocks = [var.cidr_blocks]
}
