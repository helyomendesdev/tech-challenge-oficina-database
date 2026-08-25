resource "aws_db_parameter_group" "postgres" {
  name   = "oficina-postgres-17"
  family = "postgres17"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = {
    Name = "oficina-postgres-17"
  }
}
