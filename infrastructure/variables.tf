variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "dbname"
}

variable "db_username" {
  description = "The database master username"
  type        = string
  default     = "dbuser"
}

variable "db_password" {
  description = "The database master password"
  type        = string
}