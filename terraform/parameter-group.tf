resource "aws_db_parameter_group" "postgres" {
  name   = "oficina-postgres-17"
  family = "postgres17"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "1000"
    apply_method = "immediate"
  }

  parameter {
    name         = "pg_stat_statements.track"
    value        = "all"
    apply_method = "immediate"
  }

  parameter {
    name         = "track_io_timing"
    value        = "1"
    apply_method = "immediate"
  }

  tags = {
    Name = "oficina-postgres-17"
  }
}
