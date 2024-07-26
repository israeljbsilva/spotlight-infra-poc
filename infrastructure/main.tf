provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "main-subnet-1"
  }
}

resource "aws_subnet" "main_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "main-subnet-2"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Security group for RDS allowing access from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main-subnet-group"
  subnet_ids = [aws_subnet.main_subnet_1.id, aws_subnet.main_subnet_2.id]

  tags = {
    Name = "main-subnet-group"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "subnet_association_1" {
  subnet_id      = aws_subnet.main_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_association_2" {
  subnet_id      = aws_subnet.main_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.2"
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}