resource "aws_db_subnet_group" "postgres" {
  name       = "oficina-postgres-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "oficina-postgres-subnet-group"
  }
}
