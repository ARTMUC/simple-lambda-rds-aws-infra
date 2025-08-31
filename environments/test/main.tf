# environments/test/main.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "test/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  aws_region               = var.aws_region
  project_name            = var.project_name
  environment             = var.environment
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  private_subnet_1_cidr   = var.private_subnet_1_cidr
  private_subnet_2_cidr   = var.private_subnet_2_cidr
  vpc_endpoints_security_group_id = module.security_groups.bastion_security_group_id
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# Bastion Module
module "bastion" {
  source = "../../modules/bastion"

  project_name      = var.project_name
  environment       = var.environment
  instance_type     = var.bastion_instance_type
  security_group_id = module.security_groups.bastion_security_group_id
  private_subnet_id = module.vpc.private_subnet_1_id
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  private_subnet_ids      = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.rds_security_group_id
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  db_username             = var.db_username
  storage_size            = var.db_storage_size
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  monitoring_interval     = var.db_monitoring_interval
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
}

# Lambda Module
module "lambda" {
  source = "../../modules/lambda"

  project_name        = var.project_name
  environment         = var.environment
  function_name       = var.lambda_function_name
  memory_size         = var.lambda_memory_size
  timeout             = var.lambda_timeout
  ecr_repository_name = var.ecr_repository_name
  ecr_image_count     = var.ecr_image_count
  log_retention_days  = var.lambda_log_retention_days
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security_groups.lambda_security_group_id
  db_secret_arn       = module.rds.secret_arn

  environment_variables = {
    DB_HOST     = module.rds.endpoint
    DB_NAME     = var.db_name
    DB_USERNAME = var.db_username
    DB_SECRET_ARN = module.rds.secret_arn
  }
}