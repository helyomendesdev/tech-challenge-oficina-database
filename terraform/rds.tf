resource "aws_db_instance" "postgres" {
  identifier = "oficina-postgres"

  engine         = "postgres"
  engine_version = "17.11"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  storage_encrypted = true

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  parameter_group_name = aws_db_parameter_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  backup_retention_period = 7

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "oficina-postgres"
  }
}
