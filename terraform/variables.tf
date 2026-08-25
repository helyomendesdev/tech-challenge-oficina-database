variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS será provisionado."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas utilizadas pelo RDS."
  type        = list(string)
}

variable "db_name" {
  description = "Nome do database PostgreSQL"
  type        = string
}

variable "db_username" {
  description = "Usuário administrador do PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do usuário administrador do PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS PostgreSQL"
  type        = string
  default     = "db.t3.micro"
}
