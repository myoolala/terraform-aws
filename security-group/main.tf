resource "aws_security_group" "sg" {
  name   = var.name
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingresses" {
  count = length(var.ingresses)

  type                     = "ingress"
  from_port                = var.ingresses[count.index].from_port
  to_port                  = var.ingresses[count.index].to_prot
  protocol                 = var.ingresses[count.index].protocol
  source_security_group_id = var.ingresses[count.index].source_sg
  cidr_blocks              = var.ingresses[count.index].cidr_blocks
  security_group_id        = aws_security_group.service.id
}

resource "aws_security_group_rule" "egresses" {
  count = length(var.egresses)

  type                     = "egress"
  from_port                = var.egresses[count.index].from_port
  to_port                  = var.egresses[count.index].to_prot
  protocol                 = var.egresses[count.index].protocol
  source_security_group_id = var.egresses[count.index].source_sg
  cidr_blocks              = var.egresses[count.index].cidr_blocks
  security_group_id        = aws_security_group.service.id
}