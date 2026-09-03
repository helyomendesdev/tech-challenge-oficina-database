output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL."
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Porta do PostgreSQL."
  value       = aws_db_instance.postgres.port
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS."
  value       = aws_security_group.rds.id
}

output "rds_identifier" {
  description = "Identificador da instância RDS."
  value       = aws_db_instance.postgres.identifier
}
