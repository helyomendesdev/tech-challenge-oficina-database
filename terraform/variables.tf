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
