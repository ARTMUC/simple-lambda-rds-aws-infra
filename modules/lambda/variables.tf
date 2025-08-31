variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (test, prod)"
  type        = string
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "ecr_image_count" {
  description = "Number of ECR images to keep"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 14
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "db_secret_arn" {
  description = "ARN of the database password secret"
  type        = string
}