resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-sg-"
  vpc_id = var.vpc_id

  egress {
    description = "All outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  vpc_id = var.vpc_id

  ingress {
    description = "Mysql from bastion"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "Mysql from lambda"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lambda" {
  name_prefix = "${var.project_name}-${var.environment}-lambda-sg-"
  vpc_id = var.vpc_id

  egress {
    description = "All outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-lambda-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-${var.environment}-vpc-endpoints-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}