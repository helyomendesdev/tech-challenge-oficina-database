resource "aws_security_group" "rds" {
  name        = "oficina-rds-sg"
  description = "Security group do RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "oficina-rds-sg"
  }
}
