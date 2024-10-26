resource "aws_security_group" "jajelociraptor_sg" {
  name        = "jajelociraptor_${var.name}"
  description = "Security Group for Velociraptor Server"
}

resource "aws_security_group_rule" "jajelociraptor_sg_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jajelociraptor_sg.id
}

resource "aws_security_group_rule" "jajelociraptor_sg_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jajelociraptor_sg.id
}

resource "aws_security_group_rule" "jajelociraptor_sg_client" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jajelociraptor_sg.id
}

resource "aws_security_group_rule" "jajelociraptor_sg_admin" {
  type              = "ingress"
  from_port         = 8889
  to_port           = 8889
  protocol          = "tcp"
  cidr_blocks       = formatlist("%s/32", var.admin_whitelist)
  security_group_id = aws_security_group.jajelociraptor_sg.id
}
