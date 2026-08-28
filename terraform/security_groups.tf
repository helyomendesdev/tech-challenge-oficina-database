resource "aws_security_group" "rds" {
  name        = "oficina-rds-sg"
  description = "Security group do RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "oficina-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_lambda" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.lambda_security_group_id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Permite PostgreSQL a partir da Lambda"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.eks_security_group_id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Permite PostgreSQL a partir do EKS"
}
